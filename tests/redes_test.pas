// Pruebas de T2: datos de archivo, redes, optimizadores, métricas, k-means y PCA.
// Necesitan PAI_LEARN apuntando a este repo (tools/test.sh lo pone).
uses SysUtils, Math, Pai.Learn.Random, Pai.Learn.Linalg, Pai.Learn.Data, Pai.Learn.Tensor, Pai.Learn.NN,
  Pai.Learn.Metrics, Pai.Learn.Unsupervised;

procedure TestDatos;
begin
  var I := Datasets.Iris;
  Assert.Equal(150, I.Count);
  Assert.Equal(4, I.Features);
  Assert.Equal('setosa', I.ClassNames[I.Labels[0]]);
  Assert.Equal('virginica', I.ClassNames[I.Labels[149]]);
  Assert.Equal(5.1, I.X[0, 0]);
  var D := Datasets.Digits;
  Assert.Equal(3823, D.Count);
  Assert.Equal(64, D.Features);
  Assert.Equal(1797, Datasets.Digits(False).Count);
  var Tr, Te: TDataset;
  I.Split(0.2, TRandom.Create(1), Tr, Te);
  Assert.Equal(120, Tr.Count);
  Assert.Equal(30, Te.Count);
end;

procedure TestIrisConRed;
begin
  var Azar := TRandom.Create(1);
  var Tr, Te: TDataset;
  Datasets.Iris.Split(0.3, Azar, Tr, Te);
  var Red := TMLP.Create([4, 8, 3], Azar);
  Assert.Equal(4 * 8 + 8 + 8 * 3 + 3, Red.ParameterCount);
  var Opt := TAdam.Create(Red.Parameters, 0.05);
  var X := TTensor.FromMatrix(Tr.X);
  var Primera: Double := 0.0;
  var Ultima: Double := 0.0;
  for var E := 1 to 150 do
  begin
    Opt.ZeroGrad;
    var L := CrossEntropy(Red.Forward(X), Tr.Labels);
    L.Backward;
    Opt.Step;
    if E = 1 then Primera := L.Item;
    Ultima := L.Item;
  end;
  Assert.True(Ultima < Primera / 5, Format('la pérdida bajó de %.3f a %.3f', [Primera, Ultima]));
  var Acc := Accuracy(ArgMaxRows(Red.Forward(TTensor.FromMatrix(Te.X))), Te.Labels);
  Assert.True(Acc >= 0.9, Format('exactitud con flores nuevas: %.2f', [Acc]));
end;

procedure TestSGD;
begin
  // minimizar (w - 3)² con descenso por gradiente, con y sin momento
  for var Mom in [0.0, 0.9] do
  begin
    var W := TTensor.Zeros(1, 1);
    var Tres := TTensor.FromRows([[3]]);
    var Opt := TSGD.Create([W], 0.05, Mom);
    for var I := 1 to 300 do
    begin
      Opt.ZeroGrad;
      MSE(W, Tres).Backward;
      Opt.Step;
    end;
    Assert.True(Abs(W.Item - 3) < 1e-3, Format('momento %.1f: w = %.5f', [Mom, W.Item]));
  end;
end;

procedure TestMetricas;
begin
  var Pred: TArray<Integer> := [0, 1, 1, 2, 2, 2];
  var Real: TArray<Integer> := [0, 1, 2, 2, 2, 0];
  Assert.Equal(4 / 6, Accuracy(Pred, Real));
  var M := ConfusionMatrix(Pred, Real, 3);
  Assert.Equal(1, M[0][0]);
  Assert.Equal(1, M[0][2]);
  Assert.Equal(1, M[2][1]);
  Assert.Equal(2, M[2][2]);
  Assert.Equal(2 / 3, Precision(M, 2));
  Assert.Equal(2 / 3, Recall(M, 2));
  Assert.Equal(1.0, Recall(M, 1));
  Assert.Equal(0.5, Precision(M, 1));
  Assert.True(Abs(F1(M, 1) - 2 / 3) < 1e-12);
  Assert.Contains(ConfusionToString(M, ['a', 'b', 'c']), '|');
end;

procedure TestKMeans;
begin
  var X := TMatrix.FromRows([[0, 0], [0, 1], [1, 0], [10, 10], [10, 11], [11, 10]]);
  var G := KMeans(X, 2, TRandom.Create(4));
  Assert.True(G.Assign[0] = G.Assign[1]);
  Assert.True(G.Assign[0] = G.Assign[2]);
  Assert.True(G.Assign[3] = G.Assign[5]);
  Assert.True(G.Assign[0] <> G.Assign[3], 'dos grupos separados');
  Assert.True(Abs(G.Inertia - 8 / 3) < 1e-9, Format('inercia %.4f', [G.Inertia]));
end;

procedure TestPCAIris;
begin
  var P := PCA(Datasets.Iris.X, 2);
  // los autovalores de la covarianza de este iris.csv (UCI), calculados con numpy: 4.2248 y 0.2422
  Assert.True(Abs(P.Variance[0] - 4.22484) < 1e-4, Format('primera varianza %.4f', [P.Variance[0]]));
  Assert.True(Abs(P.Variance[1] - 0.24224) < 1e-4, Format('segunda varianza %.4f', [P.Variance[1]]));
  Assert.Equal(150, P.Projected.Rows);
  Assert.Equal(2, P.Projected.Cols);
  Assert.True(Abs(Norm(P.Components.Row(0)) - 1) < 1e-9, 'la dirección mide 1');
end;
