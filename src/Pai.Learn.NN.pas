unit Pai.Learn.NN;

// Redes neuronales sobre Pai.Learn.Tensor: capas densas, una red de varias capas (perceptrón
// multicapa) y dos optimizadores (descenso por gradiente y Adam).
//
//   var Azar := TRandom.Create(1);
//   var Red := TMLP.Create([64, 32, 10], Azar);       // 64 entradas, 32 ocultas, 10 clases
//   var Opt := TAdam.Create(Red.Parameters, 0.01);
//   for var Epoca := 1 to 30 do
//   begin
//     Opt.ZeroGrad;
//     var Perdida := CrossEntropy(Red.Forward(X), Clases);
//     Perdida.Backward;
//     Opt.Step;
//   end;

interface

uses
  SysUtils, Math, Pai.Learn.Random, Pai.Learn.Tensor;

type
  TActivation = (acNone, acTanh, acRelu, acSigmoid);

  /// Una capa densa: Salida = Activación(X · W + B). W es Entradas x Salidas; B, 1 x Salidas.
  TDense = class
  public
    W, B: TTensor;
    Activation: TActivation;
    constructor Create(Inputs, Outputs: Integer; AActivation: TActivation; Rng: TRandom);
    function Forward(const X: TTensor): TTensor;
    function Parameters: TArray<TTensor>;
  end;

  /// Perceptrón multicapa: capas densas en fila. Sizes = [entradas, ocultas..., salidas]; las
  /// ocultas usan Hidden (tanh por defecto) y la última no lleva activación (da los logits, o el
  /// valor en una regresión).
  TMLP = class
  public
    Layers: TArray<TDense>;
    constructor Create(const Sizes: TArray<Integer>; Rng: TRandom; Hidden: TActivation = acTanh);
    function Forward(const X: TTensor): TTensor;
    function Parameters: TArray<TTensor>;
    /// Cuántos números aprende la red.
    function ParameterCount: Integer;
  end;

  /// Descenso por gradiente: p := p - Rate · grad (con Momentum, recuerda la dirección anterior).
  TSGD = class
  private
    FParams: TArray<TTensor>;
    FVel: TArray<TArray<Double>>;
  public
    Rate, Momentum: Double;
    constructor Create(const AParams: TArray<TTensor>; ARate: Double; AMomentum: Double = 0);
    procedure ZeroGrad;
    procedure Step;
  end;

  /// Adam: como el descenso por gradiente, pero con un paso propio para cada número, que se ajusta
  /// con el promedio de sus gradientes y de sus cuadrados.
  TAdam = class
  private
    FParams: TArray<TTensor>;
    FM, FV: TArray<TArray<Double>>;
    FT: Integer;
  public
    Rate, Beta1, Beta2, Eps: Double;
    constructor Create(const AParams: TArray<TTensor>; ARate: Double = 0.001);
    procedure ZeroGrad;
    procedure Step;
  end;

implementation

function ZerosLike(const P: TTensor): TArray<Double>;
begin
  SetLength(Result, Length(P.Node.Data));
  for var I := 0 to High(Result) do
    Result[I] := 0;
end;

{ TDense }

constructor TDense.Create(Inputs, Outputs: Integer; AActivation: TActivation; Rng: TRandom);
begin
  // inicio de Xavier/Glorot: pesos chicos, más chicos cuantas más entradas, para que la señal no
  // crezca ni se apague al pasar por muchas capas
  W := TTensor.Random(Inputs, Outputs, Rng, Sqrt(6 / (Inputs + Outputs)));
  B := TTensor.Zeros(1, Outputs);
  Activation := AActivation;
end;

function TDense.Forward(const X: TTensor): TTensor;
begin
  Result := X.MatMul(W) + B;
  case Activation of
    acTanh: Result := Result.Tanh;
    acRelu: Result := Result.Relu;
    acSigmoid: Result := Result.Sigmoid;
  end;
end;

function TDense.Parameters: TArray<TTensor>;
begin
  Result := [W, B];
end;

{ TMLP }

constructor TMLP.Create(const Sizes: TArray<Integer>; Rng: TRandom; Hidden: TActivation);
begin
  if Length(Sizes) < 2 then
    raise EArgumentException.Create('una red necesita al menos [entradas, salidas]');
  SetLength(Layers, Length(Sizes) - 1);
  for var I := 0 to High(Layers) do
    Layers[I] := TDense.Create(Sizes[I], Sizes[I + 1], if I < High(Layers) then Hidden else acNone, Rng);
end;

function TMLP.Forward(const X: TTensor): TTensor;
begin
  Result := X;
  for var L in Layers do
    Result := L.Forward(Result);
end;

function TMLP.Parameters: TArray<TTensor>;
begin
  Result := [];
  for var L in Layers do
    Result := Result + L.Parameters;
end;

function TMLP.ParameterCount: Integer;
begin
  Result := 0;
  for var P in Parameters do
    Result := Result + Length(P.Node.Data);
end;

{ TSGD }

constructor TSGD.Create(const AParams: TArray<TTensor>; ARate, AMomentum: Double);
begin
  FParams := AParams;
  Rate := ARate;
  Momentum := AMomentum;
  SetLength(FVel, Length(AParams));
  for var I := 0 to High(AParams) do
    FVel[I] := ZerosLike(AParams[I]);
end;

procedure TSGD.ZeroGrad;
begin
  for var P in FParams do
    P.ZeroGrad;
end;

procedure TSGD.Step;
begin
  for var K := 0 to High(FParams) do
  begin
    var N := FParams[K].Node;
    var D := N.Data;
    var V := FVel[K];
    for var I := 0 to High(D) do
    begin
      V[I] := Momentum * V[I] - Rate * N.Grad[I];
      D[I] := D[I] + V[I];
    end;
    FVel[K] := V;
    N.Data := D;
  end;
end;

{ TAdam }

constructor TAdam.Create(const AParams: TArray<TTensor>; ARate: Double);
begin
  FParams := AParams;
  Rate := ARate;
  Beta1 := 0.9;
  Beta2 := 0.999;
  Eps := 1e-8;
  SetLength(FM, Length(AParams));
  SetLength(FV, Length(AParams));
  for var I := 0 to High(AParams) do
  begin
    FM[I] := ZerosLike(AParams[I]);
    FV[I] := ZerosLike(AParams[I]);
  end;
end;

procedure TAdam.ZeroGrad;
begin
  for var P in FParams do
    P.ZeroGrad;
end;

procedure TAdam.Step;
begin
  Inc(FT);
  // corrección del sesgo: al principio M y V arrancan en cero y se quedan cortos
  var C1 := 1 - Power(Beta1, FT);
  var C2 := 1 - Power(Beta2, FT);
  for var K := 0 to High(FParams) do
  begin
    var N := FParams[K].Node;
    var D := N.Data;
    var M := FM[K];
    var V := FV[K];
    for var I := 0 to High(D) do
    begin
      var G := N.Grad[I];
      M[I] := Beta1 * M[I] + (1 - Beta1) * G;
      V[I] := Beta2 * V[I] + (1 - Beta2) * G * G;
      D[I] := D[I] - Rate * (M[I] / C1) / (Sqrt(V[I] / C2) + Eps);
    end;
    FM[K] := M;
    FV[K] := V;
    N.Data := D;
  end;
end;

end.
