// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Mira dos palabras atrás
procedure TestTrigramas;
begin
  var M := TTrigramas.Create;
  var P := M.Next(['había', 'una']);
  Assert.Equal('vez', P[0].Token, 'después de «había una» viene «vez»');
end;

/// Retrocede a bigramas
[Hint('Si Length(Result) = 0 después de pedirle a FTri, pide a FBi.')]
procedure TestRetroceso;
begin
  var M := TTrigramas.Create;
  var P := M.Next(['xyzzy', 'el']);
  Assert.True(Length(P) > 0, 'nunca vio «xyzzy el», pero sí «el»: tiene que retroceder');
  Assert.Equal('hombre', P[0].Token, 'después de «el» lo más frecuente es «hombre»');
end;

/// Narrador usa tu modelo de trigramas
procedure TestNarrador;
begin
  var R := Narrador.Chat('había una vez');
  Assert.Equal('pascal/TTrigramas', R.Model);
  Assert.True(R.Text <> '');
  Assert.Equal(0.0, R.Cost, 'un modelo propio no cuesta');
end;
