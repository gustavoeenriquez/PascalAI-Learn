# Linear regression with gradient descent

We have points (x, y) that roughly follow a line, and we want to find the line `y = w·x + b` that best
explains them. "Best" means with the lowest **mean squared error**:

```
L(w, b) = (1/n) · Σ (w·xᵢ + b − yᵢ)²
```

Instead of solving the formula (you can, for a line), we're going to do what every neural network does:
**walk down the slope**. The derivatives of L say in which direction the error goes up:

```
∂L/∂w = (2/n) · Σ (w·xᵢ + b − yᵢ) · xᵢ
∂L/∂b = (2/n) · Σ (w·xᵢ + b − yᵢ)
```

and at each step we move w and b a little bit **the opposite way**:

```
w := w − rate · ∂L/∂w
b := b − rate · ∂L/∂b
```

## What you'll do

1. `Perdida(W, B, Datos)` (loss): the mean squared error.
2. `Gradiente(W, B, Datos, GW, GB)` (gradient): the two derivatives above.
3. `Entrenar(Datos, Tasa, Pasos)` (train; `Tasa` = rate, `Pasos` = steps): starts at w = 0, b = 0 and
   repeats the descent step.

The data is generated with `y = 3x + 2` plus a bit of noise, so at the end w and b should be close to 3
and 2.

## Think about it

- Try rates 0.01, 0.5 and 1.2. What happens to the loss in each case?
- In lesson 4 the program will compute the gradient by itself (automatic differentiation). Which part of
  this work disappears?
