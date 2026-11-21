# Aprender com exemplos (k vizinhos)

Até agora o programa fazia o que nós mandávamos com regras. Hoje ele vai **aprender com exemplos**.

Temos 40 frutas que já sabemos o que são: 20 maçãs e 20 peras. De cada uma sabemos duas coisas:
quanto pesa (em quilogramas) e o quanto é vermelha (de 0 a 1). Chega uma fruta nova: pesa 152 gramas e
é bem vermelha. É maçã ou pera?

A ideia dos **k vizinhos** é muito simples:

1. Medimos o quanto a fruta nova é **diferente** de cada fruta conhecida (a sua *distância*).
2. Ficamos com as **k mais parecidas** (as de menor distância).
3. Ganha a classe que **mais se repete** entre essas k.

## A distância

Se colocarmos cada fruta como um ponto (peso, vermelhidão), a distância entre duas frutas é a da linha reta
entre os dois pontos, pelo teorema de Pitágoras:

```
distância = raiz( (peso1 - peso2)² + (vermelhidão1 - vermelhidão2)² )
```

Em Pascal: `Sqrt(Sqr(A.Weight - B.Weight) + Sqr(A.Redness - B.Redness))`.

## O que você vai fazer

Abra `inicio.pas`. Há duas funções com um `Todo(...)`: é ali que você escreve o seu código.

1. `Distancia`: a distância entre duas frutas.
2. `Clasificar` (classificar): ordena as frutas por distância (isso já está feito), olha as `K` primeiras e devolve a
   classe que mais se repete (`'apple'` ou `'pear'`).

Você pode rodar o seu programa quando quiser com `pai inicio.pas` e conferi-lo com `pai learn check`.

## Para pensar

- O que acontece com k = 1? E com k = 40?
- O peso está em quilogramas (0,15) e a vermelhidão vai de 0 a 1. Qual das duas pesa mais na distância?
  O que aconteceria se o peso estivesse em gramas?
