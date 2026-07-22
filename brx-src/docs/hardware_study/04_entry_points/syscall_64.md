# entry_SYSCALL_64 — Ponto de Entrada de Syscalls

## Conceito

Quando um programa em userspace executa `syscall`, o processador:

1. Salva RIP em RCX
2. Salva RFLAGS em R11
3. Troca CS para o selector de kernel
4. Troca RIP para o endereço em LSTAR MSR
5. Troca RSP para o stack do kernel
6. Executa o código em `entry_SYSCALL_64`

## Fluxo Detalhado

```
Userspace:
  movq $SYS_write, %rax
  movq $1, %rdi
  leaq msg, %rsi
  movq $len, %rdx
  syscall                    # ← entra no kernel

Kernel (entry_SYSCALL_64):
  swapgs                      # Troca GS base para kernel
  movq %rsp, PER_CPU_VAR(rsp_scratch)  # Salva RSP userspace
  movq PER_CPU_VAR(cpu_current_top_of_stack), %rsp  # RSP kernel

  # Criar stack frame mínimo
  pushq %rcx                  # RIP de retorno (syscall colocou aqui)
  pushq %r11                  # RFLAGS (syscall colocou aqui)

  # Salvar registradores callee-saved
  pushq %rbx
  pushq %rbp
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  # Preparar argumentos para C
  movq %rax, %rdi             # syscall number
  call do_syscall_64          # Chama handler em C

  # Restaurar registradores
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  popq %rbx

  popq %r11                   # Restaura RFLAGS
  popq %rcx                   # Restaura RIP

  # Retornar ao userspace
  movq PER_CPU_VAR(rsp_scratch), %rsp  # Restaura RSP userspace
  swapgs                      # Troca GS base de volta
  sysretq                     # Retorna ao userspace
```

## O que acontece em `do_syscall_64`

```c
long do_syscall_64(unsigned long nr, struct pt_regs *regs) {
    // Verificar se syscall number é válido
    if (nr >= NR_syscalls)
        return -ENOSYS;

    // Chamar handler da syscall table
    return sys_call_table[nr](regs);
}
```

## MSR (Model Specific Registers) Envolvidos

| MSR | Endereço | Valor no Linux |
|-----|----------|----------------|
| STAR | 0xC0000081 | CS/SS selectors para syscall/sysret |
| LSTAR | 0xC0000082 | Endereço de entry_SYSCALL_64 |
| CSTAR | 0xC0000083 | Endereço para modo compatibilidade |
| SFMASK | 0xC0000084 | Máscara de RFLAGS (quais bits limpar) |

## Diferença: syscall vs int 0x80

| Aspecto | syscall (moderno) | int 0x80 (legacy) |
|---------|-------------------|-------------------|
| Velocidade | Rápido (~50 ciclos) | Lento (~200+ ciclos) |
| Registradores | rax, rdi, rsi, rdx, r10, r8, r9 | eax, ebx, ecx, edx, esi, edi, ebp |
| Retorno | sysret | iret |
| 64-bit | Sim | Não (32-bit only) |

O BRX usa `syscall` (não `int 0x80`) porque é mais rápido e suporta 64-bit.

## BRXH: O que implementar

A BRXH **não implementa entry_SYSCALL_64** — isso é código do kernel.
Mas precisa entender:

1. **Como usar syscall corretamente** — convenção de registradores
2. **O que o kernel faz por baixo** — para debugar problemas
3. **Como sysret funciona** — para entender o retorno

### Convenção de Syscalls BRX

```asm
# Wrapper padronizado para todas as syscalls
# Entrada: rax = número, rdi, rsi, rdx, r10, r8, r9 = args
# Saída: rax = retorno (negativo = erro)

brx_do_syscall:
    # Salvar rcx e r11 (destruídos por syscall)
    pushq %rcx
    pushq %r11

    # Executar syscall
    syscall

    # Verificar erro
    testq %rax, %rax
    jns .syscall_ok

    # Erro: rax contém -errno
    # Converter para código BRX
    negq %rax
    call brx_translate_errno

.syscall_ok:
    popq %r11
    popq %rcx
    ret
```

### Leitura de MSRs (apenas info)

```asm
# A BRXH pode ler MSRs apenas se tiver CAP_SYS_RAWIO
# Normalmente não tem — é userspace

# Mas pode ler via /dev/cpu/0/msr (se montado)
brxh_read_msr:
    movq $SYS_open, %rax
    leaq msr_path, %rdi
    movq $O_RDONLY, %rsi
    syscall
    # ...
    ret
```
