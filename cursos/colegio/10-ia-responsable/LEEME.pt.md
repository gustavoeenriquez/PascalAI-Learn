# IA responsável: o viés está nos dados

Um modelo aprende **com os exemplos que damos a ele**. Se os exemplos estão desbalanceados, o modelo
também fica. Hoje você vai ver isso com números.

Uma quitanda treinou seu classificador de k vizinhos (lição 5), com k = 9, usando **36 maçãs e só
4 peras**: era o que tinha à mão. O que acontece com as peras novas? Pense nisso antes de rodar o programa:
em uma votação de 9 vizinhos, quantos votos uma pera pode juntar no máximo?

A exatidão total pode parecer muito boa (quase tudo é maçã…) e esconder que **quase todas as peras
são mal classificadas**. Por isso é preciso medir **por grupo**: das peras de verdade, quantas ele reconheceu?

Isso acontece na vida real com consequências sérias: sistemas que reconhecem pior certos rostos, vozes ou
sotaques porque quase não havia exemplos deles no treinamento.

## O que você vai fazer

1. `AciertoDe(Clase, Datos, Prueba)` (acerto de): das frutas de `Prueba` (teste) que são de `Clase`, que fração
   o modelo treinado com `Datos` classifica bem.
2. `Balancear(Datos)`: um conjunto novo com a mesma quantidade de cada classe (tantas quanto a classe que
   tem menos).

O programa compara o modelo desbalanceado com o balanceado.

## Para pensar

- Qual é a exatidão total de cada modelo? E por classe? Qual você preferiria se fosse uma pera?
- Balancear jogando dados fora não é a única solução: que outras você imagina? (conseguir mais exemplos,
  dar mais peso aos poucos…)
- Além do viés, que outras perguntas é preciso fazer antes de usar IA? (privacidade dos dados,
  quem é responsável se ela errar, se as pessoas sabem que estão falando com uma máquina…)
