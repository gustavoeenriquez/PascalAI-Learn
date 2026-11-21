unit Pai.Learn.Tensor;

// Gradiente automático sobre matrices enteras: la misma idea de Pai.Learn.Grad (cada operación
// recuerda de dónde salió y cómo devolver el gradiente), pero cada nodo es una matriz. Así una capa
// de una red es UNA multiplicación y no miles de números sueltos, y entrenar con cientos de
// ejemplos a la vez es posible.
//
//   var X := TTensor.FromRows([[0, 0], [0, 1], [1, 0], [1, 1]]);    // 4 ejemplos, 2 entradas
//   var W := TTensor.Random(2, 3, Azar);
//   var B := TTensor.Zeros(1, 3);
//   var H := (X.MatMul(W) + B).Tanh;                                  // 4 x 3
//   var L := MSE(H.MatMul(V), Y);
//   L.Backward;                                                       // W.Grad, B.Grad...
//
// Las formas: una matriz de N filas (ejemplos) por M columnas. Sumar una matriz de 1 fila a una de N
// filas la suma a cada fila (es el sesgo de una capa).

interface

uses
  SysUtils, Generics.Collections, Pai.Learn.Random, Pai.Learn.Linalg;

type
  TTensorNode = class;
  TTensorBackStep = reference to procedure(Node: TTensorNode);

  TTensorNode = class
  public
    Rows, Cols: Integer;
    Data: TArray<Double>;        // fila por fila: (R, C) está en Data[R * Cols + C]
    Grad: TArray<Double>;        // misma forma que Data
    Parents: TArray<TTensorNode>;
    Op: string;
    BackStep: TTensorBackStep;
    constructor Create(ARows, ACols: Integer);
    procedure AddGrad(const G: TArray<Double>);
  end;

  TTensor = record
    Node: TTensorNode;
    function Rows: Integer;
    function Cols: Integer;
    function Data: TArray<Double>;
    function Grad: TArray<Double>;
    function Get(R, C: Integer): Double;
    procedure Put(R, C: Integer; V: Double);
    /// El primer (o único) valor: para una pérdida, que es 1 x 1.
    function Item: Double;

    class function Zeros(ARows, ACols: Integer): TTensor; static;
    class function FromRows(const ARows: TArray<TVec>): TTensor; static;
    class function FromMatrix(const M: TMatrix): TTensor; static;
    /// Valores al azar uniformes en [-Scale, Scale].
    class function Random(ARows, ACols: Integer; Rng: TRandom; Scale: Double = 1): TTensor; static;
    function ToMatrix: TMatrix;

    /// Producto de matrices: (N x K) por (K x M) da N x M.
    function MatMul(const B: TTensor): TTensor;
    /// Suma elemento a elemento; si B tiene 1 fila, se suma a cada fila (el sesgo).
    class operator Add(const A, B: TTensor): TTensor;
    class operator Subtract(const A, B: TTensor): TTensor;
    /// Producto elemento a elemento (no es el de matrices: ese es MatMul).
    class operator Multiply(const A, B: TTensor): TTensor;
    class operator Multiply(K: Double; const A: TTensor): TTensor;

    /// Las filas Ids de esta tabla, en ese orden (un embedding: la fila de cada token).
    function Gather(const Ids: TArray<Integer>): TTensor;
    function Transpose: TTensor;
    /// Softmax de cada fila. Con Causal, la fila i solo mira las columnas 0..i (lo que vino antes): la
    /// máscara de un modelo de lenguaje, que no puede ver el futuro.
    function SoftmaxRows(Causal: Boolean = False): TTensor;
    function Tanh: TTensor;
    function Sigmoid: TTensor;
    function Relu: TTensor;
    /// El promedio de todos los elementos (1 x 1).
    function Mean: TTensor;
    /// La suma de todos los elementos (1 x 1).
    function Sum: TTensor;

    /// Calcula el gradiente de este tensor (1 x 1, una pérdida) respecto de todo de lo que depende.
    procedure Backward;
    procedure ZeroGrad;
    function ToString(Decimals: Integer = 3): string;
  end;

/// Error cuadrático medio entre Pred y Target (misma forma): 1 x 1.
function MSE(const Pred, Target: TTensor): TTensor;

/// Entropía cruzada de Logits (N x clases, sin softmax) con las clases correctas (N enteros): 1 x 1.
/// Aplica softmax por dentro, de la forma estable (restando el máximo de cada fila).
function CrossEntropy(const Logits: TTensor; const Labels: TArray<Integer>): TTensor;

