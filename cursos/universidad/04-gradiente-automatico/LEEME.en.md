# Automatic differentiation

In lesson 3 you wrote the derivatives by hand. With a network of millions of weights that's impossible:
the program computes the derivatives by itself, with **reverse-mode automatic differentiation**
(*backpropagation*).

The idea:

1. Each operation creates a **node** that remembers its value and which nodes it came from. So, when
   computing `y = tanh(x·w + b)`, a graph gets built: `x, w → (·) → (+ b) → tanh → y`.
2. Each node knows how to **pass back** the gradient it receives (the chain rule):
   - sum `a + b`: passes the same gradient to each one;
   - product `a · b`: passes `b · g` to `a`, and `a · g` to `b`;
   - `tanh(a)`: passes `(1 − tanh²(a)) · g`.
3. `Backward` sets the gradient of `y` to 1 and walks the graph **backwards**, in an order where each
   node has already received all of its gradient before passing it on (reversed topological order). If
   a node is used twice, the gradients that reach it are **added up**.

## What you'll do

`inicio.pas` has a small version of `Pai.Learn.Grad`. The sum is already written as an example.

1. The backward step of the product (`Mul`) and of `Tanh`.
2. `Backward`: the topological order (with `Visitar` (visit), recursive) and the reverse walk.

The tests compare your gradients with the ones worked out by hand for each operation and for the example.

## Think about it

- Why does the order matter? Find an example where walking in a different order gives an incomplete
  gradient.
- Read `src/Pai.Learn.Grad.pas`: what does it have that your version doesn't?
