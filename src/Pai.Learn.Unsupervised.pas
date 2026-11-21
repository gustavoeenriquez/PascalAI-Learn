unit Pai.Learn.Unsupervised;

// Aprender sin etiquetas: k-means (agrupar puntos parecidos) y PCA (encontrar las direcciones en
// que más varían los datos, para verlos en 2D).
//
//   var G := KMeans(Datos.X, 3, Azar);           // G.Assign[i]: el grupo del punto i
//   var P := PCA(Datos.X, 2);                    // P.Projected: los puntos en 2 dimensiones

interface

uses
  SysUtils, Math, Pai.Learn.Random, Pai.Learn.Linalg;

type
  TKMeansResult = record
    Centers: TMatrix;              // K x columnas
    Assign: TArray<Integer>;       // el grupo de cada fila
    Iterations: Integer;
    Inertia: Double;               // suma de distancias² de cada punto a su centro
  end;

  TPCAResult = record
    Mean: TVec;                    // el promedio de cada columna (se resta antes de proyectar)
    Components: TMatrix;           // K x columnas: las direcciones, de la que más varía a la que menos
    Variance: TVec;                // cuánto varían los datos en cada dirección
    Projected: TMatrix;            // filas x K: los datos en las nuevas coordenadas
  end;

/// k-means (algoritmo de Lloyd): K centros elegidos entre los puntos; repite asignar cada punto al
/// centro más cercano y mover cada centro al promedio de sus puntos, hasta que nada cambie.
function KMeans(const X: TMatrix; K: Integer; Rng: TRandom; MaxIterations: Integer = 100): TKMeansResult;

/// Análisis de componentes principales: las K direcciones de mayor varianza (por el método de la
/// potencia sobre la matriz de covarianza, quitando cada dirección encontrada).
function PCA(const X: TMatrix; K: Integer): TPCAResult;

implementation

function SqDist(const X: TMatrix; Row: Integer; const C: TMatrix; CRow: Integer): Double;
begin
  Result := 0;
  for var J := 0 to X.Cols - 1 do
    Result := Result + Sqr(X[Row, J] - C[CRow, J]);
end;

function KMeans(const X: TMatrix; K: Integer; Rng: TRandom; MaxIterations: Integer): TKMeansResult;
begin
  if (K < 1) or (K > X.Rows) then
    raise EArgumentException.CreateFmt('KMeans: K = %d con %d puntos', [K, X.Rows]);
  // centros iniciales: K puntos distintos al azar
  Result.Centers := TMatrix.Create(K, X.Cols);
  var Taken: TArray<Integer> := [];
  while Length(Taken) < K do
  begin
    var P := Rng.NextInt(X.Rows);
    var Dup := False;
    for var T in Taken do
      if T = P then
        Dup := True;
    if not Dup then
    begin
      for var J := 0 to X.Cols - 1 do
        Result.Centers[Length(Taken), J] := X[P, J];
      Taken := Taken + [P];
    end;
  end;
  SetLength(Result.Assign, X.Rows);
  for var I := 0 to X.Rows - 1 do
    Result.Assign[I] := -1;
  Result.Iterations := 0;
  var Changed := True;
  while Changed and (Result.Iterations < MaxIterations) do
  begin
    Inc(Result.Iterations);
    Changed := False;
    // 1) cada punto al centro más cercano
    for var I := 0 to X.Rows - 1 do
    begin
      var Best := 0;
      for var C := 1 to K - 1 do
        if SqDist(X, I, Result.Centers, C) < SqDist(X, I, Result.Centers, Best) then
          Best := C;
      if Best <> Result.Assign[I] then
      begin
        Result.Assign[I] := Best;
        Changed := True;
      end;
    end;
    // 2) cada centro al promedio de sus puntos (uno sin puntos se queda donde estaba)
    for var C := 0 to K - 1 do
    begin
      var N := 0;
      var Sum := TMatrix.Create(1, X.Cols);
      for var I := 0 to X.Rows - 1 do
        if Result.Assign[I] = C then
        begin
          Inc(N);
          for var J := 0 to X.Cols - 1 do
            Sum[0, J] := Sum[0, J] + X[I, J];
        end;
      if N > 0 then
        for var J := 0 to X.Cols - 1 do
          Result.Centers[C, J] := Sum[0, J] / N;
    end;
  end;
  Result.Inertia := 0;
  for var I := 0 to X.Rows - 1 do
    Result.Inertia := Result.Inertia + SqDist(X, I, Result.Centers, Result.Assign[I]);
end;

function PCA(const X: TMatrix; K: Integer): TPCAResult;
begin
  var N := X.Rows;
  var D := X.Cols;
  if (K < 1) or (K > D) then
    raise EArgumentException.CreateFmt('PCA: K = %d con %d columnas', [K, D]);
  // centrar: restar el promedio de cada columna
  SetLength(Result.Mean, D);
  for var J := 0 to D - 1 do
  begin
    var S := 0.0;
    for var I := 0 to N - 1 do
      S := S + X[I, J];
    Result.Mean[J] := S / N;
  end;
  var Xc := TMatrix.Create(N, D);
  for var I := 0 to N - 1 do
    for var J := 0 to D - 1 do
      Xc[I, J] := X[I, J] - Result.Mean[J];
  // covarianza: Xcᵀ · Xc / (N - 1)
  var Cov := (1 / Max(1, N - 1)) * (Xc.Transpose * Xc);
  Result.Components := TMatrix.Create(K, D);
  SetLength(Result.Variance, K);
  for var C := 0 to K - 1 do
  begin
    // método de la potencia: multiplicar una y otra vez por Cov alinea el vector con la dirección
    // de mayor varianza
    var V: TVec;
    SetLength(V, D);
    for var J := 0 to D - 1 do
      V[J] := 1 + J * 0.01;
    for var It := 1 to 500 do
    begin
      var W := Cov * V;
      var Nw := Norm(W);
      if Nw = 0 then
        Break;
      V := Scale(1 / Nw, W);
    end;
    var Lambda := Dot(V, Cov * V);
    Result.Variance[C] := Lambda;
    for var J := 0 to D - 1 do
      Result.Components[C, J] := V[J];
    // quitarle a Cov esa dirección (deflación) para encontrar la siguiente
    for var A := 0 to D - 1 do
      for var B := 0 to D - 1 do
        Cov[A, B] := Cov[A, B] - Lambda * V[A] * V[B];
  end;
  Result.Projected := Xc * Result.Components.Transpose;
end;

end.
