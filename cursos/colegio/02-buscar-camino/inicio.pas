uses
  SysUtils, Generics.Collections, Pai.Learn.Search;

var
  Visitadas: TArray<TCell>;    // en el orden en que se revisaron

/// El camino más corto de la salida a la meta (las dos incluidas); vacío si no hay camino.
function BuscarEnAnchura(L: TMaze): TArray<TCell>;
begin
  Visitadas := [];
  var Cola := TQueue<TCell>.Create;
  var Vino := TDictionary<TCell, TCell>.Create;     // de dónde llegué a cada casilla
  Cola.Enqueue(L.Start);
  Vino.Add(L.Start, L.Start);
  Result := [];
  Todo('mientras haya casillas en la cola: saca la primera, mira si es la meta y mete sus vecinas nuevas');
end;

begin
  var L := TMaze.Create(Mazes.Corridors);
  var Camino := BuscarEnAnchura(L);
  WriteLn('Revisé ', Length(Visitadas), ' casillas.');
  WriteLn('El camino mide ', Length(Camino) - 1, ' pasos.');
end.
