# Learning without labels: k-means

Until now each example came with its answer (the species of the flower, the digit). Often there are no
answers: just data. Can you still learn something? Yes: find **groups** of similar things.

**k-means** looks for K groups with a very simple idea that repeats until nothing changes:

1. **Assign:** each point goes to the group of the nearest center.
2. **Move:** each center moves to the average of the points in its group.

It starts with K centers chosen among the points. On each round, the sum of the squared distances from
each point to its center (the **inertia**) goes down or stays the same, so it always ends.

## What you'll do

1. `Asignar(X, Centros, Grupo)` (assign): puts in `Grupo[i]` the center nearest to row i. Returns
   whether any point changed group.
2. `Mover(X, Grupo, Centros)` (move): each center to the average of its points (a center with no points
   doesn't move).

The program groups the 150 Iris flowers into 3 groups **without looking at the species**, and at the end
compares the groups with the real species.

## Think about it

- Do the groups match the species? Which one gets mixed with which?
- Change the initial centers (`[0, 50, 100]` in the program) to other rows. Does it always find the same
  groups?
- How would you choose K if you didn't know how many species there are? (try K from 1 to 8 and look at
  the inertia)
