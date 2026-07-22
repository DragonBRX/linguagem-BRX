#!/bin/bash
# Build com símbolos de debug
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEBUG=1 "$SCRIPT_DIR/build.sh"
