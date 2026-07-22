# ============================================================
# BRX — Primitivas de Desenho
# ============================================================
# fb_draw_rect:   retangulo preenchido com rep stosl (32bpp)
# fb_draw_line:   algoritmo de Bresenham (todos os octantes)
# fb_draw_circle: algoritmo midpoint circle
#
# BUGS CORRIGIDOS:
#   1. Variaveis de 4 bytes (fb_pitch) lidas com addq (8 bytes),
#      incorporando lixo do campo adjacente.
#   2. fb_put_pixel destroi r8/r9 internamente, mas fb_draw_line
#      guardava estado do algoritmo nesses registradores.
#   3. Mesmo problema em fb_draw_circle.
#
# Estrategia de preservacao:
#   Cada funcao salva/restaura apenas os callee-saved que usa.
#   Em loops que chamam fb_put_pixel, salva os caller-saved
#   volateis na pilha antes do call e restaura depois.
# ============================================================

    .text
    .globl fb_draw_rect
    .globl fb_draw_line
    .globl fb_draw_circle

# ============================================================
# fb_draw_rect
# ============================================================
# Retangulo preenchido. Otimizado com rep stosl para 32bpp.
#
# Entrada:
#   %edi = x
#   %esi = y
#   %edx = largura (w)
#   %ecx = altura (h)
#   %r8d = cor 32-bit (0xAABBGGRR)
#
# Preserva: %rbx, %rbp, %r12-%r15
# Destrói: todos os demais
# ============================================================
fb_draw_rect:
    cmpl $0, fb_state(%rip)
    je   .Ldr_done

    pushq %rbx
    pushq %r12
    pushq %r13

    # r12d = cor, ebx = w, r13d = h
    movl %r8d, %r12d
    movl %edx, %ebx
    movl %ecx, %r13d

    # Se w ou h <= 0, sai
    testl %ebx, %ebx
    jle  .Ldr_pop
    testl %r13d, %r13d
    jle  .Ldr_pop

    # --- Clipping esquerda ---
    cmpl $0, %edi
    jge  .Ldr_cr
    addl %edi, %ebx
    xorl %edi, %edi
    testl %ebx, %ebx
    jle  .Ldr_pop
.Ldr_cr:
    # --- Clipping direita: w = min(w, fb_width - x) ---
    movl fb_width(%rip), %eax
    subl %edi, %eax
    cmpl %ebx, %eax
    jge  .Ldr_ct
    movl %eax, %ebx
.Ldr_ct:
    testl %ebx, %ebx
    jle  .Ldr_pop

    # --- Clipping topo ---
    cmpl $0, %esi
    jge  .Ldr_cb
    addl %esi, %r13d
    xorl %esi, %esi
    testl %r13d, %r13d
    jle  .Ldr_pop
.Ldr_cb:
    # --- Clipping base: h = min(h, fb_height - y) ---
    movl fb_height(%rip), %eax
    subl %esi, %eax
    cmpl %r13d, %eax
    jge  .Ldr_start
    movl %eax, %r13d
.Ldr_start:
    testl %r13d, %r13d
    jle  .Ldr_pop

    # Calcular endereco do pixel (x, y):
    #   offset = y * pitch + x * 4
    # BUG FIX #1: carregar pitch em 32-bit
    movq fb_base(%rip), %rax
    movl %esi, %ecx
    movl fb_pitch(%rip), %edx       # 32-bit load
    imull %edx, %ecx
    movslq %ecx, %rcx
    movslq %edi, %rdx
    shlq $2, %rdx
    addq %rdx, %rcx
    addq %rcx, %rax               # rax -> endereco do primeiro pixel

    # Loop de linhas:
    #   rdi  = ponteiro linha atual
    #   r12d = cor
    #   ebx  = w (dwords)
    #   r13d = contador de linhas
    movq %rax, %rdi

.Ldr_row:
    movl %r12d, %eax
    movl %ebx, %ecx
    cld
    rep stosl

    # Avancar para proxima linha
    # BUG FIX #1: 32-bit load
    movl fb_pitch(%rip), %eax
    movslq %eax, %rax
    addq %rax, %rdi

    decl %r13d
    jnz  .Ldr_row

.Ldr_pop:
    popq %r13
    popq %r12
    popq %rbx
.Ldr_done:
    retq


