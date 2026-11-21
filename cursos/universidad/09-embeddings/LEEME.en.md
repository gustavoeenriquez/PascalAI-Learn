# Language II: embeddings

An n-gram treats «loro» (parrot) and «tucán» (toucan) as two unrelated words. An **embedding**
represents each word with a vector of numbers, learned so that words that appear in **similar
contexts** end up **close together**. It's the idea behind word2vec (Mikolov et al., 2013): "you shall
know a word by the company it keeps".

`Pai.Learn.Embed` trains 32-number vectors on Quiroga's stories (it takes a few seconds). What's missing
is using them. The measure of closeness is **cosine similarity**: the cosine of the angle between the two
vectors, 1 if they point the same way, 0 if they have nothing to do with each other.

```
cosine(u, v) = (u · v) / (|u| · |v|)
```

## What you'll do

1. `Coseno(U, V)` (cosine).
2. `MasCercanas(E, Palabra, N)` (nearest): the N words in the vocabulary most similar to `Palabra`
   (not counting the word itself), from most to least similar.

## Think about it

- Which words end up close to «tortuga» (turtle)? And to «dijo» (said)? Does it make sense?
- With 19,000 words of text, the neighbors are sometimes odd. How much text do large models use?
  (trillions of words)
- Embeddings also learn whatever is in the text, including its prejudices. How could you notice that?
