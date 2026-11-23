unit Pai.Learn.Search;

// Laberintos en cuadrícula y las dos búsquedas de las lecciones: en anchura y A*.
//
// Un laberinto se escribe con texto: '#' es pared, '.' es pasillo, 'S' la salida y 'G' la meta.
//
//   var L := TMaze.Create(Mazes.Rooms);
//   var R := BreadthFirst(L);
//   WriteLn('revisó ', Length(R.Visited), ' casillas; el camino mide ', Length(R.Path) - 1, ' pasos');

interface

uses
  SysUtils, Generics.Collections;

type
  TCell = record
    Row, Col: Integer;
    constructor Create(ARow, ACol: Integer);
    class operator Equal(const A, B: TCell): Boolean;
    class operator NotEqual(const A, B: TCell): Boolean;
    function ToString: string;
  end;

  TMaze = class
  private
    FRows: TArray<string>;
    FStart, FGoal: TCell;
  public
    constructor Create(const ARows: TArray<string>);
    function RowCount: Integer;
    function ColCount: Integer;
    function IsWall(const C: TCell): Boolean;
    /// Las casillas vecinas (arriba, abajo, izquierda, derecha) que no son pared.
    function Neighbors(const C: TCell): TArray<TCell>;
    /// Reconstruye el camino desde la salida hasta Last siguiendo «de dónde vine» hacia atrás.
    function PathFrom(CameFrom: TDictionary<TCell, TCell>; const Last: TCell): TArray<TCell>;
    property Start: TCell read FStart;
    property Goal: TCell read FGoal;
  end;

  TSearchResult = record
    Path: TArray<TCell>;      // de la salida a la meta, las dos incluidas; vacío si no hay camino
    Visited: TArray<TCell>;   // en el orden en que se revisaron
  end;

  Mazes = class
  public
    /// Pasillos de un solo ancho (11 x 21): la lección 2.
    class function Corridors: TArray<string>; static;
    /// Salas abiertas con algunas paredes (11 x 21): la lección 3, donde A* se luce.
    class function Rooms: TArray<string>; static;
  end;

/// Distancia contando pasos en la cuadrícula, sin diagonales y sin mirar las paredes.
function Manhattan(const A, B: TCell): Integer;

/// Búsqueda en anchura: revisa primero todo lo que está a 1 paso, después a 2... Encuentra el
/// camino más corto, pero no sabe hacia dónde queda la meta.
function BreadthFirst(Maze: TMaze): TSearchResult;

/// A*: revisa primero la casilla con menor (pasos hechos + distancia estimada a la meta); si
/// empatan, la que está más cerca de la meta. Con Manhattan como estimación también encuentra el
/// camino más corto, y en espacios abiertos revisa muchas menos casillas.
function AStar(Maze: TMaze): TSearchResult;

/// Búsqueda en profundidad: sigue un pasillo hasta el fondo antes de volver atrás a probar otro.
/// Encuentra un camino (si lo hay), pero no siempre el más corto; usa poca memoria.
function DepthFirst(Maze: TMaze): TSearchResult;

type
  /// El tres en raya, para la búsqueda adversaria: 9 casillas (0..8, por filas) con 'X', 'O' o ' '.
  /// Juega X primero.
  TTicTacToe = record
    Cells: string;               // 9 caracteres
    class function Empty: TTicTacToe; static;
    class function FromText(const S: string): TTicTacToe; static;
    /// A quién le toca: 'X' si hay tantas X como O; si no, 'O'.
    function Turn: Char;
    /// 'X' u 'O' si alguien hizo tres en línea; ' ' si no.
    function Winner: Char;
    function Full: Boolean;
    /// Las casillas libres (si el juego no terminó).
    function Moves: TArray<Integer>;
    /// El tablero después de jugar en la casilla Cell quien tiene el turno.
    function Play(Cell: Integer): TTicTacToe;
    function ToString: string;
  end;

  TMinimaxResult = record
    Move: Integer;               // la mejor jugada para quien tiene el turno (-1 si el juego terminó)
    Value: Integer;              // +1 gana X, -1 gana O, 0 empate (con juego perfecto de los dos)
    Nodes: Integer;              // cuántos tableros revisó
  end;

