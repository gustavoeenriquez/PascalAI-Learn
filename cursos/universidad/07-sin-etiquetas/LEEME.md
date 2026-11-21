# Aprender sin etiquetas: k-means

Hasta ahora cada ejemplo traía su respuesta (la especie de la flor, el dígito). Muchas veces no hay
respuestas: solo datos. ¿Se puede aprender algo igual? Sí: encontrar **grupos** de cosas parecidas.

**k-means** busca K grupos con una idea muy simple que se repite hasta que nada cambia:

1. **Asignar:** cada punto va al grupo del centro más cercano.
2. **Mover:** cada centro se mueve al promedio de los puntos de su grupo.

Empieza con K centros elegidos entre los puntos. Cada vuelta, la suma de las distancias² de cada punto a
su centro (la **inercia**) baja o se queda igual, así que siempre termina.

## Lo que vas a hacer

1. `Asignar(X, Centros, Grupo)`: pone en `Grupo[i]` el centro más cercano a la fila i. Devuelve si algún
   punto cambió de grupo.
2. `Mover(X, Grupo, Centros)`: cada centro al promedio de sus puntos (un centro sin puntos no se mueve).

El programa agrupa las 150 flores de Iris en 3 grupos **sin mirar la especie**, y al final compara los
grupos con las especies de verdad.

## Para pensar

- ¿Coinciden los grupos con las especies? ¿Cuál se mezcla con cuál?
- Corre con otra semilla. ¿Siempre encuentra los mismos grupos?
- ¿Cómo elegirías K si no supieras cuántas especies hay? (prueba con K de 1 a 8 y mira la inercia)
