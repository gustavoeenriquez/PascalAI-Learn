uses
  SysUtils, Pai.Learn.Random, Pai.Learn.Linalg, Pai.Learn.Data;

/// Distancia al cuadrado entre la fila I de X y la fila C de Centros.
function Dist2(const X: TMatrix; I: Integer; const Centros: TMatrix; C: Integer): Double;
begin
  Result := 0;
  for var J := 0 to X.Cols - 1 do
    Result := Result + Sqr(X[I, J] - Centros[C, J]);
end;

/// Cada fila de X al centro más cercano. True si algún punto cambió de grupo.
function Asignar(const X, Centros: TMatrix; var Grupo: TArray<Integer>): Boolean;
begin
  Todo('para cada fila, el centro con menor Dist2; anota si cambió');
end;

/// Cada centro al promedio de los puntos de su grupo.
procedure Mover(const X: TMatrix; const Grupo: TArray<Integer>; var Centros: TMatrix);
begin
  Todo('suma las filas de cada grupo, cuéntalas y divide');
end;

function Inercia(const X, Centros: TMatrix; const Grupo: TArray<Integer>): Double;
begin
  Result := 0;
  for var I := 0 to X.Rows - 1 do
    Result := Result + Dist2(X, I, Centros, Grupo[I]);
end;

/// k-means completo: centros iniciales = las filas Inicio de X.
function Agrupar(const X: TMatrix; const Inicio: TArray<Integer>; out Centros: TMatrix): TArray<Integer>;
begin
  Centros := TMatrix.Create(Length(Inicio), X.Cols);
  for var C := 0 to High(Inicio) do
    for var J := 0 to X.Cols - 1 do
      Centros[C, J] := X[Inicio[C], J];
  SetLength(Result, X.Rows);
  for var I := 0 to High(Result) do
    Result[I] := -1;
  var Vueltas := 0;
  while Asignar(X, Centros, Result) and (Vueltas < 100) do
  begin
    Mover(X, Result, Centros);
    Inc(Vueltas);
  end;
end;

begin
  var Flores := Datasets.Iris;
  var Centros: TMatrix;
  var Grupo := Agrupar(Flores.X, [0, 50, 100], Centros);
  WriteLn('inercia: ', Inercia(Flores.X, Centros, Grupo):0:2);
  // cuántas flores de cada especie cayeron en cada grupo
  for var G := 0 to 2 do
  begin
    Write('grupo ', G, ':');
    for var E := 0 to 2 do
    begin
      var N := 0;
      for var I := 0 to Flores.Count - 1 do
        if (Grupo[I] = G) and (Flores.Labels[I] = E) then
          Inc(N);
      Write('  ', Flores.ClassNames[E], ' ', N);
    end;
    WriteLn;
  end;
end.
