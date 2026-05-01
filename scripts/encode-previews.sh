#!/bin/bash
# Generate silent H.264 PREVIEW clips for the projects carousel.
# Strategy:
#   - Same resolution AND same duration as the source (no trim, no scaling).
#   - Carousel loops this file; detail page upgrades to the full master + AAC.
#   - Target ~2.5 MB per file (user cap): video bitrate is derived from source
#     duration so long clips stay small while short clips still look sharp.
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

  # Target muxed file ≈ 2.4 MiB (stay under ~3 MB on disk). Tight maxrate ≈ avg.
  dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | tr -d '\r\n' || echo "10")
  br_k=$(awk -v d="$dur" 'BEGIN {
    if (d < 0.25) d = 0.25;
    tgt = 2.35 * 1024 * 1024;
    br = int(tgt * 8 / d / 1000);
    if (br < 180) br = 180;
    if (br > 4000) br = 4000;
    print br;
  }')
  max_k=$(( br_k + 120 ))
  buf_k=$(( br_k * 2 ))

  ffmpeg -y -hide_banner -loglevel error \
    -i "$src" \
    -map 0:v:0 \
    -c:v libx264 -profile:v high -level 4.1 -pix_fmt yuv420p \
    -preset medium \
    -b:v "${br_k}k" -maxrate "${max_k}k" -bufsize "${buf_k}k" \
    -g 120 -keyint_min 120 -sc_threshold 0 \
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
