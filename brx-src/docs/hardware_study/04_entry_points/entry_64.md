# entry_64 — Interrupções e Exceções

## Conceito

Quando ocorre uma interrupção de hardware ou exceção da CPU,
o processador consulta a IDT e salta para o handler correspondente.

## Tipos de Entry

### 1. Interrupções de Hardware (IRQs)

```
Timer tick (IRQ 0):
  → IDT[32] → handler_timer → schedule() → atualiza jiffies

Teclado (IRQ 1):
  → IDT[33] → handler_keyboard → lê scancode → buffer

Mouse (IRQ 12):
  → IDT[44] → handler_mouse → lê pacote PS/2
```

### 2. Exceções da CPU

| Vetor | Nome | Causa |
|-------|------|-------|
| 0 | #DE | Divisão por zero |
| 6 | #UD | Opcode inválido |
| 13 | #GP | General Protection (acesso privilegiado) |
| 14 | #PF | Page Fault |

### 3. Interrupções de Software

```
int 0x80  → syscall legacy (32-bit)
int 0x03  → breakpoint (debug)
```

## Estrutura do Handler

```asm
# Handler genérico de interrupção
entry_interrupt:
    # Salvar todos registradores
    pushq %rax
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11

    # Chamar handler em C
    call do_interrupt_handler

    # Restaurar registradores
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rdi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rax

    # Retornar
    iretq
```

## Diferença: syscall vs interrupt entry

| Aspecto | Syscall Entry | Interrupt Entry |
|---------|---------------|-------------------|
| Instrução | `syscall` | `int` ou hardware |
| Stack switch | Via MSR/SWAPGS | Via TSS/IST |
| Registradores salvos | Mínimo (rcx, r11) | Todos |
| Retorno | `sysret` | `iretq` |
| Desempenho | ~50 ciclos | ~200+ ciclos |

## BRXH: O que implementar

A BRXH não implementa handlers de interrupção, mas pode:

### 1. Capturar Sinais

```asm
# SIGALRM para timer
# SIGIO para I/O assíncrono
# SIGSEGV para page faults

brxh_setup_sigalrm:
    # Configurar timer via setitimer
    movq $SYS_setitimer, %rax
    movq $0, %rdi               # ITIMER_REAL
    leaq new_value, %rsi
    xorq %rdx, %rdx             # old_value = NULL
    syscall
    ret
```

### 2. Usar eventfd/epoll para I/O assíncrono

```asm
# Para input não-bloqueante eficiente
# Criar epoll instance
movq $SYS_epoll_create1, %rax
movq $EPOLL_CLOEXEC, %rdi
syscall

# Adicionar fd do evdev ao epoll
# Esperar eventos com epoll_wait
```

### 3. Poll para input

```asm
# Alternativa simples: poll()
brxh_poll_input:
    movq $SYS_poll, %rax
    leaq pollfd_struct, %rdi
    movq $1, %rsi               # nfds
    movq $0, %rdx               # timeout = 0 (não bloqueante)
    syscall
    ret
```
