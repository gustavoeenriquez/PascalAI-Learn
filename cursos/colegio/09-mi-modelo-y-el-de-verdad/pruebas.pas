// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// El modelo sabe qué viene después de «una»
[Hint('En Create: FModelo := TNGram.Create(2); FModelo.Train(Tokenize.Words(Datasets.Text(''cuentos'')));')]
procedure TestNext;
begin
  var M := TBigramas.Create;
  var P := M.Next(['había', 'una']);
  Assert.True(Length(P) > 0, 'después de «una» tiene que haber palabras posibles');
  Assert.Equal('vez', P[0].Token, 'la más probable después de «una» es «vez»');
end;

/// Narrador usa tu modelo
procedure TestNarrador;
begin
  var R := Narrador.Chat('había una vez');
  Assert.Equal('pascal/TBigramas', R.Model, 'pai.package elige tu modelo');
  Assert.True(R.Text <> '', 'tu modelo tiene que escribir algo');
  Assert.True(R.Tokens > 3, 'los tokens se cuentan como con un modelo de verdad');
end;

/// Escribe con palabras de los cuentos
procedure TestPalabras;
begin
  var Conocidas := TVocab.Create(Tokenize.Words(Datasets.Text('cuentos')));
  for var W in Tokenize.Words(Narrador.Ask('el tigre')) do
    Assert.True(Conocidas.Id(W) >= 0, Format('«%s» no aparece en los cuentos', [W]));
end;
