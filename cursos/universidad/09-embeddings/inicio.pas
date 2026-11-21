uses
  SysUtils, Math, Pai.Learn.Random, Pai.Learn.Data, Pai.Learn.Text, Pai.Learn.Embed;

/// Similitud coseno: (U · V) / (|U| · |V|); 0 si alguno es el vector cero.
function Coseno(const U, V: TArray<Double>): Double;
begin
  Todo('el producto punto dividido por el producto de los largos');
end;

/// Las N palabras más parecidas a Palabra (sin ella), de la más parecida a la menos. Prob = similitud.
function MasCercanas(E: TWordEmbedding; const Palabra: string; N: Integer): TArray<TTokenProb>;
begin
  Todo('recorre las palabras con E.Word(I) para I de 0 a E.VocabSize - 1 y quédate con las N de mayor Coseno');
end;

begin
  var E := TWordEmbedding.Create(32);
  E.Train(Tokenize.Words(Datasets.Text('cuentos')), TRandom.Create(1), 3);
  var Palabras: TArray<string> := ['tortuga', 'loro', 'agua', 'dijo'];
  for var P in Palabras do
  begin
    Write(P, ':');
    for var C in MasCercanas(E, P, 5) do
      Write(' ', C.Token, ' (', C.Prob:0:2, ')');
    WriteLn;
  end;
end.
