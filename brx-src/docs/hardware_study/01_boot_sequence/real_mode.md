# Modo Real (16-bit)

## Conceito

Quando o processador x86 liga, ele começa em **modo real** (16-bit).
Este modo existe por compatibilidade com o 8086 original (1978).

## Características

| Aspecto | Modo Real |
|---------|-----------|
| Tamanho de registrador | 16-bit |
| Memória endereçável | 1 MB (0x00000 a 0xFFFFF) |
| Endereçamento | Segmento:Offset (real = segmento × 16 + offset) |
| Proteção de memória | Nenhuma |
| Multitarefa | Não |
| Interrupções | Via BIOS (INT 0x10, 0x13, etc.) |

## Exemplo de endereçamento

```
Segmento = 0x07C0
Offset   = 0x0000
Endereço real = 0x07C0 × 16 + 0x0000 = 0x7C00
```

Este é o endereço onde o BIOS carrega o bootloader.

## Por que a BRXH não usa

A BRXH roda em **userspace** dentro de um sistema Linux já bootado.
O kernel já fez toda a transição modo real → protegido → longo.

## Mas é útil entender porque...

- O **bootloader** (GRUB) ainda opera em modo real antes de carregar o kernel
- O **kernel** começa em modo real e faz a transição
- Entender isso ajuda a entender **por que** o modo longo funciona como funciona

## Transição para Modo Protegido

O kernel faz:

1. Desativa interrupções (`cli`)
2. Carrega GDT (`lgdt`)
3. Seta bit PE (Protection Enable) em CR0
4. Faz jump far para código de 32-bit
5. Reativa interrupções

## Referência BRXH

A BRXH pode ler os registradores de controle para **verificar** em qual modo está:

```asm
# Verificar se modo longo está ativo
movq %cr0, %rax
andq $0x80000001, %rax    # PG (paging) + PE (protection)
# Se resultado == 0x80000001, está em modo longo com paginação
```
