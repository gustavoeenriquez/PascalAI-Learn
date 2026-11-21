# Representación: vectores y matrices

Casi todo en IA se representa con números ordenados: una imagen es una matriz de píxeles, una palabra es
un vector, una capa de una red neuronal es una matriz de pesos. Y casi todo el cómputo es el mismo:
**multiplicar matrices**.

El producto de A (m × n) por B (n × p) es una matriz C (m × p) donde cada elemento es el producto punto
de una fila de A por una columna de B:

```
C[i, j] = A[i, 0]·B[0, j] + A[i, 1]·B[1, j] + ... + A[i, n-1]·B[n-1, j]
```

## Lo que vas a hacer

`Pai.Learn.Linalg` ya trae `TMatrix` con su producto (`A * B`), pero hoy lo escribes tú:

1. `Punto(U, V)`: el producto punto de dos vectores (`TVec`).
2. `Producto(A, B)`: el producto de dos matrices, con los tres `for` anidados. Si las dimensiones no
   coinciden, lanza `EArgumentException`.

`TMatrix.Create(Filas, Columnas)` la crea llena de ceros; `M[i, j]` lee y escribe un elemento;
`M.Rows` y `M.Cols` son sus dimensiones.

Después, abre `src/Pai.Learn.Linalg.pas` y compara con cómo lo hace la biblioteca.

## Para pensar

- ¿Cuántas multiplicaciones hace `Producto` con dos matrices de 100 × 100? ¿Y de 1000 × 1000?
- Una rotación en el plano es una matriz de 2 × 2. ¿Qué hace multiplicar dos rotaciones?
