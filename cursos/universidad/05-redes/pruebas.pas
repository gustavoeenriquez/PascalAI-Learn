// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La salida tiene la forma correcta
procedure TestForma;
begin
  Crear(3, 5, 2, TRandom.Create(1));
  var S := Adelante(TTensor.Zeros(7, 3));
  Assert.Equal(7, S.Rows, 'una fila por ejemplo');
  Assert.Equal(2, S.Cols, 'una columna por salida');
end;

/// La cuenta hacia adelante
[Hint('No olvides la tanh en la capa oculta, y que en la última capa NO va.')]
procedure TestAdelante;
begin
  W1 := TTensor.FromRows([[1, -1]]);
  B1 := TTensor.FromRows([[0, 0.5]]);
  W2 := TTensor.FromRows([[2], [3]]);
  B2 := TTensor.FromRows([[1]]);
  var S := Adelante(TTensor.FromRows([[0.5]]));
  // H = tanh([0.5, 0]) = [0.4621, 0];  S = 0.4621·2 + 0·3 + 1
  var Esperado := 2 * (Exp(1) - 1) / (Exp(1) + 1) + 1;
  Assert.True(Abs(S.Item - Esperado) < 1e-9, Format('se esperaba %.6f y salió %.6f', [Esperado, S.Item]));
end;

/// Aprende XOR
[Hint('Después de Backward: para cada parámetro P, P.Node.Data[I] := P.Node.Data[I] - Tasa * P.Node.Grad[I].')]
procedure TestXor;
begin
  Crear(2, 4, 1, TRandom.Create(2));
  var X := TTensor.FromRows([[0, 0], [0, 1], [1, 0], [1, 1]]);
  var Y := TTensor.FromRows([[0], [1], [1], [0]]);
  var L: Double := 0.0;
  for var E := 1 to 800 do
    L := Paso(X, Y, 0.2);
  Assert.True(L < 0.02, Format('la pérdida quedó en %.4f', [L]));
end;

/// Aprende dígitos escritos a mano
procedure TestDigitos;
begin
  var Azar := TRandom.Create(3);
  var Tr, Te: TDataset;
  Datasets.Digits.Split(1 - 500 / 3823, Azar, Tr, Te);    // 500 para entrenar, el resto para probar
  Crear(64, 16, 10, Azar);
  // minilotes de 20 ejemplos: un paso por lote, 10 pasadas por los 500
  for var E := 1 to 10 do
    for var Lote := 0 to Tr.Count div 20 - 1 do
    begin
      var Idx: TArray<Integer> := [];
      for var I := Lote * 20 to Lote * 20 + 19 do
        Idx := Idx + [I];
      var Sub := Tr.Subset(Idx);
      // la respuesta como 10 columnas: 1 en la del dígito correcto, 0 en las demás
      var Y := TTensor.Zeros(20, 10);
      for var I := 0 to 19 do
        Y.Put(I, Sub.Labels[I], 1);
      Paso(TTensor.FromMatrix(Sub.X), Y, 1.0);
    end;
  var Acierto := Accuracy(ArgMaxRows(Adelante(TTensor.FromMatrix(Te.X))), Te.Labels);
  Assert.True(Acierto >= 0.8, Format('acertó el %.1f %% de los dígitos nuevos', [100 * Acierto]));
end;
