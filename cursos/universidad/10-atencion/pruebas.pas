// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La forma de la salida
procedure TestForma;
begin
  var Azar := TRandom.Create(1);
  var S := Atencion(TTensor.Random(5, 4, Azar), TTensor.Random(4, 4, Azar), TTensor.Random(4, 4, Azar),
    TTensor.Random(4, 4, Azar));
  Assert.Equal(5, S.Rows, 'una fila por posición');
  Assert.Equal(4, S.Cols);
end;

/// Igual que la atención de la biblioteca
[Hint('No olvides la máscara: SoftmaxRows(True). Y la escala: (1 / Sqrt(Q.Cols)) * Puntajes.')]
procedure TestIgual;
begin
  var Azar := TRandom.Create(2);
  var A := TSelfAttention.Create(4, Azar);
  A.Wo := TTensor.FromRows([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]);   // sin la última capa
  var X := TTensor.Random(6, 4, Azar);
  var Mia := Atencion(X, A.Wq, A.Wk, A.Wv);
  var DeLaBiblioteca := A.Forward(X);
  for var I := 0 to 5 do
    for var J := 0 to 3 do
      Assert.True(Abs(Mia.Get(I, J) - DeLaBiblioteca.Get(I, J)) < 1e-9, Format('la posición (%d, %d)', [I, J]));
end;

/// No ve el futuro
[Hint('La máscara causal es el True de SoftmaxRows(True): la fila i solo mira las columnas 0..i.')]
procedure TestCausal;
begin
  var Azar := TRandom.Create(3);
  var Wq := TTensor.Random(3, 3, Azar);
  var Wk := TTensor.Random(3, 3, Azar);
  var Wv := TTensor.Random(3, 3, Azar);
  var X := TTensor.Random(4, 3, Azar);
  var Antes := Atencion(X, Wq, Wk, Wv).Get(0, 0);
  X.Put(3, 0, X.Get(3, 0) + 10);           // cambiar la última posición
  Assert.True(Abs(Atencion(X, Wq, Wk, Wv).Get(0, 0) - Antes) < 1e-12, 'la primera posición no puede ver la última');
end;
