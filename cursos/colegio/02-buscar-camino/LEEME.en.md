# Finding a path

A robot is at the start (`S`) of a maze and has to reach the goal (`G`). It can't see the whole maze:
on each square, it only knows which neighboring squares it can move to (the ones that aren't a wall `#`).

How does it find the **shortest** path? With **breadth-first search**:

1. It puts the start in a **queue** (a line: the first one in is the first one out).
2. It takes the first square out of the queue. If it's the goal, done!
3. If not, it puts into the queue every neighbor it **hasn't seen yet**, and writes down **where it
   came from** to get there.
4. Go back to step 2.

Since the queue serves in order, it first checks everything that is 1 step away, then everything 2
steps away, and so on. That's why, the first time it reaches the goal, it got there by the shortest path.

To get the path, at the end you follow "where I came from" backwards from the goal. That's already
done by `L.PathFrom(Vino, L.Goal)`.

## What you'll do

In `inicio.pas`, the function `BuscarEnAnchura` (breadth-first search) has a `Todo`. Write the loop for
steps 2 and 3. You have at hand:

- `Cola.Enqueue(C)` adds a square; `Cola.Dequeue` takes out the first one; `Cola.Count` says how many
  there are. (`Cola` = queue.)
- `Vino.ContainsKey(C)` says whether we've already seen the square; `Vino.Add(Vecina, Actual)` writes
  down where it came from. (`Vino` = came from, `Vecina` = neighbor, `Actual` = current.)
- `L.Neighbors(C)` gives the neighbors that aren't walls; `L.Goal` is the goal.
- `Visitadas := Visitadas + [Actual]` keeps the order in which you checked the squares (to draw it).

Check it with `pai learn check`.

## Think about it

- How many squares did your search check? How many does the maze have?
- If you swap the queue for a **stack** (the last one in is the first one out), does it still find
  the path? Is it the shortest?
