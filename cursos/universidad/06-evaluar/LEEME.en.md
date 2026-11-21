# Evaluating: training, test and overfitting

A model that gets 100% of the examples it learned from right can be a bad model: maybe it
**memorized** them. What matters is how it does with **new** data. That's why the data is split:

- **training**: it learns from these;
- **test**: it never sees them while learning; they're only used to measure it at the end.

When training accuracy keeps going up and test accuracy stalls or drops, the model is **overfitting**:
it learns details (noise) of the examples that don't help with new ones. A simple defense is **early
stopping**: keep the model from the epoch with the best accuracy on data it didn't use to learn.

Accuracy alone can be misleading. The **confusion matrix** tells you which classes it confuses: the row
is the true class and the column is the one the model chose.

## What you'll do

1. `Exactitud(Pred, Real)` (accuracy): the fraction of correct answers.
2. `MatrizDeConfusion(Pred, Real, Clases)` (confusion matrix).
3. `MejorEpoca(Validacion)` (best epoch): the epoch (starting at 1) with the highest validation
   accuracy.

Then run the program: it trains a large network with only 100 digits and writes, epoch by epoch, the
training accuracy and the test accuracy. Look at `sobreajuste.svg`.

## Think about it

- In which epoch does the training curve start to pull away from the test curve?
- Which digits does the model confuse most? Look at the 8 x 8 images: do they look alike?
- If you choose the best epoch by looking at the **test** data, is the final measurement still honest?
  (that's why a third group is used: **validation**)
