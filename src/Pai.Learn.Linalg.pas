unit Pai.Learn.Linalg;

// Vectores y matrices, escritos para leerse. Un vector es un arreglo de reales; una matriz guarda
// sus números fila por fila en un solo arreglo.
//
//   var A := TMatrix.FromRows([[1, 2], [3, 4]]);
//   var V: TVec := [1, 1];
//   WriteLn(VecToStr(A * V));         // [3, 7]
//   WriteLn((A * A.Transpose).ToString);

interface

uses
  SysUtils, Pai.Learn.Random;

type
  TVec = TArray<Double>;

  TMatrix = record
  private
    function GetItem(R, C: Integer): Double;
    procedure SetItem(R, C: Integer; V: Double);
  public
    Rows, Cols: Integer;
    Data: TArray<Double>;           // fila por fila: el elemento (R, C) está en Data[R * Cols + C]
    constructor Create(ARows, ACols: Integer);   // llena de ceros
    class function Identity(N: Integer): TMatrix; static;
    class function FromRows(const ARows: TArray<TVec>): TMatrix; static;
    class function Random(ARows, ACols: Integer; Rng: TRandom; Scale: Double = 1): TMatrix; static;
    function Row(R: Integer): TVec;
    function Col(C: Integer): TVec;
    function Transpose: TMatrix;
    function ToString(Decimals: Integer = 2): string;
    property Items[R, C: Integer]: Double read GetItem write SetItem; default;

    class operator Add(const A, B: TMatrix): TMatrix;
    class operator Subtract(const A, B: TMatrix): TMatrix;
    class operator Multiply(const A, B: TMatrix): TMatrix;          // producto de matrices
    class operator Multiply(const A: TMatrix; const V: TVec): TVec; // matriz por vector
    class operator Multiply(K: Double; const A: TMatrix): TMatrix;  // número por matriz
  end;

function Dot(const A, B: TVec): Double;
function Add(const A, B: TVec): TVec;
function Sub(const A, B: TVec): TVec;
function Scale(K: Double; const A: TVec): TVec;
/// El largo del vector (norma euclidiana).
function Norm(const A: TVec): Double;
/// La distancia en línea recta entre dos puntos.
function Distance(const A, B: TVec): Double;
function Mean(const A: TVec): Double;
function VecToStr(const A: TVec; Decimals: Integer = 2): string;

implementation

procedure CheckSameLength(const A, B: TVec);
begin
  if Length(A) <> Length(B) then
    raise EArgumentException.CreateFmt('los vectores tienen largos distintos (%d y %d)', [Length(A), Length(B)]);
end;

function Dot(const A, B: TVec): Double;
begin
  CheckSameLength(A, B);
  Result := 0;
  for var I := 0 to High(A) do
    Result := Result + A[I] * B[I];
end;

function Add(const A, B: TVec): TVec;
begin
  CheckSameLength(A, B);
  SetLength(Result, Length(A));
  for var I := 0 to High(A) do
    Result[I] := A[I] + B[I];
end;

function Sub(const A, B: TVec): TVec;
begin
  CheckSameLength(A, B);
  SetLength(Result, Length(A));
  for var I := 0 to High(A) do
    Result[I] := A[I] - B[I];
end;

function Scale(K: Double; const A: TVec): TVec;
begin
  SetLength(Result, Length(A));
  for var I := 0 to High(A) do
    Result[I] := K * A[I];
end;

function Norm(const A: TVec): Double;
begin
  Result := Sqrt(Dot(A, A));
end;

function Distance(const A, B: TVec): Double;
begin
  Result := Norm(Sub(A, B));
end;

function Mean(const A: TVec): Double;
begin
  Result := 0;
  for var X in A do
    Result := Result + X;
  if Length(A) > 0 then
    Result := Result / Length(A);
end;

function VecToStr(const A: TVec; Decimals: Integer): string;
begin
  Result := '[';
  for var I := 0 to High(A) do
  begin
    if I > 0 then
      Result := Result + ', ';
    Result := Result + FloatToStrF(A[I], ffFixed, 15, Decimals);
  end;
  Result := Result + ']';
end;

{ TMatrix }

constructor TMatrix.Create(ARows, ACols: Integer);
begin
  Rows := ARows;
  Cols := ACols;
  SetLength(Data, ARows * ACols);
  for var I := 0 to High(Data) do
    Data[I] := 0;
end;

