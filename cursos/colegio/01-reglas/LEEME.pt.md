# O que é IA? Regras

As primeiras inteligências artificiais, nos anos 70 e 80, eram **sistemas especialistas**: um monte de
regras «se acontecer isto, então aquilo» escritas por pessoas que sabiam muito sobre um assunto. Um sistema
especialista de medicina, por exemplo, tinha centenas de regras sobre sintomas e doenças.

Hoje você vai escrever um pequeno: ele adivinha um animal fazendo perguntas de sim ou não.

```
Tem penas?
  sim → Voa?               sim → águia      não → pinguim
  não → Vive na água?      sim → golfinho
                           não → Late?      sim → cachorro   não → gato
```

## O que você vai fazer

Em `inicio.pas`, a função `Adivinar` (adivinhar) recebe um animal (com suas respostas: `Plumas`, `Vuela`, `Agua`,
`Ladra`) e tem que devolver o nome dele seguindo a árvore acima. Use `if ... then ... else`.

Depois, acrescente mais um animal à árvore (por exemplo, a **galinha**: tem penas e quase não voa… em
que ela é diferente do pinguim?). Você vai precisar de uma pergunta nova.

## Para pensar

- O que acontece se chegar um animal que não está nas suas regras, como um morcego (não tem penas, voa)?
- Um sistema especialista **não aprende**: se algo muda, uma pessoa tem que reescrever as regras. Na
  lição 5 você vai ver um programa que aprende com exemplos.
