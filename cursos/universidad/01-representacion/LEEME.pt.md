# Representação: vetores e matrizes

Quase tudo em IA é representado com números ordenados: uma imagem é uma matriz de pixels, uma palavra é
um vetor, uma camada de uma rede neural é uma matriz de pesos. E quase todo o cálculo é o mesmo:
**multiplicar matrizes**.

O produto de A (m × n) por B (n × p) é uma matriz C (m × p) em que cada elemento é o produto escalar
de uma linha de A por uma coluna de B:

```
C[i, j] = A[i, 0]·B[0, j] + A[i, 1]·B[1, j] + ... + A[i, n-1]·B[n-1, j]
```

## O que você vai fazer

`Pai.Learn.Linalg` já traz `TMatrix` com o seu produto (`A * B`), mas hoje quem escreve é você:

1. `Punto(U, V)`: o produto escalar de dois vetores (`TVec`).
2. `Producto(A, B)`: o produto de duas matrizes, com os três `for` aninhados. Se as dimensões não
   coincidirem, lance `EArgumentException`.

`TMatrix.Create(Filas, Columnas)` (linhas, colunas) cria a matriz cheia de zeros; `M[i, j]` lê e escreve um elemento;
`M.Rows` e `M.Cols` são as suas dimensões.

Depois, abra `src/Pai.Learn.Linalg.pas` e compare com o jeito como a biblioteca faz.

## Para pensar

- Quantas multiplicações `Producto` faz com duas matrizes de 100 × 100? E de 1000 × 1000?
- Uma rotação no plano é uma matriz de 2 × 2. O que faz multiplicar duas rotações?
