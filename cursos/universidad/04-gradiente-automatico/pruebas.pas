// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

procedure Cerca(Esperado, Obtenido: Double; const Que: string);
begin
  Assert.True(Abs(Esperado - Obtenido) < 1e-6, Format('%s: se esperaba %.6f y salió %.6f', [Que, Esperado, Obtenido]));
end;

/// El producto
[Hint('En el paso hacia atrás de Mul: A.Grad := A.Grad + B.Valor * R.Grad (y lo mismo para B).')]
procedure TestProducto;
begin
  var A := Hoja(3);
  var B := Hoja(-4);
  var Y := Mul(A, B);
  Y.Grad := 1;
  Y.PasoAtras(Y);
  Cerca(-4, A.Grad, 'd(a·b)/da');
  Cerca(3, B.Grad, 'd(a·b)/db');
end;

/// La tangente hiperbólica
procedure TestTanh;
begin
  var A := Hoja(0.5);
  var Y := Tanh(A);
  Y.Grad := 1;
  Y.PasoAtras(Y);
  Cerca(1 - Sqr(Y.Valor), A.Grad, 'd(tanh a)/da');
end;

/// El ejemplo de la lección, completo
[Hint('Backward: después de Visitar(Y), Y.Grad := 1 y for I := Orden.Count - 1 downto 0 llama Orden[I].PasoAtras.')]
procedure TestEjemplo;
begin
  var X := Hoja(2.0);
  var W := Hoja(-0.5);
  var B := Hoja(0.3);
  var Y := Tanh(Add(Mul(X, W), B));
  Backward(Y);
  Cerca(-0.6043677771, Y.Valor, 'y');
  Cerca(1.2694791800, W.Grad, 'dy/dw');
  Cerca(-0.3173697950, X.Grad, 'dy/dx');
  Cerca(0.6347395900, B.Grad, 'dy/db');
end;

/// Un nodo usado dos veces
[Hint('Si un nodo aparece por dos caminos, Visitar tiene que agregarlo una sola vez (Vistos) y los gradientes se suman (+).')]
procedure TestDosVeces;
begin
  // y = x·x + x  →  dy/dx = 2x + 1
  var X := Hoja(3.0);
  var Y := Add(Mul(X, X), X);
  Backward(Y);
  Cerca(7, X.Grad, 'd(x·x + x)/dx en x = 3');
end;
