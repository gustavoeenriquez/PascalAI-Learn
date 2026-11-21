// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Elige la casilla con menor f
procedure TestEligeLaMenor;
begin
  var L := TMaze.Create(['#######', '#S...G#', '#######']);
  var Abiertas := TList<TCell>.Create;
  var Pasos := TDictionary<TCell, Integer>.Create;
  Abiertas.Add(TCell.Create(1, 1));  Pasos.Add(TCell.Create(1, 1), 3);   // f = 3 + 4 = 7
  Abiertas.Add(TCell.Create(1, 3));  Pasos.Add(TCell.Create(1, 3), 1);   // f = 1 + 2 = 3
  Abiertas.Add(TCell.Create(1, 2));  Pasos.Add(TCell.Create(1, 2), 2);   // f = 2 + 3 = 5
  Assert.Equal(1, Prometedora(L, Abiertas, Pasos), 'la de la posición 1 tiene f = 3, la menor');
end;

/// Con empate, la más cerca de la meta
[Hint('Si las dos tienen el mismo f, compara Manhattan(C, L.Goal) y quédate con la menor.')]
procedure TestEmpate;
begin
  var L := TMaze.Create(['#######', '#S...G#', '#######']);
  var Abiertas := TList<TCell>.Create;
  var Pasos := TDictionary<TCell, Integer>.Create;
  Abiertas.Add(TCell.Create(1, 2));  Pasos.Add(TCell.Create(1, 2), 2);   // f = 2 + 3 = 5
  Abiertas.Add(TCell.Create(1, 4));  Pasos.Add(TCell.Create(1, 4), 4);   // f = 4 + 1 = 5, más cerca
  Assert.Equal(1, Prometedora(L, Abiertas, Pasos));
end;

/// Encuentra el camino más corto
procedure TestCaminoMasCorto;
begin
  var L := TMaze.Create(Mazes.Corridors);
  Assert.Equal(59, Length(BuscarAEstrella(L)), 'en los pasillos, 58 pasos como la búsqueda en anchura');
end;

/// Revisa menos casillas que la búsqueda en anchura
[Hint('¿Sumas los pasos y la estimación? f = Pasos[C] + Manhattan(C, L.Goal).')]
procedure TestRevisaMenos;
begin
  var L := TMaze.Create(Mazes.Rooms);
  Assert.Equal(27, Length(BuscarAEstrella(L)), 'en las salas el camino mide 26 pasos');
  Assert.True(Length(Visitadas) < 145, Format('A* revisó %d casillas: tiene que revisar menos que la búsqueda en anchura (145)',
    [Length(Visitadas)]));
end;
