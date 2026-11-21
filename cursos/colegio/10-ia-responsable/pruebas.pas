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

/// Balancear
[Hint('Primero cuenta cuántas hay de cada clase; N es la menor. Después recorre Datos y toma una fruta si de su clase llevas menos de N.')]
procedure TestBalancear;
begin
  var B := Balancear(Desbalanceado);
  var M := 0;
  var P := 0;
  for var F in B do
    if F.Name = 'apple' then Inc(M) else Inc(P);
  Assert.Equal(4, M, 'tantas manzanas como peras');
  Assert.Equal(4, P);
end;

/// El modelo balanceado es más justo con las peras
procedure TestMasJusto;
begin
  var Prueba := Datasets.Fruits;
  var D := Desbalanceado;
  Assert.True(AciertoDe('pear', Balancear(D), Prueba) > AciertoDe('pear', D, Prueba),
    'balanceado reconoce más peras');
end;
