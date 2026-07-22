# Estudo de Hardware — Referências do Kernel Linux

> **⚠️ Aviso de Licença**
> 
> O material nesta pasta é baseado no estudo do código-fonte do **Kernel Linux**, 
> licenciado sob **GPL v2**. Este material serve **exclusivamente para estudo e 
> referência conceitual**.
> 
> **NENHUM trecho de código GPL é copiado diretamente** para o projeto BRX.
> Toda a implementação BRXH é escrita do zero em Assembly x86-64 próprio,
> traduzindo apenas os **conceitos e algoritmos** observados no kernel.
> 
> A licença do projeto BRX é diferente da GPL. Reuso de código GPL
> exigiria que todo o BRX fosse GPL — o que não é o caso.

---

## Metodologia de Estudo

```
┌─────────────────────────────────────────────────────────────┐
│  1. LER código do kernel Linux (GPL) — entender o conceito   │
│  2. ANALISAR o algoritmo — como ele funciona internamente    │
│  3. FECHAR o código GPL — não olhar mais                     │
│  4. ESCREVER do zero em BRX — implementação própria          │
│  5. COMPARAR comportamento — mesma saída, código diferente   │
└─────────────────────────────────────────────────────────────┘
```

## Áreas de Estudo

| Pasta | Kernel Linux | Aplicação BRXH |
|-------|-------------|----------------|
| `01_boot_sequence/` | `arch/x86/boot/` | Inicialização do processador |
| `02_kernel_core/` | `arch/x86/kernel/` | Interrupções, syscalls, registradores |
| `03_memory_mgmt/` | `arch/x86/mm/` | Paginação, mmap, gerenciamento de memória |
| `04_entry_points/` | `arch/x86/entry/` | Pontos de entrada de syscalls |

## Analogia: Como a BRXV já fez

A BRXV não copiou código do Xorg ou Wayland. Em vez disso:

1. **Estudou** como o X11/Wayland funcionam (protocolos, buffers)
2. **Entendeu** que o Linux expõe `/dev/fb0` para acesso direto
3. **Implementou** do zero: abre `/dev/fb0`, mapeia com `mmap`, pinta pixels

A BRXH fará o mesmo com o kernel:

1. **Estudar** como o kernel gerencia memória, interrupções, syscalls
2. **Entender** os mecanismos (paging, IDT, syscall entry)
3. **Implementar** do zero em `src/internal/hardware/`

## Referências Externas

- [Intel 64 and IA-32 Architectures Software Developer's Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [AMD64 Architecture Programmer's Manual](https://developer.amd.com/resources/developer-guides-manuals/)
- [OSDev Wiki](https://wiki.osdev.org/)
- [Linux Kernel Source](https://git.kernel.org/)
