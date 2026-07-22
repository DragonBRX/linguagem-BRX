# Visual — BRXV (FrameBuffer, Input, Backends)

## Arquivos

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `brxv_api.s` | API unificada. Interface comum para todos os backends. | ✅ |
| `brxv_linux_fbdev.s` | Backend Linux: /dev/fb0 + evdev | ✅ |
| `brxv_linux_x11.s` | Backend Linux X11 (Xlib) | ❌ |
| `brxv_linux_wayland.s` | Backend Linux Wayland | ❌ |
| `brxv_windows_gdi.s` | Backend Windows GDI+ | ❌ |
| `brxv_bsd_fbdev.s` | Backend *BSD fbdev | ❌ |
| `brxv_font.s` | Fonte bitmap 8×8 embutida | ✅ |
| `brxv_draw.s` | Primitivas: pixel, linha (Bresenham), retângulo, círculo | ✅ |
| `brxv_text.s` | Renderização de texto usando fonte bitmap | ✅ |
| `brxv_input.s` | Input abstrato: teclado + mouse | ✅ (parcial) |
| `brxv_input_keyboard.s` | Teclado evdev /dev/input/event0 | ✅ |
| `brxv_input_mouse.s` | Mouse evdev | ❌ |
| `brxv_window.s` | Gerenciamento de janela/contexto | ✅ (1 janela) |
| `brxv_buffer.s` | Double buffering / vsync | ❌ |

## API Unificada (brxv_api.s)

```asm
# Inicialização
brxv_init()           → inicializa backend ativo
brxv_shutdown()       → libera recursos

# Janela
brxv_win_open(w, h)   → abre janela/framebuffer
brxv_win_close()      → fecha
brxv_win_swap()       → swap buffers (futuro)

# Desenho
brxv_draw_pixel(x, y, color)
brxv_draw_line(x1, y1, x2, y2, color)
brxv_draw_rect(x, y, w, h, color)
brxv_draw_circ(cx, cy, r, color)
brxv_draw_text(x, y, str, color)
brxv_clear(color)

# Input
brxv_key_poll()       → retorna tecla pressionada ou 0
brxv_mouse_poll()     → retorna (x, y, buttons) (futuro)

# Timing
brxv_wait(ms)         → nanosleep
```

## Backend Linux FrameBuffer

```
open("/dev/fb0", O_RDWR)
  → ioctl(FBIOGET_VSCREENINFO)  → obtém resolução, bpp
  → ioctl(FBIOGET_FSCREENINFO)  → obtém line_length
  → mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)
  → escreve diretamente nos pixels
```

## Backend evdev Teclado

```
open("/dev/input/event0", O_RDONLY|O_NONBLOCK)
  → read() em loop
  → decodifica struct input_event
  → EV_KEY + value=1 (press) → mapeia para código ASCII/BRX
```
