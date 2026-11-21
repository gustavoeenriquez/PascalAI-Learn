# Avaliar: treinamento, teste e sobreajuste

Um modelo que acerta 100 % dos exemplos com que aprendeu pode ser um modelo ruim: talvez ele os tenha
**decorado**. O que importa é como ele se sai com dados **novos**. Por isso os dados são separados:

- **treinamento**: com estes ele aprende;
- **teste**: ele nunca os vê enquanto aprende; servem só para medi-lo no final.

Quando a exatidão de treinamento continua subindo e a de teste estaciona ou cai, o modelo está
**sobreajustando**: aprende detalhes (ruído) dos exemplos que não servem para os novos. Uma defesa
simples é a **parada antecipada**: guardar o modelo da época com melhor exatidão em dados que ele não usou
para aprender.

A exatidão sozinha pode enganar. A **matriz de confusão** diz quais classes ele confunde: a linha é a classe
verdadeira e a coluna, a que o modelo escolheu.

## O que você vai fazer

1. `Exactitud(Pred, Real)` (exatidão): a fração de acertos.
2. `MatrizDeConfusion(Pred, Real, Clases)`.
3. `MejorEpoca(Validacion)` (melhor época): a época (a partir de 1) com maior exatidão de validação.

Depois, rode o programa: ele treina uma rede grande com só 100 dígitos e escreve, época por época, a
exatidão de treinamento e a de teste. Veja `sobreajuste.svg`.

## Para pensar

- Em que época a curva de treinamento começa a se separar da de teste?
- Quais dígitos o modelo mais confunde? Olhe as imagens de 8 x 8: elas se parecem?
- Se você escolhe a melhor época olhando os dados de **teste**, a medida final continua sendo honesta?
  (por isso se usa um terceiro grupo: **validação**)
