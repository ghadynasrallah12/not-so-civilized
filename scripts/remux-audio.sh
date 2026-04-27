#!/bin/bash
# Add audio tracks back to the existing optimized project videos.
#
# Strategy: copy the optimized H.264 video bitstream as-is (no re-encode, no quality loss)
# and attach the audio stream from the original, loudness-normalized and transcoded to
# AAC 128 kbps stereo. This is fast (~seconds per video) because only audio is encoded.
#
# Loudness normalization (loudnorm, EBU R128) levels everything to -16 LUFS so a quiet
# clip (e.g. katarina at -38 dB) becomes audible without making a loud clip clip.
# True-peak limited to -1.5 dBFS for safety on consumer speakers.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

LOG=scripts/remux-audio.log
: > "$LOG"

remux() {
  local optimized="$1"   # existing video-only mp4 we want to keep
  local original="$2"    # source with audio
  local label="$(basename "$optimized" .mp4)"

  if [ ! -f "$optimized" ]; then
    echo "MISSING optimized: $optimized" | tee -a "$LOG"
    return 1
  fi
  if [ ! -f "$original" ]; then
    echo "MISSING original:  $original" | tee -a "$LOG"
    return 1
  fi

  local before=$(stat -f%z "$optimized")
  local tmp="${optimized}.audio.tmp.mp4"

  echo "" | tee -a "$LOG"
  echo "=== $(date '+%H:%M:%S') Remuxing $label ===" | tee -a "$LOG"

  # -map 0:v:0       → copy video stream from optimized (existing 1080p H.264, faststart)
  # -map 1:a:0       → take first audio stream from original
  # -c:v copy        → no video re-encode (instant)
  # -af loudnorm=... → EBU R128 normalize: target -16 LUFS, range 11, true peak -1.5 dBFS
  # -c:a aac 128k    → AAC stereo, browser-friendly, ~1 MB/min
  # -shortest        → trim to whichever stream ends first (defends against tiny drift)
  # -movflags +faststart → moov atom up front so progressive playback works
  ffmpeg -y -hide_banner -loglevel error \
    -i "$optimized" \
    -i "$original" \
    -map 0:v:0 -map 1:a:0 \
    -c:v copy \
    -af "loudnorm=I=-16:LRA=11:TP=-1.5" \
    -c:a aac -b:a 128k -ac 2 -ar 48000 \
    -shortest \
    -movflags +faststart \
    "$tmp" 2>&1 | tee -a "$LOG"

  if [ ! -f "$tmp" ]; then
    echo "  FAILED to produce $tmp" | tee -a "$LOG"
    return 1
  fi

  local after=$(stat -f%z "$tmp")
  mv "$tmp" "$optimized"

  local kb_before=$(( before / 1024 ))
  local kb_after=$(( after / 1024 ))
  echo "  done: ${kb_before}KB -> ${kb_after}KB" | tee -a "$LOG"
}

remux "assets/web/PROJECT/optimized/aki-web.mp4"             "assets/original/AKI/p1.mp4"
remux "assets/web/PROJECT/optimized/akiki-web.mp4"           "assets/original/AKIKI/FILM 1.mp4"
remux "assets/web/PROJECT/optimized/beit-trad-web.mp4"       "assets/original/BEIT TRAD/BEIT TRAD COLORED.mp4"
remux "assets/web/PROJECT/optimized/besh-web.mp4"            "assets/original/BESH/2.mp4"
remux "assets/web/PROJECT/optimized/bokja-web.mp4"           "assets/original/BOKJA/BOKJA WEDESIGN.mp4"
remux "assets/web/PROJECT/optimized/elissar-web.mp4"         "assets/original/ELISSAR/ELISSAR KANSO FIL FINAL WITH SUBTITLES.mov"
remux "assets/web/PROJECT/optimized/irrelevant-web.mp4"      "assets/original/IRRELEVANT/IRRELEVANT_DOCU_FINAL.MP4"
remux "assets/web/PROJECT/optimized/katarina-web.mp4"        "assets/original/KATARINA/albino.mp4"
remux "assets/web/PROJECT/optimized/mj-web.mp4"              "assets/original/MJ/MARIE JOE FILM WITH SUBTITLES.mp4"
remux "assets/web/PROJECT/optimized/naggiar-artist-web.mp4"  "assets/original/NAGGIAR ARTIST/OUISAM FINAL mp4.mp4"
remux "assets/web/PROJECT/optimized/naggiar-film-web.mp4"    "assets/original/NAGGIAR FILM/NAGGIAR_4K_FINAL01_.MP4"
remux "assets/web/PROJECT/optimized/oil-gaz-web.mp4"         "assets/original/OIL&GAZ/GENERAL OIL&GAZ.mp4"
remux "assets/web/PROJECT/optimized/orient-web.mp4"          "assets/original/ORIENT/CITY VIEW.mp4"
remux "assets/web/PROJECT/optimized/pop-up-web.mp4"          "assets/original/POP UP/MAN.mp4"
remux "assets/web/PROJECT/optimized/sami-web.mp4"            "assets/original/SAMI/final sami.mp4"
remux "assets/web/PROJECT/optimized/saras-bag-web.mp4"       "assets/original/SARA'S BAG/HORIZONTAL WITHOUT BARS WITH SUBTITLES .mp4"
remux "assets/web/PROJECT/optimized/saristique-web.mp4"      "assets/original/SARISTIQUE/FINAL OMDB SARI.mp4"
remux "assets/web/PROJECT/optimized/soar-web.mp4"            "assets/original/SOAR/SOAR_ESTHER_V4.mp4"
remux "assets/web/PROJECT/optimized/steakbar-sushi-web.mp4"  "assets/original/STEAKBAR SUSHI/vclassic 2025-07-16 183053.365.MOV"

echo "" | tee -a "$LOG"
echo "=== $(date '+%H:%M:%S') ALL DONE ===" | tee -a "$LOG"
ls -lh assets/web/PROJECT/optimized/*.mp4 | tee -a "$LOG"
