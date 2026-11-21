# Do meu modelo ao de verdade

Na lição 8 você escreveu um modelo que adivinha a palavra seguinte. Os grandes modelos de linguagem
(ChatGPT, Llama, Claude…) fazem **o mesmo**: recebem um texto e dão as probabilidades da palavra
(ou do pedaço de palavra) seguinte. A diferença está em quanto eles olham para trás e em com quanto texto
aprenderam.

No PascalAI, um modelo é declarado assim, e você faz perguntas a ele com `Ask`:

```pascal
model Narrador;                         // qual é, quem diz é o pai.package

WriteLn(Narrador.Ask('había una vez'));
```

E em `pai.package` (nesta mesma pasta) se escolhe **qual** modelo é:

```ini
[models]
Narrador = pascal/TBigramas      ; o seu, escrito em Pascal
; Narrador = ollama/llama3.2     ; um de verdade (se você tiver o Ollama instalado)
```

`pascal/TBigramas` quer dizer: «o modelo é a classe TBigramas do meu programa». Para funcionar,
a classe implementa `ILanguageModel`, que pede uma única função:

```pascal
function Next(const Context: TArray<string>): TArray<TTokenProb>;
// dados os tokens anteriores, as probabilidades do seguinte
```

O programa e os testes **não mudam** ao trocar de modelo: só muda uma linha do `pai.package`.

## O que você vai fazer

1. `TBigramas.Create`: treina um `TNGram` de 2 (bigramas) com os contos de Quiroga.
2. `TBigramas.Next`: devolve o que o n-grama diz para esse contexto.

Depois, rode o programa várias vezes.

## Para pensar

- Se você tiver o Ollama, troque a linha do `pai.package` e rode de novo. O que mudou na resposta? E no
  programa?
- `R.Tokens` conta os tokens, como com um modelo de verdade. Quantos o seu modelo usou?
- Por que o seu modelo inventa frases sem sentido, mesmo que cada par de palavras exista nos contos?
