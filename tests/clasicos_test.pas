// Pruebas de lo que agregó D-381 (auditoría F14): regresión lineal y logística, árbol de decisión, espirales,
// lotes, búsqueda en profundidad, minimax con poda y los gráficos nuevos (mapa de calor, árbol, cuadrícula, HTML).
uses SysUtils, Pai.Learn.Data, Pai.Learn.Linalg, Pai.Learn.Classic, Pai.Learn.Plot, Pai.Learn.Search,
  Pai.Learn.Random;

procedure TestRegresionLineal;
begin
  var X := TMatrix.FromRows([[0], [1], [2], [3], [4]]);
  var Y: TVec := [1, 3, 5, 7, 9];        // y = 2x + 1
  var L := TLinearRegression.Create;
  L.Fit(X, Y, 0.05, 2000);
  Assert.True(Abs(L.W[0] - 2) < 0.01, 'la pendiente');
  Assert.True(Abs(L.B - 1) < 0.01, 'el corte');
  Assert.True(L.Losses[High(L.Losses)] < L.Losses[0], 'la pérdida baja');
  Assert.True(Abs(L.Predict([10]) - 21) < 0.1, 'predice fuera de lo visto');
  L.Free;
end;

procedure TestRegresionLogistica;
begin
  var F := Datasets.Fruits;
  var X := TMatrix.Create(Length(F), 2);
  var Y: TVec;
  SetLength(Y, Length(F));
  for var I := 0 to High(F) do
  begin
    X[I, 0] := F[I].Weight;
    X[I, 1] := F[I].Redness;
    if F[I].Target = 1 then Y[I] := 1 else Y[I] := 0;
  end;
  var G := TLogisticRegression.Create;
  G.Fit(X, Y, 1, 2000);
  var Ok := 0;
  for var I := 0 to High(F) do
    if G.Predict(F[I].Features) = Round(Y[I]) then
      Inc(Ok);
  Assert.True(Ok >= 36, 'separa manzanas y peras: ' + IntToStr(Ok));
  Assert.True((G.Probability([0.2, 0.9]) > 0.5) <> (G.Probability([0.2, 0.1]) > 0.5), 'roja y no roja, distinto');
  G.Free;
end;

procedure TestArbolIris;
begin
  var Iris := Datasets.Iris;
  var T := TDecisionTree.Create(3);
  T.FeatureNames := ['sépalo largo', 'sépalo ancho', 'pétalo largo', 'pétalo ancho'];
  T.Fit(Iris);
  var Hits := 0;
  for var I := 0 to Iris.Count - 1 do
    if T.Predict(Iris.X.Row(I)) = Iris.Labels[I] then
      Inc(Hits);
  Assert.True(Hits >= 140, 'aciertos: ' + IntToStr(Hits));
  Assert.Contains(T.ToString, '¿pétalo largo <= 2.45?');
  Assert.Contains(T.ToString, 'sí: → setosa (50)');
  var P := T.ToPlot;
  var S := Plot.Tree(P, 'Iris');
  Assert.Contains(S, '<svg');
  Assert.Contains(S, 'setosa');
  P.Free;
  T.Free;
end;

procedure TestEspiralesYLotes;
begin
  var S := Datasets.Spirals(50, 3);
  Assert.Equal(150, S.Count);
  Assert.Equal(2, S.Features);
  Assert.Equal('brazo 2', S.ClassNames[2]);
  var Rng := TRandom.Create(1);
  var B := S.Batches(32, Rng);
  Assert.Equal(5, Length(B));
  Assert.Equal(32, B[0].Count);
  Assert.Equal(22, B[4].Count);
  var Total := 0;
  for var X in B do
    Total := Total + X.Count;
  Assert.Equal(150, Total, 'los lotes cubren todo');
  Rng.Free;
end;

procedure TestProfundidadYMinimax;
begin
  var M := TMaze.Create(Mazes.Rooms);
  var D := DepthFirst(M);
  var A := BreadthFirst(M);
  Assert.True(Length(D.Path) > 0, 'encuentra un camino');
  Assert.True(Length(D.Path) >= Length(A.Path), 'no más corto que el de anchura');
  M.Free;
  // con una jugada hecha (desde el tablero vacío, sin poda, son 550 000 tableros: unos segundos)
  var Sin := Minimax(TTicTacToe.FromText('    X    '), False);
  var Con := Minimax(TTicTacToe.FromText('    X    '), True);
  Assert.Equal(0, Sin.Value, 'con juego perfecto, empate');
  Assert.Equal(Sin.Value, Con.Value, 'la poda no cambia el resultado');
  Assert.True(Con.Nodes < Sin.Nodes div 10, 'la poda revisa muchos menos tableros');
  Assert.Equal(2, Minimax(TTicTacToe.FromText('XX OO    ')).Move, 'X completa la fila');
  Assert.Equal(2, Minimax(TTicTacToe.FromText('XX O     ')).Move, 'O tiene que tapar la fila de arriba');
end;

procedure TestGraficosNuevos;
begin
  var H := Plot.Heatmap(TMatrix.FromRows([[1, 2], [3, 4]]), 'calor', ['a', 'b'], ['x', 'y']);
  Assert.Contains(H, 'calor');
  Assert.Equal(4, (Length(H) - Length(H.Replace('<rect', ''))) div Length('<rect'), 'una casilla por valor');
  var G := Plot.Grid(TMatrix.FromRows([[0, 1], [2, 3]]), ['>v', '^ '], ['  ', ' #'], 'Q');
  Assert.Contains(G, '→');
  Assert.Contains(G, '#2a3245');
  var Page := Plot.Html('Página', [H, G]);
  Assert.Contains(Page, '<!doctype html>');
  Assert.Equal(2, (Length(Page) - Length(Page.Replace('<figure>', ''))) div Length('<figure>'), 'dos gráficos');
end;
