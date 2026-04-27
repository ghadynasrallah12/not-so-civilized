#!/bin/bash
# Find media files in assets/ that are NOT referenced by index.html
# (or by the JOURNAL manifest used dynamically). Lists candidates to delete.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

REFERENCES=$(mktemp)
ON_DISK=$(mktemp)

# 1. Static refs in index.html (and any other HTML)
grep -oE 'assets/[^"'"'"' )]+\.(mp4|mov|webm|m4v|jpg|jpeg|png|webp|avif|gif|svg|ico|woff|woff2|otf|ttf)' index.html \
  | sed 's/?[^"]*$//' | sort -u >> "$REFERENCES"

# 2. Dynamic JOURNAL refs (read manifest, build full paths)
JOURNAL_BASE="assets/web/homepage/optimized/JOURNAL"
if [ -f "$JOURNAL_BASE/journal-manifest.json" ]; then
  python3 -c "
import json, urllib.parse
with open('$JOURNAL_BASE/journal-manifest.json') as f:
    files = json.load(f)
for fn in files:
    print(f'$JOURNAL_BASE/{fn}')
print('$JOURNAL_BASE/journal-manifest.json')
" >> "$REFERENCES"
fi

sort -u "$REFERENCES" -o "$REFERENCES"

# 3. Files actually on disk
find assets -type f \( \
  -iname '*.mp4' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.m4v' \
  -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
  -o -iname '*.avif' -o -iname '*.gif' -o -iname '*.svg' -o -iname '*.ico' \
  -o -iname '*.woff' -o -iname '*.woff2' -o -iname '*.otf' -o -iname '*.ttf' \
\) | sort -u > "$ON_DISK"

echo "=== Referenced files: $(wc -l < "$REFERENCES") ==="
echo "=== On-disk files:    $(wc -l < "$ON_DISK") ==="
echo ""
echo "=== UNUSED files on disk (not referenced anywhere): ==="
comm -23 "$ON_DISK" "$REFERENCES" | while read -r f; do
  size=$(stat -f%z "$f" 2>/dev/null || echo 0)
  printf "%10d  %s\n" "$size" "$f"
done | sort -rn

echo ""
echo "=== Referenced files MISSING from disk (broken links): ==="
comm -13 "$ON_DISK" "$REFERENCES"

rm -f "$REFERENCES" "$ON_DISK"
