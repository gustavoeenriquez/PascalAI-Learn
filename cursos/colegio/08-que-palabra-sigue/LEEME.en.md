# Which word comes next

Language models like ChatGPT do, deep down, just one thing: **guess which word comes next**. They write
one word, then another, and another… Today you're going to build the simplest one of all.

We read the *Cuentos de la selva* (Jungle Tales) by Horacio Quiroga (1918) and we **count**: after each
word, which words appeared and how many times? (The stories are in Spanish, so the words are too:
«el» = the, «una» = a, «había» = had / there was.)

```
after «el»:      hombre (44 times), agua (38), tigre (30), loro (22), cazador (19), …
after «una»:     vez (14), sola (9), abeja (6), tarde (5), noche (5), …
after «había»:   hecho (8), sido (6), una (5), pasado (5), muerto (4), …
```

These pairs of consecutive words are called **bigrams**. To write a text:

1. We start with a word.
2. We look at which words followed it in the stories and pick one (the most frequent, or a random one
   weighted by how many times it appeared).
3. We repeat with the new word.

## What you'll do

1. `Contar(Palabras)` (count words): fills the dictionary `Siguen` (follow): for each word, how many
   times each word that came after it appeared.
2. `LaMasFrecuente(Palabra)` (the most frequent): the word that followed `Palabra` most often.

The program writes a sentence by always picking the most frequent word. What happens?

## Think about it

- Always picking the most frequent word, the sentence falls into a **loop** and repeats itself. Why?
- `Pai.Learn.Text` includes `TNGram`, which picks **at random** according to the probabilities. Does it
  read better?
- Our model only looks **one** word back. How many does ChatGPT look at? (thousands)
