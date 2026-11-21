uses
  SysUtils, Pai.Learn.Linalg, Pai.Learn.Data, Pai.Learn.Neighbors;

/// k vecinos (lección 5) con la biblioteca: la clase de F según los K vecinos de Datos.
function Clasificar(const F: TFruit; const Datos: TArray<TFruit>; K: Integer): string;
begin
  var Puntos: TArray<TVec> := [];
  var Clases: TArray<string> := [];
  for var D in Datos do
  begin
    Puntos := Puntos + [D.Features];
    Clases := Clases + [D.Name];
  end;
  Result := KNearest(Puntos, Clases, F.Features, K);
end;

/// De las frutas de Prueba que son de Clase, la fracción que se clasifica bien (k = 9).
function AciertoDe(const Clase: string; const Datos, Prueba: TArray<TFruit>): Double;
begin
  Todo('cuenta las de esa clase en Prueba y cuántas de ellas Clasificar acierta');
end;

/// Las frutas de Datos, con tantas de cada clase como tiene la clase con menos.
function Balancear(const Datos: TArray<TFruit>): TArray<TFruit>;
begin
  Todo('cuenta manzanas y peras, y toma las primeras N de cada una (N = la menor cuenta)');
end;

/// 36 manzanas y 4 peras: lo que tenía a mano la frutería.
function Desbalanceado: TArray<TFruit>;
begin
  Result := [];
  var Peras := 0;
  for var F in Datasets.Fruits + Datasets.FruitsTest do
    if F.Name = 'apple' then
      Result := Result + [F]
    else if Peras < 4 then
    begin
      Result := Result + [F];
      Inc(Peras);
    end;
end;

begin
  var Prueba := Datasets.Fruits;
  var D := Desbalanceado;
  WriteLn('Desbalanceado: manzanas ', 100 * AciertoDe('apple', D, Prueba):0:0, ' %, peras ',
    100 * AciertoDe('pear', D, Prueba):0:0, ' %');
  var B := Balancear(D);
  WriteLn('Balanceado (', Length(B), ' frutas): manzanas ', 100 * AciertoDe('apple', B, Prueba):0:0, ' %, peras ',
    100 * AciertoDe('pear', B, Prueba):0:0, ' %');
end.
