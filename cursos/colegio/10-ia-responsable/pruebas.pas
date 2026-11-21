// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Medir el acierto de una clase
[Hint('Recorre Prueba: si F.Name = Clase, suma 1 al total y, si Clasificar(F, Datos, 9) = Clase, a los aciertos.')]
procedure TestAciertoDe;
begin
  var Datos: TArray<TFruit> := [TFruit.Create(0.17, 0.8, 'apple'), TFruit.Create(0.17, 0.8, 'apple'),
    TFruit.Create(0.17, 0.8, 'apple'), TFruit.Create(0.12, 0.3, 'pear'), TFruit.Create(0.12, 0.3, 'pear')];
  var Prueba: TArray<TFruit> := [TFruit.Create(0.17, 0.8, 'apple'), TFruit.Create(0.12, 0.3, 'pear')];
  // con k = 9 (aquí hay 5 frutas: votan todas) hay 3 manzanas y 2 peras: todo sale manzana
  Assert.Equal(1.0, AciertoDe('apple', Datos, Prueba));
  Assert.Equal(0.0, AciertoDe('pear', Datos, Prueba), 'con 3 manzanas y 2 peras votando, ninguna pera se reconoce');
end;

/// Balancear con copias de las peras
[Hint('Cuenta manzanas (M) y peras (P). Después recorre Datos una y otra vez y agrega cada pera que encuentres, hasta haber agregado M - P.')]
procedure TestBalancear;
begin
  var B := Balancear(Desbalanceado);
  var M := 0;
  var P := 0;
  for var F in B do
    if F.Name = 'apple' then Inc(M) else Inc(P);
  Assert.Equal(20, M, 'las 20 manzanas siguen');
  Assert.Equal(20, P, 'las 4 peras, repetidas, hasta ser 20');
  Assert.Equal(24 + 16, Length(B));
end;

/// El modelo balanceado es más justo con las peras
procedure TestMasJusto;
begin
  var D := Desbalanceado;
  Assert.Equal(0.0, AciertoDe('pear', D, Clientes), 'con 4 peras entre 24 frutas y k = 9, ninguna pera gana una votación');
  Assert.True(AciertoDe('pear', Balancear(D), Clientes) > 0.5, 'balanceado reconoce las peras');
end;
