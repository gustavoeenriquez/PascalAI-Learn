// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Un tablero terminado
procedure TestTerminado;
begin
  Assert.Equal(1, AlfaBeta('XXX' + 'OO.' + '...', 'O', -2, 2));
  Assert.Equal(0, AlfaBeta('XOX' + 'XOO' + 'OXX', 'O', -2, 2));
end;

/// El mismo valor que Minimax
[Hint('Con turno X devuelve Alfa al final (el mejor valor que encontró); con turno O, Beta.')]
procedure TestMismoValor;
begin
  for var T in ['X..' + '.O.' + '...', 'XO.' + '.X.' + '...', 'XX.' + 'OOX' + '...', 'O..' + '...' + '..X'] do
  begin
    var Turno := if T.CountChar('X') > T.CountChar('O') then 'O' else 'X';
    Assert.Equal(Minimax(T, Turno), AlfaBeta(T, Turno, -2, 2), 'el tablero ' + T);
  end;
end;

/// Poda: revisa muchos menos nodos
[Hint('¿Cortas el for cuando Alfa >= Beta? Usa Break.')]
procedure TestPoda;
begin
  Nodos := 0;
  Minimax('X........', 'O');
  var ConMinimax := Nodos;
  Nodos := 0;
  Assert.Equal(0, AlfaBeta('X........', 'O', -2, 2));
  Assert.True(Nodos * 5 < ConMinimax,
    Format('alfa-beta revisó %d nodos y Minimax %d: tiene que revisar al menos 5 veces menos', [Nodos, ConMinimax]));
end;
