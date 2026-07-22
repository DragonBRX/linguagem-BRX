# Manuais Intel

## Intel 64 and IA-32 Architectures Software Developer's Manual

### Volumes

| Volume | Título | Conteúdo Relevante |
|--------|--------|-------------------|
| 1 | Basic Architecture | Modos de operação, registradores, memória |
| 2 | Instruction Set Reference | Todas as instruções x86-64 |
| 3 | System Programming Guide | Paginação, proteção, syscalls, MSRs |
| 4 | Model-Specific Registers | MSRs específicos por processador |

## Downloads

- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

## Seções Relevantes para BRXH

### Volume 1

- Capítulo 3: Basic Execution Environment
- Capítulo 3.4: Segment Registers
- Capítulo 3.6: Operand-Size and Address-Size Attributes

### Volume 2

- SYSCALL — Fast System Call
- SYSRET — Return From Fast System Call
- CPUID — CPU Identification
- RDTSC — Read Time-Stamp Counter
- INVLPG — Invalidate TLB Entries
- SWAPGS — Swap GS Base Register

### Volume 3

- Capítulo 2: System Architecture Overview
- Capítulo 3: Protected-Mode Memory Management
- Capítulo 4: Paging
- Capítulo 5: Protection
- Capítulo 6: Interrupt and Exception Handling
- Capítulo 7: Task Management
- Capítulo 25: VMX Non-Root Operation

### Volume 3, Part 3

- Capítulo 28: Introduction to VMX Operation
- Capítulo 29: VMX Instructions

## Tabelas Importantes

### Tabela 2-1: IA-32e Mode Execution Environment

| Modo | Tamanho de Operando | Tamanho de Endereço |
|------|---------------------|---------------------|
| 64-bit | 32-bit (padrão), 64-bit (REX.W) | 64-bit |
| Compatibility | 16, 32-bit | 32-bit |

### Tabela 4-1: Paging Structures

| Estrutura | Entradas | Tamanho | Aponta para |
|-----------|----------|---------|-------------|
| PML4 | 512 | 8 bytes | PDPT |
| PDPT | 512 | 8 bytes | PD |
| PD | 512 | 8 bytes | PT ou página 2MB |
| PT | 512 | 8 bytes | Página 4KB |
