---
Task ID: 1
Agent: Super Z (main)
Task: Implementar 6 melhorias no ecossistema BRX v0.7

Work Log:
- Corrigiu macro SYSCALL em brx_defs.s (colisao case-insensitive com instrucao syscall)
- Gerou fonte bitmap 8x8 completa (141 glifos: ASCII 0x20-0x7E + 46 acentuados do portugues)
- Implementou decodificacao UTF-8 em brxv_font.s (sequencias 0xC3 0xXX)
- Criou brxv_colors.s com 80+ cores nomeadas (PT+EN): cinza, marrom, roxo, laranja, rosa, verde/azul variados, dourado, etc.
- Implementou color_resolve com parser de hex (#RRGGBB) e busca por nome na tabela
- Escreveu brxv_buffer.s com fb_open/fb_close/fb_clear/fb_put_pixel/fb_get_pixel
- Implementou fb_clear com rep stosl para preenchimento rapido em 32bpp
- Escreveu brxv_draw.s com fb_draw_rect (rep stosl otimizado), fb_draw_line (Bresenham), fb_draw_circle (midpoint)
- Corrigiu BUG #1: addq fb_pitch(%rip) lia 8 bytes de variavel de 4 bytes
- Corrigiu BUG #2: fb_put_pixel corrompia caller-saved regs em fb_draw_line
- Corrigiu BUG #3: mesmo problema em fb_draw_circle
- Implementou rnd (xorshift32 com seed RDTSC) — distribuicao 0.4986 vs 0.5000 esperado
- Implementou bsin/bcos por tabela de lookup (91 entradas, erro max 2e-6)
- Gerou bitmap_8x8.bin (1200 bytes) para assets
- Validou todos os arquivos com as (GNU assembler), zero erros
- Testou bsin/bcos com 13 angulos (incluindo negativos e >360), todos OK
- Testou rnd com 10000 amostras, distribuicao uniforme confirmada

Stage Summary:
- 5 arquivos .s criados/ modificados, 1 arquivo novo (brxv_colors.s)
- 3 bugs reais encontrados e corrigidos
- Todos montam sem erros com as --64
- bsin/bcos: erro maximo 0.000002 (essencialmente exato para 1 grau de resolucao)
- rnd: distribuicao uniforme (0.4986)
