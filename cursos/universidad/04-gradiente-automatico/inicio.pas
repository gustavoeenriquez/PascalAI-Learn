uses
  SysUtils, Generics.Collections;

type
  TNodo = class;
  TPasoAtras = reference to procedure(R: TNodo);

  TNodo = class
  public
    Valor, Grad: Double;
    Padres: TArray<TNodo>;
    PasoAtras: TPasoAtras;     // reparte R.Grad hacia los padres (nil en una hoja)
    constructor Create(AValor: Double; const APadres: TArray<TNodo>);
  end;

constructor TNodo.Create(AValor: Double; const APadres: TArray<TNodo>);
begin
  Valor := AValor;
  Padres := APadres;
end;

function Hoja(V: Double): TNodo;
begin
  Result := TNodo.Create(V, []);
end;

/// a + b: a cada uno le llega el mismo gradiente (el ejemplo).
function Add(A, B: TNodo): TNodo;
begin
  Result := TNodo.Create(A.Valor + B.Valor, [A, B]);
  Result.PasoAtras := procedure(R: TNodo)
    begin
      A.Grad := A.Grad + R.Grad;
      B.Grad := B.Grad + R.Grad;
    end;
end;

/// a · b
function Mul(A, B: TNodo): TNodo;
begin
  Result := TNodo.Create(A.Valor * B.Valor, [A, B]);
  Result.PasoAtras := procedure(R: TNodo)
    begin
      Todo('a A le llega B.Valor · R.Grad; a B, A.Valor · R.Grad');
    end;
end;

/// tanh(a)
function Tanh(A: TNodo): TNodo;
begin
  var E2 := Exp(2 * A.Valor);
  Result := TNodo.Create((E2 - 1) / (E2 + 1), [A]);
  Result.PasoAtras := procedure(R: TNodo)
    begin
      Todo('a A le llega (1 − R.Valor²) · R.Grad');
    end;
end;

/// Pone en cada nodo del grafo de Y su gradiente dY/dnodo.
procedure Backward(Y: TNodo);
var
  Orden: TList<TNodo>;
  Vistos: TDictionary<TNodo, Boolean>;

  // agrega N a Orden después de todos sus padres
  procedure Visitar(N: TNodo);
  begin
    Todo('si no lo viste: márcalo, visita sus padres y agrégalo a Orden');
  end;

begin
  Orden := TList<TNodo>.Create;
  Vistos := TDictionary<TNodo, Boolean>.Create;
  Visitar(Y);
  Todo('Y.Grad := 1 y recorre Orden de atrás hacia adelante llamando a PasoAtras (si no es nil)');
end;

begin
  var X := Hoja(2.0);
  var W := Hoja(-0.5);
  var B := Hoja(0.3);
  var Y := Tanh(Add(Mul(X, W), B));
  Backward(Y);
  WriteLn('y = ', Y.Valor:0:4, '   dy/dw = ', W.Grad:0:4, '   dy/dx = ', X.Grad:0:4);
end.
