unit Pai.Learn.Plot;

// Gráficos en SVG, escritos en PascalAI para que se puedan leer: líneas (la pérdida que baja),
// puntos (los datos de dos clases), una recta de frontera (el perceptrón), laberintos (la búsqueda),
// mapas de calor (pesos, atención, matriz de confusión), árboles (decisión, búsqueda) y cuadrículas
// (Q-learning); varios juntos en una página HTML con Plot.Html.
// El archivo .svg se abre en cualquier navegador (y el IDE lo muestra al lado del código).
//
//   var G := TPlot.Create('Pérdida por época', 'época', 'pérdida');
//   for var E := 1 to 100 do
//     G.Line('semilla 1', E, Perdida);
//   G.SaveSvg('perdida.svg');

interface

uses
  SysUtils, Generics.Collections, Pai.Learn.Search, Pai.Learn.Linalg;

type
  TPlotKind = (pkLine, pkScatter);

  TSeries = class
  public
    Name: string;
    Kind: TPlotKind;
    Xs, Ys: TList<Double>;
    constructor Create(const AName: string; AKind: TPlotKind);
    destructor Destroy; override;
  end;

  TPlot = class
  private
    FTitle, FXLabel, FYLabel: string;
    FSeries: TObjectList<TSeries>;
    FHasBoundary: Boolean;
    FW1, FW2, FB: Double;
    function SeriesNamed(const AName: string; AKind: TPlotKind): TSeries;
  public
    constructor Create(const ATitle: string; const AXLabel: string = 'x'; const AYLabel: string = 'y');
    destructor Destroy; override;
    /// Agrega un punto a la línea Series (se unen en el orden en que llegan).
    procedure Line(const Series: string; X, Y: Double);
    /// Agrega un punto suelto a la serie Series (cada serie, un color).
    procedure Scatter(const Series: string; X, Y: Double);
    /// La recta W1·x + W2·y + B = 0 (la frontera de un perceptrón), con su lado positivo sombreado.
    procedure Boundary(W1, W2, B: Double);
    /// El gráfico como texto SVG.
    function ToSvg: string;
    procedure SaveSvg(const AFileName: string);
    /// El gráfico en una página HTML (D-381).
    procedure SaveHtml(const AFileName: string);
  end;

  /// Un nodo de un árbol para dibujar (Plot.Tree): su texto, sus hijos y el rótulo de cada rama.
  /// Libera a sus hijos.
  TPlotNode = class
  public
    Text: string;
    Children: TArray<TPlotNode>;
    EdgeLabels: TArray<string>;
    constructor Create(const AText: string = '');
    destructor Destroy; override;
    function Add(const AText: string; const AEdge: string = ''): TPlotNode;
  end;

  /// Los gráficos que no son series (D-381): cada uno devuelve el texto SVG.
  Plot = class
  public
    /// Un mapa de calor: cada casilla de M con un color según su valor (azul los menores, naranja los
    /// mayores) y el número escrito si ShowValues. RowNames/ColNames rotulan filas y columnas (opcionales).
    class function Heatmap(const M: TMatrix; const Title: string = ''; const RowNames: TArray<string> = nil;
      const ColNames: TArray<string> = nil; ShowValues: Boolean = True): string; static;
    /// Un árbol: la raíz arriba y los hijos debajo (un árbol de decisión, el de una búsqueda).
    class function Tree(Root: TPlotNode; const Title: string = ''): string; static;
    /// Una cuadrícula de valores (Q-learning: el valor de cada casilla), con flechas opcionales
    /// ('^', 'v', '<', '>' o ' ' por casilla, fila por fila) y casillas tapadas en Walls ('#').
    class function Grid(const Values: TMatrix; const Arrows: TArray<string> = nil;
      const Walls: TArray<string> = nil; const Title: string = ''): string; static;
    /// Una página HTML con estos SVG uno debajo del otro (se abre en el navegador; el IDE la muestra).
    class function Html(const Title: string; const Svgs: TArray<string>): string; static;
  end;

