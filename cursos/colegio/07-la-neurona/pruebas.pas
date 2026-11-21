// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La neurona decide con la suma
procedure TestPredecir;
begin
  W1 := 1; W2 := 1; B := -1;
  Assert.Equal(1, Predecir(TFruit.Create(0.6, 0.5)), '0.6 + 0.5 - 1 = 0.1, positiva: manzana (+1)');
  Assert.Equal(-1, Predecir(TFruit.Create(0.2, 0.3)), '0.2 + 0.3 - 1 = -0.5, negativa: pera (-1)');
  Assert.Equal(1, Predecir(TFruit.Create(0.5, 0.5)), 'la suma da 0 justo: cuenta como manzana');
end;

/// Si acierta, no cambia nada
[Hint('Si Predecir(F) = F.Target, el error es 0 y W1, W2 y B no cambian.')]
procedure TestAciertaNoCambia;
begin
  W1 := 1; W2 := 1; B := -1;
  Ajustar(TFruit.Create(0.6, 0.5, 'apple'), 0.1);
  Assert.True((W1 = 1) and (W2 = 1) and (B = -1), 'acertó: los pesos tienen que quedar igual');
end;

/// Si se equivoca, mueve la recta
[Hint('error := F.Target - Predecir(F); después W1 := W1 + Tasa * error * F.Weight (y lo mismo con W2 y B).')]
procedure TestSeEquivoca;
begin
  W1 := 0; W2 := 0; B := 0;
  // con todo en 0 dice manzana; pero es una pera: error = -1 - 1 = -2
  Ajustar(TFruit.Create(0.12, 0.30, 'pear'), 0.1);
  Assert.True(Abs(W1 - (-0.024)) < 1e-12, Format('W1 tenía que quedar en -0.024 y quedó en %g', [W1]));
  Assert.True(Abs(W2 - (-0.06)) < 1e-12, Format('W2 tenía que quedar en -0.06 y quedó en %g', [W2]));
  Assert.True(Abs(B - (-0.2)) < 1e-12, Format('B tenía que quedar en -0.2 y quedó en %g', [B]));
end;

/// Aprende a separar las frutas
procedure TestAprende;
begin
  W1 := 0; W2 := 0; B := 0;
  var Datos := Datasets.Fruits;
  for var Vuelta := 1 to 200 do
    for var F in Datos do
      Ajustar(F, 0.1);
  Assert.True(Errores(Datos) <= 2, Format('después de 200 vueltas se equivoca en %d frutas', [Errores(Datos)]));
end;
