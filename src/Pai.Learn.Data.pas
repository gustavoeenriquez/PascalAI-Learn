unit Pai.Learn.Data;

// Conjuntos de datos pequeños para las lecciones. Los que se generan aquí salen siempre iguales
// (semilla fija) y se puede leer cómo se hicieron. Fuente y licencia de cada uno: datos/DATOS.md.
//
//   for var F in Datasets.Fruits do
//     WriteLn(F.Name, ' ', F.Weight:0:3, ' kg, roja ', F.Redness:0:2);

interface

uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Linalg;

type
  /// Una fruta: cuánto pesa y qué tan roja es. Name es 'apple' o 'pear'; Target, +1 o -1
  /// (manzana o pera), para los modelos que separan en dos clases.
  TFruit = record
    Weight: Double;     // en kilogramos
    Redness: Double;    // 0 = nada roja, 1 = completamente roja
    Name: string;
    Target: Integer;
    constructor Create(AWeight, ARedness: Double; const AName: string = '');
    /// Las dos medidas como vector: [Weight, Redness].
    function Features: TVec;
  end;

  /// Un ejemplo con entradas (X) y la salida esperada (Y).
  TSample = record
    X: TVec;
    Y: Double;
  end;

  Datasets = class
  public
    /// 40 frutas para aprender (20 manzanas y 20 peras), en orden mezclado.
    class function Fruits: TArray<TFruit>; static;
    /// 20 frutas distintas, para comprobar con frutas que el modelo no vio.
    class function FruitsTest: TArray<TFruit>; static;
    /// La tabla del O exclusivo: 1 si las entradas son distintas, 0 si son iguales.
    class function XorTable: TArray<TSample>; static;
  end;

implementation

constructor TFruit.Create(AWeight, ARedness: Double; const AName: string);
begin
  Weight := AWeight;
  Redness := ARedness;
  Name := AName;
  Target := if AName = 'apple' then 1 else if AName = 'pear' then -1 else 0;
end;

function TFruit.Features: TVec;
begin
  Result := [Weight, Redness];
end;

function Clamp(X, Lo, Hi: Double): Double;
begin
  Result := if X < Lo then Lo else if X > Hi then Hi else X;
end;

// Manzanas: unos 170 g y bastante rojas. Peras: unos 128 g y poco rojas. Con algo de ruido,
// así que algunas se parecen a las de la otra clase.
function MakeFruits(Seed, PerKind: Integer): TArray<TFruit>;
begin
  var Rng := TRandom.Create(Seed);
  try
    SetLength(Result, 2 * PerKind);
    for var I := 0 to PerKind - 1 do
      Result[I] := TFruit.Create(Rng.Gauss(0.170, 0.014), Clamp(Rng.Gauss(0.72, 0.11), 0.05, 0.98), 'apple');
    for var I := PerKind to 2 * PerKind - 1 do
      Result[I] := TFruit.Create(Rng.Gauss(0.128, 0.014), Clamp(Rng.Gauss(0.34, 0.13), 0.03, 0.95), 'pear');
    // mezclar (Fisher-Yates), para que no vengan todas las manzanas primero
    for var I := High(Result) downto 1 do
    begin
      var J := Rng.NextInt(I + 1);
      var T := Result[I];
      Result[I] := Result[J];
      Result[J] := T;
    end;
  finally
    Rng.Free;
  end;
end;

class function Datasets.Fruits: TArray<TFruit>;
begin
  Result := MakeFruits(7, 20);
end;

class function Datasets.FruitsTest: TArray<TFruit>;
begin
  Result := MakeFruits(8, 10);
end;

class function Datasets.XorTable: TArray<TSample>;

  function S(A, B, Y: Double): TSample;
  begin
    Result.X := [A, B];
    Result.Y := Y;
  end;

begin
  Result := [S(0, 0, 0), S(0, 1, 1), S(1, 0, 1), S(1, 1, 0)];
end;

end.
