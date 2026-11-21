// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La distancia entre dos frutas
procedure TestDistancia;
begin
  var A := TFruit.Create(0.150, 0.80);
  var B := TFruit.Create(0.150, 0.20);
  Assert.True(Abs(Distancia(A, B) - 0.6) < 1e-9, 'la distancia entre (0.150, 0.80) y (0.150, 0.20) tiene que ser 0.6');
  var C := TFruit.Create(0.180, 0.40);
  Assert.True(Abs(Distancia(A, C) - Sqrt(Sqr(0.03) + Sqr(0.4))) < 1e-9, 'la distancia tiene que mirar el peso y la rojez');
  Assert.True(Abs(Distancia(C, A) - Distancia(A, C)) < 1e-12, 'de A a C tiene que dar lo mismo que de C a A');
end;

/// El vecino más cercano (k = 1)
[Hint('Con K = 1 la respuesta es la clase de la primera fruta de Orden: Orden[0].Name.')]
procedure TestUnVecino;
begin
  var Datos: TArray<TFruit> := [TFruit.Create(0.170, 0.80, 'apple'), TFruit.Create(0.120, 0.30, 'pear')];
  Assert.Equal('pear', Clasificar(TFruit.Create(0.125, 0.35), Datos, 1));
  Assert.Equal('apple', Clasificar(TFruit.Create(0.165, 0.75), Datos, 1));
end;

/// La votación con k = 3
[Hint('¿Estás contando los 3 vecinos o solo el primero? Recorre Orden de 0 a K - 1 y cuenta.')]
procedure TestVotacion;
begin
  var Datos: TArray<TFruit> := [
    TFruit.Create(0.150, 0.50, 'pear'),     // la más cercana es pera...
    TFruit.Create(0.150, 0.62, 'apple'),
    TFruit.Create(0.150, 0.66, 'apple'),    // ...pero dos de las tres son manzanas
    TFruit.Create(0.120, 0.10, 'pear')];
  Assert.Equal('apple', Clasificar(TFruit.Create(0.150, 0.54), Datos, 3),
    'entre las 3 más cercanas hay 2 manzanas y 1 pera');
  Assert.Equal('apple', Clasificar(TFruit.Create(0.152, 0.81), Datasets.Fruits, 3));
end;

/// Frutas que el programa nunca vio
procedure TestExactitud;
begin
  var Bien := 0;
  for var F in Datasets.FruitsTest do
    if Clasificar(F, Datasets.Fruits, 3) = F.Name then
      Inc(Bien);
  Assert.True(Bien >= 18, Format('acertó %d de 20; tiene que acertar al menos 18', [Bien]));
end;
