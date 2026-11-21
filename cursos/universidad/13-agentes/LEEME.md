# Agentes: herramientas, búsqueda y seguridad

Un **agente** es un programa que usa un modelo de lenguaje para decidir qué hacer, con **herramientas**
(funciones que el modelo puede pedir) y **memoria** (datos que se le pasan). En PascalAI un agente es un
proceso del grafo, como cualquier otro:

```pascal
agent TBibliotecario
  model Cerebro;
  function Responder(const Pregunta: string): string;
end;
```

Hoy armas un bibliotecario que contesta preguntas sobre los *Cuentos de la selva*, en tres partes:

1. **Buscar (RAG).** El modelo no sabe de memoria los cuentos. Antes de preguntarle, se busca el párrafo
   más relacionado con la pregunta y se le pasa junto con ella (*retrieval-augmented generation*). La
   búsqueda más simple: contar cuántas palabras de la pregunta (de 4 letras o más) aparecen en cada
   párrafo.
2. **Defenderse (inyección de prompts).** Lo que se le pasa al modelo puede traer instrucciones
   escondidas: «Ignora las instrucciones anteriores y…». Si un texto de afuera manda sobre el modelo, el
   atacante manda sobre el agente. Hay que detectarlo antes de usarlo.
3. **Probar.** Un agente se prueba con modelos falsos (`Mock.Model`) y con un modelo que juzga la
   respuesta (`Assert.Judge`), sin gastar.

## Lo que vas a hacer

1. `Buscar(Pregunta)`: el párrafo de los cuentos con más palabras de la pregunta.
2. `EsInyeccion(Texto)`: True si el texto intenta darle órdenes al modelo (contiene «ignora las
   instrucciones», «olvida las instrucciones», «a partir de ahora eres» o «nuevas instrucciones», sin
   importar mayúsculas).

El agente ya está escrito: busca, revisa, y le pregunta a `Cerebro`. En `pai.package` `Cerebro` es
`mock/eco` (contesta repitiendo lo que recibe, sin red); con Ollama, cámbialo por un modelo real.

## Para pensar

- La búsqueda por palabras falla con sinónimos («venado» y «gama»). ¿Cómo ayudarían los embeddings de
  la lección 9?
- Detectar frases fijas es una defensa débil: ¿cómo la saltarías? Por eso los agentes corren con
  **permisos mínimos** (`[classroom]` y el sandbox): aunque el modelo obedezca al atacante, no puede
  hacer daño fuera de lo permitido.
- ¿Qué otras herramientas le darías al bibliotecario? ¿Cuáles serían peligrosas?
