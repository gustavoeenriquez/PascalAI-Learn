# Linguagem II: embeddings

Um n-grama trata «loro» (papagaio) e «tucán» (tucano) como duas palavras sem relação. Um **embedding** representa cada
palavra com um vetor de números, aprendido para que as palavras que aparecem em **contextos parecidos**
fiquem **perto**. É a ideia do word2vec (Mikolov et al., 2013): «você conhecerá uma palavra pelas palavras
que a acompanham».

`Pai.Learn.Embed` treina vetores de 32 números com os contos de Quiroga (leva alguns segundos). O que
falta é usá-los. A medida de proximidade é a **similaridade de cosseno**: o cosseno do ângulo entre os dois
vetores, 1 se apontam para o mesmo lado, 0 se não têm nada a ver.

```
cosseno(u, v) = (u · v) / (|u| · |v|)
```

## O que você vai fazer

1. `Coseno(U, V)`.
2. `MasCercanas(E, Palabra, N)` (mais próximas): as N palavras do vocabulário mais parecidas com `Palabra` (sem contar
   ela mesma), da mais parecida para a menos.

## Para pensar

- Quais palavras ficam perto de «tortuga» (tartaruga)? E de «dijo» (disse)? Faz sentido?
- Com 19.000 palavras de texto, os vizinhos às vezes são estranhos. Quanto texto os modelos grandes usam?
  (trilhões de palavras)
- Os embeddings também aprendem o que existe no texto, incluindo os seus preconceitos. Como isso poderia ser percebido?
