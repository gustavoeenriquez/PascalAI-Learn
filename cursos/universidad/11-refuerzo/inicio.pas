uses
  SysUtils, Pai.Learn.Random, Pai.Learn.RL;

const
  Flechas: array[0..3] of string = ('↑', '↓', '←', '→');

var
  Q: TArray<TArray<Double>>;     // Q[estado][acción], 4 acciones: arriba, abajo, izquierda, derecha
  Azar: TRandom;
  Alfa, Gamma, Epsilon: Double;

/// La acción con mayor Q en Estado (con empate, la primera).
function Mejor(Estado: Integer): Integer;
begin
  Result := 0;
  for var A := 1 to 3 do
    if Q[Estado][A] > Q[Estado][Result] then
      Result := A;
end;

/// ε-codicioso: con probabilidad Epsilon una acción al azar (Azar.NextInt(4)); si no, Mejor(Estado).
function Elegir(Estado: Integer): Integer;
begin
  Todo('compara Azar.NextDouble con Epsilon');
end;

/// La regla de Q-learning para una transición.
procedure Aprender(Estado, Accion: Integer; Premio: Double; Siguiente: Integer; Termino: Boolean);
begin
  Todo('objetivo := Premio (+ Gamma · Q[Siguiente][Mejor(Siguiente)] si no terminó) y mueve Q[Estado][Accion] hacia él');
end;

/// Prepara la tabla en cero para un mundo.
procedure Reiniciar(Mundo: TGridWorld);
begin
  SetLength(Q, Mundo.StateCount);
  for var S := 0 to High(Q) do
    Q[S] := [0, 0, 0, 0];
  Azar := TRandom.Create(1);
  Alfa := 0.5;
  Gamma := 0.95;
  Epsilon := 0.1;
end;

/// Un episodio: desde la salida hasta terminar (o 200 pasos). Devuelve el premio total.
function Episodio(Mundo: TGridWorld): Double;
begin
  var S := Mundo.Start;
  Result := 0;
  for var K := 1 to 200 do
  begin
    var A := Elegir(S);
    var Sig: Integer;
    var Premio: Double;
    var Fin: Boolean;
    Mundo.Step(S, TMove(A), Sig, Premio, Fin);
    Aprender(S, A, Premio, Sig, Fin);
    Result := Result + Premio;
    S := Sig;
    if Fin then
      Break;
  end;
end;

begin
  var Mundo := TGridWorld.Create(TGridWorld.Classic);
  Reiniciar(Mundo);
  for var E := 1 to 300 do
  begin
    var P := Episodio(Mundo);
    if E mod 50 = 0 then
      WriteLn('episodio ', E, ': premio ', P:0:0);
  end;
  // las flechas: la mejor acción de cada casilla
  for var R := 0 to Mundo.RowCount - 1 do
  begin
    for var C := 0 to Mundo.ColCount - 1 do
    begin
      var S := R * Mundo.ColCount + C;
      if CharInSet(Mundo.CellAt(S), ['.', 'S']) then Write(Flechas[Mejor(S)]) else Write(Mundo.CellAt(S));
    end;
    WriteLn;
  end;
end.
