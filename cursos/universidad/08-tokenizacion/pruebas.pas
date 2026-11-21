// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Unir un par
procedure TestUnir;
begin
  Assert.Equal('ab|c|ab', string.Join('|', Unir(['a', 'b', 'c', 'a', 'b'], 'a', 'b')));
  Assert.Equal('aa|a', string.Join('|', Unir(['a', 'a', 'a'], 'a', 'a')), 'de izquierda a derecha, sin solaparse');
  Assert.Equal('x|y', string.Join('|', Unir(['x', 'y'], 'a', 'b')), 'si el par no está, queda igual');
end;

/// El par más frecuente
[Hint('La clave del diccionario es A + '' '' + B; al final recorre las claves y quédate con la de mayor cuenta (con empate, la menor alfabéticamente).')]
procedure TestParMasFrecuente;
begin
  var P: TArray<TArray<string>> := [['l', 'a'], ['l', 'a', 's'], ['a', 's']];
  Assert.Equal('a s', ParMasFrecuente(P), '«l a» y «a s» aparecen 2 veces cada uno: gana el menor alfabéticamente');
  var Q: TArray<TArray<string>> := [['x', 'y', 'x', 'y'], ['y', 'x']];
  Assert.Equal('x y', ParMasFrecuente(Q), '«x y» y «y x» aparecen 2 veces cada uno: gana el menor alfabéticamente');
end;

/// Sin pares
procedure TestSinPares;
begin
  var P: TArray<TArray<string>> := [['a'], ['b']];
  Assert.Equal('', ParMasFrecuente(P));
end;
