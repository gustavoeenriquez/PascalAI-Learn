# Responsible AI: the bias is in the data

A model learns **from the examples we give it**. If the examples are unbalanced, so is the model.
Today you'll see it with numbers.

A fruit shop trained its k-nearest-neighbors classifier (lesson 5), with k = 9, using **20 apples and
only 4 pears**: that's what it had at hand. What happens with new pears? Think about it before running
the program: in a vote among 9 neighbors, how many votes can a pear get at most?

Then they test it with one day's customers: 10 apples and 2 pears the model has never seen. The
**overall accuracy** looks good (83%: almost everything is apples…) and hides that **not a single pear** is
classified correctly. That's why you have to measure **per group**: of the real pears, how many did
it recognize?

This happens in real life with serious consequences: systems that recognize certain faces, voices or
accents worse because there were hardly any examples of them during training.

## What you'll do

1. `AciertoDe(Clase, Datos, Prueba)` (hit rate of a class): of the fruits in `Prueba` (test) that
   belong to `Clase` (class), what fraction the model trained with `Datos` (data) classifies correctly.
2. `Balancear(Datos)` (balance): the same data plus **copies of the pears** (repeating them in order)
   until there are as many pears as apples. This is called **oversampling** the class with few examples.

The program compares the unbalanced model with the balanced one.

## Think about it

- What is the overall accuracy of each model? And per class? Which one would you prefer if you were a
  pear?
- Copying the pears isn't the only solution: what others can you think of? (getting more real
  examples, removing apples, giving more weight to the pears' votes…) What's wrong with copying?
- Besides bias, what other questions should you ask before using AI? (data privacy, who is responsible
  if it gets something wrong, whether people know they're talking to a machine…)
