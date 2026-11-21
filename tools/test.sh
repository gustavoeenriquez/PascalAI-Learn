#!/usr/bin/env bash
# Corre las pruebas de la biblioteca: ./tools/test.sh [archivo o carpeta]
# PAI: el ejecutable de pai (por defecto, el del PATH; si no está, el del repo del motor al lado).
set -euo pipefail
cd "$(dirname "$0")/.."
PAI="${PAI:-pai}"
command -v "$PAI" >/dev/null || [ -x "$PAI" ] || PAI="../PascalAI/bin/win64/pai.exe"
export PAI_LEARN="$PWD"
export PAI_PATH="$PWD/src"
"$PAI" test "${1:-tests}"
