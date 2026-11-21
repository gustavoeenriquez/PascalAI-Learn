# Redes neurais

Um perceptron sozinho traça uma reta. Uma **rede** coloca neurônios em **camadas**: cada camada recebe as saídas
da anterior. Com uma camada oculta e uma ativação não linear (tanh), a rede consegue aprender fronteiras
curvas: XOR, espirais, dígitos escritos à mão.

Com matrizes, uma camada inteira é uma única conta. Se X tem um exemplo por linha:

```
H = tanh(X · W1 + B1)        X: N x entradas    W1: entradas x ocultas    H: N x ocultas
S = H · W2 + B2              W2: ocultas x saídas                         S: N x saídas
```

`TTensor` (de `Pai.Learn.Tensor`) faz essas contas e lembra de onde saiu cada resultado, então
`Perdida.Backward` preenche o gradiente de W1, B1, W2 e B2 (é o que você escreveu na lição 4, mas com
matrizes).

## O que você vai fazer

1. `Adelante(X)` (para frente): as duas fórmulas acima.
2. `Paso(X, Y, Tasa)` (passo): zera os gradientes, calcula a perda (erro quadrático médio, `MSE`),
   faz `Backward` e move cada parâmetro no sentido contrário ao seu gradiente. Devolve a perda.

Os testes treinam a sua rede com XOR e com dígitos escritos à mão. Com os dígitos não se usam os 500
exemplos a cada passo, mas sim **minilotes** de 20: muitos passos pequenos, cada um com uma parte dos
dados. Assim a rede aprende muito mais rápido.

## Para pensar

- Quantos números uma rede 64 → 32 → 10 aprende? (`TMLP.ParameterCount` conta)
- Mude a taxa de 0.2 para 0.5 e observe a perda época por época. Ela chega quase a zero… e de repente
  explode. Por que um passo grande demais faz a rede «pular» por cima do mínimo?
- Troque `Tanh` por `Relu`. Ela aprende mais rápido ou mais devagar?
- `Pai.Learn.NN` traz `TMLP` e `TAdam`: compare a sua rede com eles em `digitos.pas`, na pasta do curso.
