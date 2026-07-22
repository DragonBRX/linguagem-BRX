# ============================================================
# BRX — Macros de Debug
# ============================================================
# Ativáveis via flag de compilação DEBUG=1
# ============================================================

.ifdef DEBUG

.macro DEBUG_PRINT msg
    .section .rodata
    1:
    .asciz "\msg\n"
    .text
    pushq %rax
    pushq %rdi
    pushq %rsi
    pushq %rdx
    movq $SYS_write, %rax
    movq $2, %rdi           # stderr
    leaq 1b, %rsi
    movq $64, %rdx          # max len
    call strlen
    movq %rax, %rdx
    movq $SYS_write, %rax
    syscall
    popq %rdx
    popq %rsi
    popq %rdi
    popq %rax
.endm

.macro DEBUG_REG reg, name
    .section .rodata
    1:
    .asciz "\name = %llx\n"
    .text
    pushq %rdi
    pushq %rsi
    pushq %rax
    movq $2, %rdi           # stderr
    leaq 1b, %rsi
    movq \reg, %rdx
    call fprintf            # requer libc — usar apenas em debug
    popq %rax
    popq %rsi
    popq %rdi
.endm

.else

.macro DEBUG_PRINT msg
.endm

.macro DEBUG_REG reg, name
.endm

.endif
