# Árboles de decisión

En la lección 1 escribiste las preguntas a mano («¿tiene plumas?»). Un **árbol de decisión** que
**aprende** elige solo las preguntas, mirando los ejemplos.

La pregunta más simple sobre una fruta es: «¿la rojez es mayor que un número?». Ese número es el
**umbral**. ¿Cuál umbral es el mejor? El que **menos se equivoca** con las frutas que ya conocemos.

La idea para encontrarlo:

1. Probar como umbral la rojez de cada fruta conocida.
2. Para cada uno, contar cuántas frutas quedarían mal clasificadas si decimos «manzana si la rojez es
   mayor que el umbral, pera si no».
3. Quedarse con el umbral que da menos errores.

Esa pregunta sola es un árbol de un nivel (un «tocón»). Un árbol de verdad vuelve a hacer lo mismo con
cada mitad, y así se arma el árbol entero.

## Lo que vas a hacer

1. `ErroresConUmbral(Datos, U)`: cuántas frutas se clasifican mal con el umbral U.
2. `MejorUmbral(Datos)`: prueba cada rojez y devuelve el umbral con menos errores.

## Para pensar

- ¿Qué pasa si en vez de la rojez se pregunta por el peso? ¿Cuál de las dos es mejor pregunta?
- Un árbol muy profundo puede acertar **todas** las frutas conocidas. ¿Eso quiere decir que va a acertar
  con frutas nuevas? (se llama **sobreajuste**, y lo vas a ver en la universidad)
