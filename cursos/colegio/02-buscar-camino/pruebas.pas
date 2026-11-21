// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Un pasillo recto
[Hint('Cuando sacas la meta de la cola, devuelve L.PathFrom(Vino, Actual).')]
procedure TestPasilloRecto;
begin
  var L := TMaze.Create(['#####', '#S.G#', '#####']);
  var Camino := BuscarEnAnchura(L);
  Assert.Equal(3, Length(Camino), 'el camino de S a G pasa por 3 casillas');
  Assert.True(Camino[0] = L.Start, 'el camino empieza en la salida');
  Assert.True(Camino[High(Camino)] = L.Goal, 'el camino termina en la meta');
end;

/// El camino más corto en el laberinto de pasillos
[Hint('¿Revisas si una vecina ya está en Vino antes de meterla a la cola? Si no, la búsqueda da vueltas.')]
procedure TestLaberinto;
begin
  var L := TMaze.Create(Mazes.Corridors);
  var Camino := BuscarEnAnchura(L);
  Assert.Equal(59, Length(Camino), 'el camino más corto mide 58 pasos (59 casillas)');
  for var I := 1 to High(Camino) do
    Assert.Equal(1, Manhattan(Camino[I - 1], Camino[I]), 'cada paso va a una casilla vecina');
end;

/// Revisa las casillas en orden de cercanía
[Hint('Agrega cada casilla que sacas de la cola a Visitadas: Visitadas := Visitadas + [Actual].')]
procedure TestOrden;
begin
  var L := TMaze.Create(Mazes.Rooms);
  BuscarEnAnchura(L);
  Assert.Equal(145, Length(Visitadas), 'en el laberinto de salas revisa 145 casillas hasta la meta');
  Assert.True(Visitadas[0] = L.Start, 'la primera que revisa es la salida');
end;

/// Sin camino
procedure TestSinCamino;
begin
  var L := TMaze.Create(['#####', '#S#G#', '#####']);
  Assert.Equal(0, Length(BuscarEnAnchura(L)), 'si no hay camino, el resultado está vacío');
end;