/// Softmax por filas (sin gradiente): las probabilidades de cada clase.
function Softmax(const Logits: TTensor): TMatrix;

/// La posición del mayor de cada fila: la clase que elige el modelo.
function ArgMaxRows(const T: TTensor): TArray<Integer>;

implementation

uses
  Math;

{ TTensorNode }

constructor TTensorNode.Create(ARows, ACols: Integer);
begin
  Rows := ARows;
  Cols := ACols;
  SetLength(Data, ARows * ACols);
  SetLength(Grad, ARows * ACols);
  for var I := 0 to High(Data) do
  begin
    Data[I] := 0;
    Grad[I] := 0;
  end;
end;

procedure TTensorNode.AddGrad(const G: TArray<Double>);
begin
  for var I := 0 to High(Grad) do
    Grad[I] := Grad[I] + G[I];
end;

function NewTensor(ARows, ACols: Integer; const AParents: TArray<TTensorNode>; const AOp: string): TTensor;
begin
  Result.Node := TTensorNode.Create(ARows, ACols);
  Result.Node.Parents := AParents;
  Result.Node.Op := AOp;
end;

{ TTensor }

function TTensor.Rows: Integer;
begin
  Result := Node.Rows;
end;

function TTensor.Cols: Integer;
begin
  Result := Node.Cols;
end;

function TTensor.Data: TArray<Double>;
begin
  Result := Node.Data;
end;

function TTensor.Grad: TArray<Double>;
begin
  Result := Node.Grad;
end;

function TTensor.Get(R, C: Integer): Double;
begin
  Result := Node.Data[R * Node.Cols + C];
end;

procedure TTensor.Put(R, C: Integer; V: Double);
begin
  Node.Data[R * Node.Cols + C] := V;
end;

function TTensor.Item: Double;
begin
  Result := Node.Data[0];
end;

class function TTensor.Zeros(ARows, ACols: Integer): TTensor;
begin
  Result := NewTensor(ARows, ACols, [], '');
end;

class function TTensor.FromRows(const ARows: TArray<TVec>): TTensor;
begin
  Result := FromMatrix(TMatrix.FromRows(ARows));
end;

class function TTensor.FromMatrix(const M: TMatrix): TTensor;
begin
  Result := NewTensor(M.Rows, M.Cols, [], '');
  Result.Node.Data := Copy(M.Data);
end;

class function TTensor.Random(ARows, ACols: Integer; Rng: TRandom; Scale: Double): TTensor;
begin
  Result := NewTensor(ARows, ACols, [], '');
  for var I := 0 to High(Result.Node.Data) do
    Result.Node.Data[I] := Rng.Uniform(-Scale, Scale);
end;

function TTensor.ToMatrix: TMatrix;
begin
  Result := TMatrix.Create(Node.Rows, Node.Cols);
  Result.Data := Copy(Node.Data);
end;

// Los bucles van en procedimientos aparte, sin métodos anónimos: las variables que captura un
// método anónimo viven en un entorno y leerlas dentro de un bucle es más lento.

/// C (N x M) := A (N x K) · B (K x M)
procedure MatMulForward(const A, B: TArray<Double>; var C: TArray<Double>; N, K, M: Integer);
begin
  // C[i, j] = Σ_k A[i, k] · B[k, j]; el orden i, k, j recorre B y C fila por fila
  for var I := 0 to N - 1 do
    for var KK := 0 to K - 1 do
    begin
      var AIK := A[I * K + KK];
      if AIK <> 0 then
      begin
        var RowC := I * M;
        var RowB := KK * M;
        for var J := 0 to M - 1 do
          C[RowC + J] := C[RowC + J] + AIK * B[RowB + J];
      end;
    end;
end;

/// GA += G · Bᵀ   y   GB += Aᵀ · G
procedure MatMulBackward(const A, B, G: TArray<Double>; var GA, GB: TArray<Double>; N, K, M: Integer);
begin
  for var I := 0 to N - 1 do
    for var KK := 0 to K - 1 do
    begin
      var RowG := I * M;
      var RowB := KK * M;
      var AIK := A[I * K + KK];
      var S := 0.0;
      for var J := 0 to M - 1 do
      begin
        var GIJ := G[RowG + J];
        S := S + GIJ * B[RowB + J];
        GB[RowB + J] := GB[RowB + J] + AIK * GIJ;
      end;
      GA[I * K + KK] := GA[I * K + KK] + S;
    end;
end;

