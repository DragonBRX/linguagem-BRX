# Sandbox — BRXS (Execução Isolada)

## Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `brxs_api.s` | API de sandbox | ⚠️ |
| `isolate.s` | Isolamento de processo | ❌ |
| `limits.s` | Limites de memória e tempo | ⚠️ |
| `loader.s` | Loader de plugins isolados | ⚠️ |

## Comandos BRXS Expostos

```
sbx
  lim mem 64          # limite de memória em MB
  lim time 5000       # limite de tempo em ms
  load "plugin.brx"   # carrega código isolado
end
```

## Isolamento Planejado

```
┌─────────────────────────────────────────┐
│  Processo Hospedeiro (BRX principal)    │
│  - Variáveis próprias                    │
│  - Acesso total ao sistema               │
├─────────────────────────────────────────┤
│  Processo Isolado (plugin.brx)           │
│  - Memória separada (lim mem)            │
│  - Tempo limitado (lim time)             │
│  - Sem acesso ao filesystem do host      │
│  - Comunicação via arquivos temp         │
└─────────────────────────────────────────┘
```

## Implementação Futura

- Linux: namespaces + seccomp-bpf + cgroups
- Sem fork/exec — isolamento via mmap protegido
