# Redes neuronales

Un perceptrón solo traza una recta. Una **red** pone neuronas en **capas**: cada capa recibe las salidas
de la anterior. Con una capa oculta y una activación no lineal (tanh), la red puede aprender fronteras
curvas: XOR, espirales, dígitos escritos a mano.

Con matrices, una capa entera es una sola cuenta. Si X tiene un ejemplo por fila:

```
H = tanh(X · W1 + B1)        X: N x entradas    W1: entradas x ocultas    H: N x ocultas
S = H · W2 + B2              W2: ocultas x salidas                        S: N x salidas
```

`TTensor` (de `Pai.Learn.Tensor`) hace estas cuentas y recuerda de dónde salió cada resultado, así que
`Perdida.Backward` llena el gradiente de W1, B1, W2 y B2 (es lo que escribiste en la lección 4, pero con
matrices).

## Lo que vas a hacer

1. `Adelante(X)`: las dos fórmulas de arriba.
2. `Paso(X, Y, Tasa)`: pone los gradientes en cero, calcula la pérdida (error cuadrático medio, `MSE`),
   hace `Backward` y mueve cada parámetro en contra de su gradiente. Devuelve la pérdida.

Las pruebas entrenan tu red con XOR y con dígitos escritos a mano. Con los dígitos no se usan los 500
ejemplos en cada paso, sino **minilotes** de 20: muchos pasos chicos, cada uno con una parte de los
datos. Así la red aprende mucho más rápido.

## Para pensar

- ¿Cuántos números aprende una red 64 → 32 → 10? (`TMLP.ParameterCount` lo cuenta)
- Cambia la tasa de 0.2 a 0.5 y mira la pérdida época por época. Llega casi a cero… y de repente
  explota. ¿Por qué un paso demasiado grande hace que la red «salte» por encima del mínimo?
- Cambia `Tanh` por `Relu`. ¿Aprende más rápido o más lento?
- `Pai.Learn.NN` trae `TMLP` y `TAdam`: escribe la misma red con `TMLP.Create([64, 16, 10], Azar)` y
  `TAdam.Create(Red.Parameters, 0.01)`, entrénala con `CrossEntropy` y compara cuánto acierta.
