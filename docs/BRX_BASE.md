# BRX Base — linguagem-base multilíngue

Esta camada não substitui o núcleo Assembly existente. Ela define um contrato comum para que implementações escritas em linguagens diferentes produzam a mesma representação interna.

## Objetivo

```text
Frontend BRX em Python ─┐
Frontend futuro em C ───┤
Frontend futuro em Rust ┼──> BRX-IR ──> runtime compatível
Outros frontends ───────┘
```

Cada frontend pode ser escrito na linguagem mais adequada, mas precisa gerar a mesma BRX-IR. A definição da linguagem não fica presa a Python, C, Rust, Assembly ou outra implementação específica.

## Sintaxe atual

```brx
fn dobro(valor)
    return valor * 2
end

let soma = 0
loop i:1 to 5
    if i == 3
        continue
    end
    set soma = soma + dobro(i)
end

if soma > 10
    out "resultado=" + soma
else
    out "resultado pequeno"
end

return soma
```

### Declarações e saída

- `let nome = expressão`: declara uma variável;
- `set nome = expressão`: altera uma variável existente;
- `out expressão`: produz saída;
- `return expressão`: retorna um valor;
- `return`: retorna sem valor.

### Controle de fluxo

- `if condição` / `else` / `end`;
- `while condição` / `end`;
- `loop i:1 to 10` / `end`;
- `loop i:10 downto 1` / `end`;
- `break`;
- `continue`.

### Funções

```brx
fn soma(a, b)
    return a + b
end

let resultado = soma(20, 22)
```

As variáveis criadas dentro de uma função pertencem ao escopo local da chamada.

### Expressões

- inteiros, números decimais, textos, booleanos e `None`;
- variáveis e chamadas de funções BRX;
- `+`, `-`, `*`, `/`, `//` e `%`;
- `==`, `!=`, `<`, `<=`, `>` e `>=`;
- `and`, `or` e `not`;
- parênteses.

Código Python arbitrário, atributos, índices, imports e chamadas externas não são aceitos pelo avaliador de referência.

## BRX-IR v2

A BRX-IR v2 representa blocos de forma estrutural. Um `if` possui listas internas `then` e `else`; loops e funções possuem um campo `body`.

```json
{
  "format": "BRX-IR",
  "version": 2,
  "module": "main",
  "instructions": [
    {
      "op": "if",
      "args": {
        "condition": "x > 0",
        "then": [
          {"op": "print", "args": {"value": "x"}, "line": 2}
        ],
        "else": []
      },
      "line": 1
    }
  ]
}
```

Regras do contrato:

1. O campo `format` deve ser `BRX-IR`.
2. Alterações incompatíveis exigem uma nova versão.
3. Cada instrução possui operação, argumentos e linha de origem.
4. Blocos são armazenados como listas de instruções aninhadas.
5. Frontends diferentes devem gerar operações equivalentes para o mesmo comportamento.
6. O runtime não deve depender da sintaxe original que produziu a IR.
7. Um runtime deve rejeitar operações que não reconheça.

## Operações IR v2

- `let`, `set`, `print`, `return`;
- `if`;
- `while`;
- `loop`;
- `break`, `continue`;
- `function`.

## Segurança do runtime de referência

- limite padrão de 100.000 instruções executadas;
- expressões analisadas por AST restrita;
- nenhuma importação ou acesso direto ao ambiente Python;
- erro para variável, função ou operação inexistente.

## Execução

```bash
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --emit-ir
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --run
python3 -m unittest discover -s tests -v
```

## Próximas expansões da linguagem

- tipos BRX explícitos e verificáveis;
- listas, mapas e estruturas;
- tabela de símbolos compartilhada;
- importação de módulos BRX;
- serialização binária da BRX-IR;
- frontend de referência em C ou Rust;
- ABI de extensões para módulos escritos em outras linguagens.
