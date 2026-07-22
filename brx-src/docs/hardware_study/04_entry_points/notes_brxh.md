# Notas de Implementação BRXH — Entry Points

## O que a BRXH realmente precisa implementar

### 1. Syscall Wrapper Genérico

```asm
# src/internal/runtime/syscalls.s
# Já parcialmente implementado na v06

# brx_syscall(n, a1, a2, a3, a4, a5, a6)
# Convenção: rax=n, rdi=a1, rsi=a2, rdx=a3, r10=a4, r8=a5, r9=a6

brx_syscall:
    pushq %rbp
    movq %rsp, %rbp

    # syscall destrói rcx e r11
    pushq %rcx
    pushq %r11

    # Preparar argumentos
    movq %rdi, %rax         # n
    movq %rsi, %rdi         # a1
    movq %rdx, %rsi         # a2
    movq %rcx, %rdx         # a3
    movq %r8, %r10          # a4 (em r10, não rcx!)
    movq %r9, %r8           # a5
    movq 16(%rbp), %r9      # a6 (da stack)

    syscall

    # Verificar erro
    testq %rax, %rax
    jns .ok

    # rax = -errno, converter
    negq %rax
    call brx_errno_to_error_code

.ok:
    popq %r11
    popq %rcx
    popq %rbp
    ret
```

### 2. Tabela de Syscalls BRX

```asm
# src/internal/runtime/syscalls.s

syscall_table:
    # read = 0
    .quad 0, brx_sys_read
    # write = 1
    .quad 1, brx_sys_write
    # open = 2
    .quad 2, brx_sys_open
    # close = 3
    .quad 3, brx_sys_close
    # stat = 4
    .quad 4, brx_sys_stat
    # fstat = 5
    .quad 5, brx_sys_fstat
    # lseek = 8
    .quad 8, brx_sys_lseek
    # mmap = 9
    .quad 9, brx_sys_mmap
    # mprotect = 10
    .quad 10, brx_sys_mprotect
    # munmap = 11
    .quad 11, brx_sys_munmap
    # brk = 12
    .quad 12, brx_sys_brk
    # ioctl = 16
    .quad 16, brx_sys_ioctl
    # nanosleep = 35
    .quad 35, brx_sys_nanosleep
    # getpid = 39
    .quad 39, brx_sys_getpid
    # exit = 60
    .quad 60, brx_sys_exit
    # uname = 63
    .quad 63, brx_sys_uname
    # fcntl = 72
    .quad 72, brx_sys_fcntl
    # getdents = 78
    .quad 78, brx_sys_getdents
    # gettimeofday = 96
    .quad 96, brx_sys_gettimeofday
    # sigaction = 13 (rt_sigaction = 13 no 64-bit? Verificar)
    # ... continuar
    .quad 0, 0              # terminator
```

### 3. Sinais

```asm
# src/internal/hardware/brxh_api.s

# Estrutura sigaction
.struct 0
sigaction_handler:  .struct sigaction_handler + 8
sigaction_flags:    .struct sigaction_flags + 8
sigaction_restorer: .struct sigaction_restorer + 8
sigaction_mask:     .struct sigaction_mask + 8
sigaction_size:

brxh_install_signal_handler:
    # rdi = signum, rsi = handler_ptr
    pushq %rbp
    movq %rsp, %rbp

    # Preencher sigaction
    movq %rsi, sigaction_handler
    movq $SA_RESTORER, sigaction_flags
    movq $0, sigaction_restorer
    movq $0, sigaction_mask

    # rt_sigaction(signum, &act, NULL, sizeof(sigset_t))
    movq $SYS_rt_sigaction, %rax
    movq %rdi, %rdi         # signum
    leaq sigaction_struct, %rsi
    xorq %rdx, %rdx         # oldact = NULL
    movq $8, %r10           # sigsetsize
    syscall

    popq %rbp
    ret
```

### 4. Timer de Alta Precisão

```asm
# src/internal/runtime_loop/timer.s

# Usar clock_gettime(CLOCK_MONOTONIC) para timing
# Mais preciso que gettimeofday (não afetado por NTP)

brxh_get_monotonic_time:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_clock_gettime, %rax
    movq $1, %rdi           # CLOCK_MONOTONIC
    leaq timespec_buf, %rsi
    syscall

    # timespec_buf.tv_sec * 1e9 + tv_nsec
    movq timespec_buf, %rax
    imulq $1000000000, %rax
    addq timespec_buf + 8, %rax

    popq %rbp
    ret
```

## Resumo de Implementação

| Conceito do Kernel | Implementação BRXH | Arquivo |
|-------------------|---------------------|---------|
| entry_SYSCALL_64 | Usar instrução `syscall` | `syscalls.s` |
| entry_64 (IRQs) | Sinais via `sigaction` | `brxh_api.s` |
| sysret | Retorno automático do kernel | — |
| iretq | Não usado (não é kernel) | — |
| Modo compat 32-bit | Não suportado (BRX é 64-bit) | — |
| Timer (IRQ 0) | `clock_gettime` / `nanosleep` | `timer.s` |
