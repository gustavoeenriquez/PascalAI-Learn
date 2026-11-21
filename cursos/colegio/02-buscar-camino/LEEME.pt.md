# Buscar um caminho

Um robô está na saída (`S`) de um labirinto e tem que chegar à meta (`G`). Ele não vê o labirinto
inteiro: só sabe, em cada casa, para quais casas vizinhas pode passar (as que não são parede `#`).

Como ele encontra o caminho **mais curto**? Com a **busca em largura**:

1. Coloca a saída em uma **fila** (o primeiro que entra é o primeiro que sai).
2. Tira a primeira casa da fila. Se for a meta, terminou!
3. Se não, coloca na fila cada vizinha que **ainda não tenha visto** e anota **de onde veio** até ela.
4. Volta ao passo 2.

Como a fila atende em ordem, primeiro ela verifica tudo o que está a 1 passo, depois tudo o que está a 2
passos, e assim por diante. Por isso, na primeira vez que chega à meta, chegou pelo caminho mais curto.

Para saber o caminho, no final percorre-se o «de onde eu vim» a partir da meta, de trás para frente. Isso já é feito por
`L.PathFrom(Vino, L.Goal)`.

## O que você vai fazer

Em `inicio.pas`, a função `BuscarEnAnchura` (buscar em largura) tem um `Todo`. Escreva o laço dos passos 2 e 3.
Você tem à mão:

- `Cola.Enqueue(C)` coloca uma casa na fila (`Cola`); `Cola.Dequeue` tira a primeira; `Cola.Count` diz quantas há.
- `Vino.ContainsKey(C)` diz se já vimos a casa; `Vino.Add(Vecina, Actual)` anota de onde ela veio.
- `L.Neighbors(C)` dá as vizinhas que não são parede; `L.Goal` é a meta.
- `Visitadas := Visitadas + [Actual]` guarda a ordem em que você verificou as casas (para desenhá-la).

Confira com `pai learn check`.

## Para pensar

- Quantas casas sua busca verificou? Quantas o labirinto tem?
- Se você trocar a fila por uma **pilha** (o último que entra é o primeiro que sai), ela continua encontrando
  o caminho? É o mais curto?
