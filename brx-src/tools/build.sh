#!/bin/bash
# ============================================================
# BRX Build Script
# Compila todo o ecossistema BRX a partir dos módulos .s
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/linux"
SRC_DIR="$PROJECT_ROOT/src/internal"
INCLUDE_DIR="$SRC_DIR/include"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== BRX Build System v0.6 ===${NC}"
echo ""

# Detectar assembler
if command -v nasm &> /dev/null; then
    ASSEMBLER="nasm"
    AS_FLAGS="-f elf64"
    echo -e "${GREEN}Assembler detectado: nasm${NC}"
elif command -v as &> /dev/null; then
    ASSEMBLER="as"
    AS_FLAGS=""
    echo -e "${GREEN}Assembler detectado: GNU as${NC}"
else
    echo -e "${RED}Erro: nenhum assembler encontrado (nasm ou as)${NC}"
    exit 1
fi

# Detectar linker
if command -v ld &> /dev/null; then
    LINKER="ld"
    echo -e "${GREEN}Linker detectado: ld${NC}"
else
    echo -e "${RED}Erro: linker ld não encontrado${NC}"
    exit 1
fi

# Criar diretório de build
mkdir -p "$BUILD_DIR"

# Ordem de concatenação dos módulos
echo -e "${YELLOW}Concatenando módulos...${NC}"

CORE_FILES=(
    # 1. Includes (sempre primeiro)
    "$INCLUDE_DIR/brx_defs.s"
    "$INCLUDE_DIR/brx_structs.s"
    "$INCLUDE_DIR/brx_errors.s"
    "$INCLUDE_DIR/brx_debug.s"

    # 2. Core
    "$SRC_DIR/core/brx_entry.s"
    "$SRC_DIR/core/brx_config.s"
    "$SRC_DIR/core/brx_main.s"

    # 3. Parser
    "$SRC_DIR/parser/lexer_tokens.s"
    "$SRC_DIR/parser/lexer_utils.s"
    "$SRC_DIR/parser/lexer.s"
    "$SRC_DIR/parser/parser_ops.s"
    "$SRC_DIR/parser/parser_ast.s"
    "$SRC_DIR/parser/parser_blocks.s"
    "$SRC_DIR/parser/parser.s"

    # 4. Runtime
    "$SRC_DIR/runtime/memory_heap.s"
    "$SRC_DIR/runtime/memory_stack.s"
    "$SRC_DIR/runtime/memory_gc.s"
    "$SRC_DIR/runtime/memory.s"
    "$SRC_DIR/runtime/variables.s"
    "$SRC_DIR/runtime/functions.s"
    "$SRC_DIR/runtime/builtins_math.s"
    "$SRC_DIR/runtime/builtins_string.s"
    "$SRC_DIR/runtime/builtins_list.s"
    "$SRC_DIR/runtime/builtins.s"
    "$SRC_DIR/runtime/syscalls_file.s"
    "$SRC_DIR/runtime/syscalls_mem.s"
    "$SRC_DIR/runtime/syscalls.s"
    "$SRC_DIR/runtime/io.s"

    # 5. Visual
    "$SRC_DIR/visual/brxv_font.s"
    "$SRC_DIR/visual/brxv_draw.s"
    "$SRC_DIR/visual/brxv_text.s"
    "$SRC_DIR/visual/brxv_buffer.s"
    "$SRC_DIR/visual/brxv_window.s"
    "$SRC_DIR/visual/brxv_input_keyboard.s"
    "$SRC_DIR/visual/brxv_input_mouse.s"
    "$SRC_DIR/visual/brxv_input.s"
    "$SRC_DIR/visual/brxv_linux_fbdev.s"
    "$SRC_DIR/visual/brxv_linux_x11.s"
    "$SRC_DIR/visual/brxv_linux_wayland.s"
    "$SRC_DIR/visual/brxv_windows_gdi.s"
    "$SRC_DIR/visual/brxv_bsd_fbdev.s"
    "$SRC_DIR/visual/brxv_api.s"

    # 6. Runtime Loop (BRXR)
    "$SRC_DIR/runtime_loop/timer.s"
    "$SRC_DIR/runtime_loop/events.s"
    "$SRC_DIR/runtime_loop/game_loop.s"

    # 7. Binary (BRXB)
    "$SRC_DIR/binary/compiler_elf.s"
    "$SRC_DIR/binary/compiler_pe.s"
    "$SRC_DIR/binary/compiler_macho.s"
    "$SRC_DIR/binary/optimizer.s"
    "$SRC_DIR/binary/linker.s"
    "$SRC_DIR/binary/compiler.s"

    # 8. Hardware (BRXH)
    "$SRC_DIR/hardware/registers.s"
    "$SRC_DIR/hardware/ports.s"
    "$SRC_DIR/hardware/mmap.s"
    "$SRC_DIR/hardware/inline_asm.s"
    "$SRC_DIR/hardware/brxh_api.s"

    # 9. Sandbox (BRXS)
    "$SRC_DIR/sandbox/limits.s"
    "$SRC_DIR/sandbox/isolate.s"
    "$SRC_DIR/sandbox/loader.s"
    "$SRC_DIR/sandbox/brxs_api.s"

    # 10. Translate (BRXT)
    "$SRC_DIR/translate/syscall_mapper.s"
    "$SRC_DIR/translate/pe_loader.s"
    "$SRC_DIR/translate/wine_compat.s"
    "$SRC_DIR/translate/brxt_api.s"
)

# Concatenar tudo em um arquivo temporário
TEMP_ASM="$BUILD_DIR/brx_core_temp.s"
echo "; BRX Core — Gerado automaticamente" > "$TEMP_ASM"
echo "; Data: $(date)" >> "$TEMP_ASM"
echo "; Versão: 0.6" >> "$TEMP_ASM"
echo "" >> "$TEMP_ASM"

for file in "${CORE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  → $(basename "$file")"
        echo "; ===== $(basename "$file") =====" >> "$TEMP_ASM"
        cat "$file" >> "$TEMP_ASM"
        echo "" >> "$TEMP_ASM"
    else
        echo -e "${YELLOW}  ⚠ Arquivo não encontrado: $file (criando stub)${NC}"
        echo "; STUB: $file" >> "$TEMP_ASM"
        echo "" >> "$TEMP_ASM"
    fi
done

# Montar
echo ""
echo -e "${YELLOW}Montando...${NC}"
if [ "$ASSEMBLER" = "nasm" ]; then
    nasm -f elf64 "$TEMP_ASM" -o "$BUILD_DIR/brx_core.o"
else
    as $AS_FLAGS "$TEMP_ASM" -o "$BUILD_DIR/brx_core.o"
fi

# Linkar
echo -e "${YELLOW}Linkando...${NC}"
ld -o "$BUILD_DIR/brx" "$BUILD_DIR/brx_core.o"

# Limpar temporário
rm "$TEMP_ASM"

# Tornar executável
chmod +x "$BUILD_DIR/brx"

# Verificar
echo ""
echo -e "${GREEN}✅ Build concluído!${NC}"
echo -e "${BLUE}Executável: $BUILD_DIR/brx${NC}"
echo -e "${BLUE}Tamanho: $(ls -lh "$BUILD_DIR/brx" | awk '{print $5}')${NC}"
echo ""
echo "Uso: $BUILD_DIR/brx <arquivo.brx>"
