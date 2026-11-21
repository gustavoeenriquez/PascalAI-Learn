# Atenção: um transformer minúsculo

Um n-grama olha um número fixo de palavras para trás. A **atenção** (Vaswani et al., 2017, «Attention is all
you need») deixa cada posição decidir **para quais posições anteriores olhar** e quanto. É o coração de
todos os modelos de linguagem atuais.

Para uma sequência X (uma linha por token):

```
Q = X · Wq        o que cada posição pergunta
K = X · Wk        a chave que cada posição oferece
V = X · Wv        o que cada posição entrega
pesos = softmax( Q · Kᵀ / √d )      com máscara causal: a linha i só vê as colunas 0..i
saída = pesos · V
```

A linha i de `pesos` diz quanto a posição i olha para cada posição anterior. A divisão por √d (d é o
número de colunas de Q) evita que as pontuações fiquem enormes e o softmax sature.

## O que você vai fazer

`Atencion(X, Wq, Wk, Wv)`: as fórmulas acima com `TTensor` (`MatMul`, `Transpose`,
`SoftmaxRows(True)` e um número por tensor: `K * T`). Como tudo é `TTensor`, o gradiente sai sozinho.

O programa treina o `TTinyTransformer` de `Pai.Learn.Attention` (que usa a mesma atenção) com os
contos de Quiroga, caractere por caractere, e escreve um texto. Leva alguns minutos: é um modelo de
verdade, em miniatura.

## Para pensar

- O que ele escreve antes de treinar? E depois de 300 passos? Você reconhece sílabas, espaços, sinais?
- Por que a máscara causal é necessária para treinar um modelo que escreve?
- `TTinyTransformer.Block.Attn.LastWeights` tem os pesos da última passada: para quais letras a
  última posição de «había una vez» (era uma vez) olha?