/// Un laberinto en SVG: paredes, casillas revisadas (más oscuras las más tardías) y el camino.
function MazeSvg(Maze: TMaze; const Visited, Path: TArray<TCell>): string;

/// Escribe Text en el archivo (UTF-8).
procedure SaveText(const AFileName, AText: string);

implementation

uses
  IOUtils;

const
  // colores que se leen en fondo claro y oscuro
  Palette: array[0..5] of string = ('#2f5bd3', '#d9480f', '#0e8f7e', '#8b3fd9', '#c0266d', '#b08800');
  Width = 640;
  Height = 400;
  Left = 60;
  Right = 20;
  Top = 40;
  Bottom = 50;

function Num(X: Double): string;
begin
  // con punto decimal siempre (SVG no entiende la coma)
  Result := FloatToStrF(X, ffFixed, 15, 2).Replace(',', '.');
end;

function Esc(const S: string): string;
begin
  Result := S.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;');
end;

procedure SaveText(const AFileName, AText: string);
begin
  TFile.WriteAllText(AFileName, AText, TEncoding.UTF8);
end;

{ TSeries }

constructor TSeries.Create(const AName: string; AKind: TPlotKind);
begin
  Name := AName;
  Kind := AKind;
  Xs := TList<Double>.Create;
  Ys := TList<Double>.Create;
end;

destructor TSeries.Destroy;
begin
  Xs.Free;
  Ys.Free;
  inherited;
end;

{ TPlot }

constructor TPlot.Create(const ATitle, AXLabel, AYLabel: string);
begin
  FTitle := ATitle;
  FXLabel := AXLabel;
  FYLabel := AYLabel;
  FSeries := TObjectList<TSeries>.Create(True);
end;

destructor TPlot.Destroy;
begin
  FSeries.Free;
  inherited;
end;

function TPlot.SeriesNamed(const AName: string; AKind: TPlotKind): TSeries;
begin
  for var S in FSeries do
    if S.Name = AName then
      Exit(S);
  Result := TSeries.Create(AName, AKind);
  FSeries.Add(Result);
end;

procedure TPlot.Line(const Series: string; X, Y: Double);
begin
  var S := SeriesNamed(Series, pkLine);
  S.Xs.Add(X);
  S.Ys.Add(Y);
end;

procedure TPlot.Scatter(const Series: string; X, Y: Double);
begin
  var S := SeriesNamed(Series, pkScatter);
  S.Xs.Add(X);
  S.Ys.Add(Y);
end;

procedure TPlot.Boundary(W1, W2, B: Double);
begin
  FHasBoundary := True;
  FW1 := W1;
  FW2 := W2;
  FB := B;
end;

function TPlot.ToSvg: string;
var
  XMin, XMax, YMin, YMax: Double;
  SB: TStringBuilder;

  function PX(X: Double): Double;
  begin
    Result := Left + (X - XMin) / (XMax - XMin) * (Width - Left - Right);
  end;

  function PY(Y: Double): Double;
  begin
    Result := Height - Bottom - (Y - YMin) / (YMax - YMin) * (Height - Top - Bottom);
  end;

