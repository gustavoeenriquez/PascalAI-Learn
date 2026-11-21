# Busca adversária: poda alfa-beta

O minimax verifica a árvore completa de jogadas. Para o jogo da velha são mais de meio milhão de tabuleiros;
para o xadrez, mais do que átomos no universo. Mas muito desse trabalho é inútil.

O **alfa-beta** carrega dois números enquanto busca:

- **α**: o melhor que MAX (X) já tem garantido por outro caminho;
- **β**: o melhor que MIN (O) já tem garantido.

Se em um ramo se descobre que o valor vai ficar fora de [α, β], o adversário nunca vai permiti-lo:
o ramo deixa de ser verificado (é **podado**). O resultado é **exatamente o mesmo** que o do Minimax, verificando
muito menos nós.

```
AlfaBeta(T, turno, α, β):
  se terminou: devolver a pontuação
  se turno é X: para cada jogada:  v := AlfaBeta(filho, O, α, β); α := max(α, v); se α ≥ β: cortar
                devolver α
  se turno é O: para cada jogada:  v := AlfaBeta(filho, X, α, β); β := min(β, v); se α ≥ β: cortar
                devolver β
```

## O que você vai fazer

`inicio.pas` traz o jogo da velha e um `Minimax` que conta os nós que verifica. Escreva `AlfaBeta`,
que também tem que somar 1 a `Nodos` (nós) cada vez que é chamado.

## Para pensar

- Quantos nós cada um verifica a partir do tabuleiro vazio?
- A poda depende da **ordem** em que as jogadas são testadas. Que ordem ajudaria mais?
- Para o xadrez, nem com poda é suficiente: corta-se a busca a certa profundidade e usa-se uma **avaliação**
  aproximada do tabuleiro. Como você a faria para o jogo da velha?
