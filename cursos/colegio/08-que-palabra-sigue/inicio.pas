uses
  SysUtils, Generics.Collections, Pai.Learn.Data, Pai.Learn.Text;

var
  // Siguen['una']['vez'] = cuántas veces vino «vez» después de «una»
  Siguen: TDictionary<string, TDictionary<string, Integer>>;

/// Cuenta los pares de palabras seguidas.
procedure Contar(const Palabras: TArray<string>);
begin
  Siguen := TDictionary<string, TDictionary<string, Integer>>.Create;
  Todo('para cada posición I (menos la última): la palabra I y la que sigue (I + 1); suma 1 en Siguen');
end;

/// La palabra que más veces vino después de Palabra ('' si nunca apareció).
function LaMasFrecuente(const Palabra: string): string;
begin
  Todo('recorre Siguen[Palabra] y quédate con la de más veces');
end;

begin
  Contar(Tokenize.Words(Datasets.Text('cuentos')));
  var P := 'había';
  var Frase := P;
  for var I := 1 to 15 do
  begin
    P := LaMasFrecuente(P);
    Frase := Frase + ' ' + P;
  end;
  WriteLn(Frase);
end.