begin
  // los límites: de todos los puntos, con un margen del 5 %
  XMin := 0; XMax := 1; YMin := 0; YMax := 1;
  var First := True;
  for var S in FSeries do
    for var I := 0 to S.Xs.Count - 1 do
    begin
      if First or (S.Xs[I] < XMin) then XMin := S.Xs[I];
      if First or (S.Xs[I] > XMax) then XMax := S.Xs[I];
      if First or (S.Ys[I] < YMin) then YMin := S.Ys[I];
      if First or (S.Ys[I] > YMax) then YMax := S.Ys[I];
      First := False;
    end;
  if XMax = XMin then XMax := XMin + 1;
  if YMax = YMin then YMax := YMin + 1;
  var DX := (XMax - XMin) * 0.05;
  var DY := (YMax - YMin) * 0.05;
  XMin := XMin - DX; XMax := XMax + DX; YMin := YMin - DY; YMax := YMax + DY;

  SB := TStringBuilder.Create;
  try
    SB.Append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + IntToStr(Width) + ' ' + IntToStr(Height) +
      '" font-family="sans-serif" font-size="12">').Append(sLineBreak);
    SB.Append('<rect width="100%" height="100%" fill="#ffffff"/>').Append(sLineBreak);
    SB.Append('<text x="' + IntToStr(Width div 2) + '" y="22" text-anchor="middle" font-size="15" fill="#1b2230">' +
      Esc(FTitle) + '</text>').Append(sLineBreak);

    // la frontera: el lado positivo sombreado y la recta
    if FHasBoundary and ((FW1 <> 0) or (FW2 <> 0)) then
    begin
      var Pts: TArray<string> := [];
      // recorte del rectángulo por el semiplano W1·x + W2·y + B >= 0 (Sutherland-Hodgman con un borde)
      var CX: TArray<Double> := [XMin, XMax, XMax, XMin];
      var CY: TArray<Double> := [YMin, YMin, YMax, YMax];
      for var K := 0 to 3 do
      begin
        var K2 := (K + 1) mod 4;
        var FA := FW1 * CX[K] + FW2 * CY[K] + FB;
        var FB2 := FW1 * CX[K2] + FW2 * CY[K2] + FB;
        if FA >= 0 then
          Pts := Pts + [Num(PX(CX[K])) + ',' + Num(PY(CY[K]))];
        if (FA >= 0) <> (FB2 >= 0) then
        begin
          var T := FA / (FA - FB2);
          Pts := Pts + [Num(PX(CX[K] + T * (CX[K2] - CX[K]))) + ',' + Num(PY(CY[K] + T * (CY[K2] - CY[K])))];
        end;
      end;
      if Length(Pts) > 2 then
        SB.Append('<polygon points="' + string.Join(' ', Pts) + '" fill="#2f5bd3" fill-opacity="0.08"/>').Append(sLineBreak);
    end;

    // ejes
    SB.Append('<line x1="' + IntToStr(Left) + '" y1="' + IntToStr(Height - Bottom) + '" x2="' + IntToStr(Width - Right) +
      '" y2="' + IntToStr(Height - Bottom) + '" stroke="#586174"/>').Append(sLineBreak);
    SB.Append('<line x1="' + IntToStr(Left) + '" y1="' + IntToStr(Top) + '" x2="' + IntToStr(Left) + '" y2="' +
      IntToStr(Height - Bottom) + '" stroke="#586174"/>').Append(sLineBreak);
    for var K := 0 to 4 do
    begin
      var VX := XMin + (XMax - XMin) * K / 4;
      var VY := YMin + (YMax - YMin) * K / 4;
      SB.Append('<text x="' + Num(PX(VX)) + '" y="' + IntToStr(Height - Bottom + 16) +
        '" text-anchor="middle" fill="#586174">' + FloatToStrF(VX, ffGeneral, 3, 2) + '</text>').Append(sLineBreak);
      SB.Append('<text x="' + IntToStr(Left - 6) + '" y="' + Num(PY(VY) + 4) +
        '" text-anchor="end" fill="#586174">' + FloatToStrF(VY, ffGeneral, 3, 2) + '</text>').Append(sLineBreak);
    end;
    SB.Append('<text x="' + IntToStr(Width div 2) + '" y="' + IntToStr(Height - 10) +
      '" text-anchor="middle" fill="#586174">' + Esc(FXLabel) + '</text>').Append(sLineBreak);
    SB.Append('<text x="14" y="' + IntToStr(Height div 2) + '" text-anchor="middle" fill="#586174" transform="rotate(-90 14 ' +
      IntToStr(Height div 2) + ')">' + Esc(FYLabel) + '</text>').Append(sLineBreak);

    if FHasBoundary and (FW2 <> 0) then
      SB.Append('<line x1="' + Num(PX(XMin)) + '" y1="' + Num(PY(-(FW1 * XMin + FB) / FW2)) + '" x2="' + Num(PX(XMax)) +
        '" y2="' + Num(PY(-(FW1 * XMax + FB) / FW2)) + '" stroke="#1b2230" stroke-width="2" clip-path="url(#area)"/>')
        .Append(sLineBreak);

    // las series, cada una con su color
    for var N := 0 to FSeries.Count - 1 do
    begin
      var S := FSeries[N];
      var Color := Palette[N mod Length(Palette)];
      if S.Kind = pkLine then
      begin
        var Pts: TArray<string> := [];
        for var I := 0 to S.Xs.Count - 1 do
          Pts := Pts + [Num(PX(S.Xs[I])) + ',' + Num(PY(S.Ys[I]))];
        SB.Append('<polyline points="' + string.Join(' ', Pts) + '" fill="none" stroke="' + Color +
          '" stroke-width="1.8"/>').Append(sLineBreak);
      end
      else
        for var I := 0 to S.Xs.Count - 1 do
          SB.Append('<circle cx="' + Num(PX(S.Xs[I])) + '" cy="' + Num(PY(S.Ys[I])) + '" r="4.5" fill="' + Color + '"/>')
            .Append(sLineBreak);
      // la leyenda
      SB.Append('<rect x="' + IntToStr(Width - Right - 150) + '" y="' + IntToStr(Top + 4 + 18 * N) +
        '" width="12" height="12" fill="' + Color + '"/>').Append(sLineBreak);
      SB.Append('<text x="' + IntToStr(Width - Right - 132) + '" y="' + IntToStr(Top + 14 + 18 * N) + '" fill="#1b2230">' +
        Esc(S.Name) + '</text>').Append(sLineBreak);
    end;
    SB.Append('<clipPath id="area"><rect x="' + IntToStr(Left) + '" y="' + IntToStr(Top) + '" width="' +
      IntToStr(Width - Left - Right) + '" height="' + IntToStr(Height - Top - Bottom) + '"/></clipPath>').Append(sLineBreak);
    SB.Append('</svg>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TPlot.SaveSvg(const AFileName: string);
begin
  SaveText(AFileName, ToSvg);
end;

function MazeSvg(Maze: TMaze; const Visited, Path: TArray<TCell>): string;
const
  S = 20;
begin
  var Order := TDictionary<TCell, Integer>.Create;
  var OnPath := TDictionary<TCell, Boolean>.Create;
  var SB := TStringBuilder.Create;
  try
    for var I := 0 to High(Visited) do
      if not Order.ContainsKey(Visited[I]) then
        Order.Add(Visited[I], I);
    for var C in Path do
      OnPath.AddOrSetValue(C, True);
    SB.Append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + IntToStr(Maze.ColCount * S) + ' ' +
      IntToStr(Maze.RowCount * S) + '">').Append(sLineBreak);
    for var R := 0 to Maze.RowCount - 1 do
      for var Col := 0 to Maze.ColCount - 1 do
      begin
        var C := TCell.Create(R, Col);
        var Pos := 'x="' + IntToStr(Col * S) + '" y="' + IntToStr(R * S) + '" width="' + IntToStr(S) + '" height="' +
          IntToStr(S) + '"';
        if Maze.IsWall(C) then
          SB.Append('<rect ' + Pos + ' fill="#2a3245"/>')
        else
        begin
          SB.Append('<rect ' + Pos + ' fill="#ffffff"/>');
          if Order.ContainsKey(C) then
            SB.Append('<rect ' + Pos + ' fill="#2f5bd3" fill-opacity="' +
              Num(0.12 + 0.6 * Order[C] / Length(Visited)) + '"/>');
          if OnPath.ContainsKey(C) then
            SB.Append('<circle cx="' + IntToStr(Col * S + S div 2) + '" cy="' + IntToStr(R * S + S div 2) +
              '" r="4" fill="#d9480f"/>');
        end;
        SB.Append(sLineBreak);
      end;
    SB.Append('</svg>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    Order.Free;
    OnPath.Free;
    SB.Free;
  end;
end;


// ------------------------------------------------------------------ árboles, mapas de calor y cuadrículas (D-381)

constructor TPlotNode.Create(const AText: string);
begin
  inherited Create;
  Text := AText;
end;

destructor TPlotNode.Destroy;
begin
  for var C in Children do
    C.Free;
  inherited;
end;

function TPlotNode.Add(const AText, AEdge: string): TPlotNode;
begin
  Result := TPlotNode.Create(AText);
  Children := Children + [Result];
  EdgeLabels := EdgeLabels + [AEdge];
end;

procedure TPlot.SaveHtml(const AFileName: string);
begin
  SaveText(AFileName, Plot.Html(FTitle, [ToSvg]));
end;

/// Un color de azul (0) a naranja (1), pasando por blanco
function HeatColor(T: Double): string;

  function Mix(A, B: Integer; F: Double): Integer;
  begin
    Result := Round(A + (B - A) * F);
  end;

begin
  if T < 0 then T := 0;
  if T > 1 then T := 1;
  var R, G, B: Integer;
  if T < 0.5 then
  begin
    R := Mix(47, 255, T * 2); G := Mix(91, 255, T * 2); B := Mix(211, 255, T * 2);
  end
  else
  begin
    R := Mix(255, 217, (T - 0.5) * 2); G := Mix(255, 72, (T - 0.5) * 2); B := Mix(255, 15, (T - 0.5) * 2);
  end;
  Result := '#' + IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
end;

class function Plot.Heatmap(const M: TMatrix; const Title: string; const RowNames, ColNames: TArray<string>;
  ShowValues: Boolean): string;
const
  CS = 36;
begin
  var Lo: Double := 0.0;
  var Hi: Double := 0.0;
  if Length(M.Data) > 0 then
  begin
    Lo := M.Data[0];
    Hi := M.Data[0];
    for var V in M.Data do
    begin
      if V < Lo then Lo := V;
      if V > Hi then Hi := V;
    end;
  end;
  var LeftM := 10;
  if Length(RowNames) > 0 then LeftM := 90;
  var TopM := 10;
  if Title <> '' then TopM := TopM + 24;
  if Length(ColNames) > 0 then TopM := TopM + 20;
  var W := LeftM + M.Cols * CS + 10;
  var H := TopM + M.Rows * CS + 10;
  var SB := TStringBuilder.Create;
  try
    SB.Append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(H) +
      '" font-family="sans-serif" font-size="11">').Append(sLineBreak);
    if Title <> '' then
      SB.Append('<text x="' + IntToStr(W div 2) + '" y="18" text-anchor="middle" font-size="14">' + Esc(Title) +
        '</text>').Append(sLineBreak);
    for var C := 0 to High(ColNames) do
      if C < M.Cols then
        SB.Append('<text x="' + IntToStr(LeftM + C * CS + CS div 2) + '" y="' + IntToStr(TopM - 6) +
          '" text-anchor="middle">' + Esc(ColNames[C]) + '</text>');
    for var R := 0 to M.Rows - 1 do
    begin
      if R < Length(RowNames) then
        SB.Append('<text x="' + IntToStr(LeftM - 6) + '" y="' + IntToStr(TopM + R * CS + CS div 2 + 4) +
          '" text-anchor="end">' + Esc(RowNames[R]) + '</text>');
      for var C := 0 to M.Cols - 1 do
      begin
        var V := M[R, C];
        var T: Double := 0.5;
        if Hi > Lo then T := (V - Lo) / (Hi - Lo);
        SB.Append('<rect x="' + IntToStr(LeftM + C * CS) + '" y="' + IntToStr(TopM + R * CS) + '" width="' +
          IntToStr(CS) + '" height="' + IntToStr(CS) + '" fill="' + HeatColor(T) + '" stroke="#ffffff"/>');
        if ShowValues then
          SB.Append('<text x="' + IntToStr(LeftM + C * CS + CS div 2) + '" y="' + IntToStr(TopM + R * CS + CS div 2 + 4) +
            '" text-anchor="middle" fill="#1d1d1f">' + FormatFloat('0.##', V) + '</text>');
      end;
      SB.Append(sLineBreak);
    end;
    SB.Append('</svg>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

/// Cuántas hojas tiene el subárbol (el ancho que ocupa)
function Leaves(N: TPlotNode): Integer;
begin
  if Length(N.Children) = 0 then
    Exit(1);
  Result := 0;
  for var C in N.Children do
    Result := Result + Leaves(C);
end;

function Depth(N: TPlotNode): Integer;
begin
  Result := 1;
  for var C in N.Children do
    if Depth(C) + 1 > Result then
      Result := Depth(C) + 1;
end;

procedure DrawNode(SB: TStringBuilder; N: TPlotNode; X0, Y, LeafW, LevelH: Integer);
// X0: el borde izquierdo de su franja; el nodo va al centro de las hojas que le tocan
begin
  var W := Leaves(N) * LeafW;
  var CX := X0 + W div 2;
  var BoxW := LeafW - 10;
  var Cursor := X0;
  for var I := 0 to High(N.Children) do
  begin
    var Ch := N.Children[I];
    var CW := Leaves(Ch) * LeafW;
    var CCX := Cursor + CW div 2;
    SB.Append('<line x1="' + IntToStr(CX) + '" y1="' + IntToStr(Y + 30) + '" x2="' + IntToStr(CCX) + '" y2="' +
      IntToStr(Y + LevelH) + '" stroke="#8a8a8f"/>');
    if (I < Length(N.EdgeLabels)) and (N.EdgeLabels[I] <> '') then
      SB.Append('<text x="' + IntToStr((CX + CCX) div 2 + 4) + '" y="' + IntToStr(Y + 30 + (LevelH - 30) div 2) +
        '" fill="#6b6b70">' + Esc(N.EdgeLabels[I]) + '</text>');
    DrawNode(SB, Ch, Cursor, Y + LevelH, LeafW, LevelH);
    Cursor := Cursor + CW;
  end;
  var Fill := '#e8eefc';
  if Length(N.Children) = 0 then Fill := '#fde9dd';
  SB.Append('<rect x="' + IntToStr(CX - BoxW div 2) + '" y="' + IntToStr(Y) + '" width="' + IntToStr(BoxW) +
    '" height="30" rx="6" fill="' + Fill + '" stroke="#2f5bd3"/>');
  SB.Append('<text x="' + IntToStr(CX) + '" y="' + IntToStr(Y + 19) + '" text-anchor="middle">' + Esc(N.Text) +
    '</text>').Append(sLineBreak);
end;

class function Plot.Tree(Root: TPlotNode; const Title: string): string;
const
  LEAF_W = 120;
  LEVEL_H = 70;
begin
  var TopM := 10;
  if Title <> '' then TopM := 34;
  var W := Leaves(Root) * LEAF_W;
  var H := TopM + Depth(Root) * LEVEL_H;
  var SB := TStringBuilder.Create;
  try
    SB.Append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(H) +
      '" font-family="sans-serif" font-size="11">').Append(sLineBreak);
    if Title <> '' then
      SB.Append('<text x="' + IntToStr(W div 2) + '" y="18" text-anchor="middle" font-size="14">' + Esc(Title) +
        '</text>').Append(sLineBreak);
    DrawNode(SB, Root, 0, TopM, LEAF_W, LEVEL_H);
    SB.Append('</svg>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

class function Plot.Grid(const Values: TMatrix; const Arrows, Walls: TArray<string>; const Title: string): string;
const
  CS = 44;
begin
  var Lo: Double := 0.0;
  var Hi: Double := 0.0;
  var First := True;
  for var R := 0 to Values.Rows - 1 do
    for var C := 0 to Values.Cols - 1 do
    begin
      if (R < Length(Walls)) and (C < Length(Walls[R])) and (Walls[R][C + 1] = '#') then
        Continue;
      var V := Values[R, C];
      if First or (V < Lo) then Lo := V;
      if First or (V > Hi) then Hi := V;
      First := False;
    end;
  var TopM := 10;
  if Title <> '' then TopM := 34;
  var W := Values.Cols * CS + 20;
  var H := TopM + Values.Rows * CS + 10;
  var SB := TStringBuilder.Create;
  try
    SB.Append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + IntToStr(W) + ' ' + IntToStr(H) +
      '" font-family="sans-serif" font-size="11">').Append(sLineBreak);
    if Title <> '' then
      SB.Append('<text x="' + IntToStr(W div 2) + '" y="18" text-anchor="middle" font-size="14">' + Esc(Title) +
        '</text>').Append(sLineBreak);
    for var R := 0 to Values.Rows - 1 do
      for var C := 0 to Values.Cols - 1 do
      begin
        var X := 10 + C * CS;
        var Y := TopM + R * CS;
        var Pos := 'x="' + IntToStr(X) + '" y="' + IntToStr(Y) + '" width="' + IntToStr(CS) + '" height="' +
          IntToStr(CS) + '"';
        if (R < Length(Walls)) and (C < Length(Walls[R])) and (Walls[R][C + 1] = '#') then
        begin
          SB.Append('<rect ' + Pos + ' fill="#2a3245"/>');
          Continue;
        end;
        var T: Double := 0.5;
        if Hi > Lo then T := (Values[R, C] - Lo) / (Hi - Lo);
        SB.Append('<rect ' + Pos + ' fill="' + HeatColor(T) + '" stroke="#ffffff"/>');
        SB.Append('<text x="' + IntToStr(X + CS div 2) + '" y="' + IntToStr(Y + CS - 6) +
          '" text-anchor="middle" fill="#1d1d1f">' + FormatFloat('0.##', Values[R, C]) + '</text>');
        if (R < Length(Arrows)) and (C < Length(Arrows[R])) and (Arrows[R][C + 1] <> ' ') then
        begin
          var A := Arrows[R][C + 1];
          var Sym := '';
          if A = '^' then Sym := '↑' else if A = 'v' then Sym := '↓' else if A = '<' then Sym := '←'
          else if A = '>' then Sym := '→' else Sym := A;
          SB.Append('<text x="' + IntToStr(X + CS div 2) + '" y="' + IntToStr(Y + 20) +
            '" text-anchor="middle" font-size="16" fill="#1d1d1f">' + Esc(Sym) + '</text>');
        end;
      end;
    SB.Append('</svg>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

class function Plot.Html(const Title: string; const Svgs: TArray<string>): string;
begin
  var SB := TStringBuilder.Create;
  try
    SB.Append('<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" ' +
      'content="width=device-width,initial-scale=1"><title>' + Esc(Title) + '</title><style>' +
      'body{margin:0;padding:16px;background:#f7f7f5;color:#1d1d1f;font:14px/1.45 system-ui,sans-serif}' +
      'h1{font-size:18px;margin:0 0 12px}figure{margin:0 0 16px;background:#fff;border:1px solid #e3e3df;' +
      'border-radius:8px;padding:8px}svg{width:100%;height:auto;max-width:720px;display:block}' +
      '@media (prefers-color-scheme:dark){body{background:#161618;color:#e8e8ea}figure{background:#fff}}' +
      '</style></head><body>').Append(sLineBreak);
    SB.Append('<h1>' + Esc(Title) + '</h1>').Append(sLineBreak);
    for var S in Svgs do
      SB.Append('<figure>' + S + '</figure>').Append(sLineBreak);
    SB.Append('</body></html>').Append(sLineBreak);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
