# Manuais AMD

## AMD64 Architecture Programmer's Manual

### Volumes

| Volume | Título |
|--------|--------|
| 1 | Application Programming |
| 2 | System Programming |
| 3 | General-Purpose and System Instructions |
| 4 | 128-Bit and 256-Bit Media Instructions |
| 5 | 64-Bit Media and x87 Floating-Point Instructions |

## Downloads

- https://developer.amd.com/resources/developer-guides-manuals/

## Seções Relevantes para BRXH

### Volume 2: System Programming

- Capítulo 1: System-Programming Overview
- Capítulo 2: x86-64 Long Mode
- Capítulo 3: Segmented Virtual Memory
- Capítulo 4: Paged Virtual Memory
- Capítulo 5: Page Translation and Protection
- Capítulo 6: System Management Instructions
- Capítulo 7: Interrupts and Exceptions
- Capítulo 8: Task Management
- Capítulo 15: Secure Virtual Machine

## AMD64 vs Intel 64

| Aspecto | AMD64 | Intel 64 (EM64T) |
|---------|-------|------------------|
| Origem | AMD (2003) | Intel (2004) |
| Modo longo | Sim | Sim |
| Paginação | 4-level | 4-level (5-level futuro) |
| Syscalls | `syscall`/`sysret` | `syscall`/`sysret` |
| MSRs | Similares | Similares |
| 3DNow! | Removido | Nunca teve |

> Para a BRXH, as diferenças são mínimas. O código funciona em ambos.

## Recursos Adicionais AMD

- AMD Developer Central: https://developer.amd.com/
- AMD Optimizing C/C++ Compiler: https://developer.amd.com/amd-aocc/
