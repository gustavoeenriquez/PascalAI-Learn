# Linguagem I: tokenização (BPE) e n-gramas

Um modelo de linguagem não vê letras nem palavras: vê **tokens**. Com palavras inteiras, o vocabulário é
enorme e uma palavra nova não pode ser representada; com letras, as sequências ficam longas. Os modelos
grandes usam algo intermediário: **BPE** (*byte pair encoding*, Sennrich et al., 2016).

O BPE começa com caracteres e repete:

1. contar todos os **pares de tokens vizinhos** no texto;
2. **unir** o par mais frequente em um token novo.

Depois de algumas uniões aparecem `" de"`, `" la"`, `"ción"`… pedaços frequentes de palavras (do espanhol, a língua dos contos).
Uma palavra que ele nunca viu é montada do mesmo jeito, com pedaços menores.

A segunda metade da lição é medir um **n-grama** com a **perplexidade**: quantas opções o modelo
«parecia ter» a cada passo com um texto que ele não viu. Quanto mais baixa, melhor.

## O que você vai fazer

1. `ParMasFrecuente(Palabras)` (par mais frequente): cada palavra é uma lista de tokens; devolve o par de vizinhos mais
   frequente como `'a b'` (em caso de empate, o menor em ordem alfabética).
2. `Unir(Tokens, A, B)`: substitui cada `A` seguido de `B` por `A + B`.

O programa aprende 30 uniões com um conto e depois compara a perplexidade de bigramas e trigramas.

## Para pensar

- Quais uniões ele aprende primeiro? Por que tantas começam com um espaço?
- Com estes contos, os unigramas dão menos perplexidade que os bigramas, e os bigramas menos que os
  trigramas: olhar mais para trás piora! Por quê? (dica: com 19.000 palavras, quantos trios de palavras
  do conto novo o modelo viu alguma vez? Quando não viu nada, a suavização reparte a probabilidade entre
  as 2.800 palavras do vocabulário.) Os modelos grandes resolvem isso com muitíssimo mais texto e com
  embeddings: palavras parecidas se ajudam entre si.
