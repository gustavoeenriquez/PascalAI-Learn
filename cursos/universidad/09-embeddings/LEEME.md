# Lenguaje II: embeddings

Un n-grama trata «loro» y «tucán» como dos palabras sin relación. Un **embedding** representa cada
palabra con un vector de números, aprendido para que las palabras que aparecen en **contextos parecidos**
queden **cerca**. Es la idea de word2vec (Mikolov et al., 2013): «conocerás una palabra por las palabras
que la acompañan».

`Pai.Learn.Embed` entrena vectores de 32 números con los cuentos de Quiroga (tarda unos segundos). Lo que
falta es usarlos. La medida de cercanía es la **similitud coseno**: el coseno del ángulo entre los dos
vectores, 1 si apuntan igual, 0 si no tienen nada que ver.

```
coseno(u, v) = (u · v) / (|u| · |v|)
```

## Lo que vas a hacer

1. `Coseno(U, V)`.
2. `MasCercanas(E, Palabra, N)`: las N palabras del vocabulario más parecidas a `Palabra` (sin contarla a
   ella), de la más parecida a la menos.

## Para pensar

- ¿Qué palabras quedan cerca de «tortuga»? ¿Y de «dijo»? ¿Tiene sentido?
- Con 19.000 palabras de texto, los vecinos son a veces raros. ¿Cuánto texto usan los modelos grandes?
  (billones de palabras)
- Los embeddings aprenden también lo que hay en el texto, incluidos sus prejuicios. ¿Cómo se podría notar?
