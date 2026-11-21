# Representation: vectors and matrices

Almost everything in AI is represented with ordered numbers: an image is a matrix of pixels, a word is
a vector, a layer of a neural network is a matrix of weights. And almost all the computation is the
same: **multiplying matrices**.

The product of A (m × n) by B (n × p) is a matrix C (m × p) where each element is the dot product of a
row of A and a column of B:

```
C[i, j] = A[i, 0]·B[0, j] + A[i, 1]·B[1, j] + ... + A[i, n-1]·B[n-1, j]
```

## What you'll do

`Pai.Learn.Linalg` already includes `TMatrix` with its product (`A * B`), but today you write it
yourself:

1. `Punto(U, V)` (dot): the dot product of two vectors (`TVec`).
2. `Producto(A, B)` (product): the product of two matrices, with three nested `for` loops. If the
   dimensions don't match, raise `EArgumentException`.

`TMatrix.Create(Filas, Columnas)` (rows, columns) creates it filled with zeros; `M[i, j]` reads and
writes an element; `M.Rows` and `M.Cols` are its dimensions.

Then open `src/Pai.Learn.Linalg.pas` and compare it with how the library does it.

## Think about it

- How many multiplications does `Producto` do with two 100 × 100 matrices? And with 1000 × 1000?
- A rotation in the plane is a 2 × 2 matrix. What does multiplying two rotations do?
