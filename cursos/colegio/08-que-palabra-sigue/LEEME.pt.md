# Qual palavra vem depois

Os modelos de linguagem como o ChatGPT fazem, no fundo, uma coisa só: **adivinhar qual palavra vem depois**.
Escrevem uma palavra, depois outra, e outra… Hoje você vai construir o mais simples de todos.

Lemos os *Cuentos de la selva* (Contos da selva) de Horacio Quiroga (1918) e **contamos**: depois de cada palavra,
quais palavras apareceram e quantas vezes? (o texto está em espanhol, então as palavras também)

```
depois de «el»:       hombre (44 vezes), agua (38), tigre (30), loro (22), cazador (19), …
depois de «una»:      vez (14), sola (9), abeja (6), tarde (5), noche (5), …
depois de «había»:    hecho (8), sido (6), una (5), pasado (5), muerto (4), …
```

Esses pares de palavras seguidas se chamam **bigramas**. Para escrever um texto:

1. Começamos com uma palavra.
2. Olhamos quais palavras vieram depois dela nos contos e escolhemos uma (a mais frequente, ou uma ao acaso
   de acordo com quantas vezes apareceu).
3. Repetimos com a palavra nova.

## O que você vai fazer

1. `Contar(Palabras)`: preenche o dicionário `Siguen`: para cada palavra, quantas vezes apareceu cada
   palavra que veio depois.
2. `LaMasFrecuente(Palabra)` (a mais frequente): a palavra que mais vezes veio depois de `Palabra`.

O programa escreve uma frase escolhendo sempre a mais frequente. O que acontece?

## Para pensar

- Escolhendo sempre a mais frequente, a frase entra em um **ciclo** e se repete. Por quê?
- `Pai.Learn.Text` traz `TNGram`, que escolhe **ao acaso** de acordo com as probabilidades. Fica melhor de ler?
- Nosso modelo só olha **uma** palavra para trás. Quantas o ChatGPT olha? (milhares)
