# Regresión lineal con descenso por gradiente

Tenemos puntos (x, y) que siguen más o menos una recta, y queremos encontrar la recta
`y = w·x + b` que mejor los explica. «Mejor» quiere decir con el menor **error cuadrático medio**:

```
L(w, b) = (1/n) · Σ (w·xᵢ + b − yᵢ)²
```

En vez de despejar la fórmula (se puede, para una recta), vamos a hacer lo que hacen todas las redes
neuronales: **bajar por la pendiente**. Las derivadas de L dicen hacia dónde sube el error:

```
∂L/∂w = (2/n) · Σ (w·xᵢ + b − yᵢ) · xᵢ
∂L/∂b = (2/n) · Σ (w·xᵢ + b − yᵢ)
```

y en cada paso movemos w y b un poquito **en contra**:

```
w := w − tasa · ∂L/∂w
b := b − tasa · ∂L/∂b
```

## Lo que vas a hacer

1. `Perdida(W, B, Datos)`: el error cuadrático medio.
2. `Gradiente(W, B, Datos, GW, GB)`: las dos derivadas de arriba.
3. `Entrenar(Datos, Tasa, Pasos)`: empieza en w = 0, b = 0 y repite el paso de descenso.

Los datos se generan con `y = 3x + 2` más un poco de ruido, así que al final w y b tienen que quedar
cerca de 3 y 2.

## Para pensar

- Prueba con tasa 0.01, 0.5 y 1.2. ¿Qué pasa con la pérdida en cada caso?
- En la lección 4 el gradiente lo va a calcular el programa solo (gradiente automático). ¿Qué parte de
  este trabajo desaparece?
