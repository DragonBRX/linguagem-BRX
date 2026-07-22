# Notas de Implementação BRXH — Boot Sequence

## O que a BRXH realmente precisa

A BRXH **não boota o sistema**. Ela roda dentro de um Linux já bootado.
Mas precisa entender o estado do processador para:

1. **Verificar** se está realmente em modo longo
2. **Detectar** features do processador (cpuid)
3. **Usar** syscalls corretamente
4. **Mapear** memória via `mmap` (que depende da paginação)

## Implementação BRXH: Detecção de Modo

```asm
# src/internal/hardware/brxh_api.s
# Verifica se o processador está em modo longo

brxh_check_long_mode:
    pushq %rbx

    # Tentar ler CR0 — se falhar (GP fault), não está em modo longo
    # Na verdade, em Ring 3, ler CR0 sempre falha
    # Então usamos cpuid

    movq $0x80000001, %rax
    cpuid
    testq $0x20000000, %rdx    # bit 29 = LM
    jz .not_long_mode

    movq $1, %rax               # TRUE
    jmp .done

.not_long_mode:
    movq $0, %rax               # FALSE

.done:
    popq %rbx
    ret
```

## Implementação BRXH: CPUID

```asm
# src/internal/hardware/registers.s
# Detecta features do processador

brxh_cpuid_features:
    pushq %rbx
    pushq %rcx
    pushq %rdx

    # CPUID nível 1 — informações básicas
    movq $1, %rax
    cpuid

    # ECX bits:
    # bit 0: SSE3
    # bit 9: SSSE3
    # bit 19: SSE4.1
    # bit 20: SSE4.2
    # bit 28: AVX

    # EDX bits:
    # bit 25: SSE
    # bit 26: SSE2

    # Guardar em estrutura global
    movq %rcx, cpu_features_ecx
    movq %rdx, cpu_features_edx

    # CPUID nível 7 — extensões
    movq $7, %rax
    xorq %rcx, %rcx
    cpuid

    # EBX bits:
    # bit 5: AVX2
    # bit 16: AVX-512F

    movq %rbx, cpu_features_ebx_7

    popq %rdx
    popq %rcx
    popq %rbx
    ret
```

## Implementação BRXH: Info do Sistema

```asm
# src/internal/hardware/brxh_api.s
# Obtém informações do sistema operacional

brxh_sysinfo:
    # Usar uname syscall para obter info do kernel
    movq $SYS_uname, %rax       # 63
    leaq utsname_buffer, %rdi
    syscall

    # utsname_buffer contém:
    # sysname: "Linux"
    # nodename: hostname
    # release: versão do kernel
    # version: data de compilação
    # machine: "x86_64"

    ret
```

## Resumo

| Conceito do Kernel | Aplicação BRXH |
|-------------------|----------------|
| Modo Real → Protegido → Longo | Não replicado — BRX roda em userspace |
| GDT | Não manipulado — kernel já configurou |
| Paginação (CR3) | Usado indiretamente via `mmap` |
| Syscalls (entry_64) | Usado via instrução `syscall` |
| CPUID | Implementado em `registers.s` |
