// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// La exactitud
procedure TestExactitud;
begin
  Assert.Equal(0.75, Exactitud([1, 2, 3, 4], [1, 2, 3, 0]));
  Assert.Equal(1.0, Exactitud([5, 5], [5, 5]));
  Assert.Equal(0.0, Exactitud([1], [2]));
end;

/// La matriz de confusión
[Hint('La fila es la clase VERDADERA (Real[i]) y la columna la ELEGIDA (Pred[i]): Inc(M[Real[I]][Pred[I]]).')]
procedure TestMatriz;
begin
  var M := MatrizDeConfusion([0, 1, 1, 2, 2, 2], [0, 1, 2, 2, 2, 0], 3);
  Assert.Equal(3, Length(M));
  Assert.Equal(1, M[0][0], 'un 0 bien clasificado');
  Assert.Equal(1, M[0][2], 'un 0 que el modelo creyó 2');
  Assert.Equal(1, M[2][1], 'un 2 que el modelo creyó 1');
  Assert.Equal(2, M[2][2], 'dos 2 bien clasificados');
  Assert.Equal(0, M[1][0]);
end;

/// La mejor época
[Hint('Las épocas se cuentan desde 1: si el mayor está en la posición 0, es la época 1.')]
procedure TestMejorEpoca;
begin
  Assert.Equal(3, MejorEpoca([0.5, 0.7, 0.9, 0.8, 0.85]));
  Assert.Equal(1, MejorEpoca([0.9]));
  Assert.Equal(2, MejorEpoca([0.1, 0.6, 0.6]), 'con empate, la primera');
end;

/// Con pocos datos, el modelo memoriza
procedure TestSobreajuste;
begin
  var Azar := TRandom.Create(7);
  var Tr, Te: TDataset;
  Datasets.Digits.Split(1 - 100 / 3823, Azar, Tr, Te);
  var Red := TMLP.Create([64, 64, 10], Azar);
  var Opt := TAdam.Create(Red.Parameters, 0.01);
  var XTr := TTensor.FromMatrix(Tr.X);
  for var E := 1 to 60 do
  begin
    Opt.ZeroGrad;
    CrossEntropy(Red.Forward(XTr), Tr.Labels).Backward;
    Opt.Step;
  end;
  var AE := Exactitud(ArgMaxRows(Red.Forward(XTr)), Tr.Labels);
  var AP := Exactitud(ArgMaxRows(Red.Forward(TTensor.FromMatrix(Te.X))), Te.Labels);
  Assert.Equal(1.0, AE, 'con 100 ejemplos y 60 épocas los acierta todos');
  Assert.True(AP < AE - 0.05, Format('con datos nuevos acierta menos: %.1f %%', [100 * AP]));
end;
