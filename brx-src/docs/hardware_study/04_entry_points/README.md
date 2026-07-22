# Entry Points — arch/x86/entry/

## O que o kernel faz aqui

O código em `arch/x86/entry/` contém os **pontos de entrada** para:
- Syscalls (`entry_SYSCALL_64`)
- Interrupções (`entry_IRQ`)
- Exceções (`entry_64`)
- Iret (`entry_SYSCALL_64_after_hwframe`)

## Arquivos principais do kernel

| Arquivo | Função |
|---------|--------|
| `entry_64.S` | Entry points para interrupções e exceções |
| `entry_32.S` | Entry points para modo compatibilidade 32-bit |
| `entry_SYSCALL_64.S` | Entry point de syscalls em 64-bit |
| `entry_SYSCALL_compat.S` | Entry point de syscalls 32-bit em 64-bit |
| `thunk_64.S` | Thunks para chamadas entre modos |

## Conceitos-chave para BRXH

### 1. entry_SYSCALL_64

Código assembly que o processador executa quando um programa userspace
chama `syscall`. Salva estado, chama handler, restaura estado.

### 2. entry_64 (Interrupções)

Código que o processador executa quando ocorre uma interrupção de hardware
ou exceção. Similar ao syscall entry mas com mais estado para salvar.

### 3. sysret / iretq

Instruções de retorno ao userspace após syscall/interrupção.

## Notas de Implementação BRXH

Ver `notes_brxh.md` para tradução dos conceitos.
