unit Pai.Learn.Metrics;

// Cómo medir un clasificador: exactitud, matriz de confusión y, por clase, precisión,
// exhaustividad y F1.
//
//   var Pred := ArgMaxRows(Red.Forward(X));
//   WriteLn('exactitud: ', 100 * Accuracy(Pred, Prueba.Labels):0:1, ' %');
//   WriteLn(ConfusionToString(ConfusionMatrix(Pred, Prueba.Labels, 10), Prueba.ClassNames));

interface

uses
  SysUtils;

type
  TConfusion = TArray<TArray<Integer>>;   // [clase verdadera][clase elegida]

/// La fracción de aciertos (0 a 1).
function Accuracy(const Predicted, Actual: TArray<Integer>): Double;

/// Cuántas veces cada clase verdadera (fila) se clasificó como cada clase (columna).
function ConfusionMatrix(const Predicted, Actual: TArray<Integer>; Classes: Integer): TConfusion;

/// De las que el modelo dijo que eran de la clase K, qué fracción lo eran.
function Precision(const M: TConfusion; K: Integer): Double;
/// De las que eran de la clase K, qué fracción encontró el modelo.
function Recall(const M: TConfusion; K: Integer): Double;
/// La media armónica de precisión y exhaustividad.
function F1(const M: TConfusion; K: Integer): Double;

/// La matriz como tabla de texto, con los nombres de las clases.
function ConfusionToString(const M: TConfusion; const Names: TArray<string>): string;

implementation

function Accuracy(const Predicted, Actual: TArray<Integer>): Double;
begin
  if Length(Predicted) <> Length(Actual) then
    raise EArgumentException.CreateFmt('Accuracy: %d predicciones y %d respuestas', [Length(Predicted), Length(Actual)]);
  if Length(Actual) = 0 then
    Exit(0);
  var Ok := 0;
  for var I := 0 to High(Actual) do
    if Predicted[I] = Actual[I] then
      Inc(Ok);
  Result := Ok / Length(Actual);
end;

function ConfusionMatrix(const Predicted, Actual: TArray<Integer>; Classes: Integer): TConfusion;
begin
  SetLength(Result, Classes);
  for var I := 0 to Classes - 1 do
  begin
    SetLength(Result[I], Classes);
    for var J := 0 to Classes - 1 do
      Result[I][J] := 0;
  end;
  for var I := 0 to High(Actual) do
    Inc(Result[Actual[I]][Predicted[I]]);
end;

function Precision(const M: TConfusion; K: Integer): Double;
begin
  var Said := 0;
  for var I := 0 to High(M) do
    Inc(Said, M[I][K]);
  Result := if Said = 0 then 0 else M[K][K] / Said;
end;

function Recall(const M: TConfusion; K: Integer): Double;
begin
  var Were := 0;
  for var J := 0 to High(M[K]) do
    Inc(Were, M[K][J]);
  Result := if Were = 0 then 0 else M[K][K] / Were;
end;

function F1(const M: TConfusion; K: Integer): Double;
begin
  var P := Precision(M, K);
  var R := Recall(M, K);
  Result := if P + R = 0 then 0 else 2 * P * R / (P + R);
end;

function ConfusionToString(const M: TConfusion; const Names: TArray<string>): string;

  function Pad(const S: string; W: Integer): string;
  begin
    Result := S;
    while Length(Result) < W do
      Result := ' ' + Result;
  end;

begin
  var W := 5;
  for var N in Names do
    if Length(N) + 1 > W then
      W := Length(N) + 1;
  Result := Pad('', W) + ' |';
  for var N in Names do
    Result := Result + Pad(N, W);
  Result := Result + sLineBreak + StringOfChar('-', W + 2 + W * Length(Names)) + sLineBreak;
  for var I := 0 to High(M) do
  begin
    Result := Result + Pad(Names[I], W) + ' |';
    for var J := 0 to High(M[I]) do
      Result := Result + Pad(IntToStr(M[I][J]), W);
    Result := Result + sLineBreak;
  end;
end;

end.
