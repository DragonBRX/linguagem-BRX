# Modo Longo (64-bit) — TARGET BRX

## Conceito

Modo de operação de 64-bit dos processadores x86-64 (AMD64 / Intel 64).
**É aqui que o BRX roda**.

## Características

| Aspecto | Modo Longo |
|---------|-----------|
| Tamanho de registrador | 64-bit (rax, rbx, ..., r15) |
| Memória endereçável | 2^64 teoricamente, 2^48 praticamente |
| Endereçamento | Paginado obrigatório |
| Segmentação | Flat (quase desativada) |
| Syscalls | `syscall` / `sysret` |
| Modos de operação | 64-bit mode + compatibility mode |

## Registradores de Controle

| Registrador | Função | BRXH acessa? |
|-------------|--------|-------------|
| CR0 | Controles globais (paging, protection) | ❌ Ring 3 |
| CR2 | Endereço que causou page fault | ❌ Ring 3 |
| CR3 | Endereço base da tabela de páginas | ❌ Ring 3 |
| CR4 | Extensões (PAE, PGE, PCIDE) | ❌ Ring 3 |
| CR8 | Prioridade de interrupção (TPL) | ❌ Ring 3 |
| EFER | Long Mode Enable (MSR 0xC0000080) | ❌ Ring 3 |

> ⚠️ A BRXH em userspace **não pode ler/escrver CRx diretamente**.
> Isso gera #GP (General Protection Fault).
> Mas pode usar `cpuid` para detectar features.

## Paginação em Modo Longo

### 4-Level Paging (padrão)

```
CR3 → PML4 (Page Map Level 4)
  → PDPT (Page Directory Pointer Table)
    → PD (Page Directory)
      → PT (Page Table)
        → Página física (4KB)
```

### 5-Level Paging (futuro, Intel)

Adiciona nível PML5 para suportar > 256TB de memória virtual.

## Syscalls em Modo Longo

```asm
# Userspace (Ring 3)
movq $SYS_write, %rax
movq $1, %rdi
leaq msg, %rsi
movq $len, %rdx
syscall          # → entra no kernel via entry_SYSCALL_64

# Kernel (Ring 0)
# entry_SYSCALL_64 salva estado, despacha handler, restaura, sysret
```

## BRXH: O que implementar

A BRXH não manipula CR3/EFER diretamente, mas precisa entender:

1. **Como `mmap` funciona** — o kernel usa as tabelas de página para mapear memória
2. **Como `syscall` funciona** — entry point no kernel, handler, retorno
3. **Como detectar features** — `cpuid` para saber se o processador suporta algo

### Detectando features com CPUID

```asm
# Verificar se Long Mode é suportado
cpuid
# EAX=0x80000001, EDX bit 29 = LM (Long Mode)
```

A BRXH pode usar `cpuid` em userspace para detectar:
- SSE, AVX, AVX-512
- Número de cores
- Tamanho de cache
- etc.
