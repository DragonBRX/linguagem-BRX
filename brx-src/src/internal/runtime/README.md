# Runtime — Memória, Variáveis, Funções, Builtins, I/O

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `memory.s` | Interface de memória: alloc, free, realloc. |
| `memory_heap.s` | Heap allocator (first-fit, futuro: buddy system). |
| `memory_stack.s` | Stack de execução (call stack, expression stack). |
| `memory_gc.s` | Garbage collector (futuro: mark-and-sweep). |
| `variables.s` | Tabela de símbolos: get, set, declare, scope. |
| `functions.s` | Call stack: call, return, argument passing, closure. |
| `builtins.s` | Dispatcher de funções built-in. |
| `builtins_math.s` | abs, min, max, sqrt, sin, cos, tan, rand, floor, ceil. |
| `builtins_string.s` | len, str, lower, upper, split, join. |
| `builtins_list.s` | push, pop, len, index. |
| `io.s` | out (stdout), in (stdin), file I/O básico. |
| `syscalls.s` | Wrappers de syscalls Linux genéricos. |
| `syscalls_file.s` | open, read, write, close, lseek, stat. |
| `syscalls_mem.s` | brk, mmap, mprotect, munmap. |

## Gerenciamento de Memória

```
┌────────────────────────────────────────┐
│  Stack (cresce para baixo)            │
│  - Call frames                         │
│  - Variáveis locais                    │
├────────────────────────────────────────┤
│  Heap (cresce para cima)               │
│  - Objetos alocados dinamicamente       │
│  - Strings, listas, AST nodes           │
├────────────────────────────────────────┤
│  BSS — Variáveis globais não-inicializ.│
├────────────────────────────────────────┤
│  Data — Variáveis globais inicializadas│
│  - Tabela de tokens                     │
│  - Tabela de símbolos                   │
│  - Buffer do framebuffer               │
└────────────────────────────────────────┘
```
