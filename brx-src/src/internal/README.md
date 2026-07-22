# BRX[I] — Camada Interna (Motor)

> **O que o programador NÃO VÊ.**

Esta pasta contém todo o motor do BRX implementado em **Assembly x86-64 puro**.
Nada aqui é exposto ao usuário final — tudo é acessado indiretamente via os comandos `.brx` das camadas externas.

## Filosofia

- **Um arquivo por responsabilidade**: lexer, parser, memória, desenho, input, etc.
- **Sem acoplamento**: cada módulo tem API própria, comunica-se via registradores.
- **Zero dependências**: nenhuma libc, nenhum toolkit, nenhum framework.

## Estrutura

```
src/internal/
├── include/        # Headers compartilhados (defs, structs, errors, debug)
├── core/           # Entry point, main loop, configurações
├── parser/         # Lexer + Parser + AST (7 arquivos)
├── runtime/        # Memória, variáveis, funções, builtins, I/O, syscalls (14 arquivos)
├── visual/         # BRXV: framebuffer, input, backends (15 arquivos)
├── runtime_loop/   # BRXR: game loop, timer, events (3 arquivos)
├── binary/         # BRXB: compilador ELF/PE/Mach-O (6 arquivos)
├── hardware/       # BRXH: registradores, mmap, assembly inline (5 arquivos)
├── sandbox/        # BRXS: isolamento, limites (4 arquivos)
└── translate/      # BRXT: compatibilidade cross-platform (4 arquivos)
```

## Como Funciona a Tradução

Quando o usuário escreve:
```
win
  drw 100 100 200 150 #FF0000
end
```

A camada interna executa:
1. **lexer.s** → tokeniza `win`, `drw`, números, cor
2. **parser_blocks.s** → reconhece bloco `win...end`
3. **brxv_api.s** → despacha para backend ativo
4. **brxv_linux_fbdev.s** → abre `/dev/fb0`, mapeia memória
5. **brxv_draw.s** → calcula offset, pinta pixels

O usuário nunca vê os passos 4 e 5.

## Compilação

```bash
# Todos os arquivos .s são concatenados e montados:
cat src/internal/include/*.s     src/internal/core/*.s     src/internal/parser/*.s     src/internal/runtime/*.s     src/internal/visual/*.s     ... > build/linux/brx_core.s

nasm -f elf64 build/linux/brx_core.s -o build/linux/brx_core.o
ld build/linux/brx_core.o -o build/linux/brx
```

## Convenções

- Registradores preservados: `rbx`, `rbp`, `r12-r15`
- Registradores voláteis: `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8-r11`
- Retorno de função em `rax`
- Argumentos: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
