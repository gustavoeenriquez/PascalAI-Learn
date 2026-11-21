uses
  SysUtils, Generics.Collections, Pai.Learn.Data, Pai.Learn.Text;

/// El par de tokens vecinos más frecuente en todas las palabras, como 'a b'. '' si no hay pares.
function ParMasFrecuente(const Palabras: TArray<TArray<string>>): string;
begin
  Todo('cuenta cada par Palabra[I] + '' '' + Palabra[I + 1] en un diccionario y quédate con el mayor');
end;

/// Tokens con cada A seguido de B unido en un solo token A + B.
function Unir(const Tokens: TArray<string>; const A, B: string): TArray<string>;
begin
  Todo('recorre Tokens: si Tokens[I] = A y Tokens[I + 1] = B, agrega A + B y salta dos; si no, agrega Tokens[I]');
end;

begin
  var Cuento := Copy(Datasets.Text('cuentos'), 1, 9000);       // La tortuga gigante
  // cada palabra con su espacio delante, partida en caracteres
  var Palabras: TArray<TArray<string>> := [];
  for var W in Cuento.Split([' ', #10, #13]) do
    if W <> '' then
      Palabras := Palabras + [Tokenize.Chars(' ' + W)];
  for var M := 1 to 30 do
  begin
    var Par := ParMasFrecuente(Palabras);
    if Par = '' then
      Break;
    // el par se guarda como 'a b'; un token puede empezar con espacio, así que se parte por el último
    var I := Par.LastIndexOf(' ');
    var A := Par.Substring(0, I);
    var B := Par.Substring(I + 1);
    for var K := 0 to High(Palabras) do
      Palabras[K] := Unir(Palabras[K], A, B);
    Write('[', A + B, '] ');
  end;
  WriteLn;
  // perplejidad con un cuento que no vio
  var Todo_ := Tokenize.Words(Datasets.Text('cuentos'));
  var Entrena := Copy(Todo_, 0, Length(Todo_) - 2000);
  var Prueba := Copy(Todo_, Length(Todo_) - 2000, 2000);
  for var N := 1 to 3 do
  begin
    var Modelo := TNGram.Create(N);
    Modelo.Train(Entrena);
    WriteLn(N, '-gramas: perplejidad ', Modelo.Perplexity(Prueba):0:1);
  end;
end.
