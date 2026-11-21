# Del modelo propio al modelo grande

Un `model` de PascalAI puede ser un modelo de verdad (`ollama/llama3.2`, `openai/…`) o **una clase de tu
programa** (`pascal/<Clase>`). Si la clase implementa `ILanguageModel`, el motor le pone encima todo lo
demás: `Ask`, `Chat`, `Stream`, la cuenta de tokens, la traza, el respaldo con `fallback`… El programa no
sabe cuál de los dos le contesta.

Hoy escribes un modelo mejor que el de bigramas: **trigramas con retroceso** (*backoff*). Mira dos palabras
atrás; si nunca vio ese par, retrocede y mira una sola.

```
Next(['había', 'una'])  →  lo que vino después de «había una»   (si lo vio)
Next(['xyz', 'una'])    →  lo que vino después de «una»          (retrocede a bigramas)
```

En `pai.package` eliges cuál responde:

```ini
[models]
Narrador = pascal/TTrigramas
; Narrador = pascal/TBigramas
; Narrador = ollama/llama3.2
```

## Lo que vas a hacer

1. `TTrigramas.Create`: entrena un `TNGram` de 3 y uno de 2 con los cuentos.
2. `TTrigramas.Next`: los trigramas; si no dan nada, los bigramas.

## Para pensar

- Compara el texto de `TBigramas`, `TTrigramas` y (si tienes Ollama) un modelo real con el mismo prompt.
  ¿Qué tiene el modelo grande que los tuyos no? (contexto largo, muchísimo texto, embeddings, atención)
- `maxtokens` y `temperature` del `model` también valen para tu modelo. Prueba `temperature 0`: ¿por qué
  se repite?
- Un modelo propio no puede hacer `Extract<T>` (salidas estructuradas). ¿Por qué un modelo grande sí?
