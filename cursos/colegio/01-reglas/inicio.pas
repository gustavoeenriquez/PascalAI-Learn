uses
  SysUtils;

type
  TAnimal = record
    Plumas, Vuela, Agua, Ladra: Boolean;
  end;

function Animal(Plumas, Vuela, Agua, Ladra: Boolean): TAnimal;
begin
  Result.Plumas := Plumas;
  Result.Vuela := Vuela;
  Result.Agua := Agua;
  Result.Ladra := Ladra;
end;

/// El nombre del animal, siguiendo las preguntas del árbol de LEEME.md:
/// 'águila', 'pingüino', 'delfín', 'perro' o 'gato'.
function Adivinar(const A: TAnimal): string;
begin
  if A.Plumas then
  begin
    Todo('pregunta si vuela');
  end
  else
    Todo('pregunta si vive en el agua y, si no, si ladra');
end;

begin
  //                       plumas vuela  agua   ladra
  WriteLn(Adivinar(Animal(True,  True,  False, False)));
  WriteLn(Adivinar(Animal(False, False, False, True)));
end.