procedure GatherBackward(const G: TArray<Double>; const Ids: TArray<Integer>; var GA: TArray<Double>; M: Integer);
begin
  for var I := 0 to High(Ids) do
  begin
    var Row := Ids[I] * M;
    for var J := 0 to M - 1 do
      GA[Row + J] := GA[Row + J] + G[I * M + J];
  end;
end;

procedure SoftmaxForward(const X: TArray<Double>; var Y: TArray<Double>; N, M: Integer; Causal: Boolean);
begin
  for var I := 0 to N - 1 do
  begin
    var Last := if Causal then Min(I, M - 1) else M - 1;
    var Mx := X[I * M];
    for var J := 1 to Last do
      if X[I * M + J] > Mx then
        Mx := X[I * M + J];
    var S := 0.0;
    for var J := 0 to M - 1 do
    begin
      if J <= Last then
        Y[I * M + J] := System.Exp(X[I * M + J] - Mx)
      else
        Y[I * M + J] := 0;
      S := S + Y[I * M + J];
    end;
    for var J := 0 to Last do
      Y[I * M + J] := Y[I * M + J] / S;
  end;
end;

procedure SoftmaxBackward(const Y, G: TArray<Double>; var GA: TArray<Double>; N, M: Integer);
begin
  for var I := 0 to N - 1 do
  begin
    var Dot := 0.0;
    for var J := 0 to M - 1 do
      Dot := Dot + G[I * M + J] * Y[I * M + J];
    for var J := 0 to M - 1 do
      GA[I * M + J] := GA[I * M + J] + Y[I * M + J] * (G[I * M + J] - Dot);
  end;
end;

function TTensor.MatMul(const B: TTensor): TTensor;
begin
  var NA := Node;
  var NB := B.Node;
  if NA.Cols <> NB.Rows then
    raise EArgumentException.CreateFmt('MatMul: no se puede multiplicar %dx%d por %dx%d', [NA.Rows, NA.Cols, NB.Rows, NB.Cols]);
  Result := NewTensor(NA.Rows, NB.Cols, [NA, NB], 'matmul');
  var C := Result.Node.Data;
  MatMulForward(NA.Data, NB.Data, C, NA.Rows, NA.Cols, NB.Cols);
  Result.Node.Data := C;
  // hacia atrás: dA = dC · Bᵀ   y   dB = Aᵀ · dC
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      var GB := NB.Grad;
      MatMulBackward(NA.Data, NB.Data, R.Grad, GA, GB, NA.Rows, NA.Cols, NB.Cols);
      NA.Grad := GA;
      NB.Grad := GB;
    end;
end;

class operator TTensor.Add(const A, B: TTensor): TTensor;
begin
  var NA := A.Node;
  var NB := B.Node;
  var Broadcast := (NB.Rows = 1) and (NA.Rows > 1) and (NB.Cols = NA.Cols);
  if not Broadcast and ((NA.Rows <> NB.Rows) or (NA.Cols <> NB.Cols)) then
    raise EArgumentException.CreateFmt('no se pueden sumar %dx%d y %dx%d', [NA.Rows, NA.Cols, NB.Rows, NB.Cols]);
  Result := NewTensor(NA.Rows, NA.Cols, [NA, NB], '+');
  var C := Result.Node.Data;
  var M := NA.Cols;
  for var I := 0 to High(C) do
    C[I] := NA.Data[I] + (if Broadcast then NB.Data[I mod M] else NB.Data[I]);
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      NA.AddGrad(R.Grad);
      if Broadcast then
      begin
        // el sesgo se sumó a cada fila: le llega la suma de los gradientes de todas las filas
        var GB := NB.Grad;
        for var I := 0 to High(R.Grad) do
          GB[I mod M] := GB[I mod M] + R.Grad[I];
        NB.Grad := GB;
      end
      else
        NB.AddGrad(R.Grad);
    end;
end;

class operator TTensor.Subtract(const A, B: TTensor): TTensor;
begin
  Result := A + (-1.0) * B;
end;

class operator TTensor.Multiply(const A, B: TTensor): TTensor;
begin
  var NA := A.Node;
  var NB := B.Node;
  if (NA.Rows <> NB.Rows) or (NA.Cols <> NB.Cols) then
    raise EArgumentException.CreateFmt('no se pueden multiplicar elemento a elemento %dx%d y %dx%d',
      [NA.Rows, NA.Cols, NB.Rows, NB.Cols]);
  Result := NewTensor(NA.Rows, NA.Cols, [NA, NB], '*');
  var C := Result.Node.Data;
  for var I := 0 to High(C) do
    C[I] := NA.Data[I] * NB.Data[I];
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      var GB := NB.Grad;
      for var I := 0 to High(R.Grad) do
      begin
        GA[I] := GA[I] + NB.Data[I] * R.Grad[I];
        GB[I] := GB[I] + NA.Data[I] * R.Grad[I];
      end;
      NA.Grad := GA;
      NB.Grad := GB;
    end;
