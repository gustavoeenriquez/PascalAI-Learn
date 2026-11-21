# Evaluar: entrenamiento, prueba y sobreajuste

Un modelo que acierta el 100 % de los ejemplos con que aprendió puede ser un mal modelo: tal vez los
**memorizó**. Lo que importa es cómo le va con datos **nuevos**. Por eso los datos se separan:

- **entrenamiento**: con estos aprende;
- **prueba**: no los ve nunca mientras aprende; solo sirven para medirlo al final.

Cuando la exactitud de entrenamiento sigue subiendo y la de prueba se estanca o baja, el modelo está
**sobreajustando**: aprende detalles (ruido) de los ejemplos que no sirven para los nuevos. Una defensa
simple es la **parada temprana**: guardar el modelo de la época con mejor exactitud en datos que no usó
para aprender.

La exactitud sola puede engañar. La **matriz de confusión** dice qué clases confunde: la fila es la clase
verdadera y la columna la que eligió el modelo.

## Lo que vas a hacer

1. `Exactitud(Pred, Real)`: la fracción de aciertos.
2. `MatrizDeConfusion(Pred, Real, Clases)`.
3. `MejorEpoca(Validacion)`: la época (desde 1) con mayor exactitud de validación.

Después corre el programa: entrena una red grande con solo 100 dígitos y escribe, época por época, la
exactitud de entrenamiento y la de prueba. Mira `sobreajuste.svg`.

## Para pensar

- ¿En qué época empieza a separarse la curva de entrenamiento de la de prueba?
- ¿Qué dígitos confunde más el modelo? ¿Tiene sentido (un 3 con un 8, un 1 con un 7)?
- Si eliges la mejor época mirando los datos de **prueba**, ¿sigue siendo honesta la medida final?
  (por eso se usa un tercer grupo: **validación**)
