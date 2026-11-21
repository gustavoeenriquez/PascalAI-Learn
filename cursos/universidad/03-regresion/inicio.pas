uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Data;

/// 50 puntos con x entre 0 y 1, y = 3x + 2 más un ruido normal pequeño (siempre los mismos).
function Puntos: TArray<TSample>;
begin
  var Azar := TRandom.Create(5);
  SetLength(Result, 50);
  for var I := 0 to High(Result) do
  begin
    var X := Azar.NextDouble;
    Result[I].X := [X];
    Result[I].Y := 3 * X + 2 + Azar.Gauss(0, 0.1);
  end;
end;

/// El error cuadrático medio de la recta y = W·x + B sobre los datos (x es S.X[0], y es S.Y).
function Perdida(W, B: Double; const Datos: TArray<TSample>): Double;
begin
  Todo('el promedio de (W·x + B − y)²');
end;

/// Las derivadas de la pérdida respecto de W y de B.
procedure Gradiente(W, B: Double; const Datos: TArray<TSample>; out GW, GB: Double);
begin
  Todo('las dos sumas del LEEME.md, multiplicadas por 2/n');
end;

/// Descenso por gradiente desde W = 0, B = 0.
procedure Entrenar(const Datos: TArray<TSample>; Tasa: Double; Pasos: Integer; out W, B: Double);
begin
  W := 0;
  B := 0;
  Todo('repite Pasos veces: calcula el gradiente y mueve W y B en contra');
end;

begin
  var Datos := Puntos;
  var W, B: Double;
  Entrenar(Datos, 0.5, 2000, W, B);
  WriteLn('w = ', W:0:3, '   b = ', B:0:3, '   pérdida = ', Perdida(W, B, Datos):0:5);
end.
