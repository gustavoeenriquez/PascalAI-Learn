unit Pai.Learn.Grad;

// Gradiente automático (diferenciación en modo reverso) sobre números sueltos.
//
// Cada operación con un TScalar crea un nodo que recuerda de qué nodos salió y cómo repartir el
// gradiente hacia ellos. Backward recorre ese grafo al revés aplicando la regla de la cadena:
// al final, cada nodo sabe cuánto cambia el resultado si él cambia un poquito (su Grad).
//
//   var X := Scalar(2.0);
//   var W := Scalar(-0.5);
//   var Y := (X * W + 0.3).Tanh;
//   Y.Backward;
//   WriteLn(W.Grad:0:4);          // 1.2695: dy/dw
//
// Es la idea que hay debajo de cualquier red neuronal. Las redes de verdad hacen lo mismo con
// matrices enteras en vez de números sueltos, para ir más rápido.
//
// Los nodos no se liberan uno por uno: el motor los libera al terminar el programa. Para los
// tamaños de las lecciones no es un problema.

interface

uses
  SysUtils, Math, Generics.Collections;

type
  TNode = class;

  /// Cómo un nodo reparte su gradiente hacia los nodos de los que salió.
  TBackStep = reference to procedure(Node: TNode);

  TNode = class
  public
    Value: Double;
    Grad: Double;
    Parents: TArray<TNode>;
    Op: string;               // '+', '*', 'tanh'... (para dibujar el grafo)
    Name: string;             // un nombre opcional ('w1', 'b')
    BackStep: TBackStep;
  end;

  TScalar = record
    Node: TNode;
    function Value: Double;
    function Grad: Double;
    /// Pone un nombre al nodo (aparece al dibujar el grafo). Devuelve el mismo escalar.
    function Named(const AName: string): TScalar;

    class operator Implicit(V: Double): TScalar;
    class operator Add(const A, B: TScalar): TScalar;
    class operator Subtract(const A, B: TScalar): TScalar;
    class operator Multiply(const A, B: TScalar): TScalar;
    class operator Divide(const A, B: TScalar): TScalar;
    class operator Negative(const A: TScalar): TScalar;

    function Pow(N: Double): TScalar;
    function Exp: TScalar;
    function Log: TScalar;
    function Tanh: TScalar;
    function Sigmoid: TScalar;
    function Relu: TScalar;

    /// Calcula el gradiente de este escalar respecto de todos los nodos de los que depende.
    procedure Backward;
    /// Pone en cero el gradiente de este nodo (antes de volver a calcular).
    procedure ZeroGrad;
    /// Ajusta el valor un paso en contra del gradiente: Value := Value - Rate * Grad.
    procedure Step(Rate: Double);
  end;

/// Un escalar nuevo, que no depende de nadie (una entrada o un parámetro).
function Scalar(V: Double): TScalar; overload;
function Scalar(V: Double; const AName: string): TScalar; overload;

/// Los nodos del grafo de Y, en orden: cada uno aparece después de los nodos de los que salió.
function TopologicalOrder(const Y: TScalar): TArray<TNode>;

implementation

function NewNode(AValue: Double; const AParents: TArray<TNode>; const AOp: string): TScalar;
begin
  Result.Node := TNode.Create;
  Result.Node.Value := AValue;
  Result.Node.Parents := AParents;
  Result.Node.Op := AOp;
end;

function Scalar(V: Double): TScalar;
begin
  Result := NewNode(V, [], '');
end;

function Scalar(V: Double; const AName: string): TScalar;
begin
  Result := NewNode(V, [], '');
  Result.Node.Name := AName;
end;

function TScalar.Value: Double;
begin
  Result := Node.Value;
end;

function TScalar.Grad: Double;
begin
  Result := Node.Grad;
end;

function TScalar.Named(const AName: string): TScalar;
begin
  Node.Name := AName;
  Result := Self;
end;

class operator TScalar.Implicit(V: Double): TScalar;
begin
  Result := Scalar(V);
end;

// Cada operación: (1) calcula el valor hacia adelante y (2) deja escrito cómo devolver el
// gradiente hacia atrás. R es el nodo resultado: R.Grad es lo que le llegó desde arriba.

class operator TScalar.Add(const A, B: TScalar): TScalar;
begin
  Result := NewNode(A.Value + B.Value, [A.Node, B.Node], '+');
  var NA := A.Node;
  var NB := B.Node;
  // d(a + b)/da = 1   y   d(a + b)/db = 1
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NA.Grad := NA.Grad + R.Grad;
      NB.Grad := NB.Grad + R.Grad;
    end;
end;

class operator TScalar.Subtract(const A, B: TScalar): TScalar;
begin
  Result := NewNode(A.Value - B.Value, [A.Node, B.Node], '-');
  var NA := A.Node;
  var NB := B.Node;
  // d(a - b)/da = 1   y   d(a - b)/db = -1
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NA.Grad := NA.Grad + R.Grad;
      NB.Grad := NB.Grad - R.Grad;
    end;
