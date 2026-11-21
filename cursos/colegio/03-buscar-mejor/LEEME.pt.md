# Buscar melhor (A*)

A busca em largura encontra o caminho mais curto, mas verifica casas **em todas as direções**,
inclusive as que se afastam da meta. Uma pessoa não procura assim: ela olha para onde fica a meta.

**A\*** (lê-se «A estrela») faz isso. Para cada casa a verificar, ele calcula:

```
f = passos que já dei para chegar aqui  +  quantos passos faltariam, mais ou menos
```

e verifica primeiro a que tem **menor f**. O «mais ou menos» é uma **estimativa**: aqui, a distância
Manhattan até a meta (diferença de linhas + diferença de colunas), como se não houvesse paredes. Ela nunca é
maior que o caminho de verdade, e por isso o A* também encontra o mais curto.

Se duas casas empatarem em f, convém verificar primeiro a que está **mais perto da meta**.

## O que você vai fazer

Em `inicio.pas`, a função `Prometedora` (promissora) tem um `Todo`: ela tem que devolver a posição, dentro da
lista `Abiertas`, da casa com menor f (e, em caso de empate, a de menor distância até a meta). O resto do
A* já está escrito: leia e compare com a sua busca em largura da lição 2.

Você tem à mão `Pasos[C]` (os passos até C) e `Manhattan(C, L.Goal)`.

## Para pensar

- No labirinto de **salas**, quantas casas a busca em largura verifica e quantas o A* verifica?
- E no de **corredores**? Por que ali quase não há diferença?
- O que aconteceria se a estimativa fosse o dobro da distância Manhattan?
