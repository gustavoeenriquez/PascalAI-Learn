# PascalAI-Learn

Pascal nació para enseñar a programar. PascalAI-Learn usa [PascalAI](https://github.com/gustavoeenriquez/pai)
para enseñar inteligencia artificial: el estudiante la construye con sus manos, en un lenguaje que puede
leer de principio a fin, y solo al final la compara con un modelo de verdad.

- **Para quién:** colegio (nivel 1) y universidad (nivel 2).
- **Qué:** los fundamentos. Búsqueda, vecinos, árboles, el perceptrón, el gradiente, redes, n-gramas,
  embeddings y atención, escritos en Pascal y legibles.
- **Cómo:** con `pai learn` (en el motor): `list` muestra las lecciones, `start NN` copia una y `check`
  corre sus pruebas y da pistas, sin mostrar la solución.

La especificación está en el repo del motor: `docs/spec/10-ensenanza.md` (decisión D-317).

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
| `Pai.Learn.Data` | Conjuntos de datos pequeños (`Datasets.Fruits`, `XorTable`) |
| `Pai.Learn.Plot` | Gráficos en SVG: líneas, puntos, la frontera de un perceptrón y laberintos |

Los nombres de la biblioteca están en inglés, como Delphi; las lecciones, en el idioma del alumno.

## Probar

```bash
./tools/test.sh            # con ../PascalAI/bin/win64/pai.exe, o PAI=/ruta/a/pai
```

## Licencia

El código, MIT (`LICENSE`). Los textos, las figuras y los datos propios, CC BY 4.0 (`LICENSE-CONTENT.md`).
