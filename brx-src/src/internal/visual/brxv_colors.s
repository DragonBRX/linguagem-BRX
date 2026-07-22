# ============================================================
# BRX — Tabela de Cores Nomeadas
# ============================================================
# Tabela que mapeia nomes de cores (strings) para valores RGB
# 0xAABBGGRR em 32bpp (little-endian: armazenado como RR GG BB AA).
# O parser procura na tabela e retorna o valor de 32 bits.
#
# Formato de cada entrada:
#   .asciz "nome"     (nome null-terminated)
#   .long  0xAABBGGRR  (valor 32-bit do pixel)
# ============================================================

    .section .rodata

    .align 4
color_table:
    # ---- Cores basicas (existentes na v0.6) ----
    .asciz "preto"
    .long   0xFF000000
    .asciz "black"
    .long   0xFF000000

    .asciz "branco"
    .long   0xFFFFFFFF
    .asciz "white"
    .long   0xFFFFFFFF

    .asciz "vermelho"
    .long   0xFF0000FF
    .asciz "red"
    .long   0xFF0000FF

    .asciz "verde"
    .long   0xFF00FF00
    .asciz "green"
    .long   0xFF00FF00

    .asciz "azul"
    .long   0xFFFF0000
    .asciz "blue"
    .long   0xFFFF0000

    .asciz "amarelo"
    .long   0xFF00FFFF
    .asciz "yellow"
    .long   0xFF00FFFF

    .asciz "ciano"
    .long   0xFFFFFF00
    .asciz "cyan"
    .long   0xFFFFFF00

    .asciz "magenta"
    .long   0xFFFF00FF

    # ---- Novas cores (v0.7) ----

    # Cinzas
    .asciz "cinza"
    .long   0xFF808080
    .asciz "gray"
    .long   0xFF808080
    .asciz "grey"
    .long   0xFF808080
    .asciz "cinza_claro"
    .long   0xFFC0C0C0
    .asciz "light_gray"
    .long   0xFFC0C0C0
    .asciz "light_grey"
    .long   0xFFC0C0C0
    .asciz "cinza_escuro"
    .long   0xFF404040
    .asciz "dark_gray"
    .long   0xFF404040
    .asciz "dark_grey"
    .long   0xFF404040
    .asciz "prata"
    .long   0xFFC0C0C0
    .asciz "silver"
    .long   0xFFC0C0C0

    # Marrons / Terra
    .asciz "marrom"
    .long   0xFF802000
    .asciz "brown"
    .long   0xFF802000
    .asciz "marrom_escuro"
    .long   0xFF3C1408
    .asciz "dark_brown"
    .long   0xFF3C1408
    .asciz "chocolate"
    .long   0xFFD2691E
    .asciz "siena"
    .long   0xFFA0522D
    .asciz "sienna"
    .long   0xFFA0522D
    .asciz "castanho"
    .long   0xFF8B4513
    .asciz "saddle_brown"
    .long   0xFF8B4513
    .asciz "peru"
    .long   0xFFCD853F
    .asciz "areia"
    .long   0xFFF4A460
    .asciz "sandy_brown"
    .long   0xFFF4A460
    .asciz "caramelo"
    .long   0xFFDAA520
    .asciz "goldenrod"
    .long   0xFFDAA520

    # Roxos / Violetas
    .asciz "roxo"
    .long   0xFF800080
    .asciz "purple"
    .long   0xFF800080
    .asciz "roxo_claro"
    .long   0xFF9370DB
    .asciz "medium_purple"
    .long   0xFF9370DB
    .asciz "roxo_escuro"
    .long   0xFF480082
    .asciz "dark_purple"
    .long   0xFF480082
    .asciz "violeta"
    .long   0xFFEE82EE
    .asciz "violet"
    .long   0xFFEE82EE
    .asciz "indigo"
    .long   0xFF4B0082
    .asciz "lavanda"
    .long   0xFFE6E6FA
    .asciz "lavender"
    .long   0xFFE6E6FA
    .asciz "orchid"
    .long   0xFFDA70D6

    # Laranjas
    .asciz "laranja"
    .long   0xFF00A5FF
    .asciz "orange"
    .long   0xFF00A5FF
    .asciz "laranja_escuro"
    .long   0xFF006030
    .asciz "dark_orange"
    .long   0xFF006030
    .asciz "coral"
    .long   0xFFFF7F50
    .asciz "salmao"
    .long   0xFFFA8072
    .asciz "salmon"
    .long   0xFFFA8072
    .asciz "tomate"
    .long   0xFFFF6347
    .asciz "tomato"
    .long   0xFFFF6347
    .asciz "tangerina"
    .long   0xFFFF9966
    .asciz "tangerine"
    .long   0xFFFF9966

    # Rosas / Pinks
    .asciz "rosa"
    .long   0xFFFFC0CB
    .asciz "pink"
    .long   0xFFFFC0CB
    .asciz "rosa_escuro"
    .long   0xFFFF1493
    .asciz "hot_pink"
    .long   0xFFFF1493
    .asciz "rosa_claro"
    .long   0xFFFFB6C1
    .asciz "light_pink"
    .long   0xFFFFB6C1
    .asciz "fuchsia"
    .long   0xFFFF00FF
    .asciz "deep_pink"
    .long   0xFFFF1493

    # Verdes variados
    .asciz "verde_claro"
    .long   0xFF90EE90
    .asciz "light_green"
    .long   0xFF90EE90
    .asciz "verde_escuro"
    .long   0xFF006400
    .asciz "dark_green"
    .long   0xFF006400
    .asciz "verde_lima"
    .long   0xFF32CD32
    .asciz "lime_green"
    .long   0xFF32CD32
    .asciz "lima"
    .long   0xFF00FF00
    .asciz "lime"
    .long   0xFF00FF00
    .asciz "oliva"
    .long   0xFF808000
    .asciz "olive"
    .long   0xFF808000
    .asciz "verde_agua"
    .long   0xFF40E0D0
    .asciz "turquoise"
    .long   0xFF40E0D0
    .asciz "verde_menta"
    .long   0xFF3EB489
    .asciz "mint"
    .long   0xFF3EB489
    .asciz "esmeralda"
    .long   0xFF50C878
    .asciz "emerald"
    .long   0xFF50C878
    .asciz "floresta"
    .long   0xFF228B22
    .asciz "forest_green"
    .long   0xFF228B22

    # Azuis variados
    .asciz "azul_claro"
    .long   0xFFADD8E6
    .asciz "light_blue"
    .long   0xFFADD8E6
    .asciz "azul_escuro"
    .long   0xFF00008B
    .asciz "dark_blue"
    .long   0xFF00008B
    .asciz "azul_marinho"
    .long   0xFF000080
    .asciz "navy"
    .long   0xFF000080
    .asciz "azul_royal"
    .long   0xFF4169E1
    .asciz "royal_blue"
    .long   0xFF4169E1
    .asciz "azul_ceu"
    .long   0xFF87CEEB
    .asciz "sky_blue"
    .long   0xFF87CEEB
    .asciz "aço"
    .long   0xFF4682B4
    .asciz "steel_blue"
    .long   0xFF4682B4
    .asciz "azul_teal"
    .long   0xFF008080
    .asciz "teal"
    .long   0xFF008080
    .asciz "azul_bebe"
    .long   0xFF89CFF0
    .asciz "baby_blue"
    .long   0xFF89CFF0
    .asciz "midnight_blue"
    .long   0xFF191970
    .asciz "azul_meia_noite"
    .long   0xFF191970
    .asciz "cerulean"
    .long   0xFF007BA7

    # Vermelhos variados
    .asciz "vermelho_escuro"
    .long   0xFF8B0000
    .asciz "dark_red"
    .long   0xFF8B0000
    .asciz "vermelho_claro"
    .long   0xFFFF6A6A
    .asciz "light_red"
    .long   0xFFFF6A6A
    .asciz "carmesim"
    .long   0xFFDC143C
    .asciz "crimson"
    .long   0xFFDC143C
    .asciz "borgonha"
    .long   0xFF800020
    .asciz "burgundy"
    .long   0xFF800020
    .asciz "scarlet"
    .long   0xFFFF2400
    .asciz "escarlate"
    .long   0xFFFF2400

    # Diversos
    .asciz "dourado"
    .long   0xFFFFD700
    .asciz "gold"
    .long   0xFFFFD700
    .asciz "bronze"
    .long   0xFFCD7F32
    .asciz "marfim"
    .long   0xFFFFFFF0
    .asciz "ivory"
    .long   0xFFFFFFF0
    .asciz "bege"
    .long   0xFFF5F5DC
    .asciz "beige"
    .long   0xFFF5F5DC
    .asciz "creme"
    .long   0xFFFFFDD0
    .asciz "cream"
    .long   0xFFFFFDD0
    .asciz "pessego"
    .long   0xFFFFDAB9
    .asciz "peach"
    .long   0xFFFFDAB9
    .asciz "amêndoa"
    .long   0xFFFFEBCD
    .asciz "almond"
    .long   0xFFFFEBCD
    .asciz "lilas"
    .long   0xFFC8A2C8
    .asciz "lilac"
    .long   0xFFC8A2C8
    .asciz "cereja"
    .long   0xFFDE3163
    .asciz "cherry"
    .long   0xFFDE3163
    .asciz "turquesa_escuro"
    .long   0xFF00CED1
    .asciz "dark_turquoise"
    .long   0xFF00CED1

    # Marcador de fim da tabela (nome vazio, valor = 0)
    .align 4
