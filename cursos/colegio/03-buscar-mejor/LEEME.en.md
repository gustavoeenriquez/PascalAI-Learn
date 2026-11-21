# Searching smarter (A*)

Breadth-first search finds the shortest path, but it checks squares **in every direction**, including
the ones that move away from the goal. A person doesn't search like that: they look toward where the
goal is.

**A\*** (pronounced "A star") does exactly that. For each square waiting to be checked it computes:

```
f = steps I've already taken to get here  +  roughly how many steps I still need
```

and checks first the one with the **lowest f**. The "roughly" is an **estimate**: here, the Manhattan
distance to the goal (difference in rows + difference in columns), as if there were no walls. It's never
larger than the real path, and that's why A* also finds the shortest one.

If two squares tie on f, it's better to check first the one that is **closer to the goal**.

## What you'll do

In `inicio.pas`, the function `Prometedora` (most promising) has a `Todo`: it has to return the
position, inside the list `Abiertas` (open squares), of the square with the lowest f (and on a tie, the
one with the smallest distance to the goal). The rest of A* is already written: read it and compare it
with your breadth-first search from lesson 2.

You have at hand `Pasos[C]` (the steps to reach C) and `Manhattan(C, L.Goal)`.

## Think about it

- In the **rooms** maze, how many squares does breadth-first search check, and how many does A*?
- And in the **corridors** one? Why is there almost no difference there?
- What would happen if the estimate were twice the Manhattan distance?
