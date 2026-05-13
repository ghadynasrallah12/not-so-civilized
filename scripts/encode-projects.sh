#!/bin/bash
# Re-encode all project videos for the detail player.
# Strategy:
#   - Sources live in assets/original/<PROJECT>/...  (local-only, not pushed).
#   - Keep 1080p (cap longest side at 1920px) so quality matches the previous
#     masters. Resolution is preserved.
#   - CRF 26 + tight maxrate cap → ~5-8 MB per master with imperceptible quality
#     loss for portfolio playback. Previous CRF 24 / 6M was producing 20-50 MB
#     files that take 5-20 seconds to start playback on typical broadband.
#   - preset slow → squeezes ~10-15% more compression for the same quality
#     vs medium, at the cost of ~2x encode time. Worth it: this runs once.
#   - H.264 High + yuv420p → universal browser playback (incl. Safari/iOS).
#   - Keep audio (AAC 128kbps stereo) — detail page plays with sound.
#   - +faststart → moov atom at front, browser plays before full download.
#   - keyint 48 (~2s GOP @ 24fps) → snappy seeking on the detail timeline.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

LOG=scripts/encode-projects.log
: > "$LOG"

encode() {
  local src="$1"
  local out="$2"
  local crf="${3:-26}"
  local maxrate="${4:-3500k}"
  local bufsize="${5:-7000k}"

  if [ ! -f "$src" ]; then
    echo "MISSING SOURCE: $src" | tee -a "$LOG"
    return 1
  fi

  echo "" | tee -a "$LOG"
  echo "=== $(date '+%H:%M:%S') Encoding: $src -> $out (CRF $crf, max $maxrate) ===" | tee -a "$LOG"
  local before=$(stat -f%z "$src" 2>/dev/null || echo 0)

  ffmpeg -y -hide_banner -loglevel warning -nostats \
    -i "$src" \
    -map 0:v:0 -map 0:a:0? \
    -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p \
    -preset slow -crf "$crf" \
    -maxrate "$maxrate" -bufsize "$bufsize" \
    -g 48 -keyint_min 48 -sc_threshold 0 \
    -vf "scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1920,ih))':flags=lanczos" \
    -c:a aac -b:a 128k -ac 2 -ar 48000 \
    -movflags +faststart \
    "$out" 2>&1 | tee -a "$LOG"

  if [ -f "$out" ]; then
    local after=$(stat -f%z "$out")
    local mb_before=$(( before / 1024 / 1024 ))
    local mb_after=$(( after / 1024 / 1024 ))
    echo "  done: ${mb_before}MB -> ${mb_after}MB" | tee -a "$LOG"
  else
    echo "  FAILED" | tee -a "$LOG"
    return 1
  fi
}

OUTDIR="assets/web/PROJECT/optimized"
mkdir -p "$OUTDIR"

