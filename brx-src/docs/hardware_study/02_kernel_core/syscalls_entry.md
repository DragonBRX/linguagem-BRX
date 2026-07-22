# Entry Points de Syscalls — entry_SYSCALL_64

## Conceito

`entry_SYSCALL_64` é o **ponto de entrada no kernel** quando um programa
userspace executa a instrução `syscall`.

## Fluxo Completo

```
Userspace (Ring 3)                    Kernel (Ring 0)
┌─────────────────┐                   ┌─────────────────┐
│  movq $n, %rax  │                   │                 │
│  movq $a1, %rdi │                   │                 │
│  syscall        │ ──────────────> │  entry_SYSCALL_64│
│                 │                   │    swapgs         │
│                 │                   │    mov %rsp, PER_CPU_VAR(rsp_scratch)│
│                 │                   │    mov PER_CPU_VAR(cpu_current_top_of_stack), %rsp│
│                 │                   │    push %rcx      │  # RIP de retorno
│                 │                   │    push %r11     │  # RFLAGS
│                 │                   │    push %rax      │  # syscall number
│                 │                   │    ...            │
│                 │                   │    call do_syscall_64│
│                 │                   │    ...            │
│                 │                   │    pop %rax       │
│                 │                   │    pop %r11      │
│                 │                   │    pop %rcx      │
│                 │                   │    sysretq        │ ──────────────>
│  continua       │ <──────────────── │                 │
└─────────────────┘                   └─────────────────┘
```

## Convenção de Syscalls x86-64

| Registrador | Uso |
|-------------|-----|
| `rax` | Número da syscall / Retorno |
| `rdi` | Argumento 1 |
| `rsi` | Argumento 2 |
| `rdx` | Argumento 3 |
| `r10` | Argumento 4 |
| `r8`  | Argumento 5 |
| `r9`  | Argumento 6 |
| `rcx` | Destruído (guarda RIP de retorno) |
| `r11` | Destruído (guarda RFLAGS) |

## MSR (Model Specific Registers) para Syscalls

| MSR | Endereço | Função |
|-----|----------|--------|
| STAR | 0xC0000081 | CS/SS selectors para syscall/sysret |
| LSTAR | 0xC0000082 | Endereço de entry_SYSCALL_64 |
| CSTAR | 0xC0000083 | Endereço para modo compatibilidade |
| SFMASK | 0xC0000084 | Máscara de RFLAGS |

> A BRXH não manipula MSRs diretamente — o kernel já configurou.

## Syscalls Principais para BRX

| Número | Nome | BRX usa? | Para quê? |
|--------|------|----------|-----------|
| 0 | read | ✅ | I/O, evdev |
| 1 | write | ✅ | out, framebuffer |
| 2 | open | ✅ | Arquivos, /dev/fb0, /dev/input/event0 |
| 3 | close | ✅ | Fechar descritores |
| 9 | mmap | ✅ | Framebuffer, memória |
| 10 | mprotect | ⚠️ | Proteção de memória |
| 11 | munmap | ✅ | Liberar mmap |
| 12 | brk | ✅ | Heap allocator |
| 16 | ioctl | ✅ | FB info, configuração |
| 35 | nanosleep | ✅ | wait, game loop |
| 60 | exit | ✅ | Terminar programa |
| 63 | uname | ✅ | Info do sistema |
| 102 | getuid | ❌ | (futuro: sandbox) |
| 158 | arch_prctl | ❌ | (futuro: threads) |

## Implementação BRXH: Wrapper de Syscalls

```asm
# src/internal/runtime/syscalls.s
# Wrapper genérico para syscalls Linux

# brx_syscall(n, a1, a2, a3, a4, a5, a6)
# rdi = n, rsi = a1, rdx = a2, rcx = a3, r8 = a4, r9 = a5
# stack = a6

brx_syscall:
    pushq %rbp
    movq %rsp, %rbp

    # Salvar registradores que serão destruídos
    pushq %rcx
    pushq %r11

    # Preparar argumentos
    movq %rdi, %rax         # syscall number
    movq %rsi, %rdi         # arg1
    movq %rdx, %rsi         # arg2
    movq %rcx, %rdx         # arg3
    movq %r8, %r10          # arg4 (r10, não rcx!)
    movq %r9, %r8           # arg5
    movq 16(%rbp), %r9      # arg6 (da stack)

    syscall

    # Verificar erro (rax negativo = -errno)
    testq %rax, %rax
    jns .syscall_ok

    # Erro: converter para código BRX
    negq %rax
    call brx_errno_to_error

.syscall_ok:
    popq %r11
    popq %rcx
    popq %rbp
    ret
```

> ⚠️ **Nota**: `syscall` destrói `rcx` e `r11`. O kernel usa `rcx` para
> guardar o RIP de retorno e `r11` para RFLAGS. Por isso, argumento 4
> vai em `r10` (não `rcx` como na ABI normal).
