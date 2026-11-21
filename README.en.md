# PascalAI-Learn

[Español](README.md) · **English**

Pascal was born to teach programming. PascalAI-Learn uses PascalAI (the `pai` engine) to teach artificial
intelligence: students build it with their own hands, in a language they can read from start to finish, and only
at the end compare it with a real model.

- **For whom:** school (level 1, `colegio`) and university (level 2, `universidad`).
- **What:** the fundamentals. Search, neighbors, trees, the perceptron, the gradient, networks, n-grams,
  embeddings and attention, written in Pascal and readable.
- **How:** with `pai learn` (in the engine): `list` shows the lessons, `start NN` copies one, and `check` runs its
  tests and gives hints, without showing the solution.

The lessons are in Spanish, English and Portuguese (`PAI_LANG=en`, `PAI_LANG=pt`). Each lesson has its text in
`LEEME.en.md`; the folders and the code keep their Spanish names (`inicio.pas` = starting file, `pruebas.pas` =
tests).

## Install

**The easiest way (64-bit Windows):** download `pascalai-ide-0.1.3-win64.zip` from the
[downloads](https://github.com/gustavoeenriquez/PascalAI-Learn/releases/latest) page, unzip it and open
`PaiIde.exe` (it includes `pai`, nothing to install). Switch the interface to English in View → Language. In
File → Open lesson... (or "Learn AI" on the start screen) pick a lesson; if you don't have the courses,
"Download the courses" gets them. Complete `inicio.pas` and check with **Ctrl+Shift+L**: the hints appear in the
Output.

**From the console (Windows, Linux):**

1. Download `pai` (0.1.2 or later) for your system from the
   [downloads](https://github.com/gustavoeenriquez/PascalAI-Learn/releases/latest) page (64-bit Windows or 64-bit
   Linux) and unzip it into a folder in your `PATH`. There is an **untested** version for Windows on ARM
   (`winarm64`); if it fails, the 64-bit Windows one also runs there, through emulation.
2. Download these courses (`git clone https://github.com/gustavoeenriquez/PascalAI-Learn` or the repository .zip)
   and point `PAI_LEARN` to that folder; for messages in English, set `PAI_LANG=en`:

   ```bash
   export PAI_LEARN=~/PascalAI-Learn PAI_LANG=en      # Linux
   $env:PAI_LEARN = "C:\path\PascalAI-Learn"          # Windows (PowerShell)
   $env:PAI_LANG = "en"
   ```

3. In an empty working folder:

   ```bash
   pai learn list
   pai learn start colegio/01
   cd 01-reglas
   pai learn check
   ```

The editor also highlights the code, completes names, marks errors as you type, shows the lessons' `.svg` charts
and has an AI assistant (View → Connect AI...: a local or classroom Ollama is free); its interface is in Spanish,
English or Portuguese. To use `pai learn` from the console, put the editor's folder in your `PATH`.

## Contents

| Folder | What's inside |
|---|---|
| `src/` | The `Pai.Learn` library, written in PascalAI so it can be read and debugged |
| `cursos/colegio/`, `cursos/universidad/` | The lessons: `LEEME.md` (and `LEEME.en.md`, `LEEME.pt.md`), `inicio.pas` (with gaps) and `pruebas.pas` (school 01-10 and university 01-13) |
| `datos/` | The data that doesn't fit in the code, and `DATOS.md` with the origin and license of each |
| `tests/` | The library tests (`pai test`) |
| `tools/` | `test.sh` |

Solutions and rubrics are in a private repository for teachers.

## The library

| Unit | What for |
|---|---|
| `Pai.Learn.Random` | `TRandom`: random numbers that repeat with the same seed (Park-Miller) |
| `Pai.Learn.Linalg` | `TVec` and `TMatrix`: products, distances, transpose |
| `Pai.Learn.Grad` | `TScalar`: automatic gradient on single numbers (`Backward`) |
| `Pai.Learn.Search` | Mazes (`TMaze`), breadth-first search and A* |
| `Pai.Learn.Neighbors` | k nearest neighbors |
| `Pai.Learn.Data` | Datasets: fruits and XOR (generated), Iris and 8×8 digits (from `datos/`), `TDataset` with `Split` |
| `Pai.Learn.Tensor` | `TTensor`: automatic gradient on whole matrices, MSE and cross-entropy |
| `Pai.Learn.NN` | Dense layers, `TMLP` (multilayer perceptron), `TSGD` and `TAdam` |
| `Pai.Learn.Metrics` | Accuracy, confusion matrix, precision, recall, F1 |
| `Pai.Learn.Unsupervised` | k-means and PCA |
| `Pai.Learn.Text` | Tokenizers (characters, words, BPE), vocabulary, n-grams, `ILanguageModel` and `LMGenerate` (your own model as `pascal/<Class>`) |
| `Pai.Learn.Embed` | Word embeddings (word2vec, skip-gram with negative sampling) |
| `Pai.Learn.Attention` | Causal attention and a tiny character-level transformer |
| `Pai.Learn.RL` | Q-learning on a grid |
| `Pai.Learn.Plot` | SVG charts: lines, points, a perceptron's boundary and mazes |

The library names are in English, like Delphi; the lessons, in the student's language.

## Testing

```bash
PAI=/path/to/pai ./tools/test.sh
```

## License

The code, MIT (`LICENSE`). The texts, figures and own data, CC BY 4.0 (`LICENSE-CONTENT.md`).

The `pai` engine and the editor in the downloads are not part of this repository: they can be used free of charge
for educational and personal purposes (their `LICENCIA.txt`). On Windows they are not code-signed yet, so the first
time SmartScreen may warn; the download's `LEEME.txt` explains how to check the SHA-256 sum and run it.
