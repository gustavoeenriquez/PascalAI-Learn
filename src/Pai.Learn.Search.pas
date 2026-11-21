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
