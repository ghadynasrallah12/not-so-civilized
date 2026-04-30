#!/bin/bash
# Generate short silent H.264 PREVIEW clips for the projects carousel.
# Strategy:
#   - Carousel only needs a looping teaser — detail page plays full HD + audio.
#   - 8 sec, max 720px on the long edge, tighter bitrate cap (many clips can load at once).
#   - Target ~120–450 KB per clip so scrolling stays responsive on mobile networks.
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
    -ss 0 -t 8 -i "$src" \
    -map 0:v:0 \
    -c:v libx264 -profile:v high -level 3.1 -pix_fmt yuv420p \
    -preset medium -crf 31 \
    -maxrate 650k -bufsize 1300k \
    -g 48 -keyint_min 48 -sc_threshold 0 \
    -vf "scale='if(gt(iw,ih),min(720,iw),-2)':'if(gt(iw,ih),-2,min(720,ih))':flags=lanczos" \
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
