# Buscar mejor (A*)

La búsqueda en anchura encuentra el camino más corto, pero revisa casillas **en todas las direcciones**,
también las que se alejan de la meta. Una persona no busca así: mira hacia dónde queda la meta.

**A\*** (se dice «A estrella») hace eso. Para cada casilla por revisar calcula:

```
f = pasos que ya di para llegar aquí  +  cuántos pasos me faltarían, más o menos
```

y revisa primero la que tiene **menor f**. El «más o menos» es una **estimación**: aquí, la distancia
Manhattan a la meta (filas de diferencia + columnas de diferencia), como si no hubiera paredes. Nunca es
mayor que el camino de verdad, y por eso A* también encuentra el más corto.

Si dos casillas empatan en f, conviene revisar primero la que está **más cerca de la meta**.

## Lo que vas a hacer

En `inicio.pas`, la función `Prometedora` tiene un `Todo`: tiene que devolver la posición, dentro de la
lista `Abiertas`, de la casilla con menor f (y con empate, la de menor distancia a la meta). El resto de
A* ya está escrito: léelo y compáralo con tu búsqueda en anchura de la lección 2.

Tienes a mano `Pasos[C]` (los pasos hasta C) y `Manhattan(C, L.Goal)`.

## Para pensar

- En el laberinto de **salas**, ¿cuántas casillas revisa la búsqueda en anchura y cuántas A*?
- ¿Y en el de **pasillos**? ¿Por qué ahí casi no hay diferencia?
- ¿Qué pasaría si la estimación fuera el doble de la distancia Manhattan?
