# Aprendizado por reforço: Q-learning

Ninguém diz ao agente o que fazer: ele **experimenta**, recebe prêmios ou castigos e aprende com isso. Foi assim que se aprendeu
a jogar Go ou a mover um braço robótico.

O mundo é uma grade: saída `S`, meta `G` (+10), armadilha `X` (−10), e cada passo custa −1 (convém
chegar rápido). O agente mantém uma tabela `Q[estado][ação]`: quanto prêmio total ele espera se, nesse estado,
fizer essa ação e depois continuar bem. Cada vez que faz algo e vê o resultado, ele corrige a tabela
(Watkins, 1989):

```
objetivo := prêmio                                   se o episódio terminou
objetivo := prêmio + Gamma · max Q[seguinte][·]      se não
Q[estado][ação] := Q[estado][ação] + Alfa · (objetivo − Q[estado][ação])
```

Qual ação ele escolhe? Se sempre escolher a que hoje parece melhor, nunca descobre caminhos novos. Com
**ε-guloso**: com probabilidade ε ele escolhe ao acaso (**explorar**) e, se não, a melhor (**aproveitar**, *exploit*).

## O que você vai fazer

1. `Elegir(Estado)` (escolher): ε-guloso.
2. `Aprender(Estado, Accion, Premio, Siguiente, Termino)`: a regra acima.

O programa treina 300 episódios e desenha com setas o que aprendeu.

## Para pensar

- O que acontece com ε = 0 desde o início? E com ε = 1?
- Com Gamma = 0, o agente só olha o prêmio imediato. Ele chega à meta?
- Por que o agente contorna a armadilha, mesmo que o caminho seja mais longo?
