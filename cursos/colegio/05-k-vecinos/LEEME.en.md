# Learning from examples (k nearest neighbors)

Until now the program did what we told it with rules. Today it's going to **learn from examples**.

We have 40 fruits whose type we already know: 20 apples and 20 pears. For each one we know two things:
how much it weighs (in kilograms) and how red it is (from 0 to 1). A new fruit arrives: it weighs 152
grams and it's quite red. Is it an apple or a pear?

The idea of **k nearest neighbors** is very simple:

1. We measure how **different** the new fruit is from each known fruit (its *distance*).
2. We keep the **k most similar** ones (the ones with the smallest distance).
3. The class that **appears most often** among those k wins.

## The distance

If we draw each fruit as a point (weight, redness), the distance between two fruits is the length of
the straight line between the two points, using the Pythagorean theorem:

```
distance = sqrt( (weight1 - weight2)² + (redness1 - redness2)² )
```

In Pascal: `Sqrt(Sqr(A.Weight - B.Weight) + Sqr(A.Redness - B.Redness))`.

## What you'll do

Open `inicio.pas`. There are two functions with a `Todo(...)`: that's where you write your code.

1. `Distancia` (distance): the distance between two fruits.
2. `Clasificar` (classify): sorts the fruits by distance (already done), looks at the first `K` and
   returns the class that appears most often (`'apple'` or `'pear'`).

You can run your program whenever you want with `pai inicio.pas`, and check it with `pai learn check`.

## Think about it

- What happens with k = 1? And with k = 40?
- The weight is in kilograms (0.15) and the redness goes from 0 to 1. Which of the two counts more in
  the distance? What would happen if the weight were in grams?
