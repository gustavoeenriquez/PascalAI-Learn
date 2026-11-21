unit Pai.Learn.Embed;

// Embeddings: cada palabra como un vector de números, aprendido para que las palabras que aparecen en
// contextos parecidos queden cerca. Es word2vec (Mikolov et al., 2013) en su forma «skip-gram con
// muestreo negativo», en chico:
//
//   para cada palabra y cada vecina a menos de Window posiciones:
//     acercar el vector de la palabra al vector de contexto de la vecina (que sí aparecen juntas)
//     y alejarlo del de Negatives palabras al azar (que probablemente no)
//
//   var E := TWordEmbedding.Create(32);
//   E.Train(Tokenize.Words(Texto), Azar, 3);
//   for var P in E.Nearest('loro', 5) do WriteLn(P.Token, ' ', P.Prob:0:2);   // Prob = similitud

interface

uses
  SysUtils, Math, Generics.Collections, Pai.Learn.Random, Pai.Learn.Text;

type
  TWordEmbedding = class
  private
    FDim: Integer;
    FVocab: TVocab;
    FCounts: TArray<Integer>;
    FW, FC: TArray<Double>;           // vectores de palabra y de contexto, Vocab x Dim, fila por fila
    FTable: TArray<Integer>;          // para elegir negativas según la frecuencia^0.75
  public
    Window, Negatives, MinCount: Integer;
    Rate: Double;
    constructor Create(Dim: Integer);
    destructor Destroy; override;
    /// Aprende con Epochs pasadas sobre Tokens (solo las palabras que aparecen al menos MinCount veces).
    procedure Train(const Tokens: TArray<string>; Rng: TRandom; Epochs: Integer = 3);
    function Has(const Word: string): Boolean;
    /// El vector de una palabra.
    function Vector(const Word: string): TArray<Double>;
    /// Similitud coseno: 1 = misma dirección, 0 = nada que ver.
    function Similarity(const A, B: string): Double;
    /// Las Count palabras más parecidas (Prob es la similitud).
    function Nearest(const Word: string; Count: Integer): TArray<TTokenProb>;
    /// A es a B como C es a ...: las palabras más cercanas a B - A + C.
    function Analogy(const A, B, C: string; Count: Integer): TArray<TTokenProb>;
    property Dim: Integer read FDim;
    function VocabSize: Integer;
  end;

/// Coseno entre dos vectores.
function Cosine(const A, B: TArray<Double>): Double;

implementation

function Cosine(const A, B: TArray<Double>): Double;
begin
  var D := 0.0;
  var NA := 0.0;
  var NB := 0.0;
  for var I := 0 to High(A) do
  begin
    D := D + A[I] * B[I];
    NA := NA + A[I] * A[I];
    NB := NB + B[I] * B[I];
  end;
  Result := if (NA = 0) or (NB = 0) then 0 else D / Sqrt(NA * NB);
end;

constructor TWordEmbedding.Create(Dim: Integer);
begin
  FDim := Dim;
  Window := 2;
  Negatives := 5;
  MinCount := 3;
  Rate := 0.05;
end;

destructor TWordEmbedding.Destroy;
begin
  FVocab.Free;
  inherited;
end;

function Sigma(X: Double): Double;
begin
  Result := 1 / (1 + Exp(-Max(-30.0, Min(30.0, X))));
end;

/// Un paso de muestreo negativo: acerca la palabra W al contexto C (Label = 1) o la aleja (Label = 0).
/// GradW acumula lo que hay que sumarle después al vector de la palabra.
procedure Step(var WV, CV: TArray<Double>; RowW, RowC, Dim: Integer; Lbl, Rate: Double; var GradW: TArray<Double>);
begin
  var Dot := 0.0;
  for var K := 0 to Dim - 1 do
    Dot := Dot + WV[RowW + K] * CV[RowC + K];
  var G := Rate * (Lbl - Sigma(Dot));
  for var K := 0 to Dim - 1 do
  begin
    GradW[K] := GradW[K] + G * CV[RowC + K];
    CV[RowC + K] := CV[RowC + K] + G * WV[RowW + K];
  end;
end;

