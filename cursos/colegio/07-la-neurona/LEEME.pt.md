# O neurônio (o perceptron)

Em 1958, Frank Rosenblatt construiu o **perceptron**: uma máquina que aprendia a separar duas classes. Ele é
o avô de todas as redes neurais, e cabe em três linhas.

Um neurônio recebe as medidas de uma fruta (peso e vermelhidão), multiplica cada uma por um **peso** e soma
um **viés**:

```
soma = W1 · peso + W2 · vermelhidão + B
se soma >= 0  →  maçã (+1)
se não        →  pera (−1)
```

`W1 · x + W2 · y + B = 0` é uma **reta**: de um lado ficam as maçãs e do outro, as peras.

Como ele aprende? Olha cada fruta. Se acertou, não faz nada. Se errou, move a reta um pouquinho
para o lado certo:

```
erro = resposta correta − resposta do neurônio      (0 se acertou; +2 ou −2 se não)
W1 := W1 + taxa · erro · peso
W2 := W2 + taxa · erro · vermelhidão
B  := B  + taxa · erro
```

Não é preciso cálculo: é só empurrar a reta.

## O que você vai fazer

1. `Predecir(F)` (prever): +1 ou −1 conforme a soma.
2. `Ajustar(F, Tasa)`: a regra acima (`Tasa` é a taxa).
3. Rode o programa: ele gera `perceptron.svg`; abra-o no navegador e veja a reta.

## Para pensar

- Ele chega a zero erros? Olhe o desenho: há alguma fruta que se parece mais com as da outra classe?
  Nenhuma reta consegue acertar todas, e o perceptron fica se movendo de um lado para o outro.
- Teste com a tabela do **OU exclusivo** (XOR): (0,0) e (1,1) de uma classe, (0,1) e (1,0) da outra.
  Existe alguma reta que as separe? Por isso, em 1969, achou-se que as redes neurais não serviam…
  até que muitos neurônios foram juntados em camadas.