/// Minimax: X busca el mayor valor y O el menor, suponiendo que el otro juega lo mejor posible. Con
/// Prune, la poda alfa-beta deja de revisar las jugadas que ya no pueden cambiar la decisión: el mismo
/// resultado revisando muchos menos tableros (compare Nodes).
function Minimax(const Board: TTicTacToe; Prune: Boolean = True): TMinimaxResult;

implementation

constructor TCell.Create(ARow, ACol: Integer);
begin
  Row := ARow;
  Col := ACol;
end;

class operator TCell.Equal(const A, B: TCell): Boolean;
begin
  Result := (A.Row = B.Row) and (A.Col = B.Col);
end;

class operator TCell.NotEqual(const A, B: TCell): Boolean;
begin
  Result := not (A = B);
end;

function TCell.ToString: string;
begin
  Result := '(' + IntToStr(Row) + ', ' + IntToStr(Col) + ')';
end;

constructor TMaze.Create(const ARows: TArray<string>);
var
  HasStart, HasGoal: Boolean;
begin
  if Length(ARows) = 0 then
    raise EArgumentException.Create('el laberinto está vacío');
  FRows := ARows;
  HasStart := False;
  HasGoal := False;
  for var R := 0 to High(ARows) do
  begin
    if Length(ARows[R]) <> Length(ARows[0]) then
      raise EArgumentException.CreateFmt('la fila %d mide %d y la primera %d', [R, Length(ARows[R]), Length(ARows[0])]);
    for var C := 1 to Length(ARows[R]) do
      case ARows[R][C] of
        'S': begin FStart := TCell.Create(R, C - 1); HasStart := True; end;
        'G': begin FGoal := TCell.Create(R, C - 1); HasGoal := True; end;
      end;
  end;
  if not HasStart then
    raise EArgumentException.Create('el laberinto no tiene salida (S)');
  if not HasGoal then
    raise EArgumentException.Create('el laberinto no tiene meta (G)');
end;

function TMaze.RowCount: Integer;
begin
  Result := Length(FRows);
end;

function TMaze.ColCount: Integer;
begin
  Result := Length(FRows[0]);
end;

function TMaze.IsWall(const C: TCell): Boolean;
begin
  Result := (C.Row < 0) or (C.Row >= RowCount) or (C.Col < 0) or (C.Col >= ColCount) or
    (FRows[C.Row][C.Col + 1] = '#');
end;

function TMaze.Neighbors(const C: TCell): TArray<TCell>;
begin
  Result := [];
  for var N in [TCell.Create(C.Row - 1, C.Col), TCell.Create(C.Row + 1, C.Col),
                TCell.Create(C.Row, C.Col - 1), TCell.Create(C.Row, C.Col + 1)] do
    if not IsWall(N) then
      Result := Result + [N];
end;

function TMaze.PathFrom(CameFrom: TDictionary<TCell, TCell>; const Last: TCell): TArray<TCell>;
begin
  var Cur := Last;
  Result := [Cur];
  while Cur <> FStart do
  begin
    Cur := CameFrom[Cur];
    Result := [Cur] + Result;
  end;
end;

class function Mazes.Corridors: TArray<string>;
begin
  Result := [
    '#####################',
    '#S..#.....#.........#',
    '#.#.#.###.#.#####.#.#',
    '#.#...#...#.....#.#.#',
    '#.#####.#######.#.#.#',
    '#.....#.......#.#.#.#',
    '#####.#######.#.#.###',
    '#...#.......#.#.#...#',
    '#.#.#######.#.#.###.#',
    '#.#.........#...#..G#',
    '#####################'];
end;

class function Mazes.Rooms: TArray<string>;
begin
  Result := [
    '#####################',
    '#S..................#',
    '#.......#...........#',
    '#.......#....#####..#',
    '#.......#........#..#',
    '#.#######........#..#',
    '#.......#........#..#',
    '#.......####.....#..#',
    '#..........#........#',
    '#..........#.......G#',
    '#####################'];
end;

function Manhattan(const A, B: TCell): Integer;
begin
  Result := Abs(A.Row - B.Row) + Abs(A.Col - B.Col);
