uses
  SysUtils;

const
  Lineas: array[0..7, 0..2] of Integer = ((0, 1, 2), (3, 4, 5), (6, 7, 8), (0, 3, 6), (1, 4, 7), (2, 5, 8),
    (0, 4, 8), (2, 4, 6));

var
  Nodos: Integer;    // cuántos tableros revisó la última búsqueda

function Ganador(const T: string): Char;
begin
  for var L := 0 to 7 do
  begin
    var C := T[Lineas[L, 0] + 1];
    if (C <> '.') and (T[Lineas[L, 1] + 1] = C) and (T[Lineas[L, 2] + 1] = C) then
      Exit(C);
  end;
  Result := '.';
end;

function Jugar(const T: string; I: Integer; Turno: Char): string;
begin
  Result := T;
  Result[I + 1] := Turno;
end;

/// +1 si ganó X, -1 si ganó O, 0 si empate; Terminado dice si la partida acabó.
function Puntaje(const T: string; out Terminado: Boolean): Integer;
begin
  Terminado := True;
  case Ganador(T) of
    'X': Exit(1);
    'O': Exit(-1);
  end;
  Terminado := not T.Contains('.');
  Result := 0;
end;

function Minimax(const T: string; Turno: Char): Integer;
var
  Fin: Boolean;
begin
  Inc(Nodos);
  Result := Puntaje(T, Fin);
  if Fin then
    Exit;
  Result := if Turno = 'X' then -2 else 2;
  for var I := 0 to 8 do
    if T[I + 1] = '.' then
    begin
      var V := Minimax(Jugar(T, I, Turno), if Turno = 'X' then 'O' else 'X');
      if (Turno = 'X') and (V > Result) then Result := V;
      if (Turno = 'O') and (V < Result) then Result := V;
    end;
end;

/// El mismo valor que Minimax, podando con Alfa y Beta. Suma 1 a Nodos en cada llamada.
function AlfaBeta(const T: string; Turno: Char; Alfa, Beta: Integer): Integer;
begin
  Inc(Nodos);
  Todo('el pseudocódigo del LEEME.md');
end;

begin
  Nodos := 0;
  WriteLn('Minimax:   ', Minimax('.........', 'X'), '  (', Nodos, ' nodos)');
  Nodos := 0;
  WriteLn('Alfa-beta: ', AlfaBeta('.........', 'X', -2, 2), '  (', Nodos, ' nodos)');
end.
