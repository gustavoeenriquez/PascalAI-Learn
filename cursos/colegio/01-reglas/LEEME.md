# ¿Qué es la IA? Reglas

Las primeras inteligencias artificiales, en los años 70 y 80, eran **sistemas expertos**: un montón de
reglas «si pasa esto, entonces aquello» escritas por personas que sabían mucho de un tema. Un sistema
experto de medicina, por ejemplo, tenía cientos de reglas sobre síntomas y enfermedades.

Hoy vas a escribir uno pequeño: adivina un animal haciendo preguntas de sí o no.

```
¿Tiene plumas?
  sí → ¿Vuela?            sí → águila      no → pingüino
  no → ¿Vive en el agua?  sí → delfín
                          no → ¿Ladra?     sí → perro       no → gato
```

## Lo que vas a hacer

En `inicio.pas`, la función `Adivinar` recibe un animal (con sus respuestas: `Plumas`, `Vuela`, `Agua`,
`Ladra`) y tiene que devolver su nombre siguiendo el árbol de arriba. Usa `if ... then ... else`.

Después, agrega un animal más al árbol (por ejemplo, la **gallina**: tiene plumas y casi no vuela… ¿en
qué se diferencia del pingüino?). Vas a necesitar una pregunta nueva.

## Para pensar

- ¿Qué pasa si llega un animal que no está en tus reglas, como un murciélago (no tiene plumas, vuela)?
- Un sistema experto **no aprende**: si algo cambia, una persona tiene que reescribir las reglas. En la
  lección 5 vas a ver un programa que aprende de ejemplos.
