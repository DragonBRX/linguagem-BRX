# Binary — BRXB (Compilação para Executável Nativo)

## Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `compiler.s` | Compilador principal: .brx → código de máquina | ✅ (ELF) |
| `compiler_elf.s` | Geração de ELF64 Linux | ✅ |
| `compiler_pe.s` | Geração de PE (Windows) | ❌ |
| `compiler_macho.s` | Geração de Mach-O (macOS) | ❌ |
| `linker.s` | Linker mínimo próprio | ⚠️ (básico) |
| `optimizer.s` | Otimizador: speed vs size | ❌ |

## Fluxo de Compilação

```
.brx fonte
  ├── lexer_run()      → tokens
  ├── parser_run()     → AST
  └── compiler_run()
        ├── codegen()  → gera código x86-64
        ├── optimize() → (futuro) elimina dead code, inlining
        └── emit()
              ├── ELF: compiler_elf.s
              ├── PE:  compiler_pe.s   (futuro)
              └── Mach-O: compiler_macho.s (futuro)
```

## Formato ELF64

```
ELF Header (64 bytes)
  ├── Program Header Table
  ├── .text section (código)
  ├── .data section (dados inicializados)
  ├── .rodata section (strings, constantes)
  ├── .bss section (dados não-inicializados)
  └── Section Header Table
```

## Comando BRX

```
bin
  opt speed       # ou "size"
  tgt linux64     # ou "win64", "macos"
end
```

Gera: `programa` (ELF executável)