procedure TWordEmbedding.Train(const Tokens: TArray<string>; Rng: TRandom; Epochs: Integer);
begin
  // el vocabulario: las palabras con al menos MinCount apariciones
  var Freq := TDictionary<string, Integer>.Create;
  try
    for var T in Tokens do
      if Freq.ContainsKey(T) then Freq[T] := Freq[T] + 1 else Freq.Add(T, 1);
    var Keep := TList<string>.Create;
    try
      var Keys := Freq.Keys.ToArray;
      TArray.Sort<string>(Keys);           // siempre el mismo orden
      for var K in Keys do
        if (Freq[K] >= MinCount) and K.Chars[0].IsLetter then
          Keep.Add(K);
      FVocab.Free;
      FVocab := TVocab.Create(Keep.ToArray);
    finally
      Keep.Free;
    end;
    SetLength(FCounts, FVocab.Count);
    for var I := 0 to FVocab.Count - 1 do
      FCounts[I] := Freq[FVocab.Token(I)];
  finally
    Freq.Free;
  end;
  var V := FVocab.Count;
  // vectores de palabra chicos al azar; de contexto en cero
  SetLength(FW, V * FDim);
  SetLength(FC, V * FDim);
  for var I := 0 to High(FW) do
  begin
    FW[I] := (Rng.NextDouble - 0.5) / FDim;
    FC[I] := 0;
  end;
  // tabla para las negativas: cada palabra tantas veces como su frecuencia^0.75
  var Table := TList<Integer>.Create;
  try
    for var I := 0 to V - 1 do
      for var R := 1 to Max(1, Round(Power(FCounts[I], 0.75))) do
        Table.Add(I);
    FTable := Table.ToArray;
  finally
    Table.Free;
  end;
  // el texto como números (las palabras raras se saltan)
  var Ids := FVocab.Encode(Tokens);
  var Seq := TList<Integer>.Create;
  try
    for var Id in Ids do
      if Id >= 0 then
        Seq.Add(Id);
    Ids := Seq.ToArray;
  finally
    Seq.Free;
  end;
  var W := FW;
  var C := FC;
  var Grad: TArray<Double>;
  SetLength(Grad, FDim);
  for var E := 1 to Epochs do
  begin
    var R := Rate * (1 - (E - 1) / Epochs);     // la tasa baja de a poco
    for var I := 0 to High(Ids) do
      for var J := Max(0, I - Window) to Min(High(Ids), I + Window) do
      begin
        if J = I then
          Continue;
        for var K := 0 to FDim - 1 do
          Grad[K] := 0;
        Step(W, C, Ids[I] * FDim, Ids[J] * FDim, FDim, 1, R, Grad);
        for var N := 1 to Negatives do
        begin
          var Neg := FTable[Rng.NextInt(Length(FTable))];
          if Neg <> Ids[J] then
            Step(W, C, Ids[I] * FDim, Neg * FDim, FDim, 0, R, Grad);
        end;
        for var K := 0 to FDim - 1 do
          W[Ids[I] * FDim + K] := W[Ids[I] * FDim + K] + Grad[K];
      end;
  end;
  FW := W;
  FC := C;
end;

function TWordEmbedding.Has(const Word: string): Boolean;
begin
  Result := (FVocab <> nil) and (FVocab.Id(Word.ToLower) >= 0);
end;

function TWordEmbedding.Vector(const Word: string): TArray<Double>;
begin
  var Id := FVocab.Id(Word.ToLower);
  if Id < 0 then
    raise EArgumentException.CreateFmt('«%s» no está en el vocabulario (aparece menos de %d veces)', [Word, MinCount]);
  Result := Copy(FW, Id * FDim, FDim);
end;

function TWordEmbedding.Similarity(const A, B: string): Double;
begin
  Result := Cosine(Vector(A), Vector(B));
end;

function NearestTo(E: TWordEmbedding; const Target: TArray<Double>; const Skip: TArray<string>;
  Count: Integer): TArray<TTokenProb>;
var
  P: TTokenProb;
begin
  var All := TList<TTokenProb>.Create;
  try
    for var I := 0 to E.VocabSize - 1 do
    begin
      var W := E.FVocab.Token(I);
      var Skipped := False;
      for var S in Skip do
        if S = W then
          Skipped := True;
      if Skipped then
        Continue;
      P.Token := W;
      P.Prob := Cosine(Target, E.Vector(W));
      All.Add(P);
    end;
    // las Count de mayor similitud (selección simple)
    Result := [];
    for var N := 1 to Min(Count, All.Count) do
    begin
      var Best := 0;
      for var I := 1 to All.Count - 1 do
        if All[I].Prob > All[Best].Prob then
          Best := I;
      Result := Result + [All[Best]];
      All.Delete(Best);
    end;
  finally
    All.Free;
  end;
end;

function TWordEmbedding.Nearest(const Word: string; Count: Integer): TArray<TTokenProb>;
begin
  Result := NearestTo(Self, Vector(Word), [Word.ToLower], Count);
end;

function TWordEmbedding.Analogy(const A, B, C: string; Count: Integer): TArray<TTokenProb>;
begin
  var VA := Vector(A);
  var VB := Vector(B);
  var VC := Vector(C);
  var T: TArray<Double>;
  SetLength(T, FDim);
  for var K := 0 to FDim - 1 do
    T[K] := VB[K] - VA[K] + VC[K];
  Result := NearestTo(Self, T, [A.ToLower, B.ToLower, C.ToLower], Count);
end;

function TWordEmbedding.VocabSize: Integer;
begin
  Result := if FVocab = nil then 0 else FVocab.Count;
end;

end.
