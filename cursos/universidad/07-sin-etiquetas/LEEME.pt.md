# Aprender sem rótulos: k-means

Até agora cada exemplo trazia a sua resposta (a espécie da flor, o dígito). Muitas vezes não há
respostas: só dados. Dá para aprender alguma coisa mesmo assim? Sim: encontrar **grupos** de coisas parecidas.

O **k-means** procura K grupos com uma ideia muito simples que se repete até que nada mude:

1. **Atribuir:** cada ponto vai para o grupo do centro mais próximo.
2. **Mover:** cada centro se move para a média dos pontos do seu grupo.

Começa com K centros escolhidos entre os pontos. A cada rodada, a soma das distâncias² de cada ponto ao
seu centro (a **inércia**) diminui ou fica igual, então o processo sempre termina.

## O que você vai fazer

1. `Asignar(X, Centros, Grupo)` (atribuir): coloca em `Grupo[i]` o centro mais próximo da linha i. Devolve se algum
   ponto mudou de grupo.
2. `Mover(X, Grupo, Centros)`: cada centro para a média dos seus pontos (um centro sem pontos não se move).

O programa agrupa as 150 flores de Iris em 3 grupos **sem olhar a espécie** e, no final, compara os
grupos com as espécies de verdade.

## Para pensar

- Os grupos coincidem com as espécies? Qual se mistura com qual?
- Rode com outra semente. Ele sempre encontra os mesmos grupos?
- Como você escolheria K se não soubesse quantas espécies existem? (teste com K de 1 a 8 e olhe a inércia)
