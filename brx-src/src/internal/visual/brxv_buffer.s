# ============================================================
# BRX — Framebuffer Buffer Management
# ============================================================
# Gerenciamento do framebuffer via /dev/fb0 (Linux).
# Abre o dispositivo, obtem resolucao via ioctl, mapeia com mmap.
# Fornece fb_put_pixel como primitiva base para todos os desenhos.
# ============================================================

    .section .bss

    # Estado do framebuffer
    .align 8
fb_base:        .skip 8          # ponteiro para a memoria mapeada
fb_fd:          .skip 4          # file descriptor do /dev/fb0
fb_width:       .skip 4          # resolucao horizontal (pixels)
fb_height:      .skip 4          # resolucao vertical (pixels)
fb_pitch:       .skip 4          # bytes por linha (line_length)
fb_bpp:         .skip 4          # bits por pixel (esperado: 32)
fb_line_len:    .skip 4          # comprimento de linha em bytes
fb_state:       .skip 4          # 0 = fechado, 1 = aberto

    # fb_var_screeninfo temporario (para ioctl)
    .align 16
fb_varinfo:     .skip 160

    # fb_fix_screeninfo temporario
    .align 16
fb_fixinfo:     .skip 192

    .section .rodata
fb_device_path: .asciz "/dev/fb0"

    .text
    .globl fb_open
    .globl fb_close
    .globl fb_clear
    .globl fb_put_pixel
    .globl fb_get_pixel
    .globl fb_is_open
    .globl fb_get_width
    .globl fb_get_height
    .globl fb_get_base

# ============================================================
# fb_open
# ============================================================
# Abre o framebuffer /dev/fb0 e mapeia na memoria.
#
# Saida:
#   %eax = 0 (sucesso) ou codigo de erro negativo
# Preserva: %rbx, %rbp, %r12-%r15
# Destrói: %rax, %rcx, %rdx, %rsi, %rdi, %r8-%r11
# ============================================================
fb_open:
    pushq %rbx
    pushq %r12

    # Ja esta aberto?
    cmpl $1, fb_state(%rip)
    je   .Lfb_already_open

    # open("/dev/fb0", O_RDWR)
    leaq fb_device_path(%rip), %rdi
    movq $O_RDWR, %rsi
    xorq %rdx, %rdx
    movq $SYS_open, %rax
    syscall
    movl %eax, fb_fd(%rip)
    testq %rax, %rax
    js   .Lfb_open_err

    # ioctl(fd, FBIOGET_VSCREENINFO, &fb_varinfo)
    movl fb_fd(%rip), %edi
    movq $FBIOGET_VSCREENINFO, %rsi
    leaq fb_varinfo(%rip), %rdx
    movq $SYS_ioctl, %rax
    syscall
    testq %rax, %rax
    js   .Lfb_ioctl_err

    # Extrair xres (offset 0), yres (offset 4), bits_per_pixel (offset 16)
    movl fb_varinfo(%rip), %eax
    movl %eax, fb_width(%rip)
    movl 4+fb_varinfo(%rip), %eax
    movl %eax, fb_height(%rip)
    movl 16+fb_varinfo(%rip), %eax
    movl %eax, fb_bpp(%rip)

    # ioctl(fd, FBIOGET_FSCREENINFO, &fb_fixinfo)
    movl fb_fd(%rip), %edi
    movq $FBIOGET_FSCREENINFO, %rsi
    leaq fb_fixinfo(%rip), %rdx
    movq $SYS_ioctl, %rax
    syscall
    testq %rax, %rax
    js   .Lfb_ioctl_err

    # Extrair line_length da fixinfo (offset 16)
    movl 16+fb_fixinfo(%rip), %eax
    movl %eax, fb_line_len(%rip)
    movl %eax, fb_pitch(%rip)

    # Calcular tamanho total do framebuffer
    movl fb_line_len(%rip), %eax
    imull fb_height(%rip), %eax
    movslq %eax, %rsi

    # mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)
    xorq %rdi, %rdi
    movq $3, %rdx              # PROT_READ | PROT_WRITE
    movq $1, %rcx              # MAP_SHARED
    movl fb_fd(%rip), %r8d
    xorq %r9, %r9
    movq $SYS_mmap, %rax
    syscall
    movq %rax, fb_base(%rip)
    cmpq $-4096, %rax
    jae  .Lfb_mmap_err

    movl $1, fb_state(%rip)
    xorl %eax, %eax
    popq %r12
    popq %rbx
    retq

.Lfb_already_open:
    xorl %eax, %eax
    popq %r12
    popq %rbx
    retq

.Lfb_mmap_err:
    movq $SYS_close, %rax
    movl fb_fd(%rip), %edi
    syscall
    movl $ERR_FB_MMAP, %eax
    popq %r12
    popq %rbx
    retq

