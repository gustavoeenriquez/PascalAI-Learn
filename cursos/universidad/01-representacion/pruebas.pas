// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// El producto punto
procedure TestPunto;
begin
  var U: TVec := [1, 2, 3];
  var V: TVec := [4, -5, 6];
  Assert.Equal(12.0, Punto(U, V), '1·4 + 2·(-5) + 3·6 = 12');
  var Cero: TVec := [0, 0, 0];
  Assert.Equal(0.0, Punto(U, Cero));
end;

/// El producto de dos matrices cuadradas
procedure TestCuadradas;
begin
  var A := TMatrix.FromRows([[1, 2], [3, 4]]);
  var B := TMatrix.FromRows([[5, 6], [7, 8]]);
  Assert.Equal('[19.00, 22.00]' + sLineBreak + '[43.00, 50.00]', Producto(A, B).ToString);
  Assert.Equal(A.ToString, Producto(A, TMatrix.Identity(2)).ToString, 'por la identidad queda igual');
end;

/// Matrices rectangulares
[Hint('El resultado tiene A.Rows filas y B.Cols columnas: TMatrix.Create(A.Rows, B.Cols).')]
procedure TestRectangulares;
begin
  var A := TMatrix.FromRows([[1, 0, 2], [0, 1, -1]]);        // 2 x 3
  var B := TMatrix.FromRows([[1, 2], [3, 4], [5, 6]]);       // 3 x 2
  var C := Producto(A, B);
  Assert.Equal(2, C.Rows);
  Assert.Equal(2, C.Cols);
  Assert.Equal('[11.00, 14.00]' + sLineBreak + '[-2.00, -2.00]', C.ToString);
  Assert.Equal((A * B).ToString, C.ToString, 'igual que la biblioteca');
end;

/// Dimensiones que no coinciden
[Hint('Al principio: if A.Cols <> B.Rows then raise EArgumentException.Create(''...'');')]
procedure TestDimensiones;
begin
  Assert.Raises('EArgumentException', procedure
    begin
      Producto(TMatrix.Create(2, 3), TMatrix.Create(2, 3));
    end);
end;
