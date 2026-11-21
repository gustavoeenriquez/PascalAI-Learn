# From your own model to a large model

A PascalAI `model` can be a real model (`ollama/llama3.2`, `openai/…`) or **a class in your program**
(`pascal/<Clase>`). If the class implements `ILanguageModel`, the engine puts everything else on top of
it: `Ask`, `Chat`, `Stream`, token counting, tracing, `fallback`… The program doesn't know which of the
two is answering it.

Today you write a better model than the bigram one: **trigrams with backoff**. It looks two words back;
if it has never seen that pair, it backs off and looks at just one.

```
Next(['había', 'una'])  →  what came after «había una»   (if it saw it)
Next(['xyz', 'una'])    →  what came after «una»          (backs off to bigrams)
```

In `pai.package` you choose which one answers:

```ini
[models]
Narrador = pascal/TTrigramas
; Narrador = pascal/TBigramas
; Narrador = ollama/llama3.2
```

## What you'll do

1. `TTrigramas.Create`: trains a `TNGram` of 3 and one of 2 on the stories.
2. `TTrigramas.Next`: the trigrams; if they give nothing, the bigrams.

## Think about it

- Compare the text from `TBigramas`, `TTrigramas` and (if you have Ollama) a real model with the same
  prompt. What does the large model have that yours don't? (long context, vast amounts of text,
  embeddings, attention)
- The `model`'s `maxtokens` and `temperature` also apply to your model. Try `temperature 0`: why does it
  repeat itself?
- Your own model can't do `Extract<T>` (structured outputs). Why can a large model?
