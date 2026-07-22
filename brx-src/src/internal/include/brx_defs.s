# ============================================================
# BRX — Definições Globais
# ============================================================
# Arquivo incluído por TODOS os módulos do BRX.
# Contém constantes, macros e configurações do sistema.
# ============================================================

# ---------------------------------------------------------
# Constantes do Sistema
# ---------------------------------------------------------
.equ BRX_VERSION_MAJOR, 0
.equ BRX_VERSION_MINOR, 6
.equ BRX_VERSION_PATCH, 0

# Tamanhos
.equ PAGE_SIZE, 4096
.equ STACK_SIZE, 65536
.equ HEAP_SIZE, 1048576          # 1MB heap inicial
.equ MAX_VARS, 1024              # Máximo de variáveis
.equ MAX_FUNCS, 256              # Máximo de funções
.equ MAX_STR_LEN, 4096           # Tamanho máximo de string
.equ MAX_LIST_LEN, 1024          # Tamanho máximo de lista

# Tipos de dados (usados internamente)
.equ TYPE_NULL, 0
.equ TYPE_NUM, 1
.equ TYPE_TXT, 2
.equ TYPE_BOOL, 3
.equ TYPE_LIST, 4
.equ TYPE_FUNC, 5

# Booleanos
.equ FALSE, 0
.equ TRUE, 1

# ---------------------------------------------------------
# Syscalls Linux x86-64
# ---------------------------------------------------------
.equ SYS_read, 0
.equ SYS_write, 1
.equ SYS_open, 2
.equ SYS_close, 3
.equ SYS_stat, 4
.equ SYS_fstat, 5
.equ SYS_lseek, 8
.equ SYS_mmap, 9
.equ SYS_mprotect, 10
.equ SYS_munmap, 11
.equ SYS_brk, 12
.equ SYS_ioctl, 16
.equ SYS_exit, 60
.equ SYS_getdents, 78
.equ SYS_gettimeofday, 96
.equ SYS_nanosleep, 35
.equ SYS_poll, 7

# Flags de arquivo
.equ O_RDONLY, 0
.equ O_WRONLY, 1
.equ O_RDWR, 2
.equ O_CREAT, 64
.equ O_TRUNC, 512
.equ O_NONBLOCK, 2048

# Permissões
.equ PERM_644, 420
.equ PERM_755, 493

# ---------------------------------------------------------
# Framebuffer
# ---------------------------------------------------------
.equ FB_PATH, "/dev/fb0"
.equ FBIOGET_VSCREENINFO, 0x4600
.equ FBIOPUT_VSCREENINFO, 0x4601
.equ FBIOGET_FSCREENINFO, 0x4602

# ---------------------------------------------------------
# Input (evdev)
# ---------------------------------------------------------
.equ INPUT_PATH, "/dev/input/event0"
.equ EVIOCGNAME, 0x81004506
.equ EV_KEY, 1
.equ EV_REL, 2
.equ EV_ABS, 3

# Códigos de tecla (subset)
.equ KEY_ESC, 1
.equ KEY_1, 2
.equ KEY_2, 3
.equ KEY_3, 4
.equ KEY_4, 5
.equ KEY_5, 6
.equ KEY_6, 7
.equ KEY_7, 8
.equ KEY_8, 9
.equ KEY_9, 10
.equ KEY_0, 11
.equ KEY_Q, 16
.equ KEY_W, 17
.equ KEY_E, 18
.equ KEY_R, 19
.equ KEY_T, 20
.equ KEY_Y, 21
.equ KEY_U, 22
.equ KEY_I, 23
.equ KEY_O, 24
.equ KEY_P, 25
.equ KEY_A, 30
.equ KEY_S, 31
.equ KEY_D, 32
.equ KEY_F, 33
.equ KEY_G, 34
.equ KEY_H, 35
.equ KEY_J, 36
.equ KEY_K, 37
.equ KEY_L, 38
.equ KEY_Z, 44
.equ KEY_X, 45
.equ KEY_C, 46
.equ KEY_V, 47
.equ KEY_B, 48
.equ KEY_N, 49
.equ KEY_M, 50
.equ KEY_SPACE, 57
.equ KEY_ENTER, 28
.equ KEY_LEFT, 105
.equ KEY_RIGHT, 106
.equ KEY_UP, 103
.equ KEY_DOWN, 108

# ---------------------------------------------------------
# Macros Úteis
# ---------------------------------------------------------
# NOTA: macro renomeada de SYSCALL para DO_SYSCALL porque
# o GNU as trata nomes de macro como case-insensitive, o que
# colide com a instrução nativa "syscall".
.macro DO_SYSCALL n
    movq \n, %rax
    syscall
.endm

.macro PUSH_ALL
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %rbp
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
.endm

.macro POP_ALL
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rbp
    popq %rdi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
.endm

.macro PRINT msg, len
    movq $1, %rax           # SYS_write
    movq $1, %rdi           # stdout
    leaq \msg, %rsi
    movq $\len, %rdx
    syscall
.endm

.macro EXIT code
    movq $SYS_exit, %rax
    movq $\code, %rdi
    syscall
.endm
