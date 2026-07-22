# ============================================================
# BRX — Estruturas de Dados
# ============================================================
# Layouts de memória para objetos internos do BRX.
# Todos os tamanhos estão em bytes.
# ============================================================

# ---------------------------------------------------------
# Valor BRX (variante — union de tipos)
# ---------------------------------------------------------
# Offset 0:  tipo (1 byte)
# Offset 1:  flags (1 byte)
# Offset 2:  reservado (2 bytes)
# Offset 4:  dado (8 bytes — num, ptr, ou bool)
# Offset 12: len (4 bytes) — para string/lista
# Offset 16: total = 16 bytes
.struct 0
BRXValue_type:      .struct BRXValue_type + 1
BRXValue_flags:     .struct BRXValue_flags + 1
BRXValue_reserved:  .struct BRXValue_reserved + 2
BRXValue_data:      .struct BRXValue_data + 8
BRXValue_len:       .struct BRXValue_len + 4
BRXValue_size:

# ---------------------------------------------------------
# Variável (entrada na tabela de símbolos)
# ---------------------------------------------------------
# Offset 0:  nome (64 bytes)
# Offset 64: valor (BRXValue_size bytes)
# Offset 80: escopo (4 bytes)
# Offset 84: total = 84 bytes (alinhado para 88)
.struct 0
BRXVar_name:        .struct BRXVar_name + 64
BRXVar_value:       .struct BRXVar_value + BRXValue_size
BRXVar_scope:       .struct BRXVar_scope + 4
BRXVar_size:
    .align 8
BRXVar_size_aligned:

# ---------------------------------------------------------
# Função
# ---------------------------------------------------------
# Offset 0:  nome (64 bytes)
# Offset 64: endereço do corpo (8 bytes)
# Offset 72: num_params (4 bytes)
# Offset 76: params (8×8 = 64 bytes)
# Offset 140: escopo (4 bytes)
.struct 0
BRXFunc_name:       .struct BRXFunc_name + 64
BRXFunc_addr:       .struct BRXFunc_addr + 8
BRXFunc_nparams:    .struct BRXFunc_nparams + 4
BRXFunc_params:     .struct BRXFunc_params + 64
BRXFunc_scope:      .struct BRXFunc_scope + 4
BRXFunc_size:
    .align 8
BRXFunc_size_aligned:

# ---------------------------------------------------------
# Framebuffer Info (fb_var_screeninfo)
# ---------------------------------------------------------
.struct 0
FBInfo_xres:        .struct FBInfo_xres + 4
FBInfo_yres:        .struct FBInfo_yres + 4
FBInfo_xres_virtual:.struct FBInfo_xres_virtual + 4
FBInfo_yres_virtual:.struct FBInfo_yres_virtual + 4
FBInfo_xoffset:     .struct FBInfo_xoffset + 4
FBInfo_yoffset:     .struct FBInfo_yoffset + 4
FBInfo_bits_per_pixel: .struct FBInfo_bits_per_pixel + 4
FBInfo_grayscale:   .struct FBInfo_grayscale + 4
FBInfo_red:         .struct FBInfo_red + 4
FBInfo_green:       .struct FBInfo_green + 4
FBInfo_blue:        .struct FBInfo_blue + 4
FBInfo_transp:      .struct FBInfo_transp + 4
FBInfo_nonstd:      .struct FBInfo_nonstd + 4
FBInfo_activate:    .struct FBInfo_activate + 4
FBInfo_height:      .struct FBInfo_height + 4
FBInfo_width:       .struct FBInfo_width + 4
FBInfo_accel_flags: .struct FBInfo_accel_flags + 4
FBInfo_pixclock:    .struct FBInfo_pixclock + 4
FBInfo_left_margin: .struct FBInfo_left_margin + 4
FBInfo_right_margin:.struct FBInfo_right_margin + 4
FBInfo_upper_margin:.struct FBInfo_upper_margin + 4
FBInfo_lower_margin:.struct FBInfo_lower_margin + 4
FBInfo_hsync_len:   .struct FBInfo_hsync_len + 4
FBInfo_vsync_len:   .struct FBInfo_vsync_len + 4
FBInfo_sync:        .struct FBInfo_sync + 4
FBInfo_vmode:       .struct FBInfo_vmode + 4
FBInfo_total:

# ---------------------------------------------------------
# Evento evdev (input_event)
# ---------------------------------------------------------
.struct 0
EV_time_sec:        .struct EV_time_sec + 8
EV_time_usec:       .struct EV_time_usec + 8
EV_type:            .struct EV_type + 2
EV_code:            .struct EV_code + 2
EV_value:           .struct EV_value + 4
EV_size:
