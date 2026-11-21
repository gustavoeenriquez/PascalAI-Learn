uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Data, Pai.Learn.Text, Pai.Learn.Tensor, Pai.Learn.NN, Pai.Learn.Attention;

/// Atención causal de una cabeza: softmax(Q · Kᵀ / √d, causal) · V, con Q = X·Wq, K = X·Wk, V = X·Wv.
function Atencion(const X, Wq, Wk, Wv: TTensor): TTensor;
begin
  Todo('Q, K, V con MatMul; los puntajes (1 / Sqrt(Q.Cols)) * Q.MatMul(K.Transpose); SoftmaxRows(True); por V');
end;

begin
  var Texto := Datasets.Text('cuentos');
  var Voc := TVocab.Create(Tokenize.Chars(Texto));
  var Ids := Voc.Encode(Tokenize.Chars(Texto));
  var Azar := TRandom.Create(1);
  var M := TTinyTransformer.Create(Voc.Count, 32, 32, Azar);
  var Opt := TAdam.Create(M.Parameters, 0.01);
  WriteLn('antes de entrenar: ', M.Generate(Voc, 'Había una vez', 60, Azar));
  for var Paso := 1 to 300 do
  begin
    Opt.ZeroGrad;
    var L := TTensor.Zeros(1, 1);
    for var B := 1 to 4 do
      L := L + M.Loss(Copy(Ids, Azar.NextInt(Length(Ids) - 33), 33));
    L := 0.25 * L;
    L.Backward;
    Opt.Step;
    if Paso mod 50 = 0 then
      WriteLn('paso ', Paso, ': pérdida ', L.Item:0:3);
  end;
  WriteLn('después: ', M.Generate(Voc, 'Había una vez', 120, Azar));
end.
