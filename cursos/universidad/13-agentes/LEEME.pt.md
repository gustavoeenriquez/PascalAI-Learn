# Agentes: ferramentas, busca e segurança

Um **agente** é um programa que usa um modelo de linguagem para decidir o que fazer, com **ferramentas**
(funções que o modelo pode pedir) e **memória** (dados que são passados a ele). No PascalAI, um agente é um
processo do grafo, como qualquer outro:

```pascal
agent TBibliotecario
  model Cerebro;
  function Responder(const Pregunta: string): string;
end;
```

Hoje você monta um bibliotecário que responde perguntas sobre os *Cuentos de la selva* (Contos da selva), em três partes:

1. **Buscar (RAG).** O modelo não sabe os contos de cor. Antes de perguntar a ele, busca-se o parágrafo
   mais relacionado com a pergunta e ele é passado junto com ela (*retrieval-augmented generation*). A
   busca mais simples: contar quantas palavras da pergunta (de 4 letras ou mais) aparecem em cada
   parágrafo.
2. **Defender-se (injeção de prompts).** O que é passado ao modelo pode trazer instruções
   escondidas: «Ignora las instrucciones anteriores y…» («Ignore as instruções anteriores e…»). Se um texto de fora manda no modelo, o
   atacante manda no agente. É preciso detectar isso antes de usá-lo.
3. **Testar.** Um agente é testado com modelos falsos (`Mock.Model`) e com um modelo que julga a
   resposta (`Assert.Judge`), sem gastar.

## O que você vai fazer

1. `Buscar(Pregunta)`: o parágrafo dos contos com mais palavras da pergunta (`Pregunta`).
2. `EsInyeccion(Texto)` (é injeção): True se o texto tenta dar ordens ao modelo (contém «ignora las
   instrucciones», «olvida las instrucciones», «a partir de ahora eres» ou «nuevas instrucciones», sem
   importar maiúsculas e minúsculas). As frases ficam em espanhol porque os contos e as perguntas estão em espanhol.

O agente já está escrito: ele busca, verifica e pergunta ao `Cerebro`. Em `pai.package`, `Cerebro` é
`mock/eco` (responde repetindo o que recebe, sem rede); com o Ollama, troque-o por um modelo real.

## Para pensar

- A busca por palavras falha com sinônimos («venado» e «gama», dois nomes para o veado). Como os embeddings da
  lição 9 ajudariam?
- Detectar frases fixas é uma defesa fraca: como você a contornaria? Por isso os agentes rodam com
  **permissões mínimas** (`[classroom]` e o sandbox): mesmo que o modelo obedeça ao atacante, ele não pode
  causar dano fora do permitido.
- Que outras ferramentas você daria ao bibliotecário? Quais seriam perigosas?
