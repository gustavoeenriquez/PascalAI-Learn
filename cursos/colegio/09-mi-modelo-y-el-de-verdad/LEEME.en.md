# From my model to the real one

In lesson 8 you wrote a model that guesses the next word. Large language models (ChatGPT, Llama,
Claude…) do **the same thing**: they receive a text and give the probabilities of the next word (or
piece of a word). The difference is how far back they look and how much text they learned from.

In PascalAI a model is declared like this, and you ask it things with `Ask` (`Narrador` = narrator;
«había una vez» = "once upon a time"):

```pascal
model Narrador
  primary 'mock/eco';   // pai.package says which one it is
end;

WriteLn(Narrador.Ask('había una vez'));
```

And in `pai.package` (in this same folder) you choose **which** model it is:

```ini
[models]
Narrador = pascal/TBigramas      ; yours, written in Pascal
; Narrador = ollama/llama3.2     ; a real one (if you have Ollama installed)
```

`pascal/TBigramas` means: "the model is the TBigramas class in my program". For it to work, the class
implements `ILanguageModel`, which asks for a single function:

```pascal
function Next(const Context: TArray<string>): TArray<TTokenProb>;
// given the previous tokens, the probabilities of the next one
```

The program and the tests **don't change** when you switch models: only one line in `pai.package`
changes.

## What you'll do

1. `TBigramas.Create`: trains a `TNGram` of 2 (bigrams) with Quiroga's stories.
2. `TBigramas.Next`: returns what the n-gram says for that context.

Then run the program. It always gives the same result, because the engine gives your model the same seed on every run. Add `temperature 0.2` or `temperature 2` to the `model` and see what changes.

## Think about it

- If you have Ollama, change the line in `pai.package` and run it again. What changed in the answer?
  And in the program?
- `R.Tokens` counts the tokens, just like with a real model. How many did your model use?
- Why does your model make up meaningless sentences even though every pair of words does exist in the
  stories?
