# Changelog BRX

## [v0.6] — 2026-07-20
### Added
- Framebuffer embutido diretamente no interpretador BRXE
- 8 comandos visuais funcionais: win, drw, circ, lin, outfb, clr, wait, key
- Leitura real de teclado via /dev/input/event0 (evdev, não-bloqueante)
- Fonte bitmap 8×8 embutida
- 8 novos exemplos (ex18 a ex25) incluindo demo completa
- brx_core.s cresceu de 1530 para 2793 linhas

### Changed
- BRXV não depende mais de brx_visual standalone
- Integração visual completa no parser do BRXE

### Known Issues
- Mouse não implementado
- Apenas uma janela/tela cheia
- Requer console puro (sem X11/Wayland)
- Teclado fixo em /dev/input/event0 (sem detecção dinâmica)
- brx_visual.s standalone não foi atualizado

## [v0.4] — 2026-06-XX
### Added
- Estrutura base do interpretador
- Comandos visuais iniciais (sem integração com parser)
- brx_visual.s standalone

## [v0.1] — 2026-05-XX
### Added
- Especificação inicial do ecossistema
- Protótipo em Python/tkinter (deprecado)
