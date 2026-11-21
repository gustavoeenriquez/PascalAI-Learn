# Búsqueda adversaria: poda alfa-beta

Minimax revisa el árbol completo de jugadas. Para el tres en raya son más de medio millón de tableros;
para el ajedrez, más que átomos en el universo. Pero mucho de ese trabajo es inútil.

**Alfa-beta** lleva dos números mientras busca:

- **α**: lo mejor que MAX (X) ya tiene asegurado por otro camino;
- **β**: lo mejor que MIN (O) ya tiene asegurado.

Si en una rama se descubre que el valor va a quedar fuera de [α, β], el rival nunca la va a permitir:
se deja de revisar (se **poda**). El resultado es **exactamente el mismo** que el de Minimax, revisando
muchos menos nodos.

```
AlfaBeta(T, turno, α, β):
  si terminó: devolver el puntaje
  si turno es X: para cada jugada:  v := AlfaBeta(hijo, O, α, β); α := max(α, v); si α ≥ β: cortar
                 devolver α
  si turno es O: para cada jugada:  v := AlfaBeta(hijo, X, α, β); β := min(β, v); si α ≥ β: cortar
                 devolver β
```

## Lo que vas a hacer

`inicio.pas` trae el tres en raya y un `Minimax` que cuenta los nodos que revisa. Escribe `AlfaBeta`,
que también tiene que sumar 1 a `Nodos` cada vez que se llama.

## Para pensar

- ¿Cuántos nodos revisa cada uno desde el tablero vacío?
- La poda depende del **orden** en que se prueban las jugadas. ¿Qué orden ayudaría más?
- Para el ajedrez ni con poda alcanza: se corta a cierta profundidad y se usa una **evaluación**
  aproximada del tablero. ¿Cómo la harías para el tres en raya?
