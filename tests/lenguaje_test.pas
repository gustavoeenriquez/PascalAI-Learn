// Pruebas de T3: texto, n-gramas, BPE, embeddings, atención y refuerzo.
uses SysUtils, Math, Pai.Learn.Random, Pai.Learn.Data, Pai.Learn.Tensor, Pai.Learn.NN, Pai.Learn.Text,
  Pai.Learn.Embed, Pai.Learn.Attention, Pai.Learn.RL;

procedure TestTokenizar;
begin
  Assert.Equal('había|una|vez|,|¡|hola|!', string.Join('|', Tokenize.Words('Había una vez, ¡HOLA!')));
  Assert.Equal('había una vez, ¡hola!', Tokenize.Join(Tokenize.Words('Había una vez, ¡HOLA!')));
  Assert.Equal(3, Length(Tokenize.Chars('sol')));
  var V := TVocab.Create(['a', 'b', 'a', 'c']);
  Assert.Equal(3, V.Count);
  Assert.Equal('c', V.Token(V.Id('c')));
  Assert.Equal(-1, V.Id('z'));
end;

procedure TestNGrama;
begin
  var M := TNGram.Create(2);
  M.Train(['el', 'loro', 'y', 'el', 'loro', 'y', 'el', 'tigre']);
  var P := M.Next(['el']);
  Assert.Equal('loro', P[0].Token);
  Assert.True(Abs(P[0].Prob - 2 / 3) < 1e-12);
  Assert.Equal(0, Length(M.Next(['tigre'])), 'contexto que nunca vio');
  Assert.Equal('loro y el loro', Tokenize.Join(M.Generate(['el'], 4, TRandom.Create(1), 0)), 'con temperatura 0, la más probable');
  var T := TNGram.Create(3);
  T.Train(Tokenize.Words(Datasets.Text('cuentos')));
  var B := TNGram.Create(2);
  B.Train(Tokenize.Words(Datasets.Text('cuentos')));
  var Texto := Tokenize.Words('había una vez un hombre que vivía en el monte');
  Assert.True(T.Perplexity(Texto) > 0);
  Assert.True(B.Perplexity(Texto) > 0);
end;

procedure TestBpe;
begin
  var B := TBpe.Create;
  B.Train('la la la lala lalala', 3);
  Assert.True(B.MergeCount > 0);
  var T := B.Encode('la lala');
  Assert.Equal('la lala', B.Decode(T), 'decodificar devuelve el mismo texto');
  Assert.True(Length(T) < Length('la lala'), 'las uniones juntan caracteres');
end;

procedure TestEmbeddings;
begin
  var E := TWordEmbedding.Create(16);
  E.Train(Tokenize.Words(Datasets.Text('cuentos')), TRandom.Create(1), 1);
  Assert.True(E.VocabSize > 500);
  Assert.True(E.Has('loro'));
  Assert.True(Abs(E.Similarity('loro', 'loro') - 1) < 1e-9);
  Assert.Equal(5, Length(E.Nearest('loro', 5)));
  Assert.Raises('EArgumentException', procedure begin E.Vector('xyzzy'); end);
end;

procedure TestAtencionCausal;
begin
  // la salida de la posición 0 no depende de lo que viene después
  var Azar := TRandom.Create(4);
  var A := TSelfAttention.Create(4, Azar);
  var X := TTensor.Random(3, 4, Azar);
  var Y1 := A.Forward(X);
  X.Put(2, 0, X.Get(2, 0) + 5);
  var Y2 := A.Forward(X);
  Assert.True(Abs(Y1.Get(0, 1) - Y2.Get(0, 1)) < 1e-12, 'la primera posición no ve el futuro');
  Assert.True(Abs(Y1.Get(2, 1) - Y2.Get(2, 1)) > 1e-6, 'la última sí ve el cambio');
end;

procedure TestTransformerAprende;
begin
  // una secuencia que se repite: la pérdida tiene que bajar mucho
  var Azar := TRandom.Create(1);
  var M := TTinyTransformer.Create(4, 8, 8, Azar);
  var Opt := TAdam.Create(M.Parameters, 0.05);
  var Ids: TArray<Integer> := [0, 1, 2, 3, 0, 1, 2, 3, 0];
  var Primera := 0.0;
  var Ultima := 0.0;
  for var Paso := 1 to 80 do
  begin
    Opt.ZeroGrad;
    var L := M.Loss(Ids);
    L.Backward;
    Opt.Step;
    if Paso = 1 then Primera := L.Item;
    Ultima := L.Item;
  end;
  Assert.True(Ultima < Primera / 4, Format('la pérdida bajó de %.3f a %.3f', [Primera, Ultima]));
end;

procedure TestQLearning;
begin
  var Mundo := TGridWorld.Create(TGridWorld.Classic);
  var Agente := TQLearner.Create(Mundo.StateCount, 4, TRandom.Create(1));
  for var E := 1 to 300 do
    Agente.Episode(Mundo);
  Agente.Epsilon := 0;
  Assert.True(Agente.Episode(Mundo) >= 0, 'sin explorar llega a la meta sin pasar por la trampa');
end;
