#!/bin/bash
# Generate short silent H.264 PREVIEW clips for the projects carousel.
# Strategy:
#   - Same resolution as the source (no scaling) so previews look as crisp
#     as the click-to-play full clip.
#   - First 5 seconds only — looping teaser, detail page plays the full clip + audio.
#   - VBR with a maxrate cap targeting ~2–3 MB per file (CRF 23, max 4.5 Mb/s, buf 9 Mb/s).
#   - Source = the existing optimized full HD clip (already remuxed with audio).

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

LOG=scripts/encode-previews.log
: > "$LOG"

PREVIEW_DIR="assets/web/PROJECT/optimized/previews"
mkdir -p "$PREVIEW_DIR"

preview() {
  local src="$1"
  local label="$(basename "$src" .mp4)"
  local out="$PREVIEW_DIR/${label}-preview.mp4"

  if [ ! -f "$src" ]; then
    echo "MISSING $src" | tee -a "$LOG"
    return 1
  fi

  echo "" | tee -a "$LOG"
  echo "=== $(date '+%H:%M:%S') Preview $label ===" | tee -a "$LOG"

  ffmpeg -y -hide_banner -loglevel error \
    -ss 0 -t 5 -i "$src" \
    -map 0:v:0 \
    -c:v libx264 -profile:v high -level 4.1 -pix_fmt yuv420p \
    -preset slow -crf 23 \
    -maxrate 4500k -bufsize 9000k \
    -g 60 -keyint_min 60 -sc_threshold 0 \
    -an \
    -movflags +faststart \
    "$out" 2>&1 | tee -a "$LOG"

  if [ -f "$out" ]; then
    local kb=$(( $(stat -f%z "$out") / 1024 ))
    echo "  done: ${kb}KB  $out" | tee -a "$LOG"
  else
    echo "  FAILED" | tee -a "$LOG"
    return 1
  fi
}

for src in assets/web/PROJECT/optimized/*-web.mp4; do
  preview "$src"
done

echo "" | tee -a "$LOG"
echo "=== $(date '+%H:%M:%S') ALL PREVIEWS DONE ===" | tee -a "$LOG"
ls -lh "$PREVIEW_DIR"/*.mp4 2>/dev/null | tee -a "$LOG"