# ============================================================
# fb_draw_line (Bresenham completo — todos os octantes)
# ============================================================
# Algoritmo padrao do Wikipedia, adaptado para x86-64.
#
# Entrada:
#   %edi = x0
#   %esi = y0
#   %edx = x1
#   %ecx = y1
#   %r8d = cor 32-bit (0xAABBGGRR)
#
# Preserva: %rbx, %rbp, %r12-%r15
# ============================================================
fb_draw_line:
    cmpl $0, fb_state(%rip)
    je   .Ldl_done

    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    # Atribuicao de registradores (callee-saved ou pilha):
    #   rbx  = x0 (corrente)
    #   r12  = y0 (corrente)
    #   r13  = err (corrente)
    #   r14  = |dx|
    #   r15  = |dy|
    #   Pilha [rbp+16] = sx
    #   Pilha [rbp+24] = sy
    #   Pilha [rbp+32] = cor
    #   Pilha [rbp+40] = passos restantes

    # Calcular dx = x1 - x0
    movl %edx, %eax
    subl %edi, %eax               # eax = dx

    # Calcular dy = y1 - y0
    movl %ecx, %r13d
    subl %esi, %r13d              # r13d = dy

    # |dx|, |dy|
    movl %eax, %r14d              # r14d = dx
    movl %r13d, %r15d             # r15d = dy

    # Absoluto de r14d (|dx|)
    movl %r14d, %ecx
    negl %ecx
    cmovll %r14d, %ecx            # ecx = |dx|
    movl %ecx, %r14d              # r14 = |dx|

    # Absoluto de r15d (|dy|)
    movl %r15d, %ecx
    negl %ecx
    cmovll %r15d, %ecx            # ecx = |dy|
    movl %ecx, %r15d              # r15 = |dy|

    # sx = (dx >= 0) ? 1 : -1
    movl $1, %ecx
    movl $-1, %edx
    testl %eax, %eax
    cmovsl %edx, %ecx
    pushq %rcx                    # [sp] = sx

    # sy = (dy >= 0) ? 1 : -1
    movl $1, %ecx
    movl $-1, %edx
    movl %r13d, %eax              # reusar eax = dy original
    testl %eax, %eax
    cmovsl %edx, %ecx
    pushq %rcx                    # [sp] = sy

    # Cor
    pushq %r8                     # [sp] = cor

    # err = |dx| - |dy|
    movl %r14d, %r13d
    subl %r15d, %r13d

    # rbx = x0, r12 = y0
    movl %edi, %ebx
    movl %esi, %r12d

    # passos = max(|dx|, |dy|) + 1
    movl %r14d, %ecx
    cmpl %r15d, %ecx
    cmovl %r15d, %ecx
    addl $1, %ecx
    pushq %rcx                    # [sp] = passos

    # --- Loop principal ---
    # Estado salvo: rbx=x0, r12=y0, r13=err, r14=|dx|, r15=|dy|
    # Pilha: [0]=passos, [8]=cor, [16]=sy, [24]=sx
.Ldl_loop:
    # Desenhar pixel em (x0, y0) com cor
    # BUG FIX #2: fb_put_pixel destroi r8, r9, rcx.
    # Mas nossos dados vitais estao em rbx, r12, r13, r14, r15 (callee-saved).
    # Os dados na pilha tambem estao seguros.
    # Entao so precisamos carregar os argumentos corretamente.
    movl %ebx, %edi               # x
    movl %r12d, %esi              # y
    movl 8(%rsp), %edx            # cor
    call fb_put_pixel

    # Decrementar passos
    decl (%rsp)
    jz   .Ldl_cleanup

    # e2 = 2 * err
    movl %r13d, %eax
    shll $1, %eax

    # if e2 > -|dy|  =>  err -= |dy|, x0 += sx
    movl %r15d, %ecx
    negl %ecx
    cmpl %ecx, %eax
    jle  .Ldl_skip_x
    subl %r15d, %r13d             # err -= |dy|
    addl 24(%rsp), %ebx           # x0 += sx (pilha: [24]=sx)

.Ldl_skip_x:
    # if e2 < |dx|  =>  err += |dx|, y0 += sy
    cmpl %r14d, %eax
    jge  .Ldl_loop
    addl %r14d, %r13d             # err += |dx|
    addl 16(%rsp), %r12d          # y0 += sy (pilha: [16]=sy)

    jmp  .Ldl_loop

.Ldl_cleanup:
    addq $32, %rsp               # limpar passos + cor + sy + sx

    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
.Ldl_done:
    retq


