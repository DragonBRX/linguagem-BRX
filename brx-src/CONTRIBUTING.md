# Contribuindo com BRX

## Filosofia

BRX é sobre **domínio total**. Todo código contribuído deve seguir:

1. **Zero dependências externas** — se precisa de algo, implementamos
2. **Assembly puro** — nada de C, C++, Python, etc.
3. **Modularidade** — um arquivo por responsabilidade
4. **Documentação** — todo módulo tem README explicando o que faz

## Estrutura de Módulos

Cada camada é um conjunto de arquivos `.s` independentes:

```
src/internal/<camada>/
  ├── <camada>_api.s      # Interface pública
  ├── <modulo1>.s         # Implementação específica
  ├── <modulo2>.s
  └── README.md           # Documentação da camada
```

## Como Contribuir

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nome-da-feature`
3. Implemente em assembly x86-64
4. Adicione testes em `tests/`
5. Atualize a documentação
6. Envie PR

## Convenções de Código

- Comentários em português
- Labels em snake_case
- Registradores: `rax` para retorno, `rdi, rsi, rdx` para argumentos
- Syscalls via `syscall` instruction (não libc)

## Áreas que Precisam de Ajuda

- [ ] Backend Windows (GDI+)
- [ ] Backend macOS (CoreGraphics)
- [ ] Suporte a mouse (evdev)
- [ ] Detecção dinâmica de teclado
- [ ] Double buffering
- [ ] Garbage collector
- [ ] Compilador PE (Windows)
- [ ] Compilador Mach-O (macOS)
