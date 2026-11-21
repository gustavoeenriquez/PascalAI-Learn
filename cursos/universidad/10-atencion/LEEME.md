# Atención: un transformer diminuto

Un n-grama mira un número fijo de palabras atrás. La **atención** (Vaswani et al., 2017, «Attention is all
you need») deja que cada posición decida **a qué posiciones anteriores mirar** y cuánto. Es el corazón de
todos los modelos de lenguaje actuales.

Para una secuencia X (una fila por token):

```
Q = X · Wq        lo que cada posición pregunta
K = X · Wk        la llave que ofrece cada posición
V = X · Wv        lo que entrega cada posición
pesos = softmax( Q · Kᵀ / √d )      con máscara causal: la fila i solo ve las columnas 0..i
salida = pesos · V
```

La fila i de `pesos` dice cuánto mira la posición i a cada posición anterior. La división por √d (d es el
número de columnas de Q) evita que los puntajes sean enormes y el softmax se sature.

## Lo que vas a hacer

`Atencion(X, Wq, Wk, Wv)`: las fórmulas de arriba con `TTensor` (`MatMul`, `Transpose`,
`SoftmaxRows(True)` y un número por tensor: `K * T`). Como todo es `TTensor`, el gradiente sale solo.

El programa entrena `TTinyTransformer` de `Pai.Learn.Attention` (que usa la misma atención) con los
cuentos de Quiroga, carácter por carácter, y escribe un texto. Tarda un par de minutos: es un modelo de
verdad, en chiquito.

## Para pensar

- ¿Qué escribe antes de entrenar? ¿Y después de 300 pasos? ¿Reconoces sílabas, espacios, signos?
- ¿Por qué hace falta la máscara causal para entrenar un modelo que escribe?
- `TTinyTransformer.Block.Attn.LastWeights` tiene los pesos de la última pasada: ¿a qué letras mira la
  última posición de «había una vez»?
