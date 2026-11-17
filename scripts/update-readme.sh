#!/usr/bin/env bash
# Regenera README.md: portada (Excalidraw/Portada.excalidraw.png o Excalidraw/Portada.png) + galería de dibujos Excalidraw.
# Lo ejecuta el hook pre-commit, así cada commit automático de Obsidian Git actualiza el README.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

TITLE="Notas · Proyecto final Diplomatura en Desarrollo Fintech"
PORTADA="Excalidraw/Portada.excalidraw.png"

urlenc() { python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$1"; }

# PNG exportados por Excalidraw (nota con frontmatter excalidraw-plugin + PNG del mismo nombre), más recientes primero
mapfile -t pngs < <(
  grep -rlZ --include='*.md' --exclude-dir=.git --exclude-dir=.obsidian -m1 '^excalidraw-plugin:' . |
  while IFS= read -r -d '' md; do
    png="${md%.md}.png"; [[ -f "$png" ]] && printf '%s %s\n' "$(stat -c %Y "$png")" "${png#./}"
  done | sort -rn | cut -d' ' -f2-
)

# Portada: Portada.excalidraw.png si existe; si no, el dibujo más reciente
cover=""
if [[ -f "$PORTADA" ]]; then cover="$PORTADA"; elif [[ -f Excalidraw/Portada.png ]]; then cover="Excalidraw/Portada.png"; elif (( ${#pngs[@]} )); then cover="${pngs[0]}"; fi

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
      name="$(basename "$p" .png)"; name="${name%.excalidraw}"
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
