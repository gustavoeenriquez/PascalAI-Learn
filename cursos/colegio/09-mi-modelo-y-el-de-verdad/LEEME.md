# De mi modelo al de verdad

En la lección 8 escribiste un modelo que adivina la palabra siguiente. Los modelos de lenguaje grandes
(ChatGPT, Llama, Claude…) hacen **lo mismo**: reciben un texto y dan las probabilidades de la palabra
(o el pedazo de palabra) siguiente. La diferencia está en cuánto miran hacia atrás y en con cuánto texto
aprendieron.

En PascalAI un modelo se declara así, y se le pregunta con `Ask`:

```pascal
model Narrador;                         // cuál es, lo dice pai.package

WriteLn(Narrador.Ask('había una vez'));
```

Y en `pai.package` (en esta misma carpeta) se elige **cuál** modelo es:

```ini
[models]
Narrador = pascal/TBigramas      ; el tuyo, escrito en Pascal
; Narrador = ollama/llama3.2     ; uno de verdad (si tienes Ollama instalado)
```

`pascal/TBigramas` quiere decir: «el modelo es la clase TBigramas de mi programa». Para que funcione,
la clase implementa `ILanguageModel`, que pide una sola función:

```pascal
function Next(const Context: TArray<string>): TArray<TTokenProb>;
// dados los tokens anteriores, las probabilidades del siguiente
```

El programa y las pruebas **no cambian** al cambiar de modelo: solo cambia una línea de `pai.package`.

## Lo que vas a hacer

1. `TBigramas.Create`: entrena un `TNGram` de 2 (bigramas) con los cuentos de Quiroga.
2. `TBigramas.Next`: devuelve lo que dice el n-grama para ese contexto.

Después corre el programa varias veces.

## Para pensar

- Si tienes Ollama, cambia la línea de `pai.package` y corre otra vez. ¿Qué cambió en la respuesta? ¿Y en
  el programa?
- `R.Tokens` cuenta los tokens, como con un modelo de verdad. ¿Cuántos usó tu modelo?
- ¿Por qué tu modelo inventa frases sin sentido aunque cada par de palabras sí existe en los cuentos?
