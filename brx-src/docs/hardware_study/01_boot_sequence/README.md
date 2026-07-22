# Sequência de Boot — arch/x86/boot/

## O que o kernel faz aqui

O código em `arch/x86/boot/` é o **primeiro código que o processador executa**
quando o Linux inicia. Ele faz a transição:

```
BIOS/UEFI → Modo Real (16-bit) → Modo Protegido (32-bit) → Modo Longo (64-bit)
```

## Arquivos principais do kernel

| Arquivo | Função |
|---------|--------|
| `header.S` | Cabeçalho do kernel (magic numbers, flags) |
| `main.c` | Função principal do boot (detecta hardware) |
| `pm.c` | Entra em modo protegido |
| `pmjump.S` | Salta para modo protegido |
| `compressed/head_64.S` | Descompressão e entrada em modo longo |

## Conceitos-chave para BRXH

### 1. Modo Real (16-bit)

- Segmentação: `segmento:offset` (ex: `0x07C0:0x0000`)
- Acesso a apenas 1MB de memória
- Interrupções via BIOS (INT 0x10, INT 0x13)
- **BRXH não usa** — BRX roda em userspace, não boota

### 2. Modo Protegido (32-bit)

- GDT (Global Descriptor Table) define segmentos
- Paginação opcional
- Acesso a 4GB de memória
- **BRXH não usa diretamente** — mas entender GDT ajuda a entender modo longo

### 3. Modo Longo (64-bit) ← **TARGET BRX**

- Paginação obrigatória (4-level ou 5-level)
- Segmentação quase desativada (flat model)
- Registradores de 64-bit
- Syscalls via `syscall`/`sysret`
- **É aqui que o BRX roda**

## O que a BRXH precisa saber

A BRXH não boota o sistema — ela roda **dentro** de um sistema já bootado.
Mas precisa entender:

- Como o processador chegou no modo longo (para não quebrar nada)
- Como a paginação está configurada (para `mmap` funcionar)
- Como os registradores de controle estão setados (CR0, CR3, CR4, EFER)

## Notas de Implementação BRXH

Ver `notes_brxh.md` para tradução dos conceitos para código BRX.
