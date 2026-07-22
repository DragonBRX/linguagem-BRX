# Referências — Fontes do Kernel Linux

## Repositórios Oficiais

| Recurso | URL |
|---------|-----|
| Git principal | https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git |
| GitHub mirror | https://github.com/torvalds/linux |
| Linus Tree | https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/ |
| Stable tree | https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git |

## Arquivos Específicos Estudados

### Boot

```
arch/x86/boot/header.S          # Cabeçalho do kernel
arch/x86/boot/main.c            # Função main do boot
arch/x86/boot/pmjump.S          # Salto para modo protegido
arch/x86/boot/compressed/head_64.S  # Descompressão e modo longo
```

### Kernel Core

```
arch/x86/kernel/head_64.S       # Inicialização 64-bit
arch/x86/kernel/irq.c           # Gerenciamento de interrupções
arch/x86/kernel/idt.c             # IDT
arch/x86/kernel/process.c       # Processos
arch/x86/kernel/time.c            # Timer
arch/x86/kernel/apic.c            # APIC
```

### Memory Management

```
arch/x86/mm/init.c              # Inicialização de memória
arch/x86/mm/pgtable.c           # Tabelas de página
arch/x86/mm/pgtable_64.c        # Tabelas de página 64-bit
arch/x86/mm/fault.c             # Page faults
arch/x86/mm/mmap.c              # mmap
arch/x86/mm/ioremap.c           # I/O remap
```

### Entry Points

```
arch/x86/entry/entry_64.S       # Entry points 64-bit
arch/x86/entry/entry_SYSCALL_64.S # Syscall entry
arch/x86/entry/thunk_64.S       # Thunks
```

## Como Navegar o Código

```bash
# Clonar
 git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

# Buscar arquivo específico
find linux/arch/x86 -name "*.S" -o -name "*.c" | grep -i "entry"

# Buscar função específica
grep -r "entry_SYSCALL_64" linux/arch/x86/ --include="*.S"

# Ver histórico de um arquivo
cd linux && git log --oneline arch/x86/entry/entry_SYSCALL_64.S
```

## Documentação do Kernel

| Documento | Local |
|-----------|-------|
| x86 architecture | `Documentation/arch/x86/` |
| Memory management | `Documentation/mm/` |
| Kernel API | `Documentation/core-api/` |
| Device drivers | `Documentation/driver-api/` |
