// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Un tablero terminado
procedure TestTerminado;
begin
  Assert.Equal(1, Minimax('XXX' + 'OO.' + '...', 'O'), 'X ya ganó: +1');
  Assert.Equal(-1, Minimax('XX.' + 'OOO' + 'X..', 'X'), 'O ya ganó: -1');
  Assert.Equal(0, Minimax('XOX' + 'XOO' + 'OXX', 'O'), 'lleno y sin ganador: 0');
end;

/// Ganar en una jugada
[Hint('Si le toca a X, prueba cada casilla libre con Minimax(Jugar(T, I, ''X''), ''O'') y quédate con el mayor.')]
procedure TestGanarYa;
begin
  Assert.Equal(1, Minimax('XX.' + 'OO.' + '...', 'X'), 'X gana jugando en la casilla 2');
  Assert.Equal(2, MejorJugada('XX.' + 'OO.' + '...', 'X'));
end;

/// Tapar al rival
[Hint('Cuando le toca a O, O se queda con el MENOR puntaje.')]
procedure TestTapar;
begin
  // X amenaza la fila de arriba; O no puede ganar ya: la única jugada que no pierde es tapar en la casilla 2
  Assert.Equal(2, MejorJugada('XX.' + 'OOX' + '...', 'O'));
  Assert.Equal(0, Minimax('XX.' + 'OOX' + '...', 'O'), 'tapando, empatan');
end;

/// Jugar perfecto desde la mitad de la partida
procedure TestMitad;
begin
  Assert.Equal(0, Minimax('X..' + '.O.' + '...', 'X'), 'X en una esquina y O al centro: empatan');
  Assert.Equal(1, Minimax('XO.' + '.X.' + '...', 'O'), 'O jugó al lado y X ya no se puede frenar');
  Assert.Equal(3, MejorJugada('XO.' + '.X.' + '..O', 'X'), 'X arma dos amenazas a la vez jugando en la casilla 3');
end;
