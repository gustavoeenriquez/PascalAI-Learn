# Gradiente automático

En la lección 3 escribiste las derivadas a mano. Con una red de millones de pesos eso es imposible: las
derivadas las calcula el programa solo, con **diferenciación automática en modo reverso**
(*backpropagation*).

La idea:

1. Cada operación crea un **nodo** que recuerda su valor y de qué nodos salió. Así, al calcular
   `y = tanh(x·w + b)` queda armado un grafo: `x, w → (·) → (+ b) → tanh → y`.
2. Cada nodo sabe cómo **repartir hacia atrás** el gradiente que le llega (la regla de la cadena):
   - suma `a + b`: le pasa a cada uno el mismo gradiente;
   - producto `a · b`: a `a` le pasa `b · g`, y a `b` le pasa `a · g`;
   - `tanh(a)`: le pasa `(1 − tanh²(a)) · g`.
3. `Backward` pone el gradiente de `y` en 1 y recorre el grafo **al revés**, en un orden en que cada nodo
   ya recibió todo su gradiente antes de repartirlo (orden topológico invertido). Si un nodo se usa dos
   veces, los gradientes que le llegan se **suman**.

## Lo que vas a hacer

`inicio.pas` tiene una versión chica de `Pai.Learn.Grad`. La suma ya está escrita como ejemplo.

1. El paso hacia atrás del producto (`Mul`) y de `Tanh`.
2. `Backward`: el orden topológico (con `Visitar`, recursivo) y el recorrido al revés.

Las pruebas comparan tus gradientes con los de la biblioteca y con la pendiente medida.

## Para pensar

- ¿Por qué el orden importa? Busca un ejemplo donde recorrer en otro orden dé un gradiente incompleto.
- Lee `src/Pai.Learn.Grad.pas`: ¿qué tiene que no tenga tu versión?
