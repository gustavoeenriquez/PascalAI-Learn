// Pruebas de Pai.Learn: azar, álgebra, datos, búsqueda y vecinos.
uses SysUtils, Pai.Learn.Random, Pai.Learn.Linalg, Pai.Learn.Data, Pai.Learn.Search, Pai.Learn.Neighbors;

procedure TestAzarSeRepite;
begin
  var A := TRandom.Create(42);
  var B := TRandom.Create(42);
  for var I := 1 to 100 do
    Assert.Equal(A.NextDouble, B.NextDouble, 'misma semilla, mismos números');
  // el primer número de Park-Miller con semilla 1 es 48271 / (2^31 - 1), corrido en 1
  var C := TRandom.Create(0);
  Assert.Equal((48271 - 1) / 2147483646, C.NextDouble);
end;

procedure TestAzarEnRango;
begin
  var R := TRandom.Create(3);
  var Suma: Double := 0.0;
  for var I := 1 to 10000 do
  begin
    var X := R.NextDouble;
    Assert.True((X >= 0) and (X < 1));
    Suma := Suma + R.Gauss(10, 2);
    var N := R.NextInt(6);
    Assert.True((N >= 0) and (N <= 5));
  end;
  Assert.True(Abs(Suma / 10000 - 10) < 0.1, 'la media de la normal');
end;

procedure TestVectores;
begin
  var A: TVec := [1, 2, 3];
  var B: TVec := [4, 5, 6];
  Assert.Equal(32.0, Dot(A, B));
  Assert.Equal('[5.00, 7.00, 9.00]', VecToStr(Add(A, B)));
  Assert.Equal(5.0, Distance([0, 0], [3, 4]));
  Assert.Equal(2.0, Mean(A));
  Assert.Raises('EArgumentException', procedure begin Dot([1], [1, 2]); end);
end;

procedure TestMatrices;
begin
  var A := TMatrix.FromRows([[1, 2], [3, 4]]);
  var Unos: TVec := [1, 1];
  Assert.Equal('[3.00, 7.00]', VecToStr(A * Unos));
  var P := A * A;
  Assert.Equal('[7.00, 10.00]' + sLineBreak + '[15.00, 22.00]', P.ToString);
  Assert.Equal(3.0, A.Transpose[0, 1]);
  Assert.Equal(A.ToString, (A * TMatrix.Identity(2)).ToString);
  Assert.Equal('[0.00, 0.00]' + sLineBreak + '[0.00, 0.00]', (A - A).ToString);
  Assert.Raises('EArgumentException', procedure begin var X := A * TMatrix.Create(3, 1); end);
end;

procedure TestFrutas;
begin
  var F := Datasets.Fruits;
  Assert.Equal(40, Length(F));
  var Manzanas := 0;
  for var X in F do
    if X.Name = 'apple' then
    begin
      Inc(Manzanas);
      Assert.Equal(1, X.Target);
    end;
  Assert.Equal(20, Manzanas);
  Assert.Equal(20, Length(Datasets.FruitsTest));
  Assert.Equal(VecToStr(F[0].Features, 6), VecToStr(Datasets.Fruits[0].Features, 6), 'siempre iguales');
end;

procedure TestSalasAEstrellaAhorra;
begin
  var L := TMaze.Create(Mazes.Rooms);
  var Anchura := BreadthFirst(L);
  var Estrella := AStar(L);
  Assert.Equal(27, Length(Anchura.Path));
  Assert.Equal(27, Length(Estrella.Path));
  Assert.Equal(145, Length(Anchura.Visited));
  Assert.Equal(83, Length(Estrella.Visited));
end;

procedure TestLaberinto;
begin
  var L := TMaze.Create(Mazes.Corridors);
  Assert.Equal('(1, 1)', L.Start.ToString);
  Assert.Equal('(9, 19)', L.Goal.ToString);
  var Anchura := BreadthFirst(L);
  var Estrella := AStar(L);
  Assert.Equal(59, Length(Anchura.Path), 'camino de 58 pasos');
  Assert.Equal(Length(Anchura.Path), Length(Estrella.Path), 'A* también encuentra el más corto');
  Assert.Equal(97, Length(Anchura.Visited));
  Assert.Equal(91, Length(Estrella.Visited), 'en pasillos A* casi no ahorra');
  Assert.True(Anchura.Path[0] = L.Start);
  Assert.True(Anchura.Path[High(Anchura.Path)] = L.Goal);
  for var I := 1 to High(Anchura.Path) do
    Assert.Equal(1, Manhattan(Anchura.Path[I - 1], Anchura.Path[I]), 'pasos de a una casilla');
end;

procedure TestLaberintoSinCamino;
begin
  var L := TMaze.Create(['#####', '#S#G#', '#####']);
  Assert.Equal(0, Length(BreadthFirst(L).Path));
  Assert.Equal(0, Length(AStar(L).Path));
  Assert.Raises('EArgumentException', procedure begin TMaze.Create(['#..#']); end);
end;

procedure TestVecinos;
begin
  var Puntos: TArray<TVec> := [[0, 0], [0, 1], [5, 5], [6, 5], [5, 6]];
  var Clases: TArray<string> := ['a', 'a', 'b', 'b', 'b'];
  Assert.Equal('a', KNearest(Puntos, Clases, [0.2, 0.2], 1));
  Assert.Equal('b', KNearest(Puntos, Clases, [4, 4], 3));
  Assert.Equal('b', KNearest(Puntos, Clases, [0, 0], 5), 'con k = 5 gana la mayoría');
end;

procedure TestFrutasConVecinos;
begin
  var Puntos: TArray<TVec> := [];
  var Clases: TArray<string> := [];
  for var F in Datasets.Fruits do
  begin
    Puntos := Puntos + [F.Features];
    Clases := Clases + [F.Name];
  end;
  Assert.Equal('apple', KNearest(Puntos, Clases, TFruit.Create(0.152, 0.81).Features, 3));
  var Bien := 0;
  for var F in Datasets.FruitsTest do
    if KNearest(Puntos, Clases, F.Features, 3) = F.Name then
      Inc(Bien);
  Assert.True(Bien >= 18, IntToStr(Bien) + ' de 20 bien clasificadas');
end;
