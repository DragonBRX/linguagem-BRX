# Compatibilidade — Syscalls 32-bit em 64-bit

## Conceito

Processadores x86-64 suportam executar programas de 32-bit (i386)
dentro de um sistema 64-bit. Isso requer:

1. Modo de compatibilidade (CS.L=0, CS.D=1)
2. Tabelas de syscall separadas (ia32_sys_call_table)
3. Entry point compatível (entry_SYSCALL_compat)

## Como Funciona

```
Programa 32-bit executa "int 0x80"
  → IDT[0x80] → entry_SYSCALL_compat
  → Kernel traduz argumentos 32-bit → 64-bit
  → Chama handler 64-bit
  → Traduz retorno 64-bit → 32-bit
  → Retorna via sysret (modo compatibilidade)
```

## Tabela de Syscalls 32-bit

| Número 32-bit | Nome | Número 64-bit |
|---------------|------|---------------|
| 1 | sys_exit | 60 |
| 3 | sys_read | 0 |
| 4 | sys_write | 1 |
| 5 | sys_open | 2 |
| ... | ... | ... |

## BRXH: Relevância

A BRXH **não usa** modo compatibilidade — é puramente 64-bit.
Mas entender isso é útil para:

1. **BRXT (Translate)** — traduzir executáveis 32-bit
2. **Debug** — entender processos 32-bit no sistema
3. **Segurança** — compat mode pode ter vulnerabilidades diferentes

### Detectar se processo é 32-bit

```asm
# Ler /proc/self/auxv ou /proc/self/exe
# Verificar ELF class (32-bit vs 64-bit)
```
