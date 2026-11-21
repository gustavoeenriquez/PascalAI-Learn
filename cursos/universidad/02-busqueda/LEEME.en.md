# Adversarial search: alpha-beta pruning

Minimax checks the whole game tree. For tic-tac-toe that's more than half a million boards; for chess,
more than there are atoms in the universe. But much of that work is useless.

**Alpha-beta** keeps two numbers while it searches:

- **α**: the best that MAX (X) already has guaranteed through another path;
- **β**: the best that MIN (O) already has guaranteed.

If a branch turns out to have a value that will fall outside [α, β], the opponent will never allow it:
you stop checking it (it gets **pruned**). The result is **exactly the same** as Minimax's, while
checking far fewer nodes.

```
AlphaBeta(T, turn, α, β):
  if the game is over: return the score
  if turn is X: for each move:  v := AlphaBeta(child, O, α, β); α := max(α, v); if α ≥ β: cut
                return α
  if turn is O: for each move:  v := AlphaBeta(child, X, α, β); β := min(β, v); if α ≥ β: cut
                return β
```

## What you'll do

`inicio.pas` includes tic-tac-toe and a `Minimax` that counts the nodes it checks. Write `AlfaBeta`,
which also has to add 1 to `Nodos` (nodes) every time it's called.

## Think about it

- How many nodes does each one check from the empty board?
- Pruning depends on the **order** in which moves are tried. Which order would help the most?
- For chess, not even pruning is enough: the search is cut off at a certain depth and an approximate
  **evaluation** of the board is used. How would you build one for tic-tac-toe?
