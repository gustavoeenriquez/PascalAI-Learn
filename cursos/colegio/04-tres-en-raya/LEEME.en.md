# Playing tic-tac-toe (minimax)

How does a game-playing program "think"? It imagines every possible move, and the opponent's replies to
each one, and the replies to those replies… all the way to the end of the game. That's a **game tree**.

The board is a 9-letter text, row by row: `X`, `O` or `.` for an empty square.

```
'X.O'        X . O
'.X.'   →    . X .
'..O'        . . O
```

**Minimax** gives each board a score:

- if X has already won: **+1**; if O won: **−1**; if it's full and nobody won: **0**;
- if it's not over and it's **X**'s turn: try each empty square and keep the **highest** score (X wants
  to win);
- if it's **O**'s turn: keep the **lowest** (O wants X to lose).

It's a function that calls itself (**recursive**): to know how much a board is worth, it looks at how
much the next boards are worth.

## What you'll do

In `inicio.pas` you already have `Ganador` (winner), `Lleno` (full) and `Jugar` (play). Complete
`Minimax(T, Turno)` (`Turno` = turn). `MejorJugada` (best move) uses your `Minimax` to choose where to
play.

## Think about it

- If both players play perfectly from the empty board, who wins? (try it: it takes about a second)
- How many boards does Minimax check from the empty board? Add a counter.
- Why doesn't this idea work as-is for chess?