color_table_end:
    .asciz ""
    .long   0x00000000

    .equ COLOR_NOT_FOUND, 0

# ============================================================
# color_resolve
# ============================================================
# Resolve uma string de cor para valor 32-bit.
#
# Entrada:
#   %rdi = ponteiro para string (pode ser nome ou "#RRGGBB")
#
# Saida:
#   %eax = cor 32-bit (0xAABBGGRR)
#         COLOR_NOT_FOUND (0) se invalido
#
# Preserva: %rbx, %rbp, %r12-%r15
# Destrói: %rax, %rcx, %rdx, %rsi, %r8-%r11
# ============================================================
    .text
    .globl color_resolve

color_resolve:
    # Verifica se comeca com '#' (hex literal)
    cmpb $'#', (%rdi)
    jne .Lcolor_lookup_name

    # --- Parse "#RRGGBB" ---
    # Espera formato exato: # + 6 hex digits
    movzbl 1(%rdi), %eax
    call .Lhex_digit
    shlq $4, %rax
    movzbl 2(%rdi), %ecx
    call .Lhex_digit
    orq  %rax, %rcx
    movq %rcx, %r8            # r8 = RR

    movzbl 3(%rdi), %eax
    call .Lhex_digit
    shlq $4, %rax
    movzbl 4(%rdi), %ecx
    call .Lhex_digit
    orq  %rax, %rcx
    movq %rcx, %r9            # r9 = GG

    movzbl 5(%rdi), %eax
    call .Lhex_digit
    shlq $4, %rax
    movzbl 6(%rdi), %ecx
    call .Lhex_digit
    orq  %rax, %rcx
    # rcx = BB

    # Monta 0xFF_BB_GG_RR
    shlq $16, %r9
    orq  %r9, %r8             # r8 = 0x00_GG_RR
    shlq $24, %rcx
    orq  0x00FF0000, %rcx     # rcx = 0xFF_BB_00_00
    orq  %rcx, %r8            # r8 = 0xFF_BB_GG_RR
    movq %r8, %rax
    retq

