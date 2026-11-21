# Árvores de decisão

Na lição 1 você escreveu as perguntas à mão («tem penas?»). Uma **árvore de decisão** que
**aprende** escolhe as perguntas sozinha, olhando os exemplos.

A pergunta mais simples sobre uma fruta é: «a vermelhidão é maior que um número?». Esse número é o
**limiar**. Qual limiar é o melhor? O que **menos erra** com as frutas que já conhecemos.

A ideia para encontrá-lo:

1. Testar como limiar a vermelhidão de cada fruta conhecida.
2. Para cada um, contar quantas frutas ficariam mal classificadas se dissermos «maçã se a vermelhidão for
   maior que o limiar, pera se não for».
3. Ficar com o limiar que dá menos erros.

Essa pergunta sozinha é uma árvore de um nível (um «toco»). Uma árvore de verdade faz a mesma coisa de novo com
cada metade, e assim a árvore inteira é montada.

## O que você vai fazer

1. `ErroresConUmbral(Datos, U)` (erros com o limiar): quantas frutas são mal classificadas com o limiar U.
2. `MejorUmbral(Datos)` (melhor limiar): testa cada vermelhidão e devolve o limiar com menos erros.

## Para pensar

- O que acontece se, em vez da vermelhidão, a pergunta for sobre o peso? Qual das duas é a melhor pergunta?
- Uma árvore muito profunda pode acertar **todas** as frutas conhecidas. Isso quer dizer que ela vai acertar
  as frutas novas? (isso se chama **sobreajuste**, e você vai ver na universidade)
