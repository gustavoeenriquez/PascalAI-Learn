unit Pai.Learn.Random;

// Números al azar que se repiten: con la misma semilla salen siempre los mismos, en cualquier
// computador. Así todo el grupo ve los mismos resultados.
//
// Es el generador «estándar mínimo» de Park y Miller (1988), en su versión de 1993:
//   siguiente := (anterior * 48271) mod (2^31 - 1)
// Cabe en un Int64 sin desbordarse y se puede seguir a mano. Para enseñar es suficiente;
// para criptografía, no sirve.
//
//   var Azar := TRandom.Create(42);
//   WriteLn(Azar.NextDouble);        // un real en [0, 1)
//   WriteLn(Azar.Gauss(170, 15));    // peso de una manzana, en gramos

interface

type
  TRandom = class
  private
    FState: Int64;
  public
    /// Cualquier entero sirve de semilla (0 y los negativos también).
    constructor Create(Seed: Int64);
    /// Un real entre 0 (incluido) y 1 (excluido).
    function NextDouble: Double;
    /// Un entero entre 0 y N - 1.
    function NextInt(N: Integer): Integer;
    /// Un real entre A y B.
    function Uniform(A, B: Double): Double;
    /// Un real con distribución normal (campana) de media Mean y desviación StdDev.
    function Gauss(Mean, StdDev: Double): Double;
  end;

implementation

const
  Modulus = 2147483647;   // 2^31 - 1, un número primo
  Multiplier = 48271;

constructor TRandom.Create(Seed: Int64);
begin
  // el estado tiene que estar entre 1 y Modulus - 1
  FState := Abs(Seed) mod (Modulus - 1) + 1;
end;

function TRandom.NextDouble: Double;
begin
  FState := (FState * Multiplier) mod Modulus;
  Result := (FState - 1) / (Modulus - 1);
end;

function TRandom.NextInt(N: Integer): Integer;
begin
  Result := Trunc(NextDouble * N);
end;

function TRandom.Uniform(A, B: Double): Double;
begin
  Result := A + (B - A) * NextDouble;
end;

function TRandom.Gauss(Mean, StdDev: Double): Double;
var
  U1, U2: Double;
begin
  // método de Box y Muller: dos uniformes dan una normal
  repeat
    U1 := NextDouble;
  until U1 > 0;
  U2 := NextDouble;
  Result := Mean + StdDev * Sqrt(-2 * Ln(U1)) * Cos(2 * Pi * U2);
end;

end.
