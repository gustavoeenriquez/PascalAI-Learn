uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Data, Pai.Learn.Tensor, Pai.Learn.Metrics;

var
  W1, B1, W2, B2: TTensor;

/// Crea los parámetros de una red Entradas -> Ocultas -> Salidas, con pesos chicos al azar.
procedure Crear(Entradas, Ocultas, Salidas: Integer; Azar: TRandom);
begin
  W1 := TTensor.Random(Entradas, Ocultas, Azar, 0.5);
  B1 := TTensor.Zeros(1, Ocultas);
  W2 := TTensor.Random(Ocultas, Salidas, Azar, 0.5);
  B2 := TTensor.Zeros(1, Salidas);
end;

/// La salida de la red para cada fila de X.
function Adelante(const X: TTensor): TTensor;
begin
  Todo('H := (X · W1 + B1).Tanh y después H · W2 + B2 (MatMul es el producto de matrices)');
end;

/// Un paso de descenso por gradiente con el error cuadrático medio. Devuelve la pérdida.
function Paso(const X, Y: TTensor; Tasa: Double): Double;
begin
  Todo('ZeroGrad de los 4 parámetros, Perdida := MSE(Adelante(X), Y), Backward, y mover cada uno');
end;

begin
  var Azar := TRandom.Create(2);
  Crear(2, 4, 1, Azar);
  var X := TTensor.FromRows([[0, 0], [0, 1], [1, 0], [1, 1]]);
  var Y := TTensor.FromRows([[0], [1], [1], [0]]);
  for var Epoca := 1 to 800 do
  begin
    var L := Paso(X, Y, 0.2);
    if Epoca mod 100 = 0 then
      WriteLn('época ', Epoca, ': pérdida ', L:0:4);
  end;
  WriteLn(Adelante(X).ToString(2));
end.
