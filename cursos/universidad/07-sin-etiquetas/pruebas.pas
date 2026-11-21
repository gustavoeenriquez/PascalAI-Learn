// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

function Puntos: TMatrix;
begin
  Result := TMatrix.FromRows([[0, 0], [0, 1], [1, 0], [10, 10], [10, 11], [11, 10]]);
end;

/// Asignar al centro más cercano
procedure TestAsignar;
begin
  var Centros := TMatrix.FromRows([[0, 0], [10, 10]]);
  var Grupo: TArray<Integer> := [-1, -1, -1, -1, -1, -1];
  Assert.True(Asignar(Puntos, Centros, Grupo), 'la primera vez todos cambian de grupo');
  Assert.Equal('0 0 0 1 1 1', Format('%d %d %d %d %d %d', [Grupo[0], Grupo[1], Grupo[2], Grupo[3], Grupo[4], Grupo[5]]));
  Assert.False(Asignar(Puntos, Centros, Grupo), 'la segunda vez nadie cambia');
end;

/// Mover los centros al promedio
[Hint('Para cada centro C: suma las filas con Grupo[i] = C, cuéntalas, y si son más de 0 divide la suma por la cuenta.')]
procedure TestMover;
begin
  var Centros := TMatrix.FromRows([[5, 5], [5, 5]]);
  Mover(Puntos, [0, 0, 0, 1, 1, 1], Centros);
  Assert.Equal('[0.33, 0.33]' + sLineBreak + '[10.33, 10.33]', Centros.ToString);
end;

/// Un centro sin puntos no se mueve
procedure TestCentroVacio;
begin
  var Centros := TMatrix.FromRows([[0, 0], [99, 99]]);
  Mover(Puntos, [0, 0, 0, 0, 0, 0], Centros);
  Assert.Equal(99.0, Centros[1, 0], 'el grupo 1 no tiene puntos: su centro se queda donde estaba');
end;

/// Iris en tres grupos
procedure TestIris;
begin
  var Flores := Datasets.Iris;
  var Centros: TMatrix;
  var Grupo := Agrupar(Flores.X, [0, 50, 100], Centros);
  var I := Inercia(Flores.X, Centros, Grupo);
  Assert.True(Abs(I - 78.94) < 0.1, Format('la inercia final tiene que ser 78.94 y fue %.2f', [I]));
end;
