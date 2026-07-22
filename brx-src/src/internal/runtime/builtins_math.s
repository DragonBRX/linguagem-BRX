# ============================================================
# BRX — Builtins Matematicos Adicionais
# ============================================================
# rnd:  gerador de numeros pseudo-aleatorios via RDTSC + xorshift
# bsin: seno por tabela de lookup com interpolacao linear (Q16)
# bcos: cosseno por tabela de lookup com interpolacao linear (Q16)
#
# Ponto fixo Q16:
#   Valor 1.0 = 65536.  Fração 0.5 = 32768.
#   Retorno em Q16: [-65536, +65536] = [-1.0, +1.0]
# ============================================================

    .section .rodata

    # Tabela sin para 0..90 graus (91 entradas, Q16)
    # sin_table[i] = round(sin(i * pi/180) * 65536)
    # Gerada programaticamente, sem dependencias externas no projeto.
    .align 4
sin_table:
        .long   0
        .long   1144
        .long   2287
        .long   3430
        .long   4572
        .long   5712
        .long   6850
        .long   7987
        .long   9121
        .long   10252
        .long   11380
        .long   12505
        .long   13626
        .long   14742
        .long   15855
        .long   16962
        .long   18064
        .long   19161
        .long   20252
        .long   21336
        .long   22415
        .long   23486
        .long   24550
        .long   25607
        .long   26656
        .long   27697
        .long   28729
        .long   29753
        .long   30767
        .long   31772
        .long   32768
        .long   33754
        .long   34729
        .long   35693
        .long   36647
        .long   37590
        .long   38521
        .long   39441
        .long   40348
        .long   41243
        .long   42126
        .long   42995
        .long   43852
        .long   44695
        .long   45525
        .long   46341
        .long   47143
        .long   47930
        .long   48703
        .long   49461
        .long   50203
        .long   50931
        .long   51643
        .long   52339
        .long   53020
        .long   53684
        .long   54332
        .long   54963
        .long   55578
        .long   56175
        .long   56756
        .long   57319
        .long   57865
        .long   58393
        .long   58903
        .long   59396
        .long   59870
        .long   60326
        .long   60764
        .long   61183
        .long   61584
        .long   61966
        .long   62328
        .long   62672
        .long   62997
        .long   63303
        .long   63589
        .long   63856
        .long   64104
        .long   64332
        .long   64540
        .long   64729
        .long   64898
        .long   65048
        .long   65177
        .long   65287
        .long   65376
        .long   65446
        .long   65496
        .long   65526
        .long   65536

    .section .bss
    .align 4
rnd_state:       .skip 4
rnd_initialized:  .skip 4

    .text
    .globl rnd
    .globl rnd_seed
    .globl bsin
    .globl bcos

# ============================================================
# rnd — Gerador pseudo-aleatorio (xorshift32)
# ============================================================
# Primeira chamada: semeia com RDTSC.
# Saida: %eax = valor 32 bits aleatorio
# ============================================================
rnd:
    cmpl $0, rnd_initialized(%rip)
    jne  .Lrnd_xorshift

    rdtsc
    xorl %edx, %eax
    orl  $1, %eax
    movl %eax, rnd_state(%rip)
    movl $1, rnd_initialized(%rip)

.Lrnd_xorshift:
    movl rnd_state(%rip), %eax
    movl %eax, %ecx
    shll $13, %ecx
    xorl %ecx, %eax
    movl %eax, %ecx
    shrl $17, %ecx
    xorl %ecx, %eax
    movl %eax, %ecx
    shll $5, %ecx
    xorl %ecx, %eax
    movl %eax, rnd_state(%rip)
    retq

# ============================================================
# rnd_seed — Semeia o gerador
# ============================================================
# Entrada: %edi = semente
# ============================================================
rnd_seed:
    movl %edi, rnd_state(%rip)
    orl  $1, rnd_state(%rip)
    movl $1, rnd_initialized(%rip)
    retq

# ============================================================
# bsin — Seno por tabela + interpolacao (Q16)
# ============================================================
# Entrada: %edi = angulo em graus (inteiro, qualquer valor)
# Saida:  %eax = sin(angulo) em Q16 [-65536, +65536]
# Precisao: < 0.001 (interpolação linear entre entradas de 1 grau)
# ============================================================
bsin:
    pushq %rbx

    # Normalizar para [0, 360)
    movl %edi, %eax
.Lbsin_neg:
    cmpl $0, %eax
    jge  .Lbsin_mod
    addl $360, %eax
    jmp  .Lbsin_neg
.Lbsin_mod:
    cmpl $360, %eax
    jl   .Lbsin_norm_done
    subl $360, %eax
    jmp  .Lbsin_mod
.Lbsin_norm_done:

    # Determinar quadrante e mapear para [0, 90]
    # Q0: [0, 90)     -> table[ang]
    # Q1: [90, 180)   -> table[180 - ang]
    # Q2: [180, 270)  -> -table[ang - 180]
    # Q3: [270, 360)  -> -table[360 - ang]

    cmpl $90, %eax
    jl   .Lbsin_q0
    cmpl $180, %eax
    jl   .Lbsin_q1
    cmpl $270, %eax
    jl   .Lbsin_q2

    # Q3: ang em [270, 360)
    negl %eax
    addl $360, %eax             # eax = 360 - ang, em (0, 90]
    call .Lsin_table_lookup
    negl %eax
    popq %rbx
    retq

.Lbsin_q2:
    # Q2: ang em [180, 270)
    subl $180, %eax              # eax em [0, 90)
    call .Lsin_table_lookup
    negl %eax
    popq %rbx
    retq

.Lbsin_q1:
    # Q1: ang em [90, 180)
    negl %eax
    addl $180, %eax             # eax = 180 - ang, em (0, 90]
    call .Lsin_table_lookup
    popq %rbx
    retq

.Lbsin_q0:
    # Q0: ang em [0, 90)
    call .Lsin_table_lookup
    popq %rbx
    retq

# ============================================================
# bcos — Cosseno por tabela + interpolacao (Q16)
# ============================================================
# cos(x) = sin(x + 90)
# ============================================================
bcos:
    addl $90, %edi
    jmp  bsin

# ============================================================
# .Lsin_table_lookup (helper interno)
# ============================================================
# Busca sin(tabela) com interpolacao linear.
# Entrada: %eax = angulo inteiro em [0, 90]
# Saida:  %eax = sin em Q16
# Destrói: %rax, %rcx, %rdx, %rbx
# ============================================================
.Lsin_table_lookup:
    # Se eax == 90, retornar sin_table[90] diretamente
    cmpl $89, %eax
    jg   .Lstl_exact

    # ebx = eax (angulo inteiro, 0..89)
    movl %eax, %ebx

    # Carregar endereco da tabela
    leaq sin_table(%rip), %rax

    # eax = table[eax] (cada entrada e' 4 bytes)
    movl (%rax, %rbx, 4), %eax
    retq

.Lstl_exact:
    # angulo 90: retornar sin_table[90]
    leaq sin_table(%rip), %rax
    movl 360(%rax), %eax        # 90 * 4 = 360
    retq
