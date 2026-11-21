# Qué palabra sigue

Los modelos de lenguaje como ChatGPT hacen, en el fondo, una sola cosa: **adivinar qué palabra sigue**.
Escriben una palabra, después otra, y otra… Hoy vas a construir el más simple de todos.

Leemos los *Cuentos de la selva* de Horacio Quiroga (1918) y **contamos**: después de cada palabra,
¿qué palabras aparecieron y cuántas veces?

```
después de «el»:      hombre (44 veces), agua (38), tigre (30), loro (22), cazador (19), …
después de «una»:     vez (14), sola (9), abeja (6), tarde (5), noche (5), …
después de «había»:   hecho (8), sido (6), una (5), pasado (5), muerto (4), …
```

Esos pares de palabras seguidas se llaman **bigramas**. Para escribir un texto:

1. Empezamos con una palabra.
2. Miramos qué palabras la siguieron en los cuentos y elegimos una (la más frecuente, o una al azar
   según cuántas veces apareció).
3. Repetimos con la palabra nueva.

## Lo que vas a hacer

1. `Contar(Palabras)`: llena el diccionario `Siguen`: para cada palabra, cuántas veces apareció cada
   palabra que vino después.
2. `LaMasFrecuente(Palabra)`: la palabra que más veces siguió a `Palabra`.

El programa escribe una frase eligiendo siempre la más frecuente. ¿Qué pasa?

## Para pensar

- Eligiendo siempre la más frecuente, la frase entra en un **ciclo** y se repite. ¿Por qué?
- `Pai.Learn.Text` trae `TNGram`, que elige **al azar** según las probabilidades. ¿Se lee mejor?
- Nuestro modelo solo mira **una** palabra hacia atrás. ¿Cuántas mira ChatGPT? (miles)
