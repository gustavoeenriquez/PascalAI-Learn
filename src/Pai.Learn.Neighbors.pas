unit Pai.Learn.Neighbors;

// k vecinos más cercanos: para clasificar algo nuevo, se buscan los K ejemplos conocidos más
// parecidos (más cercanos) y gana la clase que más se repite entre ellos.
//
//   var Clase := KNearest(Puntos, Clases, [0.152, 0.81], 3);

interface

uses
  SysUtils, Generics.Collections, Pai.Learn.Linalg;

/// Las posiciones de los K puntos más cercanos a Query, del más cercano al más lejano.
function NearestIndices(const Points: TArray<TVec>; const Query: TVec; K: Integer): TArray<Integer>;

/// La clase que más se repite entre los K vecinos más cercanos. Si hay empate, gana la del
/// vecino más cercano entre las empatadas.
function KNearest(const Points: TArray<TVec>; const Labels: TArray<string>; const Query: TVec;
  K: Integer): string;

implementation

function NearestIndices(const Points: TArray<TVec>; const Query: TVec; K: Integer): TArray<Integer>;
var
  Dist: TArray<Double>;
  Idx: TArray<Integer>;
begin
  SetLength(Dist, Length(Points));
  SetLength(Idx, Length(Points));
  for var I := 0 to High(Points) do
  begin
    Dist[I] := Distance(Points[I], Query);
    Idx[I] := I;
  end;
  // ordenar por inserción: simple y suficiente para unas decenas de puntos
  for var I := 1 to High(Idx) do
  begin
    var J := I;
    while (J > 0) and (Dist[Idx[J - 1]] > Dist[Idx[J]]) do
    begin
      var T := Idx[J];
      Idx[J] := Idx[J - 1];
      Idx[J - 1] := T;
      Dec(J);
    end;
  end;
  if K > Length(Idx) then
    K := Length(Idx);
  Result := Copy(Idx, 0, K);
end;

function KNearest(const Points: TArray<TVec>; const Labels: TArray<string>; const Query: TVec;
  K: Integer): string;
begin
  if Length(Points) <> Length(Labels) then
    raise EArgumentException.Create('hay que dar una clase por cada punto');
  var Votes := TDictionary<string, Integer>.Create;
  try
    var Near := NearestIndices(Points, Query, K);
    for var I in Near do
      if Votes.ContainsKey(Labels[I]) then
        Votes[Labels[I]] := Votes[Labels[I]] + 1
      else
        Votes.Add(Labels[I], 1);
    // recorrer en orden de cercanía: con empate se queda la que apareció primero
    Result := '';
    var BestVotes := 0;
    for var I in Near do
      if Votes[Labels[I]] > BestVotes then
      begin
        BestVotes := Votes[Labels[I]];
        Result := Labels[I];
      end;
  finally
    Votes.Free;
  end;
end;

end.
