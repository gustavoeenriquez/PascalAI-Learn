# Jogar jogo da velha (minimax)

Como um programa que joga «pensa»? Imagine todas as jogadas possíveis, as respostas do adversário a
cada uma, e as respostas a essas respostas… até o fim da partida. Isso é uma **árvore de jogadas**.

O tabuleiro é um texto de 9 letras, linha por linha: `X`, `O` ou `.` para uma casa livre.

```
'X.O'        X . O
'.X.'   →    . X .
'..O'        . . O
```

O **minimax** dá uma pontuação a cada tabuleiro:

- se X já ganhou: **+1**; se O ganhou: **−1**; se está cheio e ninguém ganhou: **0**;
- se não terminou e é a vez de **X**: testa cada casa livre e fica com a **maior** pontuação (X quer
  ganhar);
- se é a vez de **O**: fica com a **menor** (O quer que X perca).

É uma função que chama a si mesma (**recursiva**): para saber quanto vale um tabuleiro, ela olha quanto
valem os tabuleiros seguintes.

## O que você vai fazer

Em `inicio.pas` já estão `Ganador` (vencedor), `Lleno` (cheio) e `Jugar` (jogar). Complete `Minimax(T, Turno)`. `MejorJugada` (melhor jogada) usa
o seu `Minimax` para escolher onde jogar.

## Para pensar

- Se os dois jogarem perfeitamente a partir do tabuleiro vazio, quem ganha? (teste: leva cerca de um segundo)
- Quantos tabuleiros o Minimax verifica a partir do tabuleiro vazio? Acrescente um contador.
- Por que essa ideia não serve do jeito que está para o xadrez?