end;

class operator TTensor.Multiply(K: Double; const A: TTensor): TTensor;
begin
  var NA := A.Node;
  Result := NewTensor(NA.Rows, NA.Cols, [NA], 'k*');
  var C := Result.Node.Data;
  for var I := 0 to High(C) do
    C[I] := K * NA.Data[I];
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to High(R.Grad) do
        GA[I] := GA[I] + K * R.Grad[I];
      NA.Grad := GA;
    end;
end;

function TTensor.Gather(const Ids: TArray<Integer>): TTensor;
begin
  var NA := Node;
  var M := NA.Cols;
  Result := NewTensor(Length(Ids), M, [NA], 'gather');
  var C := Result.Node.Data;
  for var I := 0 to High(Ids) do
    for var J := 0 to M - 1 do
      C[I * M + J] := NA.Data[Ids[I] * M + J];
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      GatherBackward(R.Grad, Ids, GA, M);
      NA.Grad := GA;
    end;
end;

function TTensor.Transpose: TTensor;
begin
  var NA := Node;
  var N := NA.Rows;
  var M := NA.Cols;
  Result := NewTensor(M, N, [NA], 'transpose');
  var C := Result.Node.Data;
  for var I := 0 to N - 1 do
    for var J := 0 to M - 1 do
      C[J * N + I] := NA.Data[I * M + J];
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to N - 1 do
        for var J := 0 to M - 1 do
          GA[I * M + J] := GA[I * M + J] + R.Grad[J * N + I];
      NA.Grad := GA;
    end;
end;

function TTensor.SoftmaxRows(Causal: Boolean): TTensor;
begin
  var NA := Node;
  var N := NA.Rows;
  var M := NA.Cols;
  Result := NewTensor(N, M, [NA], 'softmax');
  var Y := Result.Node.Data;
  SoftmaxForward(NA.Data, Y, N, M, Causal);
  Result.Node.Data := Y;
  // dx = y · (g − Σ g·y) en cada fila
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      SoftmaxBackward(R.Data, R.Grad, GA, N, M);
      NA.Grad := GA;
    end;
end;

function TTensor.Tanh: TTensor;
begin
  var NA := Node;
  Result := NewTensor(NA.Rows, NA.Cols, [NA], 'tanh');
  var C := Result.Node.Data;
  for var I := 0 to High(C) do
  begin
    var E2 := System.Exp(2 * Max(-20.0, Min(20.0, NA.Data[I])));
    C[I] := (E2 - 1) / (E2 + 1);
  end;
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to High(R.Grad) do
        GA[I] := GA[I] + (1 - R.Data[I] * R.Data[I]) * R.Grad[I];
      NA.Grad := GA;
    end;
end;

function TTensor.Sigmoid: TTensor;
begin
  var NA := Node;
  Result := NewTensor(NA.Rows, NA.Cols, [NA], 'sigmoid');
  var C := Result.Node.Data;
  for var I := 0 to High(C) do
    C[I] := 1 / (1 + System.Exp(-Max(-40.0, Min(40.0, NA.Data[I]))));
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to High(R.Grad) do
        GA[I] := GA[I] + R.Data[I] * (1 - R.Data[I]) * R.Grad[I];
      NA.Grad := GA;
    end;
end;

function TTensor.Relu: TTensor;
begin
  var NA := Node;
  Result := NewTensor(NA.Rows, NA.Cols, [NA], 'relu');
  var C := Result.Node.Data;
  for var I := 0 to High(C) do
    C[I] := if NA.Data[I] > 0 then NA.Data[I] else 0;
  Result.Node.Data := C;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to High(R.Grad) do
        if NA.Data[I] > 0 then
          GA[I] := GA[I] + R.Grad[I];
      NA.Grad := GA;
    end;
end;

function TTensor.Sum: TTensor;
begin
  var NA := Node;
  Result := NewTensor(1, 1, [NA], 'sum');
  var S := 0.0;
  for var X in NA.Data do
    S := S + X;
  Result.Node.Data[0] := S;
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var GA := NA.Grad;
      for var I := 0 to High(GA) do
        GA[I] := GA[I] + R.Grad[0];
      NA.Grad := GA;
    end;
