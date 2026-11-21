unit Pai.Learn.Text;

// Texto para modelos de lenguaje: partir en tokens (caracteres, palabras o BPE), un vocabulario y el
// modelo de n-gramas (qué token suele venir después de los N - 1 anteriores).
//
//   var Palabras := Tokenize.Words(Datasets.Text('cuentos'));
//   var M := TNGram.Create(2);                 // bigramas: mira una palabra hacia atrás
//   M.Train(Palabras);
//   WriteLn(Tokenize.Join(M.Generate(['había'], 20, Azar)));

interface

uses
  SysUtils, Math, Generics.Collections, Pai.Learn.Random;

type
  /// Un token posible y su probabilidad.
  TTokenProb = record
    Token: string;
    Prob: Double;
  end;

  /// Un modelo de lenguaje: dados los tokens anteriores, las probabilidades del siguiente. Un token
  /// vacío ('') es «fin del texto». Una clase que lo implementa, con un constructor Create sin
  /// parámetros, se puede usar como modelo de verdad: model M primary 'pascal/<Clase>' (10 §4.2).
  ILanguageModel = interface
    function Next(const Context: TArray<string>): TArray<TTokenProb>;
  end;

  /// Opcional: cómo parte y une el texto el modelo. Sin él, Tokenize.Words y Tokenize.Join.
  ITokenizer = interface
    function Tokenize(const Text: string): TArray<string>;
    function Detokenize(const Tokens: TArray<string>): string;
  end;

  Tokenize = class
  public
    /// Cada carácter es un token.
    class function Chars(const S: string): TArray<string>; static;
    /// Palabras (en minúsculas) y signos de puntuación, cada uno un token; los espacios se pierden.
    class function Words(const S: string): TArray<string>; static;
    /// Une tokens de palabras: espacio entre palabras, sin espacio antes de . , ; : ! ? ni después de ¡ ¿ —.
    class function Join(const Tokens: TArray<string>): string; static;
  end;

  /// Los tokens distintos, cada uno con un número (su posición).
  TVocab = class
  private
    FIds: TDictionary<string, Integer>;
    FTokens: TList<string>;
  public
    constructor Create(const Tokens: TArray<string>);
    destructor Destroy; override;
    function Count: Integer;
    /// El número de un token (-1 si no está).
    function Id(const Token: string): Integer;
    function Token(Id: Integer): string;
    function Encode(const Tokens: TArray<string>): TArray<Integer>;
    function Decode(const Ids: TArray<Integer>): TArray<string>;
  end;

  /// Codificación por pares de bytes (BPE), como la de los modelos grandes: empieza con caracteres y
  /// une una y otra vez el par de tokens vecinos más frecuente, hasta tener Merges uniones.
  TBpe = class
  private
    FMerges: TList<string>;        // 'a b': unir a y b (en el orden en que se aprendieron)
  public
    constructor Create;
    destructor Destroy; override;
    /// Aprende las uniones sobre el texto (cada palabra por separado, con su espacio delante).
    procedure Train(const Text: string; Merges: Integer);
    /// El texto en tokens BPE.
    function Encode(const Text: string): TArray<string>;
    function Decode(const Tokens: TArray<string>): string;
    function MergeCount: Integer;
    /// La unión número I: los dos tokens que se juntaron.
    function Merge(I: Integer): string;
  end;

  /// Modelo de n-gramas: cuenta qué token viene después de cada contexto de N - 1 tokens.
  TNGram = class
  private
    FN: Integer;
    FCounts: TDictionary<string, TDictionary<string, Integer>>;   // contexto -> siguiente -> veces
    FVocab: TDictionary<string, Boolean>;
    function Key(const Context: TArray<string>): string;
  public
    constructor Create(N: Integer);
    destructor Destroy; override;
    procedure Train(const Tokens: TArray<string>);
    /// Las probabilidades del siguiente token dados los anteriores (usa los últimos N - 1), de la más
    /// alta a la más baja. Vacío si nunca vio ese contexto.
    function Next(const Context: TArray<string>): TArray<TTokenProb>;
    /// Genera Count tokens después de Start. Temperature 0: siempre el más probable; 1: al azar
    /// según las probabilidades; más de 1: más sorpresas.
    function Generate(const Start: TArray<string>; Count: Integer; Rng: TRandom; Temperature: Double = 1): TArray<string>;
    /// Perplejidad sobre Tokens (con suavizado de Laplace): cuántas opciones «parecía tener» el modelo
    /// en cada paso. Más baja es mejor.
    function Perplexity(const Tokens: TArray<string>): Double;
    property N: Integer read FN;
    function VocabSize: Integer;
  end;

