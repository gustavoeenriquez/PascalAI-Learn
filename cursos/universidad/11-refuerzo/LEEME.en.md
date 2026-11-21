# Reinforcement learning: Q-learning

Nobody tells the agent what to do: it **tries things**, gets rewards or punishments, and learns from
that. That's how programs learned to play Go or to move a robotic arm.

The world is a grid: start `S`, goal `G` (+10), trap `X` (−10), and each step costs −1 (it pays to get
there quickly). The agent keeps a table `Q[state][action]`: how much total reward it expects if it takes
that action in that state and then keeps playing well. Every time it does something and sees the result,
it corrects the table (Watkins, 1989):

```
target := reward                                   if the episode ended
target := reward + Gamma · max Q[next][·]          otherwise
Q[state][action] := Q[state][action] + Alfa · (target − Q[state][action])
```

Which action does it choose? If it always chooses the one that looks best today, it never discovers new
paths. With **ε-greedy**: with probability ε it chooses at random (**explore**), and otherwise the best
one (**exploit**).

## What you'll do

1. `Elegir(Estado)` (choose; `Estado` = state): ε-greedy.
2. `Aprender(Estado, Accion, Premio, Siguiente, Termino)` (learn; action, reward, next, ended): the rule
   above.

The program trains 300 episodes and draws what it learned with arrows.

## Think about it

- What happens with ε = 0 from the start? And with ε = 1?
- With Gamma = 0 the agent only looks at the immediate reward. Does it reach the goal?
- Why does the agent go around the trap even though the path is longer?
