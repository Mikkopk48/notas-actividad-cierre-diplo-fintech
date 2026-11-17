#!/usr/bin/env bash
# Regenera README.md: portada (Excalidraw/Portada.excalidraw.png) + galería de dibujos Excalidraw.
# Lo ejecuta el hook pre-commit, así cada commit automático de Obsidian Git actualiza el README.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TITLE="Notas · Proyecto final Diplomatura en Desarrollo Fintech"
PORTADA="Excalidraw/Portada.excalidraw.png"

urlenc() { python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$1"; }

# Todos los PNG exportados por Excalidraw, más recientes primero
mapfile -t pngs < <(find . -path ./.git -prune -o -path ./.obsidian -prune -o -type f -name '*.excalidraw.png' -printf '%T@ %P\n' | sort -rn | cut -d' ' -f2-)

# Portada: Portada.excalidraw.png si existe; si no, el dibujo más reciente
cover=""
if [[ -f "$PORTADA" ]]; then cover="$PORTADA"; elif (( ${#pngs[@]} )); then cover="${pngs[0]}"; fi

{
  echo "# $TITLE"
  echo
  if [[ -n "$cover" ]]; then
    echo "![Portada]($(urlenc "$cover"))"
    echo
  fi
  echo "## Notas en Excalidraw"
  echo
  if (( ${#pngs[@]} == 0 )); then
    echo "_Todavía no hay dibujos._"; echo
  else
    for p in "${pngs[@]}"; do
      [[ "$p" == "$cover" ]] && continue
      name="$(basename "$p" .excalidraw.png)"
      md="${p%.png}.md"
      echo "### $name"
      echo
      echo "[![$name]($(urlenc "$p"))]($(urlenc "$md"))"
      echo
    done
  fi
  echo "---"
  echo "_README generado automáticamente por \`scripts/update-readme.sh\`._"
} > README.md
