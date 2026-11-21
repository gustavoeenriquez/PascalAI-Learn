// Las pruebas de la lección (las corre pai learn check). Sin uses ni begin..end: ven todo lo de inicio.pas.

function Ejemplo: TArray<TFruit>;
begin
  Result := [TFruit.Create(0.15, 0.20, 'pear'), TFruit.Create(0.15, 0.40, 'pear'),
    TFruit.Create(0.15, 0.55, 'apple'), TFruit.Create(0.15, 0.90, 'apple'), TFruit.Create(0.15, 0.45, 'apple')];
end;

/// Contar los errores de un umbral
procedure TestErrores;
begin
  Assert.Equal(0, ErroresConUmbral(Ejemplo, 0.42), 'con 0.42 todas quedan bien');
  Assert.Equal(1, ErroresConUmbral(Ejemplo, 0.50), 'con 0.50 la manzana de 0.45 queda como pera');
  Assert.Equal(2, ErroresConUmbral(Ejemplo, 0.10), 'con 0.10 las dos peras quedan como manzanas');
end;

/// Encontrar el mejor umbral
[Hint('Empieza con el primer umbral como el mejor y cámbialo cuando encuentres uno con MENOS errores.')]
procedure TestMejor;
begin
  var U := MejorUmbral(Ejemplo);
  Assert.Equal(0, ErroresConUmbral(Ejemplo, U), Format('el mejor umbral (%g) no se equivoca con ninguna', [U]));
end;

/// Funciona con frutas nuevas
procedure TestFrutasNuevas;
begin
  var U := MejorUmbral(Datasets.Fruits);
  Assert.True(ErroresConUmbral(Datasets.FruitsTest, U) <= 3,
    Format('con frutas nuevas se equivoca en %d de 20', [ErroresConUmbral(Datasets.FruitsTest, U)]));
end;
