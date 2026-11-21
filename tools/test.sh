#!/usr/bin/env bash
# Corre las pruebas de la biblioteca: ./tools/test.sh [filtro]
# PAI: el ejecutable de pai (por defecto, el del repo del motor al lado).
set -euo pipefail
cd "$(dirname "$0")/.."
PAI="${PAI:-../PascalAI/bin/win64/pai.exe}"
[ -x "$PAI" ] || PAI="${PAI%.exe}"
export PAI_PATH="$PWD/src"
"$PAI" test tests "$@"
