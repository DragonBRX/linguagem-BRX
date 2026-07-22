# Kernel Core — arch/x86/kernel/

## O que o kernel faz aqui

O código em `arch/x86/kernel/` é o **coração do kernel Linux em x86**.
Gerencia interrupções, exceções, syscalls, tempo, e estado dos registradores.

## Arquivos principais do kernel

| Arquivo | Função |
|---------|--------|
| `head_64.S` | Código de inicialização 64-bit |
| `irq.c` / `irqinit.c` | Gerenciamento de interrupções |
| `idt.c` | IDT (Interrupt Descriptor Table) |
| `process.c` | Criação e gerenciamento de processos |
| `time.c` | Timer e contagem de tempo |
| `tsc.c` | Time Stamp Counter |
| `apic.c` | APIC (Advanced Programmable Interrupt Controller) |
| `smp.c` | Symmetric Multi-Processing |

## Conceitos-chave para BRXH

### 1. IDT — Interrupt Descriptor Table

A IDT mapeia interrupções e exceções para handlers:

```
┌────────────────────────────────────────┐
│  Vetor 0:  Divide Error (#DE)          │
│  Vetor 1:  Debug (#DB)                 │
│  Vetor 2:  NMI                         │
│  Vetor 3:  Breakpoint (#BP)            │
│  Vetor 4:  Overflow (#OF)              │
│  Vetor 5:  Bound Range (#BR)           │
│  Vetor 6:  Invalid Opcode (#UD)        │
│  Vetor 7:  Device Not Available (#NM)    │
│  Vetor 8:  Double Fault (#DF)          │
│  Vetor 13: General Protection (#GP)    │
│  Vetor 14: Page Fault (#PF)            │
│  ...                                    │
│  Vetor 32+: IRQs (hardware)             │
│  Vetor 128: Syscall (int 0x80 legacy)  │
│  Vetor 0x80: Syscall (moderno via MSR) │
└────────────────────────────────────────┘
```

### 2. Syscalls — entry_SYSCALL_64

Quando um programa userspace executa `syscall`:

```
Userspace (Ring 3)          Kernel (Ring 0)
     │                            │
     │  syscall                   │
     │ ─────────────────────────> │
     │                            │ entry_SYSCALL_64
     │                            │   ├── swapgs
     │                            │   ├── salva registradores
     │                            │   ├── verifica syscall number
     │                            │   ├── chama handler
     │                            │   ├── restaura registradores
     │                            │   └── sysret
     │  retorna                   │
     │ <───────────────────────── │
```

### 3. Gerenciamento de Registradores

O kernel salva/restaura o estado completo do processador em:
- **Task State Segment (TSS)** — para tarefas
- **Per-CPU areas** — dados específicos de cada core
- **Process descriptor (task_struct)** — estado do processo

## O que a BRXH precisa saber

A BRXH não manipula a IDT diretamente (isso é Ring 0), mas precisa entender:

1. **Como syscalls funcionam** — para usar corretamente
2. **Como sinais funcionam** — SIGSEGV, SIGILL, etc.
3. **Como o kernel salva estado** — para entender context switches
4. **Como o timer funciona** — para `wait` e game loop

## Notas de Implementação BRXH

Ver `notes_brxh.md` para tradução dos conceitos.
