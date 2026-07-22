# Notas de Implementação BRXH — Gerenciamento de Memória

## O que a BRXH realmente precisa implementar

### 1. Heap Allocator

```asm
# src/internal/runtime/memory_heap.s
# Heap simples usando brk() ou mmap()

# Estrutura do heap:
# ┌────────────────────────────────────────┐
# │ Header (8 bytes): tamanho + flags       │
# │ Dados do bloco                          │
# │ Header do próximo bloco                 │
# │ ...                                     │
# └────────────────────────────────────────┘

# Algoritmo: First-fit
# Futuro: Buddy system ou segregated free lists

brxh_heap_init:
    # Obter brk atual
    movq $SYS_brk, %rax
    xorq %rdi, %rdi         # addr = 0 → retorna brk atual
    syscall
    movq %rax, heap_start
    movq %rax, heap_end
    ret

brxh_heap_alloc:
    # rdi = tamanho solicitado
    # Alinhar para 8 bytes
    addq $7, %rdi
    andq $~7, %rdi

    # Adicionar header
    addq $8, %rdi

    # Tentar encontrar bloco livre (first-fit)
    # Se não encontrar, expandir heap via brk

    # Retornar ponteiro para dados (após header)
    ret

brxh_heap_free:
    # rdi = ponteiro para dados
    # Marcar bloco como livre
    # Tentar coalescer com vizinhos
    ret
```

### 2. Stack de Execução

```asm
# src/internal/runtime/memory_stack.s
# Stack para execução do interpretador BRX

# Layout do stack frame:
# ┌────────────────────────────────────────┐
# │ Return address                          │ ← %rbp + 8
# │ Saved %rbp                              │ ← %rbp
# │ Variáveis locais                        │ ← %rbp - 8, -16, ...
# │ Temporários                             │
# └────────────────────────────────────────┘

# O stack já é configurado pelo SO na inicialização.
# A BRXH apenas gerencia o uso dentro do programa.

brxh_stack_push_value:
    # Empilhar valor BRX no stack
    subq $BRXValue_size, %rsp
    movq %rdi, (%rsp)       # tipo
    movq %rsi, 8(%rsp)      # dados
    ret

brxh_stack_pop_value:
    # Desempilhar valor BRX
    movq (%rsp), %rdi
    movq 8(%rsp), %rsi
    addq $BRXValue_size, %rsp
    ret
```

### 3. Mapeamento de Framebuffer

```asm
# src/internal/visual/brxv_linux_fbdev.s

brxv_fb_init:
    pushq %rbp
    movq %rsp, %rbp

    # Abrir /dev/fb0
    movq $SYS_open, %rax
    leaq fb0_path, %rdi
    movq $O_RDWR, %rsi
    syscall
    testq %rax, %rax
    js .fb_open_error
    movq %rax, fb_fd

    # Obter vscreeninfo
    movq $SYS_ioctl, %rax
    movq fb_fd, %rdi
    movq $FBIOGET_VSCREENINFO, %rsi
    leaq fb_vinfo, %rdx
    syscall

    # Calcular tamanho do buffer
    movl fb_vinfo + FBInfo_xres_virtual, %eax
    imull fb_vinfo + FBInfo_yres_virtual, %eax
    imull fb_vinfo + FBInfo_bits_per_pixel, %eax
    shrq $3, %rax               # / 8 (bits → bytes)
    movq %rax, fb_size

    # Mapear framebuffer
    movq $SYS_mmap, %rax
    xorq %rdi, %rdi
    movq fb_size, %rsi
    movq $(PROT_READ | PROT_WRITE), %rdx
    movq $MAP_SHARED, %r10
    movq fb_fd, %r8
    xorq %r9, %r9
    syscall
    testq %rax, %rax
    js .fb_mmap_error
    movq %rax, fb_ptr

    # Fechar fd (mmap mantém referência)
    movq $SYS_close, %rax
    movq fb_fd, %rdi
    syscall

    # Sucesso
    movq $0, %rax
    jmp .fb_done

.fb_open_error:
    movq $ERR_FB_OPEN, %rax
    jmp .fb_done

.fb_mmap_error:
    movq $ERR_FB_MMAP, %rax

.fb_done:
    popq %rbp
    ret
```

### 4. Proteção de Memória

```asm
# src/internal/hardware/brxh_api.s

brxh_protect_region:
    # rdi = ptr, rsi = size, rdx = prot
    movq $SYS_mprotect, %rax
    syscall
    ret

# Uso: tornar uma região executável para JIT
# brxh_protect_region(code_ptr, code_size, PROT_READ | PROT_EXEC)
```

## Resumo de Implementação

| Conceito do Kernel | Implementação BRXH | Arquivo |
|-------------------|---------------------|---------|
| Paginação (CR3) | Usado via `mmap`/`munmap` | `syscalls_mem.s` |
| TLB | Não controla (hardware) | — |
| Page Fault | Capturado via SIGSEGV | `brxh_api.s` |
| GDT | Não manipula (flat model) | — |
| brk() | Heap allocator | `memory_heap.s` |
| mmap() | Framebuffer, memória anônima | `syscalls_mem.s`, `brxv_linux_fbdev.s` |
| mprotect() | Proteção de regiões | `brxh_api.s` |
| Huge pages | Futuro (MAP_HUGETLB) | — |
