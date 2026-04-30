#!/bin/bash
# Generate tiny base64 JPEG previews (LQIP) for journal + standards images.
# These get injected as background-image so users see something the instant
# the DOM renders (well before the full image arrives).
#
# Reads the existing manifest JSONs to know which files to process.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

LOG=scripts/blur-placeholders.log
: > "$LOG"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

emit_for_file() {
  # $1 = input image, $2 = key (basename) — emit "  KEY: \"data:...\","
  local f="$1" key="$2"
  local tmp_jpg="$TMP/blur.jpg"
  ffmpeg -y -hide_banner -loglevel error -i "$f" \
    -vf "scale='if(gt(iw,ih),-1,32)':'if(gt(iw,ih),32,-1)':flags=lanczos" \
    -q:v 8 "$tmp_jpg" 2>/dev/null || return 1
  [ -f "$tmp_jpg" ] || return 1
  local b64
  b64=$(base64 < "$tmp_jpg" | tr -d '\n')
  python3 - "$key" "data:image/jpeg;base64,$b64" <<'PY'
import sys, json
print(f"  {json.dumps(sys.argv[1])}: {json.dumps(sys.argv[2])}")
PY
}

build_from_manifest() {
  # $1 = source dir, $2 = manifest json (array of filenames), $3 = output json file
  local source_dir="$1" manifest="$2" output="$3"
  if [ ! -f "$manifest" ]; then echo "MISSING manifest $manifest" | tee -a "$LOG"; return; fi
  local files
  files=$(python3 -c "import json,sys; print('\n'.join(json.load(open(sys.argv[1]))))" "$manifest")
  echo "{" > "$output"
  local first=1
  while IFS= read -r filename; do
    [ -z "$filename" ] && continue
    local f="$source_dir/$filename"
    if [ ! -f "$f" ]; then
      echo "skip missing $f" | tee -a "$LOG"
      continue
    fi
    local entry
    entry=$(emit_for_file "$f" "$filename" || true)
    if [ -n "$entry" ]; then
      if [ $first -eq 1 ]; then first=0; else echo "," >> "$output"; fi
      printf "%s" "$entry" >> "$output"
    fi
  done <<< "$files"
  echo "" >> "$output"
  echo "}" >> "$output"
  local count
  count=$(python3 -c "import json,sys; print(len(json.load(open(sys.argv[1]))))" "$output" 2>/dev/null || echo "?")
  echo "  -> wrote $output  ($count entries)" | tee -a "$LOG"
}

echo "=== Standards blur placeholders ===" | tee -a "$LOG"
build_from_manifest \
  "assets/web/standards/optimized" \
  "assets/web/standards/optimized/standards-manifest.json" \
  "assets/web/standards/optimized/blur-placeholders.json"

echo "" | tee -a "$LOG"
echo "=== Journal blur placeholders ===" | tee -a "$LOG"
build_from_manifest \
  "assets/web/homepage/optimized/JOURNAL" \
  "assets/web/homepage/optimized/JOURNAL/journal-manifest.json" \
  "assets/web/homepage/optimized/JOURNAL/blur-placeholders.json"

echo "DONE" | tee -a "$LOG"
