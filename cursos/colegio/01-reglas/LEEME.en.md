# What is AI? Rules

The first artificial intelligences, in the 70s and 80s, were **expert systems**: lots of
"if this happens, then do that" rules written by people who knew a great deal about a subject. A
medical expert system, for example, had hundreds of rules about symptoms and diseases.

Today you're going to write a small one: it guesses an animal by asking yes-or-no questions.

```
Does it have feathers?
  yes → Does it fly?             yes → águila     no → pingüino
  no  → Does it live in water?   yes → delfín
                                 no  → Does it bark?   yes → perro      no → gato
```

## What you'll do

In `inicio.pas`, the function `Adivinar` (guess) receives an animal (with its answers: `Plumas`
(feathers), `Vuela` (flies), `Agua` (water), `Ladra` (barks)) and has to return its name by following
the tree above. Use `if ... then ... else`. The animal names stay in Spanish because they are the
exact strings your function has to return: águila = eagle, pingüino = penguin, delfín = dolphin,
perro = dog, gato = cat.

Then, add one more animal to the tree (for example, the **gallina** (hen): it has feathers and can
barely fly… how is it different from the penguin?). You'll need a new question.

## Think about it

- What happens if an animal that isn't in your rules shows up, like a bat (no feathers, it flies)?
- An expert system **doesn't learn**: if something changes, a person has to rewrite the rules. In
  lesson 5 you'll see a program that learns from examples.
