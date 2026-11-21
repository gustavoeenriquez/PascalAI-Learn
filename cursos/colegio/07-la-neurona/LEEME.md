# La neurona (el perceptrón)

En 1958 Frank Rosenblatt construyó el **perceptrón**: una máquina que aprendía a separar dos clases. Es
la abuela de todas las redes neuronales, y cabe en tres líneas.

Una neurona recibe las medidas de una fruta (peso y rojez), multiplica cada una por un **peso** y suma
un **sesgo**:

```
suma = W1 · peso + W2 · rojez + B
si suma >= 0  →  manzana (+1)
si no         →  pera (−1)
```

`W1 · x + W2 · y + B = 0` es una **recta**: de un lado quedan las manzanas y del otro las peras.

¿Cómo aprende? Mira cada fruta. Si acertó, no hace nada. Si se equivocó, mueve la recta un poquito
hacia el lado correcto:

```
error = respuesta correcta − respuesta de la neurona      (0 si acertó; +2 o −2 si no)
W1 := W1 + tasa · error · peso
W2 := W2 + tasa · error · rojez
B  := B  + tasa · error
```

No hace falta cálculo: es solo empujar la recta.

## Lo que vas a hacer

1. `Predecir(F)`: +1 o −1 según la suma.
2. `Ajustar(F, Tasa)`: la regla de arriba.
3. Corre el programa: deja `perceptron.svg`, ábrelo en el navegador y mira la recta.

## Para pensar

- ¿Llega a cero errores? Mira el dibujo: ¿hay alguna fruta que se parezca más a las de la otra clase?
  Ninguna recta puede acertarlas todas, y el perceptrón se queda moviéndose de un lado al otro.
- Prueba con la tabla del **O exclusivo** (XOR): (0,0) y (1,1) de una clase, (0,1) y (1,0) de la otra.
  ¿Hay alguna recta que las separe? Por eso, en 1969, se pensó que las redes neuronales no servían…
  hasta que se juntaron muchas neuronas en capas.
