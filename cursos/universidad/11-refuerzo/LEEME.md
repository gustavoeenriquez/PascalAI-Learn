# Aprendizaje por refuerzo: Q-learning

Nadie le dice al agente qué hacer: **prueba**, recibe premios o castigos, y aprende de eso. Así aprendieron
a jugar Go o a mover un brazo robótico.

El mundo es una cuadrícula: salida `S`, meta `G` (+10), trampa `X` (−10) y cada paso cuesta −1 (conviene
llegar rápido). El agente lleva una tabla `Q[estado][acción]`: cuánto premio total espera si en ese estado
hace esa acción y después sigue bien. Cada vez que hace algo y ve el resultado, corrige la tabla
(Watkins, 1989):

```
objetivo := premio                                   si el episodio terminó
objetivo := premio + Gamma · max Q[siguiente][·]     si no
Q[estado][acción] := Q[estado][acción] + Alfa · (objetivo − Q[estado][acción])
```

¿Qué acción elige? Si siempre elige la que hoy parece mejor, nunca descubre caminos nuevos. Con
**ε-codicioso**: con probabilidad ε elige al azar (**explorar**) y si no, la mejor (**explotar**).

## Lo que vas a hacer

1. `Elegir(Estado)`: ε-codicioso.
2. `Aprender(Estado, Accion, Premio, Siguiente, Termino)`: la regla de arriba.

El programa entrena 300 episodios y dibuja con flechas lo que aprendió.

## Para pensar

- ¿Qué pasa con ε = 0 desde el principio? ¿Y con ε = 1?
- Con Gamma = 0 el agente solo mira el premio inmediato. ¿Llega a la meta?
- ¿Por qué el agente rodea la trampa aunque el camino sea más largo?
