# Do modelo próprio ao modelo grande

Um `model` do PascalAI pode ser um modelo de verdade (`ollama/llama3.2`, `openai/…`) ou **uma classe do seu
programa** (`pascal/<Clase>`). Se a classe implementa `ILanguageModel`, o motor coloca por cima todo o
resto: `Ask`, `Chat`, `Stream`, a contagem de tokens, o rastreamento, o modelo reserva com `fallback`… O programa não
sabe qual dos dois está respondendo.

Hoje você escreve um modelo melhor que o de bigramas: **trigramas com recuo** (*backoff*). Ele olha duas palavras
para trás; se nunca viu esse par, recua e olha uma só.

```
Next(['había', 'una'])  →  o que veio depois de «había una»   (se viu)
Next(['xyz', 'una'])    →  o que veio depois de «una»          (recua para bigramas)
```

Em `pai.package` você escolhe qual responde:

```ini
[models]
Narrador = pascal/TTrigramas
; Narrador = pascal/TBigramas
; Narrador = ollama/llama3.2
```

## O que você vai fazer

1. `TTrigramas.Create`: treina um `TNGram` de 3 e um de 2 com os contos.
2. `TTrigramas.Next`: os trigramas; se não derem nada, os bigramas.

## Para pensar

- Compare o texto de `TBigramas`, `TTrigramas` e (se você tiver o Ollama) um modelo real com o mesmo prompt.
  O que o modelo grande tem que os seus não têm? (contexto longo, muitíssimo texto, embeddings, atenção)
- `maxtokens` e `temperature` do `model` também valem para o seu modelo. Teste `temperature 0`: por que
  ele se repete?
- Um modelo próprio não consegue fazer `Extract<T>` (saídas estruturadas). Por que um modelo grande consegue?
