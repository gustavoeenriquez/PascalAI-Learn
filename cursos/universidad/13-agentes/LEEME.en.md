# Agents: tools, retrieval and security

An **agent** is a program that uses a language model to decide what to do, with **tools** (functions the
model can ask for) and **memory** (data that gets passed to it). In PascalAI an agent is a process in the
graph, like any other:

```pascal
agent TBibliotecario
  model Cerebro;
  function Responder(const Pregunta: string): string;
end;
```

Today you build a librarian (`TBibliotecario`) that answers questions about the *Cuentos de la selva*
(Jungle Tales), in three parts:

1. **Retrieve (RAG).** The model doesn't know the stories by heart. Before asking it, you search for the
   paragraph most related to the question and pass it along with the question (*retrieval-augmented
   generation*). The simplest search: count how many words from the question (4 letters or longer)
   appear in each paragraph.
2. **Defend (prompt injection).** What gets passed to the model can carry hidden instructions:
   «Ignora las instrucciones anteriores y…» ("Ignore the previous instructions and…"). If an outside
   text gives orders to the model, the attacker gives orders to the agent. You have to detect it before
   using it.
3. **Test.** An agent is tested with fake models (`Mock.Model`) and with a model that judges the answer
   (`Assert.Judge`), without spending anything.

## What you'll do

1. `Buscar(Pregunta)` (search; `Pregunta` = question): the paragraph from the stories with the most
   words from the question.
2. `EsInyeccion(Texto)` (is injection): True if the text tries to give orders to the model (it contains
   «ignora las instrucciones», «olvida las instrucciones», «a partir de ahora eres» or «nuevas
   instrucciones» — "ignore the instructions", "forget the instructions", "from now on you are", "new
   instructions" — regardless of upper or lower case).

The agent is already written: it searches, checks, and asks `Cerebro` (brain). In `pai.package`,
`Cerebro` is `mock/eco` (it answers by repeating what it receives, with no network); with Ollama, change
it to a real model.

## Think about it

- Searching by words fails with synonyms («venado» and «gama», two words for deer). How would the
  embeddings from lesson 9 help?
- Detecting fixed phrases is a weak defense: how would you get around it? That's why agents run with
  **least privilege** (`[classroom]` and the sandbox): even if the model obeys the attacker, it can't do
  harm outside what's allowed.
- What other tools would you give the librarian? Which ones would be dangerous?