/// Genera texto con un modelo propio: parte el prompt en tokens, pide el siguiente una y otra vez
/// (hasta MaxTokens o el fin) y une lo generado. Es lo que hace el motor con M.Ask cuando el modelo
/// es 'pascal/<Clase>'.
function LMGenerate(M: ILanguageModel; const Prompt: string; MaxTokens: Integer; Temperature: Double;
  Seed: Integer): string;
/// Cuántos tokens tiene Text según el tokenizador del modelo (para contar como con un modelo real).
function LMCountTokens(M: ILanguageModel; const Text: string): Integer;

/// Elige un token de Probs al azar según sus probabilidades (con Temperature: 0 = el más probable).
function Sample(const Probs: TArray<TTokenProb>; Rng: TRandom; Temperature: Double = 1): string;

implementation

uses
  StrUtils;

{ Tokenize }

class function Tokenize.Chars(const S: string): TArray<string>;
begin
  SetLength(Result, Length(S));
  for var I := 1 to Length(S) do
    Result[I - 1] := S[I];
end;

function IsWordChar(C: Char): Boolean;
begin
  Result := C.IsLetterOrDigit or (C = '''');
end;

class function Tokenize.Words(const S: string): TArray<string>;
begin
  // en una lista (agregar a un arreglo uno por uno lo copia entero cada vez)
  var L := TList<string>.Create;
  try
    var Start := -1;
    for var I := 1 to Length(S) + 1 do
    begin
      var C := if I <= Length(S) then S[I] else ' ';
      if IsWordChar(C) then
      begin
        if Start < 0 then
          Start := I;
      end
      else
      begin
        if Start >= 0 then
        begin
          L.Add(Copy(S, Start, I - Start).ToLower);
          Start := -1;
        end;
        if (I <= Length(S)) and not C.IsWhiteSpace then
          L.Add(string(C));
      end;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

class function Tokenize.Join(const Tokens: TArray<string>): string;
begin
  var SB := TStringBuilder.Create;
  try
    for var I := 0 to High(Tokens) do
    begin
      var T := Tokens[I];
      var NoSpaceBefore := (T = '.') or (T = ',') or (T = ';') or (T = ':') or (T = '!') or (T = '?') or (T = '…');
      var PrevOpens := (I > 0) and ((Tokens[I - 1] = '¡') or (Tokens[I - 1] = '¿') or (Tokens[I - 1] = '—'));
      if (I > 0) and not NoSpaceBefore and not PrevOpens then
        SB.Append(' ');
      SB.Append(T);
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

{ TVocab }

constructor TVocab.Create(const Tokens: TArray<string>);
begin
  FIds := TDictionary<string, Integer>.Create;
  FTokens := TList<string>.Create;
  for var T in Tokens do
    if not FIds.ContainsKey(T) then
    begin
      FIds.Add(T, FTokens.Count);
      FTokens.Add(T);
    end;
end;

destructor TVocab.Destroy;
begin
  FIds.Free;
  FTokens.Free;
  inherited;
end;

function TVocab.Count: Integer;
begin
  Result := FTokens.Count;
end;

function TVocab.Id(const Token: string): Integer;
begin
  if not FIds.TryGetValue(Token, Result) then
    Result := -1;
end;

function TVocab.Token(Id: Integer): string;
begin
  Result := FTokens[Id];
end;

function TVocab.Encode(const Tokens: TArray<string>): TArray<Integer>;
begin
  SetLength(Result, Length(Tokens));
  for var I := 0 to High(Tokens) do
    Result[I] := Id(Tokens[I]);
end;

function TVocab.Decode(const Ids: TArray<Integer>): TArray<string>;
begin
  SetLength(Result, Length(Ids));
  for var I := 0 to High(Ids) do
    Result[I] := FTokens[Ids[I]];
end;

{ TBpe }

constructor TBpe.Create;
begin
  FMerges := TList<string>.Create;
end;

destructor TBpe.Destroy;
begin
  FMerges.Free;
  inherited;
end;

/// Las palabras del texto, cada una con su espacio delante (como hacen los BPE de verdad).
function SpacedWords(const Text: string): TArray<string>;
begin
  var L := TList<string>.Create;
  try
    var Start := 1;
    for var I := 1 to Length(Text) + 1 do
      if (I > Length(Text)) or Text[I].IsWhiteSpace then
      begin
        // la palabra va de Start a I - 1; si empezó después de un espacio, lo lleva delante
        var W := Copy(Text, Start, I - Start);
        if W.Trim <> '' then
          L.Add(W);
        Start := I;
      end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

/// Une en Parts cada aparición del par A B.
function ApplyMerge(const Parts: TArray<string>; const A, B: string): TArray<string>;
begin
  Result := [];
  var I := 0;
  while I <= High(Parts) do
  begin
    if (I < High(Parts)) and (Parts[I] = A) and (Parts[I + 1] = B) then
    begin
      Result := Result + [A + B];
      Inc(I, 2);
    end
    else
    begin
      Result := Result + [Parts[I]];
      Inc(I);
    end;
  end;
end;

procedure TBpe.Train(const Text: string; Merges: Integer);
begin
  FMerges.Clear;
  // cada palabra distinta, partida en caracteres, con cuántas veces aparece
  var Freq := TDictionary<string, Integer>.Create;
  var Split := TDictionary<string, TArray<string>>.Create;
  var Pairs := TDictionary<string, Integer>.Create;
  try
    for var W in SpacedWords(Text) do
      if Freq.ContainsKey(W) then
        Freq[W] := Freq[W] + 1
      else
      begin
        Freq.Add(W, 1);
        Split.Add(W, Tokenize.Chars(W));
      end;
    for var M := 1 to Merges do
    begin
      // contar los pares vecinos
      Pairs.Clear;
      for var W in Freq.Keys do
      begin
        var P := Split[W];
        for var I := 0 to High(P) - 1 do
        begin
          var K := P[I] + #1 + P[I + 1];
          if Pairs.ContainsKey(K) then
            Pairs[K] := Pairs[K] + Freq[W]
          else
            Pairs.Add(K, Freq[W]);
        end;
      end;
      // el más frecuente (con empate, el menor alfabéticamente, para que sea siempre el mismo)
      var Best := '';
      var BestN := 0;
      for var K in Pairs.Keys do
        if (Pairs[K] > BestN) or ((Pairs[K] = BestN) and (K < Best)) then
        begin
          Best := K;
          BestN := Pairs[K];
        end;
      if BestN < 2 then
        Break;
      var AB := Best.Split([#1]);
      FMerges.Add(AB[0] + #1 + AB[1]);
      for var W in Freq.Keys.ToArray do
        Split[W] := ApplyMerge(Split[W], AB[0], AB[1]);
    end;
  finally
    Freq.Free;
    Split.Free;
    Pairs.Free;
  end;
end;

function TBpe.Encode(const Text: string): TArray<string>;
begin
  var L := TList<string>.Create;
  try
    for var W in SpacedWords(Text) do
    begin
      var P := Tokenize.Chars(W);
      for var M in FMerges do
      begin
        var AB := M.Split([#1]);
        P := ApplyMerge(P, AB[0], AB[1]);
      end;
      L.AddRange(P);
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function TBpe.Decode(const Tokens: TArray<string>): string;
begin
  Result := string.Join('', Tokens);
end;

function TBpe.MergeCount: Integer;
begin
  Result := FMerges.Count;
end;

function TBpe.Merge(I: Integer): string;
begin
  Result := FMerges[I].Replace(#1, ' + ');
end;

{ TNGram }

constructor TNGram.Create(N: Integer);
begin
  if N < 1 then
    raise EArgumentException.Create('un n-grama necesita N >= 1');
  FN := N;
  FCounts := TDictionary<string, TDictionary<string, Integer>>.Create;
  FVocab := TDictionary<string, Boolean>.Create;
end;

destructor TNGram.Destroy;
begin
  for var D in FCounts.Values do
    D.Free;
  FCounts.Free;
  FVocab.Free;
  inherited;
end;

function TNGram.Key(const Context: TArray<string>): string;
begin
  // los últimos N - 1 tokens, separados por un carácter que no aparece en el texto
  Result := '';
  var From := Max(0, Length(Context) - (FN - 1));
  for var I := From to High(Context) do
    Result := Result + Context[I] + #1;
end;

procedure TNGram.Train(const Tokens: TArray<string>);
begin
  for var T in Tokens do
    FVocab.AddOrSetValue(T, True);
  for var I := FN - 1 to High(Tokens) do
  begin
    var K := Key(Copy(Tokens, I - (FN - 1), FN - 1));
    var D: TDictionary<string, Integer>;
    if not FCounts.TryGetValue(K, D) then
    begin
      D := TDictionary<string, Integer>.Create;
      FCounts.Add(K, D);
    end;
    if D.ContainsKey(Tokens[I]) then
      D[Tokens[I]] := D[Tokens[I]] + 1
    else
      D.Add(Tokens[I], 1);
  end;
end;

function TNGram.Next(const Context: TArray<string>): TArray<TTokenProb>;
var
  D: TDictionary<string, Integer>;
  P: TTokenProb;
begin
  Result := [];
  if not FCounts.TryGetValue(Key(Context), D) then
    Exit;
  var Total := 0;
  for var C in D.Values do
    Inc(Total, C);
  for var T in D.Keys do
  begin
    P.Token := T;
    P.Prob := D[T] / Total;
    Result := Result + [P];
  end;
  // de la más probable a la menos (con empate, alfabético: siempre el mismo orden)
  for var I := 1 to High(Result) do
  begin
    var X := Result[I];
    var J := I - 1;
    while (J >= 0) and ((Result[J].Prob < X.Prob) or ((Result[J].Prob = X.Prob) and (Result[J].Token > X.Token))) do
    begin
      Result[J + 1] := Result[J];
      Dec(J);
    end;
    Result[J + 1] := X;
  end;
end;

function Sample(const Probs: TArray<TTokenProb>; Rng: TRandom; Temperature: Double): string;
begin
  if Length(Probs) = 0 then
    Exit('');
  if Temperature <= 0 then
  begin
    var Best := 0;
    for var I := 1 to High(Probs) do
      if Probs[I].Prob > Probs[Best].Prob then
        Best := I;
    Exit(Probs[Best].Token);
  end;
  // con temperatura: p^(1/T), normalizado
  var W: TArray<Double>;
  SetLength(W, Length(Probs));
  var Total := 0.0;
  for var I := 0 to High(Probs) do
  begin
    W[I] := Power(Probs[I].Prob, 1 / Temperature);
    Total := Total + W[I];
  end;
  var R := Rng.NextDouble * Total;
  for var I := 0 to High(Probs) do
  begin
    R := R - W[I];
    if R <= 0 then
      Exit(Probs[I].Token);
  end;
  Result := Probs[High(Probs)].Token;
end;

function TNGram.Generate(const Start: TArray<string>; Count: Integer; Rng: TRandom; Temperature: Double): TArray<string>;
begin
  var Context := Start;
  Result := [];
  for var I := 1 to Count do
  begin
    var T := Sample(Next(Context), Rng, Temperature);
    if T = '' then
      Break;
    Result := Result + [T];
    Context := Context + [T];
  end;
end;

function TNGram.Perplexity(const Tokens: TArray<string>): Double;
var
  D: TDictionary<string, Integer>;
begin
  var V := FVocab.Count + 1;      // +1: un token que nunca vio
  var LogSum := 0.0;
  var N := 0;
  for var I := FN - 1 to High(Tokens) do
  begin
    var Count := 0;
    var Total := 0;
    if FCounts.TryGetValue(Key(Copy(Tokens, I - (FN - 1), FN - 1)), D) then
    begin
      for var C in D.Values do
        Inc(Total, C);
      D.TryGetValue(Tokens[I], Count);
    end;
    // Laplace: como si cada token hubiera aparecido una vez más
    LogSum := LogSum + Ln((Count + 1) / (Total + V));
    Inc(N);
  end;
  Result := if N = 0 then 0 else Exp(-LogSum / N);
end;

function TNGram.VocabSize: Integer;
begin
  Result := FVocab.Count;
end;

function LMTokens(M: ILanguageModel; const Text: string): TArray<string>;
begin
  if M is ITokenizer then
    Result := (M as ITokenizer).Tokenize(Text)
  else
    Result := Tokenize.Words(Text);
end;

function LMGenerate(M: ILanguageModel; const Prompt: string; MaxTokens: Integer; Temperature: Double;
  Seed: Integer): string;
begin
  var Rng := TRandom.Create(Seed);
  var Context := LMTokens(M, Prompt);
  var Generated := TList<string>.Create;
  try
    for var I := 1 to MaxTokens do
    begin
      var T := Sample(M.Next(Context), Rng, Temperature);
      if T = '' then
        Break;
      Generated.Add(T);
      Context := Context + [T];
    end;
    if M is ITokenizer then
      Result := (M as ITokenizer).Detokenize(Generated.ToArray)
    else
      Result := Tokenize.Join(Generated.ToArray);
  finally
    Generated.Free;
    Rng.Free;
  end;
end;

function LMCountTokens(M: ILanguageModel; const Text: string): Integer;
begin
  Result := Length(LMTokens(M, Text));
end;

end.
