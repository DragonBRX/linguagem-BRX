#!/bin/bash
# Build otimizado (sem debug)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/build.sh"
strip "$SCRIPT_DIR/../build/linux/brx"
echo "Executável otimizado e stripado."
