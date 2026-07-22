# mmap — Implementação Interna

## Conceito

`mmap` mapeia arquivo ou memória anônima no espaço de endereços virtual do processo.
O kernel aloca páginas físicas sob demanda (demand paging).

## Syscall mmap

```c
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
```

| Parâmetro | Significado |
|-----------|-------------|
| `addr` | Endereço desejado (NULL = kernel escolhe) |
| `length` | Tamanho do mapeamento |
| `prot` | Proteção: PROT_READ, PROT_WRITE, PROT_EXEC |
| `flags` | MAP_SHARED, MAP_PRIVATE, MAP_ANONYMOUS, MAP_FIXED |
| `fd` | Descritor de arquivo (-1 para anônimo) |
| `offset` | Offset no arquivo |

## Flags Importantes

| Flag | Significado |
|------|-------------|
| `MAP_SHARED` | Alterações visíveis a outros processos |
| `MAP_PRIVATE` | Copy-on-write (COW) |
| `MAP_ANONYMOUS` | Sem arquivo — memória zerada |
| `MAP_FIXED` | Força endereço exato (cuidado!) |
| `MAP_POPULATE` | Pré-carrega páginas (evita page faults) |
| `MAP_HUGETLB` | Usa huge pages (2MB) |

## Como o kernel implementa mmap

```
1. Verifica parâmetros (addr alinhado, length > 0, etc.)
2. Aloca vm_area_struct (descritor da região virtual)
3. Se MAP_ANONYMOUS: marca como zero-fill on demand
4. Se arquivo: associa com inode, configura page cache
5. Insere na árvore de VMAs do processo
6. Retorna endereço virtual
7. (Lazy) Páginas físicas só alocadas no primeiro acesso (page fault)
```

## BRXH: Uso de mmap

### Framebuffer

```asm
# Mapear /dev/fb0 na memória

# 1. Abrir framebuffer
movq $SYS_open, %rax
leaq fb_path, %rdi          # "/dev/fb0"
movq $O_RDWR, %rsi
syscall
movq %rax, fb_fd

# 2. Obter informações (resolução, bpp)
movq $SYS_ioctl, %rax
movq fb_fd, %rdi
movq $FBIOGET_VSCREENINFO, %rsi
leaq fb_var, %rdx
syscall

# 3. Calcular tamanho
# size = xres_virtual * yres_virtual * bits_per_pixel / 8

# 4. Mapear
movq $SYS_mmap, %rax
xorq %rdi, %rdi             # addr = NULL (kernel escolhe)
movq fb_size, %rsi          # length
movq $(PROT_READ | PROT_WRITE), %rdx
movq $MAP_SHARED, %r10
movq fb_fd, %r8
xorq %r9, %r9               # offset = 0
syscall

# rax = ponteiro para framebuffer
movq %rax, fb_ptr
```

### Memória Anônima (Heap)

```asm
# Alocar memória anônima para uso interno

movq $SYS_mmap, %rax
xorq %rdi, %rdi
movq $1048576, %rsi         # 1MB
movq $(PROT_READ | PROT_WRITE), %rdx
movq $(MAP_PRIVATE | MAP_ANONYMOUS), %r10
movq $-1, %r8
xorq %r9, %r9
syscall

# rax = início da região alocada
```

### munmap

```asm
# Liberar mapeamento

movq $SYS_munmap, %rax
movq fb_ptr, %rdi
movq fb_size, %rsi
syscall
```

### mprotect

```asm
# Alterar proteção de região

movq $SYS_mprotect, %rax
movq region_ptr, %rdi
movq region_size, %rsi
movq $PROT_READ, %rdx       # Tornar somente leitura
syscall
```

## Dicas de Performance

1. **MAP_POPULATE** — evita page faults durante execução crítica
2. **MAP_HUGETLB** — reduz TLB pressure para grandes regiões
3. **madvise** — dá hints ao kernel sobre uso de memória
4. **mlock** — impede que páginas sejam swapadas