end;

function BreadthFirst(Maze: TMaze): TSearchResult;
begin
  Result.Path := [];
  Result.Visited := [];
  var Queue := TQueue<TCell>.Create;
  var CameFrom := TDictionary<TCell, TCell>.Create;
  try
    Queue.Enqueue(Maze.Start);
    CameFrom.Add(Maze.Start, Maze.Start);
    while Queue.Count > 0 do
    begin
      var Current := Queue.Dequeue;
      Result.Visited := Result.Visited + [Current];
      if Current = Maze.Goal then
      begin
        Result.Path := Maze.PathFrom(CameFrom, Current);
        Exit;
      end;
      for var N in Maze.Neighbors(Current) do
        if not CameFrom.ContainsKey(N) then
        begin
          CameFrom.Add(N, Current);
          Queue.Enqueue(N);
        end;
    end;
  finally
    Queue.Free;
    CameFrom.Free;
  end;
end;

function DepthFirst(Maze: TMaze): TSearchResult;
begin
  Result.Path := [];
  Result.Visited := [];
  var Stack := TStack<TCell>.Create;
  var CameFrom := TDictionary<TCell, TCell>.Create;
  var Seen := TDictionary<TCell, Boolean>.Create;
  try
    Stack.Push(Maze.Start);
    CameFrom.Add(Maze.Start, Maze.Start);
    while Stack.Count > 0 do
    begin
      var Current := Stack.Pop;
      if Seen.ContainsKey(Current) then
        Continue;
      Seen.Add(Current, True);
      Result.Visited := Result.Visited + [Current];
      if Current = Maze.Goal then
      begin
        Result.Path := Maze.PathFrom(CameFrom, Current);
        Exit;
      end;
      for var N in Maze.Neighbors(Current) do
        if not Seen.ContainsKey(N) then
        begin
          CameFrom.AddOrSetValue(N, Current);
          Stack.Push(N);
        end;
    end;
  finally
    Stack.Free;
    CameFrom.Free;
    Seen.Free;
  end;
end;

// ------------------------------------------------------------------ tres en raya y minimax

class function TTicTacToe.Empty: TTicTacToe;
begin
  Result.Cells := '         ';
end;

class function TTicTacToe.FromText(const S: string): TTicTacToe;
begin
  if Length(S) <> 9 then
    raise EArgumentException.Create('el tablero son 9 caracteres (X, O o espacio), por filas');
  Result.Cells := S.ToUpper;
end;

function TTicTacToe.Turn: Char;
begin
  var NX := 0;
  var NO := 0;
  for var C in Cells do
    if C = 'X' then Inc(NX) else if C = 'O' then Inc(NO);
  if NX = NO then Result := 'X' else Result := 'O';
end;

function TTicTacToe.Winner: Char;
const
  LINES: array[0..7, 0..2] of Integer = ((0, 1, 2), (3, 4, 5), (6, 7, 8), (0, 3, 6), (1, 4, 7), (2, 5, 8),
    (0, 4, 8), (2, 4, 6));
begin
  for var L := 0 to 7 do
  begin
    var A := Cells[LINES[L, 0] + 1];
    if (A <> ' ') and (Cells[LINES[L, 1] + 1] = A) and (Cells[LINES[L, 2] + 1] = A) then
      Exit(A);
  end;
  Result := ' ';
end;

function TTicTacToe.Full: Boolean;
begin
  Result := not Cells.Contains(' ');
end;

function TTicTacToe.Moves: TArray<Integer>;
begin
  Result := [];
  if Winner <> ' ' then
    Exit;
  for var I := 0 to 8 do
    if Cells[I + 1] = ' ' then
      Result := Result + [I];
end;

function TTicTacToe.Play(Cell: Integer): TTicTacToe;
begin
  if (Cell < 0) or (Cell > 8) or (Cells[Cell + 1] <> ' ') then
    raise EArgumentException.CreateFmt('la casilla %d no está libre', [Cell]);
  Result.Cells := Cells;
  Result.Cells[Cell + 1] := Turn;
end;

