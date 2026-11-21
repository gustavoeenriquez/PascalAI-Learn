# Decision trees

In lesson 1 you wrote the questions by hand ("does it have feathers?"). A **decision tree** that
**learns** picks the questions by itself, by looking at the examples.

The simplest question about a fruit is: "is the redness greater than some number?". That number is the
**threshold**. Which threshold is the best? The one that **makes the fewest mistakes** with the fruits we
already know.

The idea for finding it:

1. Try the redness of each known fruit as the threshold.
2. For each one, count how many fruits would be misclassified if we say "apple if the redness is
   greater than the threshold, pear otherwise".
3. Keep the threshold that gives the fewest errors.

That single question is a one-level tree (a "stump"). A real tree does the same thing again with each
half, and that's how the whole tree is built.

## What you'll do

1. `ErroresConUmbral(Datos, U)` (errors with threshold): how many fruits are misclassified with
   threshold U.
2. `MejorUmbral(Datos)` (best threshold): tries each redness and returns the threshold with the fewest
   errors.

## Think about it

- What happens if, instead of redness, you ask about weight? Which of the two is the better question?
- A very deep tree can get **all** the known fruits right. Does that mean it will get new fruits right?
  (this is called **overfitting**, and you'll see it at university)
