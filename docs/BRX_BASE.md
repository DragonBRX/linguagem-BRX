# BRX Base — linguagem-base multilíngue

Esta camada não substitui o núcleo Assembly existente. Ela introduz um contrato comum para que implementações escritas em linguagens diferentes produzam a mesma representação interna.

## Objetivo

```text
Frontend BRX em Python ─┐
Frontend futuro em C ───┤
Frontend futuro em Rust ┼──> BRX-IR ──> runtime compatível
Outros frontends ───────┘
```

Cada frontend pode ser escrito na linguagem mais adequada, mas precisa gerar a mesma BRX-IR. Isso evita que a definição da linguagem fique presa a Python, C, Rust, Assembly ou qualquer outra implementação específica.

## Subconjunto inicial

```brx
let nome = "BRX"
let valor = 10
set valor = valor * 2
out "Olá " + nome
out valor
return valor
```

Instruções atuais:

- `let nome = expressão`: declara uma variável;
- `set nome = expressão`: altera uma variável existente;
- `out expressão`: produz saída;
- `return expressão`: encerra o módulo com um valor.

Expressões atuais:

- inteiros, números decimais, textos, booleanos e `None`;
- variáveis;
- `+`, `-`, `*`, `/`, `//` e `%`;
- comparações;
- `and`, `or` e `not`;
- parênteses.

## BRX-IR v1

Exemplo de representação:

```json
{
  "format": "BRX-IR",
  "version": 1,
  "module": "main",
  "instructions": [
    {
      "op": "let",
      "args": {"name": "valor", "value": "10"},
      "line": 1
    },
    {
      "op": "return",
      "args": {"value": "valor"},
      "line": 2
    }
  ]
}
```

Regras do contrato:

1. O campo `format` deve ser `BRX-IR`.
2. Alterações incompatíveis exigem uma nova versão.
3. Cada instrução possui operação, argumentos e linha de origem.
4. Frontends diferentes devem gerar operações equivalentes para o mesmo comportamento.
5. O runtime não deve depender da sintaxe original que produziu a IR.

## Execução

```bash
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --emit-ir
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --run
python3 -m unittest discover -s tests -v
```

## Próximas expansões da linguagem

- blocos `if`, `else`, `while` e `loop` na IR;
- funções e parâmetros;
- tipos BRX explícitos;
- tabela de símbolos compartilhada;
- serialização binária da BRX-IR;
- frontend de referência em C ou Rust;
- ABI de extensões para módulos escritos em outras linguagens.
