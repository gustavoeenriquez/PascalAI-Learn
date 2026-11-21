# Neural networks

A single perceptron draws a line. A **network** puts neurons in **layers**: each layer receives the
outputs of the previous one. With one hidden layer and a non-linear activation (tanh), the network can
learn curved boundaries: XOR, spirals, handwritten digits.

With matrices, a whole layer is a single computation. If X has one example per row:

```
H = tanh(X · W1 + B1)        X: N x inputs     W1: inputs x hidden     H: N x hidden
S = H · W2 + B2              W2: hidden x outputs                      S: N x outputs
```

`TTensor` (from `Pai.Learn.Tensor`) does these computations and remembers where each result came from,
so `Perdida.Backward` fills in the gradient of W1, B1, W2 and B2 (it's what you wrote in lesson 4, but
with matrices).

## What you'll do

1. `Adelante(X)` (forward): the two formulas above.
2. `Paso(X, Y, Tasa)` (step): sets the gradients to zero, computes the loss (mean squared error,
   `MSE`), runs `Backward` and moves each parameter against its gradient. Returns the loss.

The tests train your network on XOR and on handwritten digits. With the digits, the 500 examples aren't
all used in every step; instead, **minibatches** of 20 are used: many small steps, each with a part of
the data. That way the network learns much faster.

## Think about it

- How many numbers does a 64 → 32 → 10 network learn? (`TMLP.ParameterCount` counts them)
- Change the rate from 0.2 to 0.5 and watch the loss epoch by epoch. It gets almost to zero… and
  suddenly blows up. Why does a step that's too big make the network "jump" over the minimum?
- Change `Tanh` to `Relu`. Does it learn faster or slower?
- `Pai.Learn.NN` includes `TMLP` and `TAdam`: compare your network with them in `digitos.pas` in the
  course folder.
