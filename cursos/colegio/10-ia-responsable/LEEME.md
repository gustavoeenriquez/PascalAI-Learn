# IA responsable: el sesgo está en los datos

Un modelo aprende **de los ejemplos que le damos**. Si los ejemplos están desbalanceados, el modelo
también. Hoy lo vas a ver con números.

Una frutería entrenó su clasificador de k vecinos (lección 5), con k = 9, usando **36 manzanas y solo
4 peras**: era lo que tenía a mano. ¿Qué pasa con las peras nuevas? Piénsalo antes de correr el programa:
en una votación de 9 vecinos, ¿cuántos votos puede juntar una pera como máximo?

La exactitud total puede verse muy bien (casi todo son manzanas…) y esconder que **casi todas las peras
se clasifican mal**. Por eso hay que medir **por grupo**: de las peras de verdad, ¿cuántas reconoció?

Esto pasa en la vida real con consecuencias serias: sistemas que reconocen peor ciertas caras, voces o
acentos porque casi no había ejemplos de ellos al entrenar.

## Lo que vas a hacer

1. `AciertoDe(Clase, Datos, Prueba)`: de las frutas de `Prueba` que son de `Clase`, qué fracción
   clasifica bien el modelo entrenado con `Datos`.
2. `Balancear(Datos)`: un conjunto nuevo con la misma cantidad de cada clase (tantas como la clase que
   menos tiene).

El programa compara el modelo desbalanceado con el balanceado.

## Para pensar

- ¿Cuál es la exactitud total de cada modelo? ¿Y por clase? ¿Cuál preferirías si fueras una pera?
- Balancear tirando datos no es la única solución: ¿qué otras se te ocurren? (conseguir más ejemplos,
  darle más peso a los pocos…)
- Además del sesgo, ¿qué otras preguntas hay que hacerse antes de usar IA? (privacidad de los datos,
  quién es responsable si se equivoca, si las personas saben que hablan con una máquina…)
