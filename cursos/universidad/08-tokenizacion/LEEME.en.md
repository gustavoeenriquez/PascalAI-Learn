# Language I: tokenization (BPE) and n-grams

A language model doesn't see letters or words: it sees **tokens**. With whole words, the vocabulary is
huge and a new word can't be represented; with letters, the sequences are long. Large models use
something in between: **BPE** (*byte pair encoding*, Sennrich et al., 2016).

BPE starts with characters and repeats:

1. count all the **pairs of neighboring tokens** in the text;
2. **merge** the most frequent pair into a new token.

After a few merges, `" de"`, `" la"`, `"ción"`… show up: frequent pieces of (Spanish) words. A word it
has never seen is built the same way, from smaller pieces.

The second half of the lesson is measuring an **n-gram** with **perplexity**: how many options the model
"seemed to have" at each step on a text it hadn't seen. Lower is better.

## What you'll do

1. `ParMasFrecuente(Palabras)` (most frequent pair): each word is a list of tokens; returns the most
   frequent pair of neighbors as `'a b'` (on a tie, the alphabetically smallest).
2. `Unir(Tokens, A, B)` (merge): replaces each `A` followed by `B` with `A + B`.

The program learns 30 merges from one story and then compares the perplexity of bigrams and trigrams.

## Think about it

- Which merges does it learn first? Why do so many start with a space?
- With these stories, unigrams give lower perplexity than bigrams, and bigrams lower than trigrams:
  looking further back makes it worse! Why? (hint: with 19,000 words, how many word triples from the new
  story did the model ever see? When it saw nothing, smoothing spreads the probability across the 2,600
  words in the vocabulary.) Large models solve this with vastly more text and with embeddings: similar
  words help each other.
