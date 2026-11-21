uses
  SysUtils, Pai.Learn.Data;

/// 'apple' si la rojez de F es mayor que el umbral U; si no, 'pear'.
function Clasificar(const F: TFruit; U: Double): string;
begin
  if F.Redness > U then
    Result := 'apple'
  else
    Result := 'pear';
end;

/// Cuántas frutas de Datos quedan mal clasificadas con el umbral U.
function ErroresConUmbral(const Datos: TArray<TFruit>; U: Double): Integer;
begin
  Todo('recorre Datos y cuenta las que Clasificar(F, U) no acierta (F.Name es la respuesta)');
end;

/// El umbral (una de las rojeces de Datos) con menos errores.
function MejorUmbral(const Datos: TArray<TFruit>): Double;
begin
  Todo('prueba como umbral la rojez de cada fruta y quédate con la de menos errores');
end;

begin
  var Datos := Datasets.Fruits;
  var U := MejorUmbral(Datos);
  WriteLn('La mejor pregunta: ¿la rojez es mayor que ', U:0:2, '?');
  WriteLn('Errores con las frutas conocidas: ', ErroresConUmbral(Datos, U), ' de ', Length(Datos));
  WriteLn('Errores con frutas nuevas: ', ErroresConUmbral(Datasets.FruitsTest, U), ' de ', Length(Datasets.FruitsTest));
end.
