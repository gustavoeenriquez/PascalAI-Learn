// Pruebas de Pai.Learn.Plot: el SVG tiene lo que se dibujó.
uses SysUtils, Pai.Learn.Plot, Pai.Learn.Search, Pai.Learn.Data;

procedure TestLineas;
begin
  var G := TPlot.Create('Pérdida', 'época', 'pérdida');
  for var E := 1 to 50 do
  begin
    G.Line('semilla 1', E, 1 / E);
    G.Line('semilla 2', E, 2 / E);
  end;
  var S := G.ToSvg;
  Assert.Contains(S, '<svg');
  Assert.Contains(S, 'Pérdida');
  Assert.Equal(2, (Length(S) - Length(S.Replace('<polyline', ''))) div Length('<polyline'), 'dos líneas');
  Assert.Contains(S, 'semilla 2');
  Assert.False(S.Contains('NaN') or S.Contains('INF'), 'sin números raros');
end;

procedure TestFronteraYPuntos;
begin
  var G := TPlot.Create('Frutas', 'peso (kg)', 'rojez');
  for var F in Datasets.Fruits do
    G.Scatter(F.Name, F.Weight, F.Redness);
  G.Boundary(-10, 1, 1.2);
  var S := G.ToSvg;
  Assert.Contains(S, '<polygon');
  Assert.Contains(S, 'apple');
  Assert.Contains(S, 'pear');
end;

procedure TestLaberinto;
begin
  var L := TMaze.Create(Mazes.Rooms);
  var R := AStar(L);
  var S := MazeSvg(L, R.Visited, R.Path);
  Assert.Contains(S, '<svg');
  Assert.Contains(S, 'fill="#d9480f"');
end;

procedure TestGuardar;
begin
  var F := ExtractFilePath(ParamStr(0)) + 'plot_prueba.svg';
  var G := TPlot.Create('x');
  G.Line('a', 0, 0);
  G.Line('a', 1, 1);
  G.SaveSvg(F);
  Assert.True(FileExists(F));
  DeleteFile(F);
end;
