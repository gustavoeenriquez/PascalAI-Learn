uses
  SysUtils;

const
  Lineas: array[0..7, 0..2] of Integer = (
    (0, 1, 2), (3, 4, 5), (6, 7, 8),     // filas
    (0, 3, 6), (1, 4, 7), (2, 5, 8),     // columnas
    (0, 4, 8), (2, 4, 6));               // diagonales

/// 'X' u 'O' si alguno tiene tres en línea; '.' si nadie.
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

function Lleno(const T: string): Boolean;
begin
  Result := not T.Contains('.');
end;

/// El tablero después de que Turno juega en la casilla I (0 a 8).
function Jugar(const T: string; I: Integer; Turno: Char): string;
begin
  Result := T;
  Result[I + 1] := Turno;
end;

function Otro(Turno: Char): Char;
begin
  if Turno = 'X' then Result := 'O' else Result := 'X';
end;

/// +1 si X gana jugando los dos perfecto, -1 si gana O, 0 si empatan. Turno: a quién le toca.
function Minimax(const T: string; Turno: Char): Integer;
begin
  Todo('si alguien ganó o está lleno, devuelve el puntaje; si no, prueba cada casilla libre');
end;

/// La casilla (0 a 8) donde le conviene jugar a Turno.
function MejorJugada(const T: string; Turno: Char): Integer;
begin
  Result := -1;
  var Mejor := 0;
  for var I := 0 to 8 do
    if T[I + 1] = '.' then
    begin
      var Valor := Minimax(Jugar(T, I, Turno), Otro(Turno));
      if (Result < 0) or ((Turno = 'X') and (Valor > Mejor)) or ((Turno = 'O') and (Valor < Mejor)) then
      begin
        Result := I;
        Mejor := Valor;
      end;
    end;
end;

begin
  var T := 'XO.' + '.X.' + 'O..';
  WriteLn('Le toca a X: le conviene la casilla ', MejorJugada(T, 'X'));
end.
