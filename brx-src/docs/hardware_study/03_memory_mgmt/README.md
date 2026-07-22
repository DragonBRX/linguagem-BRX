# Gerenciamento de Memória — arch/x86/mm/

## O que o kernel faz aqui

O código em `arch/x86/mm/` gerencia toda a memória do sistema:
paginação, mapeamento, caches, TLB, e proteção de memória.

## Arquivos principais do kernel

| Arquivo | Função |
|---------|--------|
| `init.c` | Inicialização do gerenciamento de memória |
| `pgtable.c` | Manipulação de tabelas de página |
| `pgtable_64.c` | Tabelas de página para 64-bit |
| `fault.c` | Tratamento de page faults |
| `mmap.c` | Implementação de mmap |
| `ioremap.c` | Mapeamento de memória de I/O |
| `pat.c` | Page Attribute Table |
| `kasan_init.c` | Kernel Address Sanitizer |

## Conceitos-chave para BRXH

### 1. Paginação

O x86-64 usa **paginação obrigatória** em modo longo.
Memória é dividida em páginas de 4KB (padrão), 2MB (huge), ou 1GB.

### 2. Tabelas de Página (4-Level)

```
CR3 → PML4 (512 entradas, 8 bytes cada = 4KB)
  → PDPT (512 entradas)
    → PD (512 entradas)
      → PT (512 entradas)
        → Página física (4KB)

Espaço virtual: 512 × 512 × 512 × 512 × 4KB = 256TB
```

### 3. mmap

`mmap` mapeia arquivo ou memória anônima no espaço virtual do processo.
O kernel atualiza as tabelas de página para apontar para as páginas físicas.

### 4. Page Fault

Quando o processador acessa um endereço virtual sem página mapeada:
1. Gera exceção #PF (vetor 14)
2. Kernel verifica se é válido (demand paging, copy-on-write)
3. Se válido: aloca página física, atualiza PT, retoma
4. Se inválido: envia SIGSEGV ao processo

## Notas de Implementação BRXH

Ver `notes_brxh.md` para tradução dos conceitos.
