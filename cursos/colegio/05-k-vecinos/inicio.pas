uses
  SysUtils, Pai.Collections, Pai.Learn.Data;

/// Qué tan distintas son dos frutas: la distancia en línea recta entre
/// (peso, rojez) de una y de la otra.
function Distancia(const A, B: TFruit): Double;
begin
  Todo('calcula la distancia entre A y B (mira LEEME.md)');
end;

/// La clase que más se repite entre las K frutas más parecidas a F.
function Clasificar(const F: TFruit; const Datos: TArray<TFruit>; K: Integer): string;
begin
  // las frutas de Datos, de la más parecida a la menos parecida
  var Orden := Datos.OrderBy(D => Distancia(F, D));
  Todo('cuenta cuántas manzanas y cuántas peras hay entre las K primeras de Orden');
end;

begin
  var Datos := Datasets.Fruits;
  var Nueva := TFruit.Create(0.152, 0.81);
  WriteLn('La fruta nueva es: ', Clasificar(Nueva, Datos, 3));
end.
