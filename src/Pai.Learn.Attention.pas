unit Pai.Learn.Attention;

// Atención y un transformer diminuto por caracteres (la arquitectura de los modelos de lenguaje
// grandes, en chico: Vaswani et al., 2017; un solo bloque es suficiente para ver la idea).
//
// Atención: cada posición pregunta (Q) y cada posición ofrece una llave (K) y un valor (V). El peso con
// que la posición i mira la j es softmax(Qi · Kj / √d); la salida es el promedio de los V con esos
// pesos. Con la máscara causal, i solo mira lo que vino antes: así se entrena a predecir lo siguiente.
//
//   var Voc := TVocab.Create(Tokenize.Chars(Texto));
//   var M := TTinyTransformer.Create(Voc.Count, 32, 24, Azar);      // 32 dimensiones, 24 de contexto
//   var Opt := TAdam.Create(M.Parameters, 0.01);
//   ... Opt.ZeroGrad; M.Loss(Ids).Backward; Opt.Step;
//   WriteLn(M.Generate(Voc, 'Había una vez', 80, Azar));

interface

uses
  SysUtils, Math, Pai.Learn.Random, Pai.Learn.Tensor, Pai.Learn.Text;

type
  /// Una cabeza de atención causal: X (T x D) -> T x D.
  TSelfAttention = class
  public
    Wq, Wk, Wv, Wo: TTensor;
    /// Los pesos de la última pasada (T x T): quién mira a quién.
    LastWeights: TTensor;
    constructor Create(D: Integer; Rng: TRandom);
    function Forward(const X: TTensor): TTensor;
    function Parameters: TArray<TTensor>;
  end;

  /// Un bloque: X + Atención(X), y después X + MLP(X) (dos capas con relu).
  TBlock = class
  public
    Attn: TSelfAttention;
    W1, B1, W2, B2: TTensor;
    constructor Create(D, Hidden: Integer; Rng: TRandom);
    function Forward(const X: TTensor): TTensor;
    function Parameters: TArray<TTensor>;
  end;

  TTinyTransformer = class
  public
    Vocab, Dim, Context: Integer;
    TokEmb, PosEmb, WOut, BOut: TTensor;
    Block: TBlock;
    constructor Create(AVocab, ADim, AContext: Integer; Rng: TRandom);
    /// Los logits (una fila por posición, una columna por token) para la secuencia Ids.
    function Forward(const Ids: TArray<Integer>): TTensor;
    /// La entropía cruzada de predecir Ids[1..] a partir de Ids[0..n-2].
    function Loss(const Ids: TArray<Integer>): TTensor;
    function Parameters: TArray<TTensor>;
    /// Las probabilidades del siguiente token después de Ids (usa los últimos Context).
    function NextProbs(const Ids: TArray<Integer>): TArray<Double>;
    /// Genera Count caracteres después de Prompt.
    function Generate(Voc: TVocab; const Prompt: string; Count: Integer; Rng: TRandom; Temperature: Double = 0.8): string;
  end;

implementation

{ TSelfAttention }

constructor TSelfAttention.Create(D: Integer; Rng: TRandom);
begin
  var S := 1 / Sqrt(D);
  Wq := TTensor.Random(D, D, Rng, S);
  Wk := TTensor.Random(D, D, Rng, S);
  Wv := TTensor.Random(D, D, Rng, S);
  Wo := TTensor.Random(D, D, Rng, S);
end;

function TSelfAttention.Forward(const X: TTensor): TTensor;
begin
  var Q := X.MatMul(Wq);
  var K := X.MatMul(Wk);
  var V := X.MatMul(Wv);
  // puntajes: cuánto se parece la pregunta de cada posición a la llave de cada otra
  var Scores := (1 / Sqrt(Wq.Cols)) * Q.MatMul(K.Transpose);
  LastWeights := Scores.SoftmaxRows(True);
  Result := LastWeights.MatMul(V).MatMul(Wo);
end;

function TSelfAttention.Parameters: TArray<TTensor>;
begin
  Result := [Wq, Wk, Wv, Wo];
