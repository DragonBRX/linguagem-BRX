# Parser — Lexer + Analisador Sintático + AST

## Arquivos

| Arquivo | Descrição | Linhas (estimado) |
|---------|-----------|-------------------|
| `lexer.s` | Tokenizador principal. Lê byte a byte, identifica tokens. | ~300 |
| `lexer_tokens.s` | Tabela de tokens e keywords. Mapeia strings → IDs. | ~200 |
| `lexer_utils.s` | Utilitários: leitura de string, número, identificador. | ~150 |
| `parser.s` | Parser recursivo-descendente. Precedência de operadores. | ~400 |
| `parser_ast.s` | Construção e manipulação da Árvore Sintática Abstrata. | ~250 |
| `parser_ops.s` | Tabela de precedência e associatividade de operadores. | ~100 |
| `parser_blocks.s` | Parsing de blocos: if/else, loop, func, win, bin, hw, sbx, tr. | ~300 |

## Tokens Suportados

```
KEYWORDS: run, var, if, else, end, loop, while, forever, to, step,
          break, continue, func, return, out, in, true, false, null,
          and, or, not, win, bin, hw, sbx, tr, upd, drw, wait,
          opt, tgt, mem, alloc, free, reg, set, lim, load, src, map

TYPES: txt, num, bool, list

OPERATORS: + - * / % == != < > <= >= = += -= *= /=

DELIMITERS: ( ) [ ] : , "

COMMENTS: # até o fim da linha
```

## AST Nodes

```
NodeType: PROGRAM, BLOCK, VAR_DECL, ASSIGN, IF, LOOP, FUNC_DEF,
          FUNC_CALL, RETURN, BINARY_OP, UNARY_OP, LITERAL, IDENTIFIER,
          MEMBER_ACCESS, LIST_LITERAL, WIN_BLOCK, BIN_BLOCK, HW_BLOCK,
          SBX_BLOCK, TR_BLOCK
```
