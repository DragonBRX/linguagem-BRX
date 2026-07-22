# Gerenciamento de Registradores

## Registradores x86-64

### Registradores de Uso Geral

| Registrador | 64-bit | 32-bit | 16-bit | 8-bit | Uso na ABI System V |
|-------------|--------|--------|--------|-------|---------------------|
| rax | rax | eax | ax | al | Retorno de função |
| rbx | rbx | ebx | bx | bl | **Preservado** |
| rcx | rcx | ecx | cx | cl | Arg 4 (volátil) |
| rdx | rdx | edx | dx | dl | Arg 3 (volátil) |
| rsi | rsi | esi | si | sil | Arg 2 (volátil) |
| rdi | rdi | edi | di | dil | Arg 1 (volátil) |
| rbp | rbp | ebp | bp | bpl | **Preservado** (frame pointer) |
| rsp | rsp | esp | sp | spl | Stack pointer |
| r8 | r8 | r8d | r8w | r8b | Arg 5 (volátil) |
| r9 | r9 | r9d | r9w | r9b | Arg 6 (volátil) |
| r10 | r10 | r10d | r10w | r10b | Volátil |
| r11 | r11 | r11d | r11w | r11b | Volátil |
| r12 | r12 | r12d | r12w | r12b | **Preservado** |
| r13 | r13 | r13d | r13w | r13b | **Preservado** |
| r14 | r14 | r14d | r14w | r14b | **Preservado** |
| r15 | r15 | r15d | r15w | r15b | **Preservado** |

### Registradores de Segmento (64-bit)

| Registrador | Uso em Modo Longo |
|-------------|-------------------|
| cs | Code Segment (base=0, limit=max) |
| ds | Data Segment (não usado, base=0) |
| es | Extra Segment (não usado) |
| ss | Stack Segment |
| fs | Base de TLS (Thread Local Storage) |
| gs | Base de kernel structures (PER_CPU) |

### Registradores de Controle

| Registrador | Função | BRXH acessa? |
|-------------|--------|-------------|
| CR0 | PG, PE, WP, etc. | ❌ Ring 3 |
| CR2 | Endereço do último page fault | ❌ Ring 3 |
| CR3 | Base da tabela de páginas (PML4) | ❌ Ring 3 |
| CR4 | PAE, PGE, PCIDE, SMEP, SMAP | ❌ Ring 3 |
| CR8 | TPL (Task Priority Level) | ❌ Ring 3 |
| EFER | LME, SCE, NX | ❌ Ring 3 (MSR) |

## Como o Kernel Gerencia Registradores

### Context Switch

Quando o kernel troca de processo:

```
1. Salva todos registradores do processo atual na task_struct
2. Atualiza CR3 para a nova tabela de páginas
3. Restaura registradores do novo processo
4. Retorna (iretq)
```

### Syscall Entry

```
entry_SYSCALL_64:
  swapgs                          # Troca GS base para kernel
  mov %rsp, PER_CPU_VAR(rsp_scratch) # Salva RSP userspace
  mov PER_CPU_VAR(cpu_current_top_of_stack), %rsp # RSP do kernel
  push %rcx                        # Salva RIP (syscall coloca aqui)
  push %r11                        # Salva RFLAGS
  ...
```

## BRXH: Acesso a Registradores

A BRXH pode acessar **registradores de uso geral** livremente.
Registradores de controle (CRx) requerem Ring 0.

### Implementação: Ler Registradores de Debug

```asm
# src/internal/hardware/registers.s
# Lê registradores de debug (DR0-DR7) — requer Ring 0 ou CAP_SYS_PTRACE

brxh_read_dr0:
    # Em Ring 3, isso gera #GP
    # Mas podemos usar ptrace em outro processo

    # Alternativa: usar /proc/self/status
    movq $SYS_open, %rax
    leaq proc_status, %rdi
    movq $O_RDONLY, %rsi
    syscall
    # ... ler e parsear
    ret
```

### Implementação: CPUID

```asm
# Detectar features do processador

brxh_cpuid:
    pushq %rbx

    # Nível básico
    movq $1, %rax
    cpuid

    # ECX features:
    # bit 0: SSE3
    # bit 9: SSSE3
    # bit 19: SSE4.1
    # bit 20: SSE4.2
    # bit 28: AVX

    # EDX features:
    # bit 25: SSE
    # bit 26: SSE2

    # Nível estendido
    movq $0x80000001, %rax
    cpuid

    # EDX features:
    # bit 29: LM (Long Mode)
    # bit 20: NX (No-Execute)

    popq %rbx
    ret
```

### Implementação: RDTSC (Time Stamp Counter)

```asm
# Lê contador de ciclos do processador
# Útil para benchmarks de alta precisão

brxh_rdtsc:
    rdtsc                    # EDX:EAX = TSC
    shlq $32, %rdx
    orq %rdx, %rax           # RAX = TSC completo
    ret
```

### Implementação: RDRAND / RDSEED

```asm
# Números aleatórios via hardware

brxh_rdrand:
    rdrand %rax              # RAX = número aleatório
    jc .rdrand_ok            # CF=1 = sucesso
    movq $-1, %rax           # Falha
.rdrand_ok:
    ret
```
