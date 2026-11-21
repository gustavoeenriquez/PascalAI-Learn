unit Pai.Learn.RL;

// Aprendizaje por refuerzo: un agente que aprende probando, con premios y castigos. Q-learning
// (Watkins, 1989) en una cuadrícula: Q[estado, acción] estima cuánto premio total se consigue si en
// ese estado se hace esa acción y después se sigue bien.
//
//   Q[s, a] := Q[s, a] + Alfa · (premio + Gamma · max_a' Q[s', a'] − Q[s, a])
//
//   var Mundo := TGridWorld.Create(TGridWorld.Classic);
//   var Agente := TQLearner.Create(Mundo.StateCount, 4, Azar);
//   for var E := 1 to 300 do Agente.Episode(Mundo);
//   WriteLn(Mundo.PolicyToString(Agente));

interface

uses
  SysUtils, Math, Pai.Learn.Random;

type
  /// Las cuatro acciones: arriba, abajo, izquierda, derecha.
  TMove = (mvUp, mvDown, mvLeft, mvRight);

  /// Una cuadrícula: '.' libre, '#' pared, 'S' salida, 'G' meta (+10), 'X' trampa (−10). Cada paso
  /// cuesta −1, así que conviene llegar rápido. Chocar contra una pared deja al agente donde estaba.
  TGridWorld = class
  private
    FRows: TArray<string>;
    FStart: Integer;
  public
    constructor Create(const ARows: TArray<string>);
    class function Classic: TArray<string>; static;
    function RowCount: Integer;
    function ColCount: Integer;
    function StateCount: Integer;
    function Start: Integer;
    function CellAt(State: Integer): Char;
    /// Hace la acción: el estado siguiente, el premio y si el episodio terminó (meta o trampa).
    procedure Step(State: Integer; Move: TMove; out Next: Integer; out Reward: Double; out Done: Boolean);
  end;

  TQLearner = class
  private
    FRng: TRandom;
  public
    Q: TArray<TArray<Double>>;      // [estado][acción]
    Alpha, Gamma, Epsilon: Double;
    constructor Create(States, Actions: Integer; Rng: TRandom);
    /// La acción con mayor Q (con empate, la primera).
    function Best(State: Integer): Integer;
    /// Con probabilidad Epsilon, una acción al azar (explorar); si no, la mejor (explotar).
    function Choose(State: Integer): Integer;
    /// La regla de Q-learning para una transición.
    procedure Learn(State, Action: Integer; Reward: Double; Next: Integer; Done: Boolean);
    /// Un episodio completo (hasta terminar o MaxSteps pasos). Devuelve el premio total.
    function Episode(World: TGridWorld; MaxSteps: Integer = 200): Double;
  end;

/// La política como flechas sobre la cuadrícula.
function PolicyToString(World: TGridWorld; Agent: TQLearner): string;

implementation

{ TGridWorld }

constructor TGridWorld.Create(const ARows: TArray<string>);
begin
  FRows := ARows;
  FStart := -1;
  for var R := 0 to High(ARows) do
    for var C := 1 to Length(ARows[R]) do
      if ARows[R][C] = 'S' then
        FStart := R * Length(ARows[0]) + C - 1;
  if FStart < 0 then
    raise EArgumentException.Create('la cuadrícula no tiene salida (S)');
end;

class function TGridWorld.Classic: TArray<string>;
begin
  Result := [
    '#########',
    '#S...#..#',
    '#.##.#.G#',
    '#....X..#',
    '#.##....#',
    '#########'];
end;

function TGridWorld.RowCount: Integer;
begin
  Result := Length(FRows);
end;

function TGridWorld.ColCount: Integer;
begin
  Result := Length(FRows[0]);
end;

function TGridWorld.StateCount: Integer;
begin
  Result := RowCount * ColCount;
end;

function TGridWorld.Start: Integer;
begin
  Result := FStart;
end;

function TGridWorld.CellAt(State: Integer): Char;
begin
  Result := FRows[State div ColCount][State mod ColCount + 1];
end;

procedure TGridWorld.Step(State: Integer; Move: TMove; out Next: Integer; out Reward: Double; out Done: Boolean);
begin
  var R := State div ColCount;
  var C := State mod ColCount;
  case Move of
    mvUp: Dec(R);
    mvDown: Inc(R);
    mvLeft: Dec(C);
    mvRight: Inc(C);
  end;
  Next := R * ColCount + C;
  if (R < 0) or (R >= RowCount) or (C < 0) or (C >= ColCount) or (CellAt(Next) = '#') then
    Next := State;
  Reward := -1;
  Done := False;
  case CellAt(Next) of
    'G': begin Reward := 10; Done := True; end;
    'X': begin Reward := -10; Done := True; end;
  end;
end;

{ TQLearner }

constructor TQLearner.Create(States, Actions: Integer; Rng: TRandom);
begin
  FRng := Rng;
  SetLength(Q, States);
  for var S := 0 to States - 1 do
  begin
    SetLength(Q[S], Actions);
    for var A := 0 to Actions - 1 do
      Q[S][A] := 0;
  end;
  Alpha := 0.5;
  Gamma := 0.95;
  Epsilon := 0.1;
end;

function TQLearner.Best(State: Integer): Integer;
begin
  Result := 0;
  for var A := 1 to High(Q[State]) do
    if Q[State][A] > Q[State][Result] then
      Result := A;
end;

function TQLearner.Choose(State: Integer): Integer;
begin
  if FRng.NextDouble < Epsilon then
    Result := FRng.NextInt(Length(Q[State]))
  else
    Result := Best(State);
end;

procedure TQLearner.Learn(State, Action: Integer; Reward: Double; Next: Integer; Done: Boolean);
begin
  var Target := Reward;
  if not Done then
    Target := Target + Gamma * Q[Next][Best(Next)];
  Q[State][Action] := Q[State][Action] + Alpha * (Target - Q[State][Action]);
end;

function TQLearner.Episode(World: TGridWorld; MaxSteps: Integer): Double;
begin
  var S := World.Start;
  Result := 0;
  for var K := 1 to MaxSteps do
  begin
    var A := Choose(S);
    var Next: Integer;
    var R: Double;
    var Done: Boolean;
    World.Step(S, TMove(A), Next, R, Done);
    Learn(S, A, R, Next, Done);
    Result := Result + R;
    S := Next;
    if Done then
      Break;
  end;
end;

function PolicyToString(World: TGridWorld; Agent: TQLearner): string;
const
  Arrows: array[0..3] of string = ('↑', '↓', '←', '→');
begin
  Result := '';
  for var R := 0 to World.RowCount - 1 do
  begin
    for var C := 0 to World.ColCount - 1 do
    begin
      var S := R * World.ColCount + C;
      var Cell := World.CellAt(S);
      if (Cell = '.') or (Cell = 'S') then
        Result := Result + Arrows[Agent.Best(S)]
      else
        Result := Result + Cell;
    end;
    Result := Result + sLineBreak;
  end;
end;

end.
