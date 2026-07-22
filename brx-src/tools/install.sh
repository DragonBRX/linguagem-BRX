#!/bin/bash
# Instalador BRX para Linux

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Instalador BRX v0.6 ===${NC}"

# Build primeiro
./tools/build.sh

# Detectar se é root
if [ "$EUID" -eq 0 ]; then
    PREFIX="/usr/local"
    BIN_DIR="$PREFIX/bin"
    SHARE_DIR="$PREFIX/share/brx"
    DESKTOP_DIR="/usr/share/applications"
    MIME_DIR="/usr/share/mime"
    BINFMT_DIR="/proc/sys/fs/binfmt_misc"
else
    PREFIX="$HOME/.local"
    BIN_DIR="$PREFIX/bin"
    SHARE_DIR="$PREFIX/share/brx"
    DESKTOP_DIR="$HOME/.local/share/applications"
    MIME_DIR="$HOME/.local/share/mime"
fi

mkdir -p "$BIN_DIR" "$SHARE_DIR" "$DESKTOP_DIR" "$MIME_DIR/packages"

# Copiar executável
cp build/linux/brx "$BIN_DIR/"
chmod +x "$BIN_DIR/brx"

# Copiar assets
cp -r assets/* "$SHARE_DIR/"

# Criar .desktop
cat > "$DESKTOP_DIR/brx.desktop" <<EOF
[Desktop Entry]
Name=BRX
Comment=Linguagem de Programação BRX
Exec=$BIN_DIR/brx %f
Icon=$SHARE_DIR/icons/brx_icon.png
Type=Application
Terminal=true
MimeType=application/x-brx;
Categories=Development;IDE;
EOF

# Registrar MIME type
cat > "$MIME_DIR/packages/brx-mime.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-brx">
    <comment>BRX Source File</comment>
    <glob pattern="*.brx"/>
    <icon name="brx_icon"/>
  </mime-type>
</mime-info>
EOF

# Atualizar databases
if command -v update-mime-database &> /dev/null; then
    update-mime-database "$MIME_DIR"
fi
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

# binfmt (se root)
if [ "$EUID" -eq 0 ] && [ -d "$BINFMT_DIR" ]; then
    echo ':BRX:M::\x72\x75\x6e::/usr/local/bin/brx:' > "$BINFMT_DIR/register"
    echo -e "${GREEN}✅ binfmt_misc registrado${NC}"
fi

echo -e "${GREEN}✅ BRX instalado em $PREFIX${NC}"
echo ""
echo "Uso: brx <arquivo.brx>"
echo "     brx compile <arquivo.brx> --output <executavel>"
