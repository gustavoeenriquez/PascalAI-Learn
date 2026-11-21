uses
  SysUtils, Pai.Learn.Linalg;

/// U · V = U[0]·V[0] + U[1]·V[1] + ...
function Punto(const U, V: TVec): Double;
begin
  Todo('suma los productos de cada par de elementos');
end;

/// A · B; EArgumentException si las columnas de A no son tantas como las filas de B.
function Producto(const A, B: TMatrix): TMatrix;
begin
  Todo('tres for anidados: filas de A, columnas de B, y la suma');
end;

begin
  var A := TMatrix.FromRows([[1, 2], [3, 4]]);
  var B := TMatrix.FromRows([[0, 1], [1, 0]]);
  WriteLn(Producto(A, B).ToString);
end.
