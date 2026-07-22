# Paginação — Tabelas de Página x86-64

## Conceito

Paginação é o mecanismo que traduz **endereços virtuais** em **endereços físicos**.
Em modo longo (64-bit), a paginação é **obrigatória**.

## Estrutura: 4-Level Paging

```
Endereço Virtual (64-bit):
┌─────────┬─────────┬─────────┬─────────┬──────────────┐
│  PML4   │  PDPT   │   PD    │   PT    │   Offset     │
│  9 bits │  9 bits │  9 bits │  9 bits │   12 bits    │
│  (bits  │ (bits   │ (bits   │ (bits   │  (bits 0-11) │
│  39-47) │ 30-38)  │ 21-29)  │ 12-20)  │              │
└─────────┴─────────┴─────────┴─────────┴──────────────┘

Total endereçável: 2^48 = 256TB (com sign extension)
Tamanho de página: 2^12 = 4KB
```

## Hierarquia de Tabelas

```
CR3 (registrador de controle)
  │
  ▼
┌────────────────────────────────────────┐
│ PML4 (Page Map Level 4)                │
│ 512 entradas × 8 bytes = 4096 bytes   │
│ Cada entrada aponta para um PDPT        │
└────────────────────────────────────────┘
  │
  ▼
┌────────────────────────────────────────┐
│ PDPT (Page Directory Pointer Table)    │
│ 512 entradas                           │
│ Cada entrada aponta para um PD          │
└────────────────────────────────────────┘
  │
  ▼
┌────────────────────────────────────────┐
│ PD (Page Directory)                    │
│ 512 entradas                           │
│ Cada entrada aponta para um PT         │
│ OU diretamente para página de 2MB      │
└────────────────────────────────────────┘
  │
  ▼
┌────────────────────────────────────────┐
│ PT (Page Table)                        │
│ 512 entradas                           │
│ Cada entrada aponta para página de 4KB  │
└────────────────────────────────────────┘
  │
  ▼
Página Física (4KB)
```

## Formato de Entrada de Tabela de Página

```
Bits 0 (P): Presente — página mapeada?
Bits 1 (R/W): Read/Write — escrita permitida?
Bits 2 (U/S): User/Supervisor — acessível em Ring 3?
Bits 3 (PWT): Page Write Through
Bits 4 (PCD): Page Cache Disable
Bits 5 (A): Accessed — CPU seta quando lê
Bits 6 (D): Dirty — CPU seta quando escreve
Bits 7 (PS): Page Size (em PD/PDPT — 0=4KB, 1=2MB/1GB)
Bits 8 (G): Global — não flusha em TLB context switch
Bits 9-11: Ignorados (disponível para SO)
Bits 12-51: Endereço físico da próxima tabela/página
Bits 52-62: Ignorados / reservados
Bits 63 (XD): Execute Disable (se EFER.NXE=1)
```

## Huge Pages

| Tipo | Tamanho | Onde configurado |
|------|---------|------------------|
| Normal | 4KB | Entrada PT |
| Huge | 2MB | Entrada PD (PS=1) |
| Giant | 1GB | Entrada PDPT (PS=1) |

Huge pages reduzem TLB misses mas aumentam fragmentação.

## TLB (Translation Lookaside Buffer)

Cache hardware que armazena traduções recentes virtual→físico.

```
Acesso à memória:
  1. Verificar TLB (rápido, ~1 ciclo)
  2. Se miss: percorrer tabelas de página (lento, ~100 ciclos)
  3. Atualizar TLB
```

Instruções para invalidar TLB:
- `invlpg addr` — invalida entrada específica
- `mov %rax, %cr3` — invalida TLB inteiro

## BRXH: O que precisa saber

A BRXH **não manipula tabelas de página diretamente** (isso é Ring 0).
Mas precisa entender:

1. **Por que `mmap` funciona** — o kernel atualiza as tabelas
2. **Page alignment** — `mmap` retorna endereços alinhados a 4KB
3. **Page faults** — acessar memória não-mapeada gera SIGSEGV
4. **Cache effects** — huge pages podem melhorar performance

### Alinhamento de Página

```asm
# mmap retorna endereço alinhado a PAGE_SIZE (4096)
# Últimos 12 bits são sempre 0

movq $SYS_mmap, %rax
xorq %rdi, %rdi         # addr = NULL (kernel escolhe)
movq $4096, %rsi        # length = 4KB
movq $(PROT_READ | PROT_WRITE), %rdx
movq $(MAP_PRIVATE | MAP_ANONYMOUS), %r10
movq $-1, %r8           # fd = -1 (anônimo)
xorq %r9, %r9           # offset = 0
syscall

# rax contém endereço alinhado: rax & 0xFFF == 0
```

### Verificar se endereço é alinhado

```asm
brxh_is_page_aligned:
    testq $0xFFF, %rdi
    jnz .not_aligned
    movq $1, %rax
    ret
.not_aligned:
    movq $0, %rax
    ret
```
