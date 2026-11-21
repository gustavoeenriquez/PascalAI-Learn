# The neuron (the perceptron)

In 1958 Frank Rosenblatt built the **perceptron**: a machine that learned to separate two classes. It's
the grandmother of all neural networks, and it fits in three lines.

A neuron receives the measurements of a fruit (weight and redness), multiplies each one by a **weight**
and adds a **bias**. (Careful: the fruit's weight in grams and the neuron's weights W1, W2 are different
things.)

```
sum = W1 · weight + W2 · redness + B
if sum >= 0  →  apple (+1)
otherwise    →  pear (−1)
```

`W1 · x + W2 · y + B = 0` is a **line**: the apples end up on one side and the pears on the other.

How does it learn? It looks at each fruit. If it got it right, it does nothing. If it got it wrong, it
moves the line a little bit toward the correct side:

```
error = correct answer − neuron's answer      (0 if right; +2 or −2 if not)
W1 := W1 + rate · error · weight
W2 := W2 + rate · error · redness
B  := B  + rate · error
```

No calculus needed: it's just pushing the line.

## What you'll do

1. `Predecir(F)` (predict): +1 or −1 depending on the sum.
2. `Ajustar(F, Tasa)` (adjust; `Tasa` = rate): the rule above.
3. Run the program: it leaves `perceptron.svg`; open it in your browser and look at the line.

## Think about it

- Does it reach zero errors? Look at the drawing: is there a fruit that looks more like the ones in the
  other class? No line can get them all right, and the perceptron keeps moving back and forth.
- Try the **exclusive OR** (XOR) table: (0,0) and (1,1) in one class, (0,1) and (1,0) in the other.
  Is there a line that separates them? That's why, in 1969, people thought neural networks were
  useless… until many neurons were put together in layers.
