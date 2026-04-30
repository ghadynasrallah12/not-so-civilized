#!/bin/bash
# Generate modern WebP + AVIF siblings for all key JPEGs.
# Strategy:
#   - Each input.jpg gets input.webp (q80) and input.avif (cq 30).
#   - Browsers pick AVIF first, then WebP, then JPEG fallback.
#   - Preserves dimensions.
# Targets:
#   - Standards optimized
#   - Journal optimized
#   - Homepage optimized hero/about/concept-creation/posters
#   - Project posters
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

LOG=scripts/encode-images.log
: > "$LOG"

WEBP_Q=80
AVIF_CQ=30   # 0=lossless, ~30 ~= visually lossless

encode_modern() {
  local src="$1"
  if [ ! -f "$src" ]; then return; fi
  case "$src" in
    *.jpg|*.JPG|*.jpeg|*.JPEG|*.png|*.PNG) ;;
    *) return ;;
  esac
  local base="${src%.*}"
  local webp="${base}.webp"
  local avif="${base}.avif"
  local before_kb=$(( $(stat -f%z "$src") / 1024 ))

  if [ ! -f "$webp" ]; then
    cwebp -quiet -q $WEBP_Q -mt -m 6 "$src" -o "$webp" 2>>"$LOG"
  fi
  if [ ! -f "$avif" ]; then
    avifenc --speed 6 --min 0 --max 63 -a end-usage=q -a cq-level=$AVIF_CQ --jobs all "$src" "$avif" >/dev/null 2>>"$LOG"
  fi

  local webp_kb=0; [ -f "$webp" ] && webp_kb=$(( $(stat -f%z "$webp") / 1024 ))
  local avif_kb=0; [ -f "$avif" ] && avif_kb=$(( $(stat -f%z "$avif") / 1024 ))
  printf "  %4dKB  ->  webp:%4dKB  avif:%4dKB  %s\n" "$before_kb" "$webp_kb" "$avif_kb" "$src" | tee -a "$LOG"
}

echo "=== Standards ===" | tee -a "$LOG"
for f in assets/web/standards/optimized/*.jpg; do encode_modern "$f"; done

echo "" | tee -a "$LOG"
echo "=== Journal ===" | tee -a "$LOG"
for f in assets/web/homepage/optimized/JOURNAL/*.{jpg,JPG,jpeg,JPEG}; do
  [ -f "$f" ] || continue
  encode_modern "$f"
done

echo "" | tee -a "$LOG"
echo "=== Homepage hero / about / concept ===" | tee -a "$LOG"
for f in assets/web/homepage/optimized/{about-web.jpg,creative-execution-web.jpg,concept-creation-web.jpg,homepage-video-poster.jpg}; do
  [ -f "$f" ] && encode_modern "$f"
done

echo "" | tee -a "$LOG"
echo "=== Project posters ===" | tee -a "$LOG"
for f in assets/web/PROJECT/optimized/posters/*.jpg; do
  [ -f "$f" ] && encode_modern "$f"
done

echo "" | tee -a "$LOG"
echo "DONE" | tee -a "$LOG"
