# Hardware — BRXH (Acesso ao Metal)

## Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `brxh_api.s` | API de hardware abstrata | ✅ |
| `registers.s` | Acesso a registradores x86-64 | ✅ |
| `ports.s` | Portas I/O (in/out) | ❌ (requer root) |
| `mmap.s` | Memory mapping direto | ✅ |
| `inline_asm.s` | Assembly inline no .brx | ⚠️ (básico) |

## Comandos BRXH Expostos

```
hw
  mem alloc 1024 -> buf    # brk/mmap
  mem free buf             # munmap
  reg set r0 1             # mov r12, 1
  reg get r0 -> val          # mov val, r12
end
```

## Syscalls Diretas

```asm
# Exemplo: read de arquivo
movq $SYS_read, %rax
movq fd, %rdi
leaq buffer, %rsi
movq count, %rdx
syscall                    # sem libc!
```

## Registradores Disponíveis

```
r0  → r12 (preservado entre chamadas)
r1  → r13
r2  → r14
r3  → r15
r4  → rbx
r5  → rbp (cuidado — frame pointer)
```

> ⚠️ `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8-r11` são voláteis e usados internamente.
