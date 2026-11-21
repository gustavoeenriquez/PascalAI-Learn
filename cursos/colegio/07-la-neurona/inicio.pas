uses
  SysUtils, Pai.Learn.Data, Pai.Learn.Plot;

var
  W1, W2, B: Double;     // los pesos y el sesgo de la neurona

/// +1 (manzana) si W1·peso + W2·rojez + B >= 0; si no, -1 (pera).
function Predecir(const F: TFruit): Integer;
begin
  Todo('calcula la suma y decide');
end;

/// La regla del perceptrón para una fruta (F.Target es la respuesta correcta: +1 o -1).
procedure Ajustar(const F: TFruit; Tasa: Double);
begin
  Todo('calcula el error y mueve W1, W2 y B');
end;

/// Cuántas frutas clasifica mal.
function Errores(const Datos: TArray<TFruit>): Integer;
begin
  Result := 0;
  for var F in Datos do
    if Predecir(F) <> F.Target then
      Inc(Result);
end;

begin
  var Datos := Datasets.Fruits;
  W1 := 0; W2 := 0; B := 0;
  for var Vuelta := 1 to 50 do
  begin
    for var F in Datos do
      Ajustar(F, 0.1);
    WriteLn('vuelta ', Vuelta, ': ', Errores(Datos), ' errores');
    if Errores(Datos) = 0 then
      Break;
  end;
  // el dibujo: las frutas y la recta
  var G := TPlot.Create('El perceptrón', 'peso (kg)', 'rojez');
  for var F in Datos do
    G.Scatter(F.Name, F.Weight, F.Redness);
  G.Boundary(W1, W2, B);
  G.SaveSvg('perceptron.svg');
  WriteLn('Abre perceptron.svg en el navegador.');
end.
