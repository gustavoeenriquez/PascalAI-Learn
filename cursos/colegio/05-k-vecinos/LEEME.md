# Aprender de ejemplos (k vecinos)

Hasta ahora el programa hacía lo que nosotros le decíamos con reglas. Hoy va a **aprender de ejemplos**.

Tenemos 40 frutas que ya sabemos qué son: 20 manzanas y 20 peras. De cada una sabemos dos cosas:
cuánto pesa (en kilogramos) y qué tan roja es (de 0 a 1). Llega una fruta nueva: pesa 152 gramos y
es bastante roja. ¿Es manzana o pera?

La idea de **k vecinos** es muy simple:

1. Medimos qué tan **distinta** es la fruta nueva de cada fruta conocida (su *distancia*).
2. Nos quedamos con las **k más parecidas** (las de menor distancia).
3. Gana la clase que **más se repite** entre esas k.

## La distancia

Si ponemos cada fruta como un punto (peso, rojez), la distancia entre dos frutas es la de la línea recta
entre los dos puntos, con el teorema de Pitágoras:

```
distancia = raíz( (peso1 - peso2)² + (rojez1 - rojez2)² )
```

En Pascal: `Sqrt(Sqr(A.Weight - B.Weight) + Sqr(A.Redness - B.Redness))`.

## Lo que vas a hacer

Abre `inicio.pas`. Hay dos funciones con un `Todo(...)`: ahí es donde escribes tu código.

1. `Distancia`: la distancia entre dos frutas.
2. `Clasificar`: ordena las frutas por distancia (ya está hecho), mira las `K` primeras y devuelve la
   clase que más se repite (`'apple'` o `'pear'`).

Puedes correr tu programa cuando quieras con `pai inicio.pas`, y comprobarlo con `pai learn check`.

## Para pensar

- ¿Qué pasa con k = 1? ¿Y con k = 40?
- El peso está en kilogramos (0,15) y la rojez va de 0 a 1. ¿Cuál de las dos pesa más en la distancia?
  ¿Qué pasaría si el peso estuviera en gramos?