# ============================================================
# fb_draw_circle (Midpoint Circle Algorithm)
# ============================================================
# Desenha circunferencia (contorno) usando simetria de 8 octantes.
#
# Entrada:
#   %edi = cx (centro x)
#   %esi = cy (centro y)
#   %edx = raio
#   %ecx = cor 32-bit (0xAABBGGRR)
#
# Preserva: %rbx, %rbp, %r12-%r15
# ============================================================
fb_draw_circle:
    cmpl $0, fb_state(%rip)
    je   .Ldc_done

    pushq %rbx
    pushq %r12
    pushq %r13

    # rbx = cx, r12d = cy, r13d = cor
    movl %edi, %ebx
    movl %esi, %r12d
    movl %ecx, %r13d

    # Se raio <= 0, sai
    testl %edx, %edx
    jle  .Ldc_pop

    # Variaveis do algoritmo (usaremos registradores locais na pilha):
    #   x = 0
    #   y = raio
    #   d = 1 - raio

    subq $16, %rsp                # alocar 16 bytes na pilha
    # [rsp+0] = x (corrente)
    # [rsp+4] = y (corrente)
    # [rsp+8] = d (decision variable)
    # [rsp+12] = raio (constante)
    movl $0, (%rsp)               # x = 0
    movl %edx, 4(%rsp)            # y = raio
    movl $1, %eax
    subl %edx, %eax
    movl %eax, 8(%rsp)            # d = 1 - raio
    movl %edx, 12(%rsp)           # raio (salvo)

    # --- Loop: enquanto x <= y ---
.Ldc_loop:
    movl (%rsp), %eax
    cmpl 4(%rsp), %eax
    jg   .Ldc_end_loop

    # --- Desenhar 8 pontos com simetria ---
    # Pontos: (cx+x, cy+y), (cx-x, cy+y), (cx+x, cy-y), (cx-x, cy-y),
    #         (cx+y, cy+x), (cx-y, cy+x), (cx+y, cy-x), (cx-y, cy-x)

    # Salvar x, y, d na pilha antes do call (fb_put_pixel nao toca a pilha)
    # Os dados estao em [rsp+0..12], que ficam intactos.
    # rbx=cx, r12d=cy, r13d=cor sao callee-saved ou na pilha.
    # So precisamos carregar edi/esi/edx.

    # Ponto 1: (cx+x, cy+y)
    movl %ebx, %edi
    addl (%rsp), %edi
    movl %r12d, %esi
    addl 4(%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 2: (cx-x, cy+y)
    movl %ebx, %edi
    subl (%rsp), %edi
    movl %r12d, %esi
    addl 4(%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 3: (cx+x, cy-y)
    movl %ebx, %edi
    addl (%rsp), %edi
    movl %r12d, %esi
    subl 4(%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 4: (cx-x, cy-y)
    movl %ebx, %edi
    subl (%rsp), %edi
    movl %r12d, %esi
    subl 4(%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 5: (cx+y, cy+x)
    movl %ebx, %edi
    addl 4(%rsp), %edi
    movl %r12d, %esi
    addl (%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 6: (cx-y, cy+x)
    movl %ebx, %edi
    subl 4(%rsp), %edi
    movl %r12d, %esi
    addl (%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 7: (cx+y, cy-x)
    movl %ebx, %edi
    addl 4(%rsp), %edi
    movl %r12d, %esi
    subl (%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # Ponto 8: (cx-y, cy-x)
    movl %ebx, %edi
    subl 4(%rsp), %edi
    movl %r12d, %esi
    subl (%rsp), %esi
    movl %r13d, %edx
    call fb_put_pixel

    # --- Atualizar variaveis ---
    # if d < 0:
    #   d = d + 2*x + 3
    #   x++
    # else:
    #   d = d + 2*(x-y) + 5
    #   x++, y--
    movl 8(%rsp), %eax           # eax = d
    cmpl $0, %eax
    jns  .Ldc_d_positive

    # d < 0: d += 2*x + 3, x++
    movl (%rsp), %ecx            # ecx = x
    shll $1, %ecx                # 2*x
    addl $3, %ecx                # 2*x + 3
    addl %ecx, %eax              # d += 2*x + 3
    movl %eax, 8(%rsp)
    incl (%rsp)                  # x++
    jmp  .Ldc_loop

.Ldc_d_positive:
    # d >= 0: d += 2*(x-y) + 5, x++, y--
    movl (%rsp), %ecx            # ecx = x
    subl 4(%rsp), %ecx           # ecx = x - y
    shll $1, %ecx                # 2*(x-y)
    addl $5, %ecx                # 2*(x-y) + 5
    addl %ecx, %eax              # d += ...
    movl %eax, 8(%rsp)
    incl (%rsp)                  # x++
    decl 4(%rsp)                 # y--
    jmp  .Ldc_loop

.Ldc_end_loop:
    addq $16, %rsp               # liberar pilha local

.Ldc_pop:
    popq %r13
    popq %r12
    popq %rbx
.Ldc_done:
    retq