# Project encode list — source path -> output filename.
# Sources: assets/original/<PROJECT>/<file>  (gitignored local masters).
# Targets: ~5-8 MB at 1920p HD, with audio. Tune crf / maxrate per clip if
# motion-heavy footage exceeds the target.
# args: src, out, crf, maxrate, bufsize
encode "assets/original/AKI/p1.mp4"                                "$OUTDIR/aki-web.mp4"            26 3500k 7000k
encode "assets/original/AKIKI/FILM 1.mp4"                          "$OUTDIR/akiki-web.mp4"          26 3500k 7000k
encode "assets/original/BEIT TRAD/BEIT TRAD COLORED.mp4"           "$OUTDIR/beit-trad-web.mp4"      26 3500k 7000k
encode "assets/original/BESH/2.mp4"                                "$OUTDIR/besh-web.mp4"           25 4500k 9000k
encode "assets/original/BOKJA/BOKJA WEDESIGN.mp4"                  "$OUTDIR/bokja-web.mp4"          26 3500k 7000k
encode "assets/original/ELISSAR/ELISSAR KANSO FIL FINAL WITH SUBTITLES.mov" "$OUTDIR/elissar-web.mp4"      26 3000k 6000k
encode "assets/original/IRRELEVANT/IRRELEVANT_DOCU_FINAL.MP4"      "$OUTDIR/irrelevant-web.mp4"     26 3000k 6000k
encode "assets/original/KATARINA/albino.mp4"                       "$OUTDIR/katarina-web.mp4"       25 4500k 9000k
encode "assets/original/MJ/MARIE JOE FILM WITH SUBTITLES.mp4"      "$OUTDIR/mj-web.mp4"             27 2500k 5000k
encode "assets/original/NAGGIAR ARTIST/OUISAM FINAL mp4.mp4"       "$OUTDIR/naggiar-artist-web.mp4" 26 3500k 7000k
encode "assets/original/NAGGIAR FILM/NAGGIAR_4K_FINAL01_.MP4"      "$OUTDIR/naggiar-film-web.mp4"   26 3000k 6000k
encode "assets/original/OIL&GAZ/GENERAL OIL&GAZ.mp4"               "$OUTDIR/oil-gaz-web.mp4"        25 4500k 9000k
encode "assets/original/ORIENT/CITY VIEW.mp4"                      "$OUTDIR/orient-web.mp4"         25 4000k 8000k
encode "assets/original/POP UP/MAN.mp4"                            "$OUTDIR/pop-up-web.mp4"         26 3500k 7000k
encode "assets/original/SAMI/final sami.mp4"                       "$OUTDIR/sami-web.mp4"           27 2500k 5000k
encode "assets/original/SARA'S BAG/HORIZONTAL WITHOUT BARS WITH SUBTITLES .mp4" "$OUTDIR/saras-bag-web.mp4"  26 3500k 7000k
encode "assets/original/SARISTIQUE/FINAL OMDB SARI.mp4"            "$OUTDIR/saristique-web.mp4"     27 2500k 5000k
encode "assets/original/SOAR/SOAR_ESTHER_V4.mp4"                   "$OUTDIR/soar-web.mp4"           25 4500k 9000k
encode "assets/original/STEAKBAR SUSHI/vclassic 2025-07-16 183053.365.MOV" "$OUTDIR/steakbar-sushi-web.mp4" 25 4500k 9000k

# Homepage hero — slightly more aggressive (CRF 25) since it autoplays on every visit.
# Homepage hero is permanently muted; encode without audio to save bytes.
encode_silent() {
  local src="$1" out="$2" crf="${3:-25}" maxrate="${4:-4M}" bufsize="${5:-8M}"
  if [ ! -f "$src" ]; then echo "MISSING SOURCE: $src" | tee -a "$LOG"; return 1; fi
  echo "" | tee -a "$LOG"
  echo "=== $(date '+%H:%M:%S') Encoding (silent): $src -> $out ===" | tee -a "$LOG"
  ffmpeg -y -hide_banner -loglevel warning -nostats \
    -i "$src" \
    -map 0:v:0 \
    -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p \
    -preset medium -crf "$crf" \
    -maxrate "$maxrate" -bufsize "$bufsize" \
    -g 60 -keyint_min 60 -sc_threshold 0 \
    -vf "scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1920,ih))':flags=lanczos" \
    -an \
    -movflags +faststart \
    "$out" 2>&1 | tee -a "$LOG"
  ls -lh "$out" | tee -a "$LOG"
}
encode_silent "assets/web/homepage/HOMEPAGE VIDEO.mov" "assets/web/homepage/optimized/homepage-video-web.mp4" 25 4M 8M

echo "" | tee -a "$LOG"
echo "=== $(date '+%H:%M:%S') ALL DONE ===" | tee -a "$LOG"
ls -lh "$OUTDIR"/*.mp4 assets/web/homepage/optimized/homepage-video-web.mp4 | tee -a "$LOG"
