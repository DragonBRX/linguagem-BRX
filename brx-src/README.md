# 🐉 Linguagem BRX

> **Domínio Total — Do Código ao Metal**

BRX é um ecossistema de linguagem de programação com **7 camadas linguísticas** que cobrem todo o caminho do código-fonte até o hardware físico. Implementado em **Assembly x86-64 puro**, sem dependências externas.

---

## 🏗️ Arquitetura de Duas Faces

```
┌─────────────────────────────────────────────────────────────┐
│              CAMADA EXTERNA (FÁCIL)                          │
│         O que o programador vê e escreve (.brx)             │
├─────────────────────────────────────────────────────────────┤
│  BRX[E] EASY      → var, if, loop, func, out, in           │
│  BRX[V] VISUAL    → win, drw, circ, lin, outfb, key        │
│  BRX[R] RUNTIME   → upd, drw, wait (game loop)             │
│  BRX[B] BINARY    → bin, opt, tgt (compilação)             │
│  BRX[H] HARDWARE  → hw, mem, reg (metal)                   │
│  BRX[S] SANDBOX   → sbx, lim, load (isolamento)            │
│  BRX[T] TRANSLATE → tr, src, map (compatibilidade)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              CAMADA INTERNA (DIFÍCIL)                        │
│      O motor escondido — o programador NÃO VÊ              │
├─────────────────────────────────────────────────────────────┤
│  BRX[I] INTERNAL  → brx_core.s (2.793 linhas, assembly)    │
│                                                              │
│  • Parser: lexer.s, parser.s, ast.s                         │
│  • Runtime: memory.s, stack.s, heap.s, builtins.s             │
│  • Visual: framebuffer, evdev, bitmap 8×8, backends         │
│  • Binary: ELF/PE/Mach-O nativos, sem GCC/LLVM/Python       │
│  • Hardware: syscalls diretas, registradores, mmap           │
│  • Sandbox: isolamento de processo, limites                 │
│  • Translate: mapeamento de syscalls, compatibilidade       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

```bash
# Clonar
git clone https://github.com/dragonvps/linguagem-BRX.git
cd linguagem-BRX

# Build
./tools/build.sh

# Rodar exemplo
./build/linux/brx examples/brxe/ex01_hello.brx

# Ou compilar para executável nativo
./build/linux/brx compile examples/brxv/ex25_demo_completa.brx --output demo
./demo
```

---

## 📁 Estrutura do Repositório

```
linguagem-BRX/
├── src/
│   ├── external/     # API pública (documentação dos comandos .brx)
│   └── internal/     # Motor em assembly (BRX[I])
│       ├── core/     # Entry point, main loop, config
│       ├── parser/   # Lexer, parser, AST (7 arquivos modulares)
│       ├── runtime/  # Memória, variáveis, funções, builtins (14 arquivos)
│       ├── visual/   # BRXV: framebuffer, input, backends (15 arquivos)
│       ├── runtime_loop/  # BRXR: game loop, timer, events
│       ├── binary/   # BRXB: compilador ELF/PE/Mach-O
│       ├── hardware/ # BRXH: registradores, syscalls, mmap
│       ├── sandbox/  # BRXS: isolamento, limites
│       ├── translate/# BRXT: compatibilidade cross-platform
│       └── include/  # Headers compartilhados
├── examples/         # Exemplos por camada (brxe, brxv, brxr, brxh, brxs)
├── tests/            # Testes unitários por módulo
├── docs/             # Documentação completa
├── tools/            # Scripts de build, debug, benchmark
├── assets/           # Fontes, ícones, temas
└── build/            # Output de compilação
```

---

## 🎨 Camadas Visuais (BRXV) — v06

| Comando | Descrição | Status |
|---------|-----------|--------|
| `win` | Abre janela/framebuffer | ✅ |
| `drw` | Retângulo | ✅ |
| `circ` | Círculo | ✅ |
| `lin` | Linha | ✅ |
| `outfb` | Texto na tela (bitmap 8×8) | ✅ |
| `clr` | Limpa tela | ✅ |
| `wait` | Pausa (ms) | ✅ |
| `key` | Leitura de teclado (evdev) | ✅ |
| `mouse` | Leitura de mouse | ❌ |
| Múltiplas janelas | — | ❌ |
| X11/Wayland | — | ❌ |

---

## 🛠️ Requisitos

- Linux kernel (para framebuffer e evdev)
- Console puro (TTY) — **não funciona em X11/Wayland**
- Assembler: `nasm` ou `as` (GNU assembler)
- Nada mais. Zero dependências.

---

## 📜 Licença

MIT License — Dragon Projects BR

---

*BRX v06 · Assembly x86-64 · 7 Camadas · 2026*
