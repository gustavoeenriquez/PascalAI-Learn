# Regressão linear com descida do gradiente

Temos pontos (x, y) que seguem mais ou menos uma reta, e queremos encontrar a reta
`y = w·x + b` que melhor os explica. «Melhor» quer dizer com o menor **erro quadrático médio**:

```
L(w, b) = (1/n) · Σ (w·xᵢ + b − yᵢ)²
```

Em vez de isolar a fórmula (dá para fazer, no caso de uma reta), vamos fazer o que todas as redes
neurais fazem: **descer pela inclinação**. As derivadas de L dizem para onde o erro sobe:

```
∂L/∂w = (2/n) · Σ (w·xᵢ + b − yᵢ) · xᵢ
∂L/∂b = (2/n) · Σ (w·xᵢ + b − yᵢ)
```

e a cada passo movemos w e b um pouquinho **no sentido contrário**:

```
w := w − taxa · ∂L/∂w
b := b − taxa · ∂L/∂b
```

## O que você vai fazer

1. `Perdida(W, B, Datos)` (perda): o erro quadrático médio.
2. `Gradiente(W, B, Datos, GW, GB)`: as duas derivadas acima.
3. `Entrenar(Datos, Tasa, Pasos)` (treinar): começa em w = 0, b = 0 e repete o passo de descida.

Os dados são gerados com `y = 3x + 2` mais um pouco de ruído, então no final w e b têm que ficar
perto de 3 e 2.

## Para pensar

- Teste com taxa 0.01, 0.5 e 1.2. O que acontece com a perda em cada caso?
- Na lição 4, o gradiente vai ser calculado pelo próprio programa (gradiente automático). Que parte
  deste trabalho desaparece?
