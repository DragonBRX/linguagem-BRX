# ============================================================
# BRX — Códigos de Erro
# ============================================================
# Todos os erros retornam um código negativo em %rax.
# Mensagens de erro são exibidas via stderr.
# ============================================================

# Erros do Parser
.equ ERR_OK, 0
.equ ERR_SYNTAX, -1
.equ ERR_UNEXPECTED_TOKEN, -2
.equ ERR_UNCLOSED_STRING, -3
.equ ERR_INVALID_NUMBER, -4
.equ ERR_UNKNOWN_KEYWORD, -5
.equ ERR_MISSING_END, -6
.equ ERR_BLOCK_MISMATCH, -7

# Erros do Runtime
.equ ERR_UNDEFINED_VAR, -10
.equ ERR_UNDEFINED_FUNC, -11
.equ ERR_TYPE_MISMATCH, -12
.equ ERR_DIV_ZERO, -13
.equ ERR_STACK_OVERFLOW, -14
.equ ERR_HEAP_FULL, -15
.equ ERR_OUT_OF_BOUNDS, -16
.equ ERR_NULL_POINTER, -17

# Erros de I/O
.equ ERR_FILE_NOT_FOUND, -20
.equ ERR_FILE_OPEN, -21
.equ ERR_FILE_READ, -22
.equ ERR_FILE_WRITE, -23

# Erros Visuais
.equ ERR_FB_OPEN, -30
.equ ERR_FB_MMAP, -31
.equ ERR_FB_IOCTL, -32
.equ ERR_INPUT_OPEN, -33
.equ ERR_INPUT_READ, -34
.equ ERR_INVALID_COLOR, -35
.equ ERR_INVALID_COORDS, -36

# Erros de Hardware
.equ ERR_MEM_ALLOC, -40
.equ ERR_MEM_FREE, -41
.equ ERR_INVALID_REG, -42
.equ ERR_SYSCALL_FAIL, -43

# Erros de Sandbox
.equ ERR_SBX_LIMIT, -50
.equ ERR_SBX_ISOLATE, -51

# Tabela de mensagens (usada por error_handler)
.section .rodata
error_table:
    .quad 0                     # ERR_OK
    .quad msg_syntax
    .quad msg_unexpected_token
    .quad msg_unclosed_string
    .quad msg_invalid_number
    .quad msg_unknown_keyword
    .quad msg_missing_end
    .quad msg_block_mismatch
    # ... continua

msg_syntax:             .asciz "Erro de sintaxe"
msg_unexpected_token:   .asciz "Token inesperado"
msg_unclosed_string:    .asciz "String nao fechada"
msg_invalid_number:     .asciz "Numero invalido"
msg_unknown_keyword:    .asciz "Palavra-chave desconhecida"
msg_missing_end:        .asciz "Bloco sem 'end'"
msg_block_mismatch:     .asciz "Bloco mal formado"
msg_undefined_var:      .asciz "Variavel nao definida"
msg_undefined_func:     .asciz "Funcao nao definida"
msg_type_mismatch:      .asciz "Tipo incompativel"
msg_div_zero:           .asciz "Divisao por zero"
msg_stack_overflow:     .asciz "Stack overflow"
msg_heap_full:          .asciz "Heap cheio"
msg_fb_open:            .asciz "Falha ao abrir framebuffer"
msg_fb_mmap:            .asciz "Falha ao mapear framebuffer"
msg_input_open:         .asciz "Falha ao abrir dispositivo de input"
