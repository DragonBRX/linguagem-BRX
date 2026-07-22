# Modo Protegido (32-bit)

## Conceito

Modo intermediário entre real e longo. Ainda usado por sistemas de 32-bit.
O kernel Linux passa por ele rapidamente no boot.

## Características

| Aspecto | Modo Protegido |
|---------|---------------|
| Tamanho de registrador | 32-bit |
| Memória endereçável | 4 GB |
| Endereçamento | Linear (via GDT) ou Paginado |
| Proteção de memória | Sim (rings 0-3) |
| Multitarefa | Sim (via TSS) |

## GDT (Global Descriptor Table)

A GDT define como a memória é segmentada:

```
┌────────────────────────────────────────┐
│  Índice 0: Null descriptor             │
│  Índice 1: Code segment (kernel)       │
│  Índice 2: Data segment (kernel)       │
│  Índice 3: Code segment (user)         │
│  Índice 4: Data segment (user)         │
│  ...                                    │
└────────────────────────────────────────┘
```

No modo longo (64-bit), a GDT ainda existe mas é "flat":
- Base = 0
- Limit = máximo (4GB ou 64-bit)
- Segmentos se sobrepõem completamente

## Rings de Proteção

```
Ring 0: Kernel (privilegiado)     ← BRXH roda aqui? NÃO!
Ring 1: Drivers (raramente usado)
Ring 2: Drivers (raramente usado)
Ring 3: Userspace (não-privilegiado)  ← BRXH roda aqui!
```

**Importante**: A BRXH roda em **Ring 3** (userspace). Não pode acessar
registradores de controle diretamente (CR0, CR3, etc.) sem syscall.

## Transição para Modo Longo

O kernel faz:

1. Habilita PAE (Physical Address Extension) em CR4
2. Carrega tabelas de página (CR3)
3. Seta bit LME (Long Mode Enable) em EFER MSR
4. Ativa paginação (PG em CR0)
5. Faz jump para código de 64-bit

## BRXH: O que aprender daqui

- Como a **GDT** funciona (mesmo que BRX não a manipule diretamente)
- Como os **rings** funcionam (BRXH está em Ring 3)
- Como a **paginação** é ativada (fundamental para `mmap`)
