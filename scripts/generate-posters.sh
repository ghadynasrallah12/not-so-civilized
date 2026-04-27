#!/bin/bash
# Generate small poster JPEG from frame 0 of each project source video.
# Used as the <video poster="..."> so cards/detail show an image instantly,
# even before the video bytes arrive.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

OUTDIR="assets/web/PROJECT/optimized/posters"
mkdir -p "$OUTDIR"

poster() {
  local src="$1"
  local out="$2"
  if [ ! -f "$src" ]; then
    echo "MISSING SOURCE: $src"
    return 1
  fi
  ffmpeg -y -hide_banner -loglevel error \
    -ss 0 -i "$src" -frames:v 1 \
    -vf "scale='if(gt(iw,ih),min(1280,iw),-2)':'if(gt(iw,ih),-2,min(1280,ih))':flags=lanczos" \
    -q:v 6 \
    "$out"
  ls -lh "$out" | awk '{print $5, $9}'
}

poster "assets/web/PROJECT/AKI/p1.mp4"                                "$OUTDIR/aki.jpg"
poster "assets/web/PROJECT/AKIKI/FILM 1.mp4"                          "$OUTDIR/akiki.jpg"
poster "assets/web/PROJECT/BEIT TRAD/BEIT TRAD COLORED.mp4"           "$OUTDIR/beit-trad.jpg"
poster "assets/web/PROJECT/BESH/2.mp4"                                "$OUTDIR/besh.jpg"
poster "assets/web/PROJECT/BOKJA/BOKJA WEDESIGN.mp4"                  "$OUTDIR/bokja.jpg"
poster "assets/web/PROJECT/ELISSAR/ELISSAR KANSO FIL FINAL WITH SUBTITLES.mov" "$OUTDIR/elissar.jpg"
poster "assets/web/PROJECT/IRRELEVANT/IRRELEVANT_DOCU_FINAL.MP4"      "$OUTDIR/irrelevant.jpg"
poster "assets/web/PROJECT/KATARINA/albino.mp4"                       "$OUTDIR/katarina.jpg"
poster "assets/web/PROJECT/MJ/MARIE JOE FILM WITH SUBTITLES.mp4"      "$OUTDIR/mj.jpg"
poster "assets/web/PROJECT/NAGGIAR ARTIST/OUISAM FINAL mp4.mp4"       "$OUTDIR/naggiar-artist.jpg"
poster "assets/web/PROJECT/NAGGIAR FILM/NAGGIAR_4K_FINAL01_.MP4"      "$OUTDIR/naggiar-film.jpg"
poster "assets/web/PROJECT/OIL&GAZ/GENERAL OIL&GAZ.mp4"               "$OUTDIR/oil-gaz.jpg"
poster "assets/web/PROJECT/ORIENT/CITY VIEW.mp4"                      "$OUTDIR/orient.jpg"
poster "assets/web/PROJECT/POP UP/MAN.mp4"                            "$OUTDIR/pop-up.jpg"
poster "assets/web/PROJECT/SAMI/final sami.mp4"                       "$OUTDIR/sami.jpg"
poster "assets/web/PROJECT/SARA'S BAG/HORIZONTAL WITHOUT BARS WITH SUBTITLES .mp4" "$OUTDIR/saras-bag.jpg"
poster "assets/web/PROJECT/SARISTIQUE/FINAL OMDB SARI.mp4"            "$OUTDIR/saristique.jpg"
poster "assets/web/PROJECT/SOAR/SOAR_ESTHER_V4.mp4"                   "$OUTDIR/soar.jpg"
poster "assets/web/PROJECT/STEAKBAR SUSHI/vclassic 2025-07-16 183053.365.MOV" "$OUTDIR/steakbar-sushi.jpg"

echo ""
echo "All posters generated."
