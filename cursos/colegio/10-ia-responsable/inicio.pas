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

/// Las frutas de Datos más copias de las peras (repitiéndolas en orden) hasta que haya tantas peras como
/// manzanas: «sobremuestrear» la clase con pocos ejemplos.
function Balancear(const Datos: TArray<TFruit>): TArray<TFruit>;
begin
  Todo('cuenta manzanas y peras, y agrega copias de las peras (una tras otra) hasta igualar a las manzanas');
end;

/// Para aprender: las 20 manzanas de Datasets.Fruits y solo 4 peras (lo que tenía a mano la frutería).
function Desbalanceado: TArray<TFruit>;
begin
  Result := [];
  var Peras := 0;
  for var F in Datasets.Fruits do
    if F.Name = 'apple' then
      Result := Result + [F]
    else if Peras < 4 then
    begin
      Result := Result + [F];
      Inc(Peras);
    end;
end;

/// Para comprobar, frutas que el modelo nunca vio, como llegan a la frutería: las 10 manzanas de
/// Datasets.FruitsTest y solo 2 peras.
function Clientes: TArray<TFruit>;
begin
  Result := [];
  var Peras := 0;
  for var F in Datasets.FruitsTest do
    if F.Name = 'apple' then
      Result := Result + [F]
    else if Peras < 2 then
    begin
      Result := Result + [F];
      Inc(Peras);
    end;
end;

/// La exactitud total: la fracción de todas las frutas de Prueba bien clasificadas (k = 9).
function Exactitud(const Datos, Prueba: TArray<TFruit>): Double;
begin
  var Bien := 0;
  for var F in Prueba do
    if Clasificar(F, Datos, 9) = F.Name then
      Inc(Bien);
  Result := Bien / Length(Prueba);
end;

begin
  var Prueba := Clientes;
  var D := Desbalanceado;
  WriteLn('Desbalanceado (', Length(D), ' frutas): exactitud total ', 100 * Exactitud(D, Prueba):0:0, ' %, manzanas ',
    100 * AciertoDe('apple', D, Prueba):0:0, ' %, peras ', 100 * AciertoDe('pear', D, Prueba):0:0, ' %');
  var B := Balancear(D);
  WriteLn('Balanceado (', Length(B), ' frutas): exactitud total ', 100 * Exactitud(B, Prueba):0:0, ' %, manzanas ',
    100 * AciertoDe('apple', B, Prueba):0:0, ' %, peras ', 100 * AciertoDe('pear', B, Prueba):0:0, ' %');
end.
