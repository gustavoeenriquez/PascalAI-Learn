// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Contar los pares
[Hint('Si Siguen no tiene la palabra, crea su diccionario: Siguen.Add(A, TDictionary<string, Integer>.Create). Después suma 1 a [B].')]
procedure TestContar;
begin
  Contar(['el', 'loro', 'y', 'el', 'loro', 'y', 'el', 'tigre']);
  Assert.Equal(2, Siguen['el']['loro'], '«loro» vino 2 veces después de «el»');
  Assert.Equal(1, Siguen['el']['tigre']);
  Assert.Equal(2, Siguen['loro']['y']);
  Assert.False(Siguen.ContainsKey('tigre'), '«tigre» es la última: nada viene después');
end;

/// La más frecuente
procedure TestMasFrecuente;
begin
  Contar(['el', 'loro', 'y', 'el', 'loro', 'y', 'el', 'tigre']);
  Assert.Equal('loro', LaMasFrecuente('el'));
  Assert.Equal('el', LaMasFrecuente('y'));
  Assert.Equal('', LaMasFrecuente('tigre'), 'nada vino después de «tigre»');
end;

/// Con los cuentos de Quiroga
procedure TestCuentos;
begin
  Contar(Tokenize.Words(Datasets.Text('cuentos')));
  Assert.Equal('vez', LaMasFrecuente('una'), 'después de «una» lo más frecuente es «vez»');
  Assert.Equal('hombre', LaMasFrecuente('el'), 'después de «el» lo más frecuente es «hombre» (44 veces)');
end;
