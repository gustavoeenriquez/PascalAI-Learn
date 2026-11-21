# Buscar un camino

Un robot está en la salida (`S`) de un laberinto y tiene que llegar a la meta (`G`). No ve el laberinto
completo: solo sabe, en cada casilla, a qué casillas vecinas puede pasar (las que no son pared `#`).

¿Cómo encuentra el camino **más corto**? Con la **búsqueda en anchura**:

1. Pone la salida en una **cola** (una fila: el primero que entra es el primero que sale).
2. Saca la primera casilla de la cola. Si es la meta, ¡terminó!
3. Si no, mete en la cola cada vecina que **todavía no haya visto**, y anota **de dónde vino** a ella.
4. Vuelve al paso 2.

Como la cola atiende en orden, primero revisa todo lo que está a 1 paso, después todo lo que está a 2
pasos, y así. Por eso, la primera vez que llega a la meta, llegó por el camino más corto.

Para saber el camino, al final se recorre «de dónde vine» desde la meta hacia atrás. Eso ya lo hace
`L.PathFrom(Vino, L.Goal)`.

## Lo que vas a hacer

En `inicio.pas`, la función `BuscarEnAnchura` tiene un `Todo`. Escribe el ciclo de los pasos 2 y 3.
Tienes a mano:

- `Cola.Enqueue(C)` mete una casilla; `Cola.Dequeue` saca la primera; `Cola.Count` dice cuántas hay.
- `Vino.ContainsKey(C)` dice si ya vimos la casilla; `Vino.Add(Vecina, Actual)` anota de dónde vino.
- `L.Neighbors(C)` da las vecinas que no son pared; `L.Goal` es la meta.
- `Visitadas := Visitadas + [Actual]` guarda el orden en que revisaste las casillas (para dibujarlo).

Comprueba con `pai learn check`.

## Para pensar

- ¿Cuántas casillas revisó tu búsqueda? ¿Cuántas tiene el laberinto?
- Si cambias la cola por una **pila** (el último que entra es el primero que sale), ¿sigue encontrando
  el camino? ¿Es el más corto?