function TTicTacToe.ToString: string;
begin
  Result := '';
  for var R := 0 to 2 do
  begin
    for var C := 0 to 2 do
    begin
      var X := Cells[R * 3 + C + 1];
      if X = ' ' then X := '.';
      Result := Result + X;
    end;
    if R < 2 then
      Result := Result + sLineBreak;
  end;
end;

function MinimaxValue(const B: TTicTacToe; Alpha, Beta: Integer; Prune: Boolean; var Nodes: Integer): Integer;
begin
  Inc(Nodes);
  var W := B.Winner;
  if W = 'X' then Exit(1);
  if W = 'O' then Exit(-1);
  if B.Full then Exit(0);
  var Maximizing := B.Turn = 'X';
  if Maximizing then Result := -2 else Result := 2;
  for var M in B.Moves do
  begin
    var V := MinimaxValue(B.Play(M), Alpha, Beta, Prune, Nodes);
    if Maximizing then
    begin
      if V > Result then Result := V;
      if Result > Alpha then Alpha := Result;
    end
    else
    begin
      if V < Result then Result := V;
      if Result < Beta then Beta := Result;
    end;
    if Prune and (Alpha >= Beta) then
      Break;                     // el otro ya tiene algo mejor antes de llegar aquí: no hace falta seguir
  end;
end;

function Minimax(const Board: TTicTacToe; Prune: Boolean): TMinimaxResult;
begin
  Result.Move := -1;
  Result.Nodes := 1;
  var Maximizing := Board.Turn = 'X';
  if Maximizing then Result.Value := -2 else Result.Value := 2;
  var Alpha := -2;
  var Beta := 2;
  for var M in Board.Moves do
  begin
    var V := MinimaxValue(Board.Play(M), Alpha, Beta, Prune, Result.Nodes);
    if (Maximizing and (V > Result.Value)) or (not Maximizing and (V < Result.Value)) then
    begin
      Result.Value := V;
      Result.Move := M;
    end;
    if Maximizing and (Result.Value > Alpha) then Alpha := Result.Value;
    if not Maximizing and (Result.Value < Beta) then Beta := Result.Value;
  end;
  if Result.Move < 0 then
  begin
    // el juego ya terminó: su valor
    var W := Board.Winner;
    if W = 'X' then Result.Value := 1 else if W = 'O' then Result.Value := -1 else Result.Value := 0;
  end;
end;

function AStar(Maze: TMaze): TSearchResult;
begin
  Result.Path := [];
  Result.Visited := [];
  var Open := TList<TCell>.Create;                       // por revisar
  var Steps := TDictionary<TCell, Integer>.Create;       // pasos desde la salida
  var CameFrom := TDictionary<TCell, TCell>.Create;
  var Done := TDictionary<TCell, Boolean>.Create;
  try
    Open.Add(Maze.Start);
    Steps.Add(Maze.Start, 0);
    while Open.Count > 0 do
    begin
      // la más prometedora: menor pasos + estimación; con empate, la más cerca de la meta
      var Best := 0;
      for var I := 1 to Open.Count - 1 do
      begin
        var FI := Steps[Open[I]] + Manhattan(Open[I], Maze.Goal);
        var FBest := Steps[Open[Best]] + Manhattan(Open[Best], Maze.Goal);
        if (FI < FBest) or ((FI = FBest) and (Manhattan(Open[I], Maze.Goal) < Manhattan(Open[Best], Maze.Goal))) then
          Best := I;
      end;
      var Current := Open[Best];
      Open.Delete(Best);
      if Done.ContainsKey(Current) then
        Continue;
      Done.Add(Current, True);
      Result.Visited := Result.Visited + [Current];
      if Current = Maze.Goal then
      begin
        Result.Path := Maze.PathFrom(CameFrom, Current);
        Exit;
      end;
      for var N in Maze.Neighbors(Current) do
      begin
        var NewSteps := Steps[Current] + 1;
        if not Steps.ContainsKey(N) or (NewSteps < Steps[N]) then
        begin
          Steps.AddOrSetValue(N, NewSteps);
          CameFrom.AddOrSetValue(N, Current);
          Open.Add(N);
        end;
      end;
    end;
  finally
    Open.Free;
    Steps.Free;
    CameFrom.Free;
    Done.Free;
  end;
end;

end.
