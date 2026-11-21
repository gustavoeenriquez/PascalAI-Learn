uses
  SysUtils, Generics.Collections, Pai.Learn.Search;

var
  Visitadas: TArray<TCell>;

/// La posición, dentro de Abiertas, de la casilla con menor f = Pasos + Manhattan a la meta;
/// si empatan, la que está más cerca de la meta.
function Prometedora(L: TMaze; Abiertas: TList<TCell>; Pasos: TDictionary<TCell, Integer>): Integer;
begin
  Todo('recorre Abiertas y quédate con la posición de la de menor f');
end;

function BuscarAEstrella(L: TMaze): TArray<TCell>;
begin
  Visitadas := [];
  Result := [];
  var Abiertas := TList<TCell>.Create;                 // por revisar
  var Pasos := TDictionary<TCell, Integer>.Create;     // pasos desde la salida
  var Vino := TDictionary<TCell, TCell>.Create;
  var Hechas := TDictionary<TCell, Boolean>.Create;
  Abiertas.Add(L.Start);
  Pasos.Add(L.Start, 0);
  while Abiertas.Count > 0 do
  begin
    var I := Prometedora(L, Abiertas, Pasos);
    var Actual := Abiertas[I];
    Abiertas.Delete(I);
    if Hechas.ContainsKey(Actual) then
      Continue;
    Hechas.Add(Actual, True);
    Visitadas := Visitadas + [Actual];
    if Actual = L.Goal then
      Exit(L.PathFrom(Vino, Actual));
    for var Vecina in L.Neighbors(Actual) do
      if not Pasos.ContainsKey(Vecina) or (Pasos[Actual] + 1 < Pasos[Vecina]) then
      begin
        Pasos.AddOrSetValue(Vecina, Pasos[Actual] + 1);
        Vino.AddOrSetValue(Vecina, Actual);
        Abiertas.Add(Vecina);
      end;
  end;
end;

begin
  var L := TMaze.Create(Mazes.Rooms);
  var Camino := BuscarAEstrella(L);
  WriteLn('A* revisó ', Length(Visitadas), ' casillas; el camino mide ', Length(Camino) - 1, ' pasos.');
  WriteLn('En anchura habría revisado ', Length(BreadthFirst(L).Visited), '.');
end.
