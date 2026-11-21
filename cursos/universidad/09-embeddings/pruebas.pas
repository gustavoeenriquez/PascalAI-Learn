// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La similitud coseno
procedure TestCoseno;
begin
  Assert.True(Abs(Coseno([1, 0], [2, 0]) - 1) < 1e-12, 'la misma dirección: 1');
  Assert.True(Abs(Coseno([1, 0], [0, 3])) < 1e-12, 'perpendiculares: 0');
  Assert.True(Abs(Coseno([1, 1], [-1, -1]) + 1) < 1e-12, 'opuestos: -1');
  Assert.Equal(0.0, Coseno([0, 0], [1, 2]), 'con el vector cero: 0');
end;

/// Las más cercanas, igual que la biblioteca
[Hint('Para cada palabra W distinta de Palabra, Coseno(E.Vector(Palabra), E.Vector(W)); ordena de mayor a menor y toma N.')]
procedure TestMasCercanas;
begin
  var E := TWordEmbedding.Create(16);
  E.Train(Tokenize.Words(Datasets.Text('cuentos')), TRandom.Create(1), 1);
  var Mias := MasCercanas(E, 'loro', 5);
  var DeLaBiblioteca := E.Nearest('loro', 5);
  Assert.Equal(5, Length(Mias));
  for var I := 0 to 4 do
  begin
    Assert.Equal(DeLaBiblioteca[I].Token, Mias[I].Token, Format('la palabra número %d', [I + 1]));
    Assert.True(Abs(DeLaBiblioteca[I].Prob - Mias[I].Prob) < 1e-9);
  end;
end;
