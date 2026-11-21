// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

function Muestra(X, Y: Double): TSample;
begin
  Result.X := [X];
  Result.Y := Y;
end;

/// La pérdida
procedure TestPerdida;
begin
  var D: TArray<TSample> := [Muestra(0, 1), Muestra(1, 3)];
  Assert.True(Abs(Perdida(2, 1, D)) < 1e-12, 'la recta y = 2x + 1 pasa por los dos puntos: pérdida 0');
  Assert.True(Abs(Perdida(0, 0, D) - 5) < 1e-12, 'con w = 0, b = 0: (1² + 3²) / 2 = 5');
end;

/// El gradiente coincide con la pendiente medida
[Hint('No olvides el factor 2/n, y que la derivada respecto de w lleva el x de cada punto.')]
procedure TestGradiente;
begin
  var D := Puntos;
  var GW, GB: Double;
  Gradiente(1.5, -0.5, D, GW, GB);
  const H = 1e-6;
  var NW := (Perdida(1.5 + H, -0.5, D) - Perdida(1.5 - H, -0.5, D)) / (2 * H);
  var NB := (Perdida(1.5, -0.5 + H, D) - Perdida(1.5, -0.5 - H, D)) / (2 * H);
  Assert.True(Abs(GW - NW) < 1e-5, Format('dL/dw: tu gradiente da %.6f y la pendiente medida %.6f', [GW, NW]));
  Assert.True(Abs(GB - NB) < 1e-5, Format('dL/db: tu gradiente da %.6f y la pendiente medida %.6f', [GB, NB]));
end;

/// El entrenamiento encuentra la recta
[Hint('En cada paso: W := W - Tasa * GW y B := B - Tasa * GB (en contra del gradiente).')]
procedure TestEntrenar;
begin
  var W, B: Double;
  Entrenar(Puntos, 0.5, 2000, W, B);
  Assert.True(Abs(W - 3) < 0.15, Format('w quedó en %.3f; tiene que quedar cerca de 3', [W]));
  Assert.True(Abs(B - 2) < 0.1, Format('b quedó en %.3f; tiene que quedar cerca de 2', [B]));
  Assert.True(Perdida(W, B, Puntos) < 0.02, 'la pérdida final tiene que ser chica (el ruido)');
end;