end;

class operator TScalar.Multiply(const A, B: TScalar): TScalar;
begin
  Result := NewNode(A.Value * B.Value, [A.Node, B.Node], '*');
  var NA := A.Node;
  var NB := B.Node;
  // d(a * b)/da = b   y   d(a * b)/db = a
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NA.Grad := NA.Grad + NB.Value * R.Grad;
      NB.Grad := NB.Grad + NA.Value * R.Grad;
    end;
end;

class operator TScalar.Divide(const A, B: TScalar): TScalar;
begin
  Result := NewNode(A.Value / B.Value, [A.Node, B.Node], '/');
  var NA := A.Node;
  var NB := B.Node;
  // d(a / b)/da = 1 / b   y   d(a / b)/db = -a / b²
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NA.Grad := NA.Grad + R.Grad / NB.Value;
      NB.Grad := NB.Grad - NA.Value / (NB.Value * NB.Value) * R.Grad;
    end;
end;

class operator TScalar.Negative(const A: TScalar): TScalar;
begin
  Result := NewNode(-A.Value, [A.Node], 'neg');
  var NA := A.Node;
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NA.Grad := NA.Grad - R.Grad;
    end;
end;

function TScalar.Pow(N: Double): TScalar;
begin
  Result := NewNode(Power(Node.Value, N), [Node], '^');
  var NX := Node;
  // d(x^n)/dx = n * x^(n-1)
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NX.Grad := NX.Grad + N * Power(NX.Value, N - 1) * R.Grad;
    end;
end;

function TScalar.Exp: TScalar;
begin
  Result := NewNode(System.Exp(Node.Value), [Node], 'exp');
  var NX := Node;
  // d(e^x)/dx = e^x
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NX.Grad := NX.Grad + R.Value * R.Grad;
    end;
end;

function TScalar.Log: TScalar;
begin
  Result := NewNode(System.Ln(Node.Value), [Node], 'log');
  var NX := Node;
  // d(ln x)/dx = 1 / x
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NX.Grad := NX.Grad + R.Grad / NX.Value;
    end;
end;

function TScalar.Tanh: TScalar;
begin
  var E2 := System.Exp(2 * Node.Value);
  Result := NewNode((E2 - 1) / (E2 + 1), [Node], 'tanh');
  var NX := Node;
  // d(tanh x)/dx = 1 - tanh² x
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NX.Grad := NX.Grad + (1 - R.Value * R.Value) * R.Grad;
    end;
end;

function TScalar.Sigmoid: TScalar;
begin
  Result := NewNode(1 / (1 + System.Exp(-Node.Value)), [Node], 'sigmoid');
  var NX := Node;
  // d(σ(x))/dx = σ(x) * (1 - σ(x))
  Result.Node.BackStep := procedure(R: TNode)
    begin
      NX.Grad := NX.Grad + R.Value * (1 - R.Value) * R.Grad;
    end;
end;

function TScalar.Relu: TScalar;
begin
  Result := NewNode(if Node.Value > 0 then Node.Value else 0, [Node], 'relu');
  var NX := Node;
  // d(relu x)/dx = 1 si x > 0; si no, 0
  Result.Node.BackStep := procedure(R: TNode)
    begin
      if NX.Value > 0 then
        NX.Grad := NX.Grad + R.Grad;
    end;
end;

function TopologicalOrder(const Y: TScalar): TArray<TNode>;
var
  Order: TList<TNode>;
  Seen: TDictionary<TNode, Boolean>;

  procedure Visit(N: TNode);
  begin
    if Seen.ContainsKey(N) then
      Exit;
    Seen.Add(N, True);
    for var P in N.Parents do
      Visit(P);
    Order.Add(N);              // después de todos sus padres
  end;

begin
  Order := TList<TNode>.Create;
  Seen := TDictionary<TNode, Boolean>.Create;
  try
    Visit(Y.Node);
    Result := Order.ToArray;
  finally
    Order.Free;
    Seen.Free;
  end;
end;

procedure TScalar.Backward;
begin
  var Order := TopologicalOrder(Self);
  // se empieza desde arriba: dY/dY = 1
  Node.Grad := 1;
  // y se baja en orden inverso, así cada nodo ya recibió todo su gradiente antes de repartirlo
  for var I := High(Order) downto 0 do
    if Assigned(Order[I].BackStep) then
      Order[I].BackStep(Order[I]);
end;

procedure TScalar.ZeroGrad;
begin
  Node.Grad := 0;
end;

procedure TScalar.Step(Rate: Double);
begin
  Node.Value := Node.Value - Rate * Node.Grad;
end;

end.
