# PascalAI-Learn

Pascal nació para enseñar a programar. PascalAI-Learn usa PascalAI (el motor `pai`)
para enseñar inteligencia artificial: el estudiante la construye con sus manos, en un lenguaje que puede
leer de principio a fin, y solo al final la compara con un modelo de verdad.

- **Para quién:** colegio (nivel 1) y universidad (nivel 2).
- **Qué:** los fundamentos. Búsqueda, vecinos, árboles, el perceptrón, el gradiente, redes, n-gramas,
  embeddings y atención, escritos en Pascal y legibles.
- **Cómo:** con `pai learn` (en el motor): `list` muestra las lecciones, `start NN` copia una y `check`
  corre sus pruebas y da pistas, sin mostrar la solución.

Las lecciones están en español, inglés y portugués (`PAI_LANG=en`, `PAI_LANG=pt`).

## Instalar

1. Descarga `pai` para tu sistema desde la página de
   [descargas](https://github.com/gustavoeenriquez/PascalAI-Learn/releases/latest) (Windows de 64 bits o Linux de
   64 bits) y descomprímelo en una carpeta que esté en el `PATH`.
2. Descarga estos cursos (`git clone https://github.com/gustavoeenriquez/PascalAI-Learn` o el .zip del
   repositorio) y apunta `PAI_LEARN` a esa carpeta:

   ```bash
   export PAI_LEARN=~/PascalAI-Learn                 # Linux
   $env:PAI_LEARN = "C:\ruta\PascalAI-Learn"         # Windows (PowerShell)
   ```

3. En una carpeta de trabajo vacía:

   ```bash
   pai learn list
   pai learn start colegio/01
   cd 01-reglas
   pai learn check
   ```

## Contenido

| Carpeta | Qué hay |
|---|---|
| `src/` | La biblioteca `Pai.Learn`, escrita en PascalAI para que se pueda leer y depurar |
| `cursos/colegio/`, `cursos/universidad/` | Las lecciones: `LEEME.md`, `inicio.pas` (con huecos) y `pruebas.pas` (colegio 01-05 y universidad 01-04) |
| `datos/` | Los datos que no caben en el código, y `DATOS.md` con el origen y la licencia de cada uno |
| `tests/` | Las pruebas de la biblioteca (`pai test`) |
| `tools/` | `test.sh` |

Las soluciones y las rúbricas están en un repositorio privado para docentes.

## La biblioteca

| Unidad | Para qué |
|---|---|
| `Pai.Learn.Random` | `TRandom`: números al azar que se repiten con la misma semilla (Park-Miller) |
| `Pai.Learn.Linalg` | `TVec` y `TMatrix`: productos, distancias, traspuesta |
| `Pai.Learn.Grad` | `TScalar`: gradiente automático sobre números sueltos (`Backward`) |
| `Pai.Learn.Search` | Laberintos (`TMaze`), búsqueda en anchura y A* |
| `Pai.Learn.Neighbors` | k vecinos más cercanos |
| `Pai.Learn.Data` | Conjuntos de datos: frutas y XOR (generados), Iris y dígitos 8×8 (de `datos/`), `TDataset` con `Split` |
| `Pai.Learn.Tensor` | `TTensor`: gradiente automático sobre matrices enteras, MSE y entropía cruzada |
| `Pai.Learn.NN` | Capas densas, `TMLP` (perceptrón multicapa), `TSGD` y `TAdam` |
| `Pai.Learn.Metrics` | Exactitud, matriz de confusión, precisión, exhaustividad, F1 |
| `Pai.Learn.Unsupervised` | k-means y PCA |
| `Pai.Learn.Text` | Tokenizadores (caracteres, palabras, BPE), vocabulario, n-gramas, `ILanguageModel` y `LMGenerate` (el modelo propio como `pascal/<Clase>`) |
| `Pai.Learn.Embed` | Embeddings de palabras (word2vec, skip-gram con muestreo negativo) |
| `Pai.Learn.Attention` | Atención causal y un transformer diminuto por caracteres |
| `Pai.Learn.RL` | Q-learning en una cuadrícula |
| `Pai.Learn.Plot` | Gráficos en SVG: líneas, puntos, la frontera de un perceptrón y laberintos |

Los nombres de la biblioteca están en inglés, como Delphi; las lecciones, en el idioma del alumno.

## Probar

```bash
PAI=/ruta/a/pai ./tools/test.sh
```

## Licencia

El código, MIT (`LICENSE`). Los textos, las figuras y los datos propios, CC BY 4.0 (`LICENSE-CONTENT.md`).

El motor `pai` de las descargas no es parte de este repositorio: se puede usar gratis con fines educativos y
personales (su `LICENCIA.txt`). En Windows todavía no tiene firma de código, así que la primera vez SmartScreen
puede avisar; el `LEEME.txt` de la descarga explica cómo verificar la suma SHA-256 y ejecutarlo.
