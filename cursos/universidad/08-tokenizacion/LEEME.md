# Lenguaje I: tokenización (BPE) y n-gramas

Un modelo de lenguaje no ve letras ni palabras: ve **tokens**. Con palabras enteras, el vocabulario es
enorme y una palabra nueva no se puede representar; con letras, las secuencias son largas. Los modelos
grandes usan algo intermedio: **BPE** (*byte pair encoding*, Sennrich et al., 2016).

BPE empieza con caracteres y repite:

1. contar todos los **pares de tokens vecinos** en el texto;
2. **unir** el par más frecuente en un token nuevo.

Después de unas cuantas uniones aparecen `" de"`, `" la"`, `"ción"`… pedazos frecuentes de palabras.
Una palabra que nunca vio se arma igual, con pedazos más chicos.

La segunda mitad de la lección es medir un **n-grama** con la **perplejidad**: cuántas opciones
«parecía tener» el modelo en cada paso con un texto que no vio. Más baja es mejor.

## Lo que vas a hacer

1. `ParMasFrecuente(Palabras)`: cada palabra es una lista de tokens; devuelve el par de vecinos más
   frecuente como `'a b'` (con empate, el menor alfabéticamente).
2. `Unir(Tokens, A, B)`: reemplaza cada `A` seguido de `B` por `A + B`.

El programa aprende 30 uniones con un cuento y después compara la perplejidad de bigramas y trigramas.

## Para pensar

- ¿Qué uniones aprende primero? ¿Por qué tantas empiezan con un espacio?
- Con estos cuentos, los unigramas dan menos perplejidad que los bigramas, y los bigramas menos que los
  trigramas: ¡mirar más atrás empeora! ¿Por qué? (pista: con 19.000 palabras, ¿cuántos tríos de palabras
  del cuento nuevo vio el modelo alguna vez? Cuando no vio nada, el suavizado reparte la probabilidad entre
  las 2.600 palabras del vocabulario.) Los modelos grandes resuelven esto con muchísimo más texto y con
  embeddings: palabras parecidas se ayudan entre sí.
