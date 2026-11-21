// Pruebas de Pai.Learn.Tensor: cada gradiente se compara con la pendiente medida
// (f(x + h) - f(x - h)) / 2h, elemento por elemento.
uses SysUtils, Math, Pai.Learn.Random, Pai.Learn.Linalg, Pai.Learn.Tensor;

type
  TLoss = reference to function(const P: TTensor): TTensor;

/// Compara el gradiente de Loss respecto de P con el numérico.
procedure CheckGrad(const P: TTensor; Loss: TLoss; const What: string);
begin
  P.ZeroGrad;
  Loss(P).Backward;
  var G := Copy(P.Grad);
  const H = 1e-6;
  for var I := 0 to High(P.Node.Data) do
  begin
    var Old := P.Node.Data[I];
    P.Node.Data[I] := Old + H;
    var Up := Loss(P).Item;
    P.Node.Data[I] := Old - H;
    var Down := Loss(P).Item;
    P.Node.Data[I] := Old;
    var Num := (Up - Down) / (2 * H);
    Assert.True(Abs(Num - G[I]) < 1e-5 * Max(1.0, Abs(Num)),
      Format('%s, elemento %d: gradiente %.8f, medido %.8f', [What, I, G[I], Num]));
  end;
end;

procedure TestFormas;
begin
  var A := TTensor.FromRows([[1, 2, 3], [4, 5, 6]]);
  var B := TTensor.FromRows([[1, 0], [0, 1], [1, 1]]);
  var C := A.MatMul(B);
  Assert.Equal(2, C.Rows);
  Assert.Equal(2, C.Cols);
  Assert.Equal('[4.000, 5.000]' + sLineBreak + '[10.000, 11.000]', C.ToString);
  var Sesgo := TTensor.FromRows([[10, 20, 30]]);
  Assert.Equal('[11.000, 22.000, 33.000]' + sLineBreak + '[14.000, 25.000, 36.000]', (A + Sesgo).ToString);
  Assert.Raises('EArgumentException', procedure begin A.MatMul(A); end);
end;

procedure TestGradientes;
begin
  var Rng := TRandom.Create(3);
  var A := TTensor.Random(3, 4, Rng);
  var B := TTensor.Random(4, 2, Rng);
  var Bias := TTensor.Random(1, 2, Rng);
  var T := TTensor.Random(3, 2, Rng);
  var Fijo := TTensor.Random(3, 4, Rng);
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := MSE(P.MatMul(B), T); end, 'matmul (izquierda)');
  CheckGrad(B, function(const P: TTensor): TTensor begin Result := MSE(A.MatMul(P), T); end, 'matmul (derecha)');
  CheckGrad(Bias, function(const P: TTensor): TTensor begin Result := MSE(A.MatMul(B) + P, T); end, 'sesgo');
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := (P * Fijo).Sum; end, 'producto elemento a elemento');
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := (P - Fijo).Tanh.Mean; end, 'resta y tanh');
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := MSE(P.Sigmoid, Fijo); end, 'sigmoide');
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := (3.0 * P).Relu.Sum; end, 'relu');
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := CrossEntropy(P, [0, 3, 1]); end, 'entropía cruzada');
  // un nodo usado dos veces: los gradientes se suman
  CheckGrad(A, function(const P: TTensor): TTensor begin Result := (P * P + P).Sum; end, 'usado dos veces');
end;

procedure TestEntropiaCruzada;
begin
  // logits iguales en 4 clases: la probabilidad es 1/4 y la pérdida ln 4
  var L := TTensor.Zeros(2, 4);
  Assert.True(Abs(CrossEntropy(L, [0, 2]).Item - Ln(4)) < 1e-12);
  // logits enormes no dan infinito (softmax estable)
  var G := TTensor.FromRows([[1000, 0, -1000]]);
  Assert.True(CrossEntropy(G, [0]).Item < 1e-9);
  Assert.Equal('[0, 2]', '[' + IntToStr(ArgMaxRows(TTensor.FromRows([[3, 1], [0, 1]]))[0]) + ', 2]');
  var P := Softmax(TTensor.FromRows([[1, 1]]));
  Assert.True(Abs(P[0, 0] - 0.5) < 1e-12);
end;

procedure TestXor;
begin
  // una red 2 -> 4 -> 1 que aprende XOR con matrices enteras
  var Rng := TRandom.Create(2);
  var X := TTensor.FromRows([[0, 0], [0, 1], [1, 0], [1, 1]]);
  var Y := TTensor.FromRows([[0], [1], [1], [0]]);
  var W1 := TTensor.Random(2, 4, Rng);
  var B1 := TTensor.Zeros(1, 4);
  var W2 := TTensor.Random(4, 1, Rng);
  var B2 := TTensor.Zeros(1, 1);
  var Params: TArray<TTensor> := [W1, B1, W2, B2];
  var Loss := 0.0;
  for var Epoca := 1 to 500 do
  begin
    for var P in Params do
      P.ZeroGrad;
    var L := MSE((X.MatMul(W1) + B1).Tanh.MatMul(W2) + B2, Y);
    L.Backward;
    for var P in Params do
      for var I := 0 to High(P.Node.Data) do
        P.Node.Data[I] := P.Node.Data[I] - 0.5 * P.Node.Grad[I];
    Loss := L.Item;
  end;
  Assert.True(Loss < 0.01, Format('la pérdida quedó en %.4f', [Loss]));
end;
