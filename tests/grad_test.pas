// Pruebas de Pai.Learn.Grad: cada derivada se compara con la aproximación numérica
// (f(x + h) - f(x - h)) / 2h.
uses SysUtils, Pai.Learn.Grad;

procedure Near(Expected, Actual: Double; const What: string);
begin
  Assert.True(Abs(Expected - Actual) < 1e-6,
    What + ': se esperaba ' + FloatToStr(Expected) + ' y salió ' + FloatToStr(Actual));
end;

type
  TFun = reference to function(const X: TScalar): TScalar;

procedure CheckDerivative(F: TFun; X0: Double; const What: string);
begin
  var X := Scalar(X0);
  var Y := F(X);
  Y.Backward;
  const H = 1e-5;
  var Numeric := (F(Scalar(X0 + H)).Value - F(Scalar(X0 - H)).Value) / (2 * H);
  Near(Numeric, X.Grad, What);
end;

procedure TestEjemploDeLaLeccion;
begin
  var X := Scalar(2.0);
  var W := Scalar(-0.5);
  var B := Scalar(0.3);
  var Y := (X * W + B).Tanh;
  Y.Backward;
  Near(-0.604367777, Y.Value, 'y');
  Near(1.26947918, W.Grad, 'dy/dw');
  Near(-0.31736979, X.Grad, 'dy/dx');
  Near(0.63473959, B.Grad, 'dy/db');
end;

procedure TestDerivadas;
begin
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X * X + X; end, 1.5, 'x² + x');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X - 3 * X; end, 0.7, 'x - 3x');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := 1 / X; end, 2.0, '1/x');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := -X; end, 2.0, '-x');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X.Pow(3); end, -1.2, 'x³');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X.Exp; end, 0.4, 'exp');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X.Log; end, 2.5, 'log');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X.Sigmoid; end, -0.3, 'sigmoide');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := X.Relu; end, 0.8, 'relu');
  CheckDerivative(function(const X: TScalar): TScalar begin Result := (X * X).Tanh / (X + 1); end, 0.6, 'compuesta');
end;

procedure TestUnNodoUsadoDosVeces;
begin
  // y = x * x: el gradiente llega por los dos caminos y se suma
  var X := Scalar(3.0);
  var Y := X * X;
  Y.Backward;
  Near(6, X.Grad, 'd(x*x)/dx');
end;

procedure TestDescensoPorGradiente;
begin
  // minimizar (w - 4)²: tiene que acercarse a 4
  var W := Scalar(0.0);
  for var I := 1 to 200 do
  begin
    W.ZeroGrad;
    var Perdida := (W - 4).Pow(2);
    Perdida.Backward;
    W.Step(0.1);
  end;
  Near(4, W.Value, 'w');
end;