end;

function TTensor.Mean: TTensor;
begin
  Result := (1.0 / Length(Node.Data)) * Sum;
end;

procedure TTensor.Backward;
var
  Order: TList<TTensorNode>;
  Seen: TDictionary<TTensorNode, Boolean>;

  procedure Visit(N: TTensorNode);
  begin
    if Seen.ContainsKey(N) then
      Exit;
    Seen.Add(N, True);
    for var P in N.Parents do
      Visit(P);
    Order.Add(N);
  end;

begin
  if Length(Node.Data) <> 1 then
    raise EArgumentException.CreateFmt('Backward empieza en una pérdida de 1x1, no en %dx%d', [Node.Rows, Node.Cols]);
  Order := TList<TTensorNode>.Create;
  Seen := TDictionary<TTensorNode, Boolean>.Create;
  try
    Visit(Node);
    Node.Grad[0] := 1;
    for var I := Order.Count - 1 downto 0 do
      if Assigned(Order[I].BackStep) then
        Order[I].BackStep(Order[I]);
  finally
    Order.Free;
    Seen.Free;
  end;
end;

procedure TTensor.ZeroGrad;
begin
  var G := Node.Grad;
  for var I := 0 to High(G) do
    G[I] := 0;
  Node.Grad := G;
end;

function TTensor.ToString(Decimals: Integer): string;
begin
  Result := ToMatrix.ToString(Decimals);
end;

function MSE(const Pred, Target: TTensor): TTensor;
begin
  var D := Pred - Target;
  Result := (D * D).Mean;
end;

function CrossEntropy(const Logits: TTensor; const Labels: TArray<Integer>): TTensor;
begin
  var NL := Logits.Node;
  var N := NL.Rows;
  var M := NL.Cols;
  if Length(Labels) <> N then
    raise EArgumentException.CreateFmt('CrossEntropy: %d filas y %d clases correctas', [N, Length(Labels)]);
  // softmax estable por filas, guardada para el paso hacia atrás
  var P: TArray<Double>;
  SetLength(P, N * M);
  var Loss := 0.0;
  for var I := 0 to N - 1 do
  begin
    var Mx := NL.Data[I * M];
    for var J := 1 to M - 1 do
      if NL.Data[I * M + J] > Mx then
        Mx := NL.Data[I * M + J];
    var S := 0.0;
    for var J := 0 to M - 1 do
    begin
      P[I * M + J] := System.Exp(NL.Data[I * M + J] - Mx);
      S := S + P[I * M + J];
    end;
    for var J := 0 to M - 1 do
      P[I * M + J] := P[I * M + J] / S;
    Loss := Loss - System.Ln(Max(P[I * M + Labels[I]], 1e-15));
  end;
  Result := NewTensor(1, 1, [NL], 'crossentropy');
  Result.Node.Data[0] := Loss / N;
  // la derivada de softmax + entropía cruzada es sencilla: (p - 1 en la clase correcta) / N
  Result.Node.BackStep := procedure(R: TTensorNode)
    begin
      var G := NL.Grad;
      for var I := 0 to N - 1 do
        for var J := 0 to M - 1 do
          G[I * M + J] := G[I * M + J] + R.Grad[0] * (P[I * M + J] - (if J = Labels[I] then 1 else 0)) / N;
      NL.Grad := G;
    end;
end;

function Softmax(const Logits: TTensor): TMatrix;
begin
  var N := Logits.Rows;
  var M := Logits.Cols;
  Result := TMatrix.Create(N, M);
  for var I := 0 to N - 1 do
  begin
    var Mx := Logits.Get(I, 0);
    for var J := 1 to M - 1 do
      Mx := Max(Mx, Logits.Get(I, J));
    var S := 0.0;
    for var J := 0 to M - 1 do
    begin
      Result[I, J] := System.Exp(Logits.Get(I, J) - Mx);
      S := S + Result[I, J];
    end;
    for var J := 0 to M - 1 do
      Result[I, J] := Result[I, J] / S;
  end;
end;

function ArgMaxRows(const T: TTensor): TArray<Integer>;
begin
  SetLength(Result, T.Rows);
  for var I := 0 to T.Rows - 1 do
  begin
    var Best := 0;
    for var J := 1 to T.Cols - 1 do
      if T.Get(I, J) > T.Get(I, Best) then
        Best := J;
    Result[I] := Best;
  end;
end;

end.
