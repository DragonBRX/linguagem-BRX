# Interrupções — IDT e IRQs

## Conceito

Interrupções são eventos que **pausam a execução atual** do processador
para atender algo mais urgente.

## Tipos de Interrupções

| Tipo | Origem | Exemplos |
|------|--------|----------|
| **Exceções** | CPU | Divisão por zero, page fault, opcode inválido |
| **IRQs** | Hardware | Teclado, mouse, timer, disco, rede |
| **Syscalls** | Software | chamadas intencionais ao kernel |
| **IPIs** | Outro core | Mensagens entre CPUs |

## IDT (Interrupt Descriptor Table)

Estrutura em memória que mapeia vetores (0-255) para handlers:

```
IDT[0]  → handler_divide_error
IDT[1]  → handler_debug
...
IDT[14] → handler_page_fault
...
IDT[32] → handler_timer_irq
IDT[33] → handler_keyboard_irq
...
IDT[128] → handler_syscall
```

## Exceções Importantes para BRXH

| Vetor | Nome | Causa Comum | BRXH lida? |
|-------|------|-------------|------------|
| 0 | #DE | Divisão por zero | ✅ via runtime check |
| 6 | #UD | Opcode inválido | ⚠️ deve capturar |
| 13 | #GP | Acesso privilegiado | ⚠️ pode acontecer |
| 14 | #PF | Page fault | ⚠️ mmap inválido |

## IRQs e Hardware

| IRQ | Dispositivo | BRXH usa? |
|-----|-------------|-----------|
| 0 | Timer (PIT/HPET) | ✅ via nanosleep |
| 1 | Teclado | ✅ via evdev |
| 12 | Mouse | ❌ (futuro) |
| 14 | IDE primário | ❌ |

## Como o kernel lida com IRQs

```
Hardware gera IRQ
  → PIC/APIC recebe
  → CPU pausa execução atual
  → Salva estado mínimo (RFLAGS, CS, RIP)
  → Consulta IDT
  → Executa handler
  → Envia EOI (End of Interrupt)
  → Restaura estado
  → Retorna (iretq)
```

## BRXH: O que implementar

A BRXH não manipula PIC/APIC/IDT, mas pode:

1. **Capturar sinais** via `sigaction` syscall:

```asm
# Instalar handler para SIGSEGV
movq $SYS_rt_sigaction, %rax
movq $11, %rdi              # SIGSEGV
leaq handler_struct, %rsi
xorq %rdx, %rdx             # oldact = NULL
movq $8, %r10               # sigsetsize
syscall
```

2. **Usar timer** via `nanosleep` ou `timer_create`:

```asm
# nanosleep para delays precisos
movq $SYS_nanosleep, %rax
leaq timespec_struct, %rdi
xorq %rsi, %rsi             # rem = NULL
syscall
```

3. **Polling não-bloqueante** para input (evdev):

```asm
# open com O_NONBLOCK
movq $SYS_open, %rax
leaq input_path, %rdi
movq $(O_RDONLY | O_NONBLOCK), %rsi
syscall

# read retorna -EAGAIN se não houver dados
```
