// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

/// Las aves
procedure TestAves;
begin
  Assert.Equal('águila', Adivinar(Animal(True, True, False, False)));
  Assert.Equal('pingüino', Adivinar(Animal(True, False, True, False)));
end;

/// El que vive en el agua
[Hint('Si no tiene plumas, la primera pregunta es si vive en el agua.')]
procedure TestAgua;
begin
  Assert.Equal('delfín', Adivinar(Animal(False, False, True, False)));
end;

/// Perro y gato
[Hint('Fíjate en las tildes y las minúsculas: el resultado tiene que ser exactamente ''perro'' o ''gato''.')]
procedure TestPerroYGato;
begin
  Assert.Equal('perro', Adivinar(Animal(False, False, False, True)));
  Assert.Equal('gato', Adivinar(Animal(False, False, False, False)));
end;
