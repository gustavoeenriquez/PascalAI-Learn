// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La regla de Q-learning
[Hint('Si Termino, el objetivo es solo Premio. Si no, Premio + Gamma * Q[Siguiente][Mejor(Siguiente)]. Después Q := Q + Alfa * (objetivo - Q).')]
procedure TestAprender;
begin
  Reiniciar(TGridWorld.Create(TGridWorld.Classic));
  Q[5] := [0, 2, 0, 0];
  Aprender(4, 3, -1, 5, False);
  // objetivo = -1 + 0.95 · 2 = 0.9;  Q = 0 + 0.5 · (0.9 - 0) = 0.45
  Assert.True(Abs(Q[4][3] - 0.45) < 1e-12, Format('Q[4][3] tenía que quedar en 0.45 y quedó en %g', [Q[4][3]]));
  Aprender(4, 3, 10, 5, True);
  // terminó: objetivo = 10;  Q = 0.45 + 0.5 · (10 - 0.45) = 5.225
  Assert.True(Abs(Q[4][3] - 5.225) < 1e-12, Format('al terminar no se mira el siguiente: quedó en %g', [Q[4][3]]));
end;

/// Explorar y explotar
procedure TestElegir;
begin
  Reiniciar(TGridWorld.Create(TGridWorld.Classic));
  Q[7] := [0, 0, 5, 0];
  Epsilon := 0;
  Assert.Equal(2, Elegir(7), 'con ε = 0 siempre la mejor');
  Epsilon := 1;
  var Distintas := 0;
  for var I := 1 to 50 do
    if Elegir(7) <> 2 then
      Inc(Distintas);
  Assert.True(Distintas > 20, 'con ε = 1 elige al azar');
end;

/// Aprende a llegar a la meta
procedure TestAprende;
begin
  var Mundo := TGridWorld.Create(TGridWorld.Classic);
  Reiniciar(Mundo);
  for var E := 1 to 300 do
    Episodio(Mundo);
  Epsilon := 0;
  Assert.True(Episodio(Mundo) >= 0, 'sin explorar llega a la meta sin pasar por la trampa');
end;