.Lcolor_lookup_name:
    # Percorre a tabela de cores comparando nomes
    leaq color_table, %rsi
.Lcolor_loop:
    # Fim da tabela?
    cmpq $color_table_end, %rsi
       jae .Lcolor_not_found

    # Compara strings
    movq %rdi, %rdx
.Lcolor_cmp:
    movzbl (%rdx), %eax
    movzbl (%rsi), %ecx
    cmpb %cl, %al
    jne .Lcolor_next_entry
    testb %al, %al
    jz   .Lcolor_match        # ambos terminaram = match
    incq %rdx
    incq %rsi
    jmp  .Lcolor_cmp

.Lcolor_next_entry:
    # Avanca ate o proximo null-terminator do nome
.Lcolor_skip_name:
    cmpb $0, (%rsi)
    je   .Lcolor_skip_val
    incq %rsi
    jmp  .Lcolor_skip_name

.Lcolor_skip_val:
    # Pula o null + 4 bytes do valor de cor
    addq $5, %rsi
    jmp  .Lcolor_loop

.Lcolor_match:
    # Ja passamos do null-terminator, aponta para o .long
    # Volta 1 byte para alinhar com o .long
    # Na verdade rsi aponta para o byte 0 do nome que casou.
    # Precisamos pular ate o .long apos o nome.
    # rsi esta no null terminator. Avanca 1 (pula null) para o .long
    incq %rsi
    # Agora rsi aponta para o inicio do .long
    movl (%rsi), %eax
    retq

.Lcolor_not_found:
    xorl %eax, %eax
    retq

# ============================================================
# .Lhex_digit (interno)
# ============================================================
# Converte um caractere hex para valor 0-15.
# Entrada: %al = caractere
# Saida:  %rax = valor 0-15 (ou 0 se invalido)
# Destrói: %rax
# ============================================================
.Lhex_digit:
    cmpb $'0', %al
    jb   .Lhd_invalid
    cmpb $'9', %al
    jbe  .Lhd_digit
    cmpb $'a', %al
    jb   .Lhd_check_upper
    cmpb $'f', %al
    jbe  .Lhd_lower
    cmpb $'A', %al
    jb   .Lhd_invalid
    cmpb $'F', %al
    ja   .Lhd_invalid
    # Upper case A-F
    subb $'A' - 10, %al
    movzbl %al, %eax
    retq
.Lhd_lower:
    subb $'a' - 10, %al
    movzbl %al, %eax
    retq
.Lhd_digit:
    subb $'0', %al
    movzbl %al, %eax
    retq
.Lhd_check_upper:
    cmpb $'A', %al
    jb   .Lhd_invalid
    cmpb $'F', %al
    ja   .Lhd_invalid
    subb $'A' - 10, %al
    movzbl %al, %eax
    retq
.Lhd_invalid:
    xorl %eax, %eax
    retq
