# Translate — BRXT (Compatibilidade Cross-Platform)

## Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `brxt_api.s` | API de tradução | ❌ |
| `syscall_mapper.s` | Mapeamento de syscalls Windows ↔ Linux | ❌ |
| `pe_loader.s` | Loader de executáveis PE | ❌ |
| `wine_compat.s` | Compatibilidade estilo Wine | ❌ |

## Visão

Executar programas compilados para outros sistemas operacionais dentro do BRX.

```
tr
  src "programa_windows.exe"
  map syscall
end
```

## Mapeamento de Syscalls

| Windows (PE) | Linux (ELF) | Descrição |
|--------------|-------------|-----------|
| NtCreateFile | sys_open    | Abrir arquivo |
| NtReadFile   | sys_read    | Ler arquivo |
| NtWriteFile  | sys_write   | Escrever arquivo |
| NtAllocateVirtualMemory | sys_mmap | Alocar memória |

## Arquitetura

```
programa_windows.exe
  → PE Loader (pe_loader.s)
  → Análise de imports/exports
  → Mapeamento de syscalls (syscall_mapper.s)
  → Emulação de APIs do Windows
  → Execução nativa no Linux via BRX runtime
```

> Esta é a camada mais complexa do ecossistema. Especificação em desenvolvimento.
