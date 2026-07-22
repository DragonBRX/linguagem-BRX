# Core — Ponto de Entrada e Loop Principal

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `brx_entry.s` | Entry point `_start`. Inicializa stack, heap, e chama main. |
| `brx_main.s` | Loop principal: lê arquivo .brx → chama parser → executa AST. |
| `brx_config.s` | Flags de compilação, constantes de configuração, detecção de SO. |

## Fluxo de Execução

```
_start
  └── brx_entry.s
        ├── init_memory()        # brk, mmap
        ├── init_variables()     # tabela de símbolos vazia
        ├── init_visual()        # detecta backend disponível
        ├── parse_args()         # argv, argc
        └── brx_main()
              ├── open_source()  # abre .brx
              ├── lexer_run()    # tokeniza
              ├── parser_run()   # constroi AST
              └── interpreter_run()  # executa nó por nó
                    └── dispatch()   # chama handler de cada comando
```
