# Attention: a tiny transformer

An n-gram looks back a fixed number of words. **Attention** (Vaswani et al., 2017, "Attention is all
you need") lets each position decide **which earlier positions to look at** and how much. It's the
heart of every current language model.

For a sequence X (one row per token):

```
Q = X · Wq        what each position asks
K = X · Wk        the key each position offers
V = X · Wv        what each position delivers
weights = softmax( Q · Kᵀ / √d )      with a causal mask: row i only sees columns 0..i
output = weights · V
```

Row i of `weights` says how much position i looks at each earlier position. Dividing by √d (d is the
number of columns of Q) keeps the scores from being huge and saturating the softmax.

## What you'll do

`Atencion(X, Wq, Wk, Wv)` (attention): the formulas above with `TTensor` (`MatMul`, `Transpose`,
`SoftmaxRows(True)` and a number times a tensor: `K * T`). Since everything is a `TTensor`, the gradient
comes for free.

The program trains `TTinyTransformer` from `Pai.Learn.Attention` (which uses the same attention) on
Quiroga's stories, character by character, and writes a text. It takes a couple of minutes: it's a real
model, in miniature.

## Think about it

- What does it write before training? And after 300 steps? Do you recognize syllables, spaces,
  punctuation?
- Why is the causal mask needed to train a model that writes?
- `TTinyTransformer.Block.Attn.LastWeights` holds the weights from the last pass: which letters does the
  last position of «había una vez» ("once upon a time") look at?
