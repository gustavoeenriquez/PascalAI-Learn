unit Pai.Learn.Data;

// Conjuntos de datos pequeños para las lecciones. Los que se generan aquí salen siempre iguales
// (semilla fija) y se puede leer cómo se hicieron. Fuente y licencia de cada uno: datos/DATOS.md.
//
//   for var F in Datasets.Fruits do
//     WriteLn(F.Name, ' ', F.Weight:0:3, ' kg, roja ', F.Redness:0:2);

interface

uses
  SysUtils, Classes, IOUtils, Pai.Learn.Random, Pai.Learn.Linalg;

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

  /// Un conjunto para clasificar: una fila de X por ejemplo y su clase (0, 1, 2...) en Labels.
  TDataset = record
    X: TMatrix;
    Labels: TArray<Integer>;
    ClassNames: TArray<string>;
    function Count: Integer;
    function Features: Integer;
    /// Los ejemplos de esas posiciones, en ese orden.
    function Subset(const Indices: TArray<Integer>): TDataset;
    /// Mezcla y separa: TestFraction de los ejemplos van a Test y el resto a Train.
    procedure Split(TestFraction: Double; Rng: TRandom; out Train, Test: TDataset);
  end;

  Datasets = class
  public
    /// Iris (Fisher, 1936): 150 flores, 4 medidas en cm (largo y ancho del sépalo y del pétalo),
    /// 3 especies. UCI Machine Learning Repository, CC BY 4.0 (doi 10.24432/C56C76).
    class function Iris: TDataset; static;
    /// Dígitos escritos a mano de 8 x 8 (Alpaydin y Kaynak, 1998): cada fila son 64 casillas con
    /// valores de 0 a 1 (cuánta tinta), y la clase es el dígito. Train: 3823; si no, los 1797 de
    /// prueba (de otras personas). UCI Machine Learning Repository, CC BY 4.0 (doi 10.24432/C50P49).
    class function Digits(Train: Boolean = True): TDataset; static;
    /// Un texto de datos/: 'cuentos' son los Cuentos de la selva de Horacio Quiroga (1918, dominio
    /// público; de Wikisource).
    class function Text(const Name: string): string; static;
    /// La carpeta datos/ de los cursos (PAI_LEARN o ~/.pai/learn).
    class function DataDir: string; static;
    /// 40 frutas para aprender (20 manzanas y 20 peras), en orden mezclado.
    class function Fruits: TArray<TFruit>; static;
    /// 20 frutas distintas, para comprobar con frutas que el modelo no vio.
    class function FruitsTest: TArray<TFruit>; static;
    /// La tabla del O exclusivo: 1 si las entradas son distintas, 0 si son iguales.
    class function XorTable: TArray<TSample>; static;
  end;

implementation

uses
  Math;

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

// ------------------------------------------------------------------ conjuntos de archivos

function TDataset.Count: Integer;
begin
  Result := Length(Labels);
end;

function TDataset.Features: Integer;
begin
  Result := X.Cols;
end;

function TDataset.Subset(const Indices: TArray<Integer>): TDataset;
begin
  Result.ClassNames := ClassNames;
  Result.X := TMatrix.Create(Length(Indices), X.Cols);
  SetLength(Result.Labels, Length(Indices));
  for var I := 0 to High(Indices) do
  begin
    for var C := 0 to X.Cols - 1 do
      Result.X[I, C] := X[Indices[I], C];
    Result.Labels[I] := Labels[Indices[I]];
  end;
end;

procedure TDataset.Split(TestFraction: Double; Rng: TRandom; out Train, Test: TDataset);
var
  Idx: TArray<Integer>;
begin
  SetLength(Idx, Count);
  for var I := 0 to High(Idx) do
    Idx[I] := I;
  for var I := High(Idx) downto 1 do
  begin
    var J := Rng.NextInt(I + 1);
    var T := Idx[I];
    Idx[I] := Idx[J];
    Idx[J] := T;
  end;
  var NTest := Round(Count * TestFraction);
  Test := Subset(Copy(Idx, 0, NTest));
  Train := Subset(Copy(Idx, NTest, Count - NTest));
end;

class function Datasets.DataDir: string;
begin
  Result := GetEnvironmentVariable('PAI_LEARN');
  if Result = '' then
    Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, '.pai'), 'learn');
  Result := TPath.Combine(Result, 'datos');
  if not TDirectory.Exists(Result) then
    raise EFileNotFoundException.Create('no encuentro la carpeta datos/ de los cursos: ponga PAI_LEARN=<carpeta de PascalAI-Learn>');
end;

function ReadLines(const AFile: string): TArray<string>;
begin
  Result := [];
  for var L in TFile.ReadAllLines(TPath.Combine(Datasets.DataDir, AFile)) do
    if L.Trim <> '' then
      Result := Result + [L.Trim];
end;

class function Datasets.Text(const Name: string): string;
begin
  var F := if SameText(Name, 'cuentos') then 'cuentos-de-la-selva.txt' else Name;
  Result := TFile.ReadAllText(TPath.Combine(DataDir, F), TEncoding.UTF8);
  if Result.StartsWith(#$FEFF) then
    Result := Result.Substring(1);
end;

class function Datasets.Iris: TDataset;
begin
  var Lines := ReadLines('iris.csv');
  Result.ClassNames := ['setosa', 'versicolor', 'virginica'];
  Result.X := TMatrix.Create(Length(Lines), 4);
  SetLength(Result.Labels, Length(Lines));
  for var I := 0 to High(Lines) do
  begin
    var F := Lines[I].Split([',']);
    for var C := 0 to 3 do
      Result.X[I, C] := StrToFloat(F[C]);
    var Name := F[4].Replace('Iris-', '');
    Result.Labels[I] := 0;
    for var K := 0 to High(Result.ClassNames) do
      if Result.ClassNames[K] = Name then
        Result.Labels[I] := K;
  end;
end;

class function Datasets.Digits(Train: Boolean): TDataset;
begin
  var Lines := ReadLines(if Train then 'digitos-entrenamiento.csv' else 'digitos-prueba.csv');
  Result.ClassNames := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  Result.X := TMatrix.Create(Length(Lines), 64);
  SetLength(Result.Labels, Length(Lines));
  for var I := 0 to High(Lines) do
  begin
    var F := Lines[I].Split([',']);
    for var C := 0 to 63 do
      Result.X[I, C] := StrToInt(F[C]) / 16;     // de 0..16 a 0..1
    Result.Labels[I] := StrToInt(F[64]);
  end;
end;

end.
