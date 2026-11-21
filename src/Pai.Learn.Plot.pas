unit Pai.Learn.Plot;

// Gráficos en SVG, escritos en PascalAI para que se puedan leer: líneas (la pérdida que baja),
// puntos (los datos de dos clases), una recta de frontera (el perceptrón) y laberintos (la búsqueda).
// El archivo .svg se abre en cualquier navegador (y el IDE lo muestra al lado del código).
//
//   var G := TPlot.Create('Pérdida por época', 'época', 'pérdida');
//   for var E := 1 to 100 do
//     G.Line('semilla 1', E, Perdida);
//   G.SaveSvg('perdida.svg');

interface

uses
  SysUtils, Generics.Collections, Pai.Learn.Search;

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

end.