.Lfb_ioctl_err:
    movq $SYS_close, %rax
    movl fb_fd(%rip), %edi
    syscall
    movl $ERR_FB_IOCTL, %eax
    popq %r12
    popq %rbx
    retq

.Lfb_open_err:
    movl $ERR_FB_OPEN, %eax
    popq %r12
    popq %rbx
    retq

# ============================================================
# fb_close
# ============================================================
# Desmapeia e fecha o framebuffer.
# Preserva: %rbx, %rbp, %r12-%r15
# ============================================================
fb_close:
    pushq %rbx
    pushq %r12

    cmpl $0, fb_state(%rip)
    je   .Lfb_close_done

    # munmap(fb_base, size)
    movq fb_base(%rip), %rdi
    movl fb_line_len(%rip), %eax
    imull fb_height(%rip), %eax
    movslq %eax, %rsi
    movq $SYS_munmap, %rax
    syscall

    # close(fd)
    movl fb_fd(%rip), %edi
    movq $SYS_close, %rax
    syscall

    movl $0, fb_state(%rip)
    xorq %rax, %rax
    movq %rax, fb_base(%rip)

.Lfb_close_done:
    popq %r12
    popq %rbx
    retq

# ============================================================
# fb_clear
# ============================================================
# Preenche todo o framebuffer com uma cor 32-bit.
# Usa rep stosl para maxima velocidade em 32bpp.
#
# Entrada:
#   %edi = cor 32-bit (0xAABBGGRR)
#
# Preserva: %rbx, %rbp, %r12-%r15
# Destrói: %rax, %rcx, %rdx, %rsi, %rdi, %r8, %r9
# ============================================================
fb_clear:
    cmpl $0, fb_state(%rip)
    je   .Lfb_clr_done

    # Salvar cor (está em %edi)
    movl %edi, %edx           # edx = cor preservada

    # Calcular total de dwords
    movl fb_line_len(%rip), %eax
    imull fb_height(%rip), %eax
    movslq %eax, %rcx
    shrq $2, %rcx              # rcx = numero de dwords

    # rep stosl: %edi = destino, %eax = valor, %ecx = contador
    movq fb_base(%rip), %rdi   # destino
    movl %edx, %eax           # valor = cor
    cld
    rep stosl

.Lfb_clr_done:
    retq

# ============================================================
# fb_put_pixel
# ============================================================
# Escreve um pixel na posicao (x, y).
#
# Entrada:
#   %edi = x
#   %esi = y
#   %edx = cor 32-bit (0xAABBGGRR)
#
# Preserva: %rbx, %rbp, %r12-%r15
# Destrói: %rax, %rcx, %r8, %r9
# ============================================================
fb_put_pixel:
    cmpl $0, fb_state(%rip)
    je   .Lpp_done

    # Clipping
    cmpl fb_width(%rip), %edi
    jae  .Lpp_done
    cmpl fb_height(%rip), %esi
    jae  .Lpp_done

    # offset = y * pitch + x * 4
    # BUG FIX: carregar pitch em 32-bit para evitar leitura de 8 bytes
    movl %esi, %r8d
    movl fb_pitch(%rip), %r9d  # 32-bit load -> zero-extension automatica
    imull %r9d, %r8d
    movslq %r8d, %r8

    movslq %edi, %r9
    shlq $2, %r9
    addq %r9, %r8

    movq fb_base(%rip), %rax
    movl %edx, (%rax, %r8)

.Lpp_done:
    retq

# ============================================================
# fb_get_pixel
# ============================================================
# Le um pixel na posicao (x, y).
#
# Entrada:
#   %edi = x
#   %esi = y
#
# Saida:
#   %eax = cor 32-bit (0xAABBGGRR), ou 0 se fora dos limites
# ============================================================
fb_get_pixel:
    cmpl $0, fb_state(%rip)
    je   .Lgp_oob

    cmpl fb_width(%rip), %edi
    jae  .Lgp_oob
    cmpl fb_height(%rip), %esi
    jae  .Lgp_oob

    movl %esi, %eax
    movl fb_pitch(%rip), %ecx   # 32-bit load
    imull %ecx, %eax
    movslq %eax, %rcx
    movslq %edi, %rax
    shlq $2, %rax
    addq %rax, %rcx

    movq fb_base(%rip), %rax
    movl (%rax, %rcx), %eax
    retq

.Lgp_oob:
    xorl %eax, %eax
    retq

# ============================================================
# Helpers de acesso ao estado
# ============================================================
fb_is_open:
    movl fb_state(%rip), %eax
    retq

fb_get_width:
    movl fb_width(%rip), %eax
    retq

fb_get_height:
    movl fb_height(%rip), %eax
    retq

fb_get_base:
    movq fb_base(%rip), %rax
    retq