class function TMatrix.Identity(N: Integer): TMatrix;
begin
  Result := TMatrix.Create(N, N);
  for var I := 0 to N - 1 do
    Result[I, I] := 1;
end;

class function TMatrix.FromRows(const ARows: TArray<TVec>): TMatrix;
begin
  if Length(ARows) = 0 then
    Exit(TMatrix.Create(0, 0));
  Result := TMatrix.Create(Length(ARows), Length(ARows[0]));
  for var R := 0 to High(ARows) do
  begin
    if Length(ARows[R]) <> Result.Cols then
      raise EArgumentException.CreateFmt('la fila %d tiene %d números y la primera %d', [R, Length(ARows[R]), Result.Cols]);
    for var C := 0 to Result.Cols - 1 do
      Result[R, C] := ARows[R][C];
  end;
end;

class function TMatrix.Random(ARows, ACols: Integer; Rng: TRandom; Scale: Double): TMatrix;
begin
  Result := TMatrix.Create(ARows, ACols);
  for var I := 0 to High(Result.Data) do
    Result.Data[I] := Rng.Uniform(-Scale, Scale);
end;

function TMatrix.GetItem(R, C: Integer): Double;
begin
  Result := Data[R * Cols + C];
end;

procedure TMatrix.SetItem(R, C: Integer; V: Double);
begin
  Data[R * Cols + C] := V;
end;

function TMatrix.Row(R: Integer): TVec;
begin
  SetLength(Result, Cols);
  for var C := 0 to Cols - 1 do
    Result[C] := Self[R, C];
end;

function TMatrix.Col(C: Integer): TVec;
begin
  SetLength(Result, Rows);
  for var R := 0 to Rows - 1 do
    Result[R] := Self[R, C];
end;

function TMatrix.Transpose: TMatrix;
begin
  Result := TMatrix.Create(Cols, Rows);
  for var R := 0 to Rows - 1 do
    for var C := 0 to Cols - 1 do
      Result[C, R] := Self[R, C];
end;

function TMatrix.ToString(Decimals: Integer): string;
begin
  Result := '';
  for var R := 0 to Rows - 1 do
  begin
    if R > 0 then
      Result := Result + sLineBreak;
    Result := Result + VecToStr(Row(R), Decimals);
  end;
end;

class operator TMatrix.Add(const A, B: TMatrix): TMatrix;
begin
  if (A.Rows <> B.Rows) or (A.Cols <> B.Cols) then
    raise EArgumentException.CreateFmt('no se pueden sumar %dx%d y %dx%d', [A.Rows, A.Cols, B.Rows, B.Cols]);
  Result := TMatrix.Create(A.Rows, A.Cols);
  for var I := 0 to High(A.Data) do
    Result.Data[I] := A.Data[I] + B.Data[I];
end;

class operator TMatrix.Subtract(const A, B: TMatrix): TMatrix;
begin
  Result := A + (-1) * B;
end;

class operator TMatrix.Multiply(const A, B: TMatrix): TMatrix;
begin
  if A.Cols <> B.Rows then
    raise EArgumentException.CreateFmt('no se puede multiplicar %dx%d por %dx%d: las columnas de la primera ' +
      'tienen que ser tantas como las filas de la segunda', [A.Rows, A.Cols, B.Rows, B.Cols]);
  Result := TMatrix.Create(A.Rows, B.Cols);
  // cada elemento (R, C) es el producto punto de la fila R de A por la columna C de B
  for var R := 0 to A.Rows - 1 do
    for var C := 0 to B.Cols - 1 do
    begin
      var S := 0.0;
      for var K := 0 to A.Cols - 1 do
        S := S + A[R, K] * B[K, C];
      Result[R, C] := S;
    end;
end;

class operator TMatrix.Multiply(const A: TMatrix; const V: TVec): TVec;
begin
  if A.Cols <> Length(V) then
    raise EArgumentException.CreateFmt('no se puede multiplicar %dx%d por un vector de %d', [A.Rows, A.Cols, Length(V)]);
  SetLength(Result, A.Rows);
  for var R := 0 to A.Rows - 1 do
    Result[R] := Dot(A.Row(R), V);
end;

class operator TMatrix.Multiply(K: Double; const A: TMatrix): TMatrix;
begin
  Result := TMatrix.Create(A.Rows, A.Cols);
  for var I := 0 to High(A.Data) do
    Result.Data[I] := K * A.Data[I];
end;

end.
