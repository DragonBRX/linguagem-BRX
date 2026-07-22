# Segmentação — GDT/LDT

## Conceito

Segmentação divide a memória em **segmentos** com base, limite e atributos.
Em x86-64, a segmentação está **quase desativada** (flat model).

## Histórico

| Modo | Segmentação |
|------|-------------|
| Real (16-bit) | Obrigatória — endereço = segmento × 16 + offset |
| Protegido (32-bit) | Complexa — GDT com múltiplos segmentos |
| Longo (64-bit) | Flat — base=0, limit=max para CS/DS/ES/SS |

## GDT em Modo Longo

```
┌────────────────────────────────────────┐
│ Índice 0: Null descriptor              │
│   Base=0, Limit=0, Present=0           │
├────────────────────────────────────────┤
│ Índice 1: Kernel Code (64-bit)         │
│   Base=0, Limit=FFFFF, DPL=0, L=1      │
├────────────────────────────────────────┤
│ Índice 2: Kernel Data                  │
│   Base=0, Limit=FFFFF, DPL=0           │
├────────────────────────────────────────┤
│ Índice 3: User Code (32-bit compat)    │
│   Base=0, Limit=FFFFF, DPL=3         │
├────────────────────────────────────────┤
│ Índice 4: User Data                    │
│   Base=0, Limit=FFFFF, DPL=3           │
├────────────────────────────────────────┤
│ Índice 5: User Code (64-bit)           │
│   Base=0, Limit=FFFFF, DPL=3, L=1      │
└────────────────────────────────────────┘
```

> Em modo longo, base e limit são ignorados para CS/DS/ES/SS.
> A memória é tratada como um espaço linear flat.

## Segmentos que ainda importam

| Segmento | Uso em 64-bit |
|----------|---------------|
| FS | Thread Local Storage (TLS) — cada thread tem base diferente |
| GS | Kernel per-CPU data (em kernelspace) / TLS (em userspace) |

### Acessar TLS via FS

```asm
# Em userspace, FS aponta para a estrutura TLS
# Acessar variável thread-local:
movq %fs:0x10, %rax    # Lê offset 0x10 da área TLS
```

## BRXH: O que precisa saber

A BRXH **não manipula GDT** (Ring 0 only). Mas pode usar:

1. **TLS via FS** — para dados por-thread (futuro)
2. **Segment override** — raro, mas possível

### Detectar base de FS/GS

```asm
# Usar arch_prctl para ler base de FS/GS
brxh_get_fs_base:
    movq $SYS_arch_prctl, %rax
    movq $0x1003, %rdi      # ARCH_GET_FS = 0x1003
    leaq fs_base, %rsi
    syscall
    movq fs_base, %rax
    ret
```
