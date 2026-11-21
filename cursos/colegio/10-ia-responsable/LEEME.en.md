# Responsible AI: the bias is in the data

A model learns **from the examples we give it**. If the examples are unbalanced, so is the model.
Today you'll see it with numbers.

A fruit shop trained its k-nearest-neighbors classifier (lesson 5), with k = 9, using **36 apples and
only 4 pears**: that's what it had at hand. What happens with new pears? Think about it before running
the program: in a vote among 9 neighbors, how many votes can a pear get at most?

The overall accuracy can look very good (almost everything is apples…) and hide that **almost all the
pears are misclassified**. That's why you have to measure **per group**: of the real pears, how many did
it recognize?

This happens in real life with serious consequences: systems that recognize certain faces, voices or
accents worse because there were hardly any examples of them during training.

## What you'll do

1. `AciertoDe(Clase, Datos, Prueba)` (hit rate of a class): of the fruits in `Prueba` (test) that
   belong to `Clase` (class), what fraction the model trained with `Datos` (data) classifies correctly.
2. `Balancear(Datos)` (balance): a new set with the same number of each class (as many as the class
   that has the fewest).

The program compares the unbalanced model with the balanced one.

## Think about it

- What is the overall accuracy of each model? And per class? Which one would you prefer if you were a
  pear?
- Balancing by throwing data away isn't the only solution: what others can you think of? (getting more
  examples, giving more weight to the few…)
- Besides bias, what other questions should you ask before using AI? (data privacy, who is responsible
  if it gets something wrong, whether people know they're talking to a machine…)
