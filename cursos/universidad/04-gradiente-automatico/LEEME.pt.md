# Gradiente automático

Na lição 3 você escreveu as derivadas à mão. Com uma rede de milhões de pesos isso é impossível: as
derivadas são calculadas pelo próprio programa, com **diferenciação automática em modo reverso**
(*backpropagation*).

A ideia:

1. Cada operação cria um **nó** que guarda o seu valor e de quais nós ele saiu. Assim, ao calcular
   `y = tanh(x·w + b)`, fica montado um grafo: `x, w → (·) → (+ b) → tanh → y`.
2. Cada nó sabe como **distribuir para trás** o gradiente que chega a ele (a regra da cadeia):
   - soma `a + b`: passa a cada um o mesmo gradiente;
   - produto `a · b`: para `a` passa `b · g`, e para `b` passa `a · g`;
   - `tanh(a)`: passa `(1 − tanh²(a)) · g`.
3. `Backward` coloca o gradiente de `y` em 1 e percorre o grafo **ao contrário**, em uma ordem em que cada nó
   já recebeu todo o seu gradiente antes de distribuí-lo (ordem topológica invertida). Se um nó é usado duas
   vezes, os gradientes que chegam a ele são **somados**.

## O que você vai fazer

`inicio.pas` tem uma versão pequena de `Pai.Learn.Grad`. A soma já está escrita como exemplo.

1. O passo para trás do produto (`Mul`) e de `Tanh`.
2. `Backward`: a ordem topológica (com `Visitar`, recursivo) e o percurso ao contrário.

Os testes comparam os seus gradientes com os da biblioteca e com a inclinação medida.

## Para pensar

- Por que a ordem importa? Procure um exemplo em que percorrer em outra ordem dê um gradiente incompleto.
- Leia `src/Pai.Learn.Grad.pas`: o que ele tem que a sua versão não tem?
