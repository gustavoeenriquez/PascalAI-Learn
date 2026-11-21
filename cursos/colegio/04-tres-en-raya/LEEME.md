# Jugar tres en raya (minimax)

¿Cómo «piensa» un programa que juega? Imagina todas las jugadas posibles, y las respuestas del rival a
cada una, y las respuestas a esas respuestas… hasta el final de la partida. Eso es un **árbol de jugadas**.

El tablero es un texto de 9 letras, fila por fila: `X`, `O` o `.` para una casilla libre.

```
'X.O'        X . O
'.X.'   →    . X .
'..O'        . . O
```

**Minimax** le da un puntaje a cada tablero:

- si ya ganó X: **+1**; si ganó O: **−1**; si está lleno y nadie ganó: **0**;
- si no terminó y le toca a **X**: prueba cada casilla libre y se queda con el **mayor** puntaje (X quiere
  ganar);
- si le toca a **O**: se queda con el **menor** (O quiere que pierda X).

Es una función que se llama a sí misma (**recursiva**): para saber cuánto vale un tablero, mira cuánto
valen los tableros que siguen.

## Lo que vas a hacer

En `inicio.pas` ya están `Ganador`, `Lleno` y `Jugar`. Completa `Minimax(T, Turno)`. `MejorJugada` usa
tu `Minimax` para elegir dónde jugar.

## Para pensar

- Si los dos juegan perfecto desde el tablero vacío, ¿quién gana? (pruébalo: tarda alrededor de un segundo)
- ¿Cuántos tableros revisa Minimax desde el tablero vacío? Agrega un contador.
- ¿Por qué esta idea no sirve tal cual para el ajedrez?