end;

{ TBlock }

constructor TBlock.Create(D, Hidden: Integer; Rng: TRandom);
begin
  Attn := TSelfAttention.Create(D, Rng);
  W1 := TTensor.Random(D, Hidden, Rng, Sqrt(6 / (D + Hidden)));
  B1 := TTensor.Zeros(1, Hidden);
  W2 := TTensor.Random(Hidden, D, Rng, Sqrt(6 / (D + Hidden)));
  B2 := TTensor.Zeros(1, D);
end;

function TBlock.Forward(const X: TTensor): TTensor;
begin
  var H := X + Attn.Forward(X);
  Result := H + (H.MatMul(W1) + B1).Relu.MatMul(W2) + B2;
end;

function TBlock.Parameters: TArray<TTensor>;
begin
  Result := Attn.Parameters + [W1, B1, W2, B2];
end;

{ TTinyTransformer }

constructor TTinyTransformer.Create(AVocab, ADim, AContext: Integer; Rng: TRandom);
begin
  Vocab := AVocab;
  Dim := ADim;
  Context := AContext;
  TokEmb := TTensor.Random(AVocab, ADim, Rng, 0.1);
  PosEmb := TTensor.Random(AContext, ADim, Rng, 0.1);
  Block := TBlock.Create(ADim, 4 * ADim, Rng);
  WOut := TTensor.Random(ADim, AVocab, Rng, Sqrt(6 / (ADim + AVocab)));
  BOut := TTensor.Zeros(1, AVocab);
end;

function TTinyTransformer.Forward(const Ids: TArray<Integer>): TTensor;
begin
  if Length(Ids) > Context then
    raise EArgumentException.CreateFmt('la secuencia mide %d y el contexto es %d', [Length(Ids), Context]);
  var Pos: TArray<Integer>;
  SetLength(Pos, Length(Ids));
  for var I := 0 to High(Pos) do
    Pos[I] := I;
  // cada token es su embedding más el de su posición (la atención sola no sabe el orden)
  var X := TokEmb.Gather(Ids) + PosEmb.Gather(Pos);
  Result := Block.Forward(X).MatMul(WOut) + BOut;
end;

function TTinyTransformer.Loss(const Ids: TArray<Integer>): TTensor;
begin
  var Inp := Copy(Ids, 0, Length(Ids) - 1);
  var Tgt := Copy(Ids, 1, Length(Ids) - 1);
  Result := CrossEntropy(Forward(Inp), Tgt);
end;

function TTinyTransformer.Parameters: TArray<TTensor>;
begin
  Result := [TokEmb, PosEmb] + Block.Parameters + [WOut, BOut];
end;

function TTinyTransformer.NextProbs(const Ids: TArray<Integer>): TArray<Double>;
begin
  var Ctx := if Length(Ids) > Context then Copy(Ids, Length(Ids) - Context, Context) else Ids;
  var L := Forward(Ctx);
  var P := Softmax(L);
  SetLength(Result, Vocab);
  for var J := 0 to Vocab - 1 do
    Result[J] := P[L.Rows - 1, J];
end;

function TTinyTransformer.Generate(Voc: TVocab; const Prompt: string; Count: Integer; Rng: TRandom;
  Temperature: Double): string;
begin
  var Ids := Voc.Encode(Tokenize.Chars(Prompt));
  for var I := 0 to High(Ids) do
    if Ids[I] < 0 then
      Ids[I] := 0;
  Result := Prompt;
  for var N := 1 to Count do
  begin
    var P := NextProbs(Ids);
    var Opts: TArray<TTokenProb>;
    SetLength(Opts, Vocab);
    for var J := 0 to Vocab - 1 do
    begin
      Opts[J].Token := IntToStr(J);
      Opts[J].Prob := P[J];
    end;
    var Id := StrToInt(Sample(Opts, Rng, Temperature));
    Ids := Ids + [Id];
    Result := Result + Voc.Token(Id);
  end;
end;

end.
