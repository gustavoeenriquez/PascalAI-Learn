uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Data, Pai.Learn.Tensor, Pai.Learn.NN, Pai.Learn.Plot;

type
  TConfusion = TArray<TArray<Integer>>;    // [clase verdadera][clase elegida]

/// La fracción de aciertos (0 a 1).
function Exactitud(const Pred, Real: TArray<Integer>): Double;
begin
  Todo('cuenta cuántas posiciones coinciden y divide por el total');
end;

/// Cuántas veces cada clase verdadera (fila) se clasificó como cada clase (columna).
function MatrizDeConfusion(const Pred, Real: TArray<Integer>; Clases: Integer): TConfusion;
begin
  Todo('crea una matriz Clases x Clases en cero y suma 1 en [Real[i]][Pred[i]]');
end;

/// La época (desde 1) con la mayor exactitud de validación; con empate, la primera.
function MejorEpoca(const Validacion: TArray<Double>): Integer;
begin
  Todo('busca la posición del mayor y súmale 1');
end;

begin
  var Azar := TRandom.Create(7);
  var Tr, Te: TDataset;
  Datasets.Digits.Split(1 - 100 / 3823, Azar, Tr, Te);    // solo 100 para aprender
  var Primeros: TArray<Integer> := [];
  for var I := 0 to 499 do
    Primeros := Primeros + [I];
  Te := Te.Subset(Primeros);                                // y 500 para medir (más rápido)
  var Red := TMLP.Create([64, 64, 10], Azar);
  var Opt := TAdam.Create(Red.Parameters, 0.01);
  var XTr := TTensor.FromMatrix(Tr.X);
  var XTe := TTensor.FromMatrix(Te.X);
  var G := TPlot.Create('Sobreajuste', 'época', 'exactitud');
  var EnPrueba: TArray<Double> := [];
  for var Epoca := 1 to 60 do
  begin
    Opt.ZeroGrad;
    CrossEntropy(Red.Forward(XTr), Tr.Labels).Backward;
    Opt.Step;
    var AE := Exactitud(ArgMaxRows(Red.Forward(XTr)), Tr.Labels);
    var AP := Exactitud(ArgMaxRows(Red.Forward(XTe)), Te.Labels);
    EnPrueba := EnPrueba + [AP];
    G.Line('entrenamiento', Epoca, AE);
    G.Line('prueba', Epoca, AP);
    if Epoca mod 10 = 0 then
      WriteLn('época ', Epoca, ': entrenamiento ', 100 * AE:0:1, ' %, prueba ', 100 * AP:0:1, ' %');
  end;
  G.SaveSvg('sobreajuste.svg');
  WriteLn('La mejor época en prueba fue la ', MejorEpoca(EnPrueba));
  var M := MatrizDeConfusion(ArgMaxRows(Red.Forward(XTe)), Te.Labels, 10);
  for var F in M do
  begin
    for var C in F do
      Write(C:5);
    WriteLn;
  end;
end.
