# Notas de Implementação BRXH — Kernel Core

## O que a BRXH realmente precisa implementar

### 1. Syscalls Wrappers

Já parcialmente implementado em `src/internal/runtime/syscalls.s`.
Precisa ser expandido para cobrir todas as syscalls usadas.

```asm
# src/internal/runtime/syscalls.s
# Tabela de syscalls usadas pelo BRX

syscall_table:
    .quad SYS_read,      brx_sys_read
    .quad SYS_write,     brx_sys_write
    .quad SYS_open,      brx_sys_open
    .quad SYS_close,     brx_sys_close
    .quad SYS_mmap,      brx_sys_mmap
    .quad SYS_munmap,    brx_sys_munmap
    .quad SYS_brk,       brx_sys_brk
    .quad SYS_ioctl,     brx_sys_ioctl
    .quad SYS_nanosleep, brx_sys_nanosleep
    .quad SYS_exit,      brx_sys_exit
    .quad SYS_uname,     brx_sys_uname
    .quad SYS_gettimeofday, brx_sys_gettimeofday
    .quad SYS_poll,      brx_sys_poll
    .quad SYS_getdents,  brx_sys_getdents
    .quad SYS_stat,      brx_sys_stat
    .quad SYS_fstat,     brx_sys_fstat
    .quad SYS_lseek,     brx_sys_lseek
    .quad SYS_mprotect,  brx_sys_mprotect
    .quad SYS_rt_sigaction, brx_sys_sigaction
    .quad SYS_rt_sigprocmask, brx_sys_sigprocmask
    .quad 0, 0  # terminator
```

### 2. Tratamento de Sinais

Para capturar SIGSEGV, SIGILL, etc.:

```asm
# src/internal/hardware/brxh_api.s

brxh_install_signal_handlers:
    pushq %rbp
    movq %rsp, %rbp

    # SIGSEGV (11)
    leaq sigsegv_handler, %rdi
    call brxh_install_handler

    # SIGILL (4)
    leaq sigill_handler, %rdi
    call brxh_install_handler

    # SIGFPE (8)
    leaq sigfpe_handler, %rdi
    call brxh_install_handler

    popq %rbp
    ret

# Handler genérico
sigsegv_handler:
    # Salvar contexto
    # Log do erro
    # Tentar recuperar ou abortar graciosamente
    movq $SYS_exit, %rax
    movq $128 + 11, %rdi   # 128 + SIGSEGV
    syscall
```

### 3. Timer de Alta Precisão

```asm
# src/internal/runtime_loop/timer.s

# Usar clock_gettime(CLOCK_MONOTONIC) para timing preciso
brxh_get_time_ns:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_clock_gettime, %rax
    movq $1, %rdi           # CLOCK_MONOTONIC
    leaq timespec_buf, %rsi
    syscall

    # timespec_buf.tv_sec * 1e9 + timespec_buf.tv_nsec
    movq timespec_buf, %rax      # tv_sec
    imulq $1000000000, %rax
    addq timespec_buf + 8, %rax  # tv_nsec

    popq %rbp
    ret

# Calcular delta para game loop
brxh_timer_delta:
    call brxh_get_time_ns
    movq %rax, %rdx
    subq last_frame_time, %rdx
    movq %rax, last_frame_time
    movq %rdx, %rax
    ret
```

### 4. Info do Sistema

```asm
# src/internal/hardware/brxh_api.s

brxh_get_cpu_count:
    # Ler /proc/cpuinfo ou usar sysconf
    movq $SYS_sysconf, %rax
    movq $84, %rdi          # _SC_NPROCESSORS_ONLN
    syscall
    ret

brxh_get_total_memory:
    # Ler /proc/meminfo
    movq $SYS_open, %rax
    leaq meminfo_path, %rdi
    movq $O_RDONLY, %rsi
    syscall
    # ... parsear "MemTotal:"
    ret

brxh_get_kernel_version:
    # uname()
    movq $SYS_uname, %rax
    leaq utsname_buf, %rdi
    syscall
    # utsname_buf.release contém versão
    ret
```

## Resumo de Implementação

| Conceito do Kernel | Implementação BRXH | Arquivo |
|-------------------|---------------------|---------|
| entry_SYSCALL_64 | Wrapper `syscall` | `syscalls.s` |
| IDT | Sinais via `sigaction` | `brxh_api.s` |
| Timer (PIT/HPET) | `clock_gettime` / `nanosleep` | `timer.s` |
| Registradores (CRx) | Não acessa (Ring 3) | — |
| CPUID | `cpuid` instruction | `registers.s` |
| RDTSC | `rdtsc` instruction | `registers.s` |
| Context switch | Não controla (kernel faz) | — |
