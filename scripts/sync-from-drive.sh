#!/usr/bin/env bash
# Rebuild this guide's asset folders from a fresh download of the source Google Drive folder:
#   https://drive.google.com/drive/folders/1s5_IJSWL6yyM9jm3GTN6jFuWez9vx468
#
# Usage:
#   scripts/sync-from-drive.sh --check <unzipped-drive-folder>   # report changes only, modify nothing
#   scripts/sync-from-drive.sh <unzipped-drive-folder>           # report, then rebuild managed folders
#
# <unzipped-drive-folder> is the folder that contains "CoolBitX brand assets" and "CoolWallet brand assets".
#
# Managed (regenerated: never hand-edit): logos/  fonts/montserrat/  fonts/barlow/  images/
#   reference/brand-guides/  reference/ad-banners/  reference/source-manifest.tsv
# Hand-written (never touched): AGENTS.md README.md CLAUDE.md LICENSE tokens/ fonts/fonts.css
#   reference/product-specs.md examples/ scripts/
#
# Requires: bash, ImageMagick 7 (`magick`), poppler (`pdftoppm`), unzip, shasum or sha256sum.
set -euo pipefail

CHECK=0
if [[ ${1:-} == --check ]]; then CHECK=1; shift; fi
[[ $# -eq 1 && -d $1 ]] || { echo "usage: $0 [--check] <unzipped-drive-folder>" >&2; exit 2; }
SRC=$(cd "$1" && pwd)
ROOT=$(cd "$(dirname "$0")/.." && pwd)
CBX="$SRC/CoolBitX brand assets"
CW="$SRC/CoolWallet brand assets"
[[ -d $CBX && -d $CW ]] || { echo "error: expected 'CoolBitX brand assets' and 'CoolWallet brand assets' in $SRC" >&2; exit 1; }
for t in magick pdftoppm unzip; do command -v "$t" >/dev/null || { echo "error: missing tool: $t" >&2; exit 1; }; done
if command -v sha256sum >/dev/null; then SHA=(sha256sum); else SHA=(shasum -a 256); fi

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/cbx-sync.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT
export MAGICK_TEMPORARY_PATH="$STAGE"
USED="$STAGE/.used"; : > "$USED"
MISSING=0

# Source files that are deliberately not part of the guide (see AGENTS.md section 9).
is_ignored() {
  case "$1" in
    *.mp4|*.MP4|*.mov|*.MOV|*.ai|*/.DS_Store|*/__MACOSX/*) return 0 ;;
    "CoolWallet brand assets/Document/"*) return 0 ;;
    *"Customized Card Design Guideline"*) return 0 ;;
    "CoolBitX brand assets/Photos/"*) return 0 ;;
    *"/Getting Started.pdf"|*"/Recovery Card.pdf") return 0 ;;
  esac
  return 1
}

# ---------------------------------------------------------------- 1. manifest diff
NEW_MANIFEST="$STAGE/source-manifest.tsv"
OLD_MANIFEST="$ROOT/reference/source-manifest.tsv"
( cd "$SRC" && find "CoolBitX brand assets" "CoolWallet brand assets" -type f ! -name .DS_Store ! -path '*/__MACOSX/*' -print0 \
    | sort -z | while IFS= read -r -d '' f; do
        h=$("${SHA[@]}" "$f" | cut -c1-64); s=$(wc -c < "$f" | tr -d ' ')
        printf '%s\t%s\t%s\n' "$h" "$s" "$f"
      done ) > "$NEW_MANIFEST"

echo "== Changes since last sync"
if [[ -f $OLD_MANIFEST ]]; then
  awk -F'\t' 'NR==FNR { if ($0 !~ /^#/) old[$3]=$1; next }
              { new[$3]=$1 }
              END {
                for (p in new) if (!(p in old)) print "ADDED    " p; else if (old[p] != new[p]) print "CHANGED  " p
                for (p in old) if (!(p in new)) print "REMOVED  " p
              }' "$OLD_MANIFEST" "$NEW_MANIFEST" | sort -k2 > "$STAGE/changes.txt"
  if [[ -s $STAGE/changes.txt ]]; then cat "$STAGE/changes.txt"; else echo "(none: the Drive folder matches the last sync)"; fi
else
  echo "(no previous manifest: first sync)"
  : > "$STAGE/changes.txt"
fi

# ---------------------------------------------------------------- helpers
slug() { # "300 x 600 – Half Page (Large Skyscraper)" -> "300-x-600-half-page-large-skyscraper"
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[[:space:]_–]+/-/g; s/[()]//g; s/\.+/./g; s/-+/-/g; s/-\././g; s/^[-.]+//; s/[-.]+$//'
}
# Renames chosen for readability; keep in sync with files referenced in AGENTS.md / examples/.
rename_rule() {
  sed -E 's/^cwp-background-removed/cwp-cutout/;
          s/^coolwallet-pro-supports-in-app-nft-functions$/cwp-in-app-nft/;
          s/^coolwallet-pro-s$/cwp-and-cws-together/;
          s/^([0-9]+)-x-([0-9]+)-/\1x\2-/; s/-large-skyscraper$//'
}
use() { # record a source as consumed; warn if it no longer exists
  if [[ -f $1 ]]; then printf '%s\n' "${1#"$SRC"/}" >> "$USED"; return 0; fi
  echo "MISSING  ${1#"$SRC"/}  (expected by this script; was it renamed on Drive?)" >&2
  MISSING=$((MISSING + 1)); return 1
}
cpy() { if use "$1"; then mkdir -p "$(dirname "$2")"; cp "$1" "$2"; fi; }
recolor() { [[ -f $1 ]] && sed -E "s/$2/$3/g" "$1" > "$4" || true; } # src from to dest

if (( CHECK )); then
  # dry pass: only collect which sources the build would consume, to report unmapped files
  cpy() { use "$1" || true; }
  recolor() { :; }
fi

O="$STAGE/out"; mkdir -p "$O"

# ---------------------------------------------------------------- 2. logos
L="$O/logos"
cpy "$CBX/logo/svg./CoolBitX_logo.svg"           "$L/coolbitx/coolbitx-logo-gold.svg"
recolor "$L/coolbitx/coolbitx-logo-gold.svg" '#AF9241' '#000000' "$L/coolbitx/coolbitx-logo-black.svg"
recolor "$L/coolbitx/coolbitx-logo-gold.svg" '#AF9241' '#FFFFFF' "$L/coolbitx/coolbitx-logo-white.svg"
cpy "$CBX/logo/png/CoolBitX_logo_Gold.png"       "$L/coolbitx/coolbitx-logo-gold.png"
cpy "$CBX/logo/png/CoolBitX_logo_black.png"      "$L/coolbitx/coolbitx-logo-black.png"
cpy "$CBX/logo/png/CoolBitX_logo_white.png"      "$L/coolbitx/coolbitx-logo-white.png"

D="$CW/Logo/CoolWallet "   # note: the Drive folder name has a trailing space
cpy "$D/svg./CW.svg"                 "$L/coolwallet/coolwallet-horizontal-dark.svg"
cpy "$D/svg./CW_mono_vertical.svg"   "$L/coolwallet/coolwallet-vertical-dark.svg"
cpy "$D/svg./CW_font.svg"            "$L/coolwallet/coolwallet-wordmark-dark.svg"
cpy "$D/Shield logo.svg"             "$L/coolwallet/coolwallet-shield-dark.svg"
cpy "$D/Shield White.svg"            "$L/coolwallet/coolwallet-shield-white.svg"
for v in horizontal vertical wordmark; do
  recolor "$L/coolwallet/coolwallet-$v-dark.svg" '#1[aA]1[aA]1[aA]' '#FFFFFF' "$L/coolwallet/coolwallet-$v-white.svg"
done
# 2025 guide "Darkmode": yellow wordmark (no shield) on navy #1C324A.
recolor "$L/coolwallet/coolwallet-wordmark-dark.svg" '#1[aA]1[aA]1[aA]' '#F7B419' "$L/coolwallet/coolwallet-wordmark-yellow.svg"
cpy "$D/png/CW logo dark horizontal.png"  "$L/coolwallet/coolwallet-horizontal-dark.png"
cpy "$D/png/CW logo white horizontal.png" "$L/coolwallet/coolwallet-horizontal-white.png"
cpy "$D/png/CW logo dark vertical.png"    "$L/coolwallet/coolwallet-vertical-dark.png"
cpy "$D/png/CW logo white vertical.png"   "$L/coolwallet/coolwallet-vertical-white.png"
cpy "$D/png/CW logo dark font.png"        "$L/coolwallet/coolwallet-wordmark-dark.png"
cpy "$D/png/CW logo white font.png"       "$L/coolwallet/coolwallet-wordmark-white.png"
cpy "$D/shield logo.png"                  "$L/coolwallet/coolwallet-shield-dark.png"
cpy "$D/Shield White.png"                 "$L/coolwallet/coolwallet-shield-white.png"

# Pro: the Drive's SVG and PNG numbering disagree; mapped by aspect ratio (verified 2026-11-08).
P="$CW/Logo/CoolWallet Pro"
cpy "$P/svg/CWP2.svg"         "$L/coolwallet-pro/coolwallet-pro-horizontal-gold.svg"
cpy "$P/svg/CWP_vertical.svg" "$L/coolwallet-pro/coolwallet-pro-vertical-gold.svg"
cpy "$P/svg/CWP1.svg"         "$L/coolwallet-pro/coolwallet-pro-wordmark-gold.svg"
cpy "$P/svg/CWP_Sliver1.svg"  "$L/coolwallet-pro/coolwallet-pro-horizontal-silver.svg"
cpy "$P/svg/CWP_Sliver2.svg"  "$L/coolwallet-pro/coolwallet-pro-vertical-silver.svg"
cpy "$P/svg/CWP_Sliver3.svg"  "$L/coolwallet-pro/coolwallet-pro-wordmark-silver.svg"
cpy "$P/png/CWP1.png"         "$L/coolwallet-pro/coolwallet-pro-horizontal-gold.png"
cpy "$P/png/CWP2.png"         "$L/coolwallet-pro/coolwallet-pro-vertical-gold.png"
cpy "$P/png/CWP3.png"         "$L/coolwallet-pro/coolwallet-pro-wordmark-gold.png"
cpy "$P/png/CWP_Sliver2.png"  "$L/coolwallet-pro/coolwallet-pro-horizontal-silver.png"
cpy "$P/png/CWP_Sliver1.png"  "$L/coolwallet-pro/coolwallet-pro-vertical-silver.png"
cpy "$P/png/CWP_Sliver3.png"  "$L/coolwallet-pro/coolwallet-pro-wordmark-silver.png"

Q="$CW/Logo/CoolWallet S"
cpy "$Q/svg/CWS_logo.svg"               "$L/coolwallet-s-legacy/coolwallet-s-horizontal-yellow.svg"
cpy "$Q/png/CWS_Logo.png"               "$L/coolwallet-s-legacy/coolwallet-s-horizontal-yellow.png"
cpy "$Q/png/CWS_Logo_Vertical_Gold.png" "$L/coolwallet-s-legacy/coolwallet-s-vertical-yellow.png"

# ---------------------------------------------------------------- 3. fonts (upright 300-700)
for z in Montserrat Barlow; do
  zip="$CW/Fonts/$z.zip"
  use "$zip" || continue
  (( CHECK )) && continue
  lc=$(slug "$z"); mkdir -p "$O/fonts/$lc"
  for w in Light Regular Medium SemiBold Bold; do
    member=$(unzip -Z1 "$zip" | grep -v '__MACOSX\|/\._' | grep -E "(^|/)$z-$w\.ttf$" | head -1 || true)
    if [[ -n $member ]]; then unzip -o -j -q "$zip" "$member" -d "$O/fonts/$lc"
    else echo "WARN     $z-$w.ttf not found in $z.zip" >&2; fi
  done
  lic=$(unzip -Z1 "$zip" | grep -E '(^|/)OFL\.txt$' | head -1 || true)
  if [[ -n $lic ]]; then unzip -o -j -q "$zip" "$lic" -d "$O/fonts/$lc"
  # The OFL requires the license beside every copy; the Drive's Montserrat.zip ships without it.
  elif [[ -f "$ROOT/scripts/font-licenses/$z-OFL.txt" ]]; then cp "$ROOT/scripts/font-licenses/$z-OFL.txt" "$O/fonts/$lc/OFL.txt"
  else echo "WARN     no OFL.txt for $z: add scripts/font-licenses/$z-OFL.txt" >&2; fi
done

# ---------------------------------------------------------------- 4. images
put_img() { # src destdir: cap 2000 px, opaque PNG -> JPG q85, transparent PNG stays PNG
  local src="$1" dst="$2" base ext
  use "$src" || return 0
  (( CHECK )) && return 0
  mkdir -p "$dst"
  base=$(slug "$(basename "${src%.*}")" | rename_rule); ext=$(printf '%s' "${src##*.}" | tr '[:upper:]' '[:lower:]')
  if [[ $ext == png && $(magick "$src" -format '%[opaque]' info:) != [Tt]rue ]]; then
    magick "$src" -resize '2000x2000>' -strip -define png:compression-level=9 "$dst/$base.png"
  else
    magick "$src" -resize '2000x2000>' -background white -flatten -strip -quality 85 -sampling-factor 4:2:0 "$dst/$base.jpg"
  fi
}
img_dir() { # source-dir dest-dir (non-recursive)
  [[ -d $1 ]] || { echo "MISSING  ${1#"$SRC"/}/" >&2; MISSING=$((MISSING + 1)); return 0; }
  while IFS= read -r -d '' f; do put_img "$f" "$2"; done \
    < <(find "$1" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0 | sort -z)
}
PIC="$CW/CoolWallet Pictures"
img_dir "$PIC/CoolWallet Pro Pictures"                    "$O/images/coolwallet-pro/lifestyle"
img_dir "$PIC/CoolWallet Pro Pictures/Box"                "$O/images/coolwallet-pro/unboxing"
img_dir "$PIC/CoolWallet Pro Pictures/Background Removed" "$O/images/coolwallet-pro/cutout"
img_dir "$PIC/CoolWallet Pro Pictures/Press"              "$O/images/coolwallet-pro/press"
img_dir "$PIC/CoolWallet S Pictures"                      "$O/images/coolwallet-s-legacy/lifestyle"
img_dir "$PIC/CoolWallet S Pictures/Box"                  "$O/images/coolwallet-s-legacy/unboxing"
img_dir "$PIC/CoolWallet S Pictures/Background Removed"   "$O/images/coolwallet-s-legacy/cutout"

# ---------------------------------------------------------------- 5. reference
guide() { # src-pdf dest-basename
  use "$1" || return 0
  (( CHECK )) && return 0
  mkdir -p "$O/reference/brand-guides"
  cp "$1" "$O/reference/brand-guides/$2.pdf"
  pdftoppm -png -singlefile -scale-to 1600 "$1" "$O/reference/brand-guides/$2"
  magick "$O/reference/brand-guides/$2.png" -strip -define png:compression-level=9 "$O/reference/brand-guides/$2.png"
}
guide "$CBX/CoolBitX_BrandGuide.pdf"       coolbitx-brand-guide-2020
guide "$CW/2025 New Brand Guidelines.pdf"  coolwallet-brand-guide-2025
guide "$CW/CoolWallet_BrandGuide_old.pdf"  coolwallet-brand-guide-2020-legacy

banner_dir() { # source-dir dest-dir
  [[ -d $1 ]] || { echo "MISSING  ${1#"$SRC"/}/" >&2; MISSING=$((MISSING + 1)); return 0; }
  while IFS= read -r -d '' f; do
    use "$f" || continue
    (( CHECK )) && continue
    mkdir -p "$2"; cp "$f" "$2/$(slug "$(basename "${f%.*}")" | rename_rule).png"
  done < <(find "$1" -maxdepth 1 -type f -iname '*.png' -print0 | sort -z)
}
banner_dir "$CW/Google AD banner/CoolWallet "    "$O/reference/ad-banners/coolwallet"
banner_dir "$CW/Google AD banner/CoolWallet Pro" "$O/reference/ad-banners/coolwallet-pro"

# ---------------------------------------------------------------- 6. unmapped report
echo
echo "== Source files this script does not use (new assets need a decision)"
cut -f3 "$NEW_MANIFEST" | while IFS= read -r p; do
  grep -qxF "$p" "$USED" && continue
  is_ignored "$p" && continue
  echo "UNMAPPED $p"
done | tee "$STAGE/unmapped.txt"
[[ -s $STAGE/unmapped.txt ]] || echo "(none)"
(( MISSING )) && echo && echo "WARNING: $MISSING expected source file(s) missing (see MISSING lines above)." >&2

# Changed files that need a human or agent follow-up, beyond the rebuild.
echo
echo "== Follow-up needed"
follow=0
if grep -qE 'BrandGuide|Brand Guidelines' "$STAGE/changes.txt"; then
  echo "- A brand guide changed: compare reference/brand-guides/*.png with tokens/tokens.css, tokens/tokens.json and AGENTS.md sections 4-6."; follow=1; fi
if grep -q 'spec_sheet' "$STAGE/changes.txt"; then
  echo "- A spec sheet changed: re-transcribe reference/product-specs.md from the PDF in the Drive download."; follow=1; fi
if grep -q '/Logo/\|/logo/' "$STAGE/changes.txt"; then
  echo "- Logo files changed: check the logo contact sheet in examples/index.html renders correctly."; follow=1; fi
(( follow )) || echo "(none)"

if (( CHECK )); then echo; echo "--check: nothing was modified."; exit 0; fi

# ---------------------------------------------------------------- 7. image index + contact sheets
FONT="$O/fonts/barlow/Barlow-Medium.ttf"; [[ -f $FONT ]] || FONT=""
{
  echo "# Image index"
  echo
  echo "Generated by scripts/sync-from-drive.sh. Do not edit by hand. Images are capped at 2000 px on the long edge."
  echo
  echo "- **Tone** = mean luminance: use \`dark\` photos in dark/navy sections and \`light\` photos in light sections; \`mid\` can work in either, but check it."
  echo "- **cutout** = transparent PNG, which works on any surface color."
  echo "- To see them all at once, open \`contact-sheet.jpg\` in each product folder (labeled with file names)."
  echo "- \`coolwallet-s-legacy\` shows a discontinued product. Use it only when the page is about CoolWallet S."
  echo
  for prod in coolwallet-pro coolwallet-s-legacy; do
    [[ -d $O/images/$prod ]] || continue
    echo "## $prod"; echo
    echo "| File | Size (px) | Tone |"; echo "|---|---|---|"
    files=()
    while IFS= read -r f; do files+=("$f"); done < <(cd "$O/images" && find "$prod" -type f \( -name '*.jpg' -o -name '*.png' \) | sort -V)
    for f in "${files[@]}"; do
      p="$O/images/$f"
      wh=$(magick "$p" -format '%w×%h' info:)
      if [[ $(magick "$p" -format '%[opaque]' info:) != [Tt]rue ]]; then t=cutout
      else m=$(magick "$p" -colorspace Gray -format '%[fx:int(mean*100)]' info:)
        if (( m < 35 )); then t=dark; elif (( m > 65 )); then t=light; else t=mid; fi
      fi
      echo "| \`$f\` | $wh | $t |"
    done
    echo
    ( cd "$O/images" && magick montage ${FONT:+-font "$FONT"} -pointsize 14 -fill '#1B202A' -background '#E6E6E6' \
        -label '%t' "${files[@]}" -geometry 240x160+6+6 -tile 7x -quality 80 "$prod/contact-sheet.jpg" )
  done
} > "$O/images/INDEX.md"

# ---------------------------------------------------------------- 8. swap into place
remove() { if command -v trash >/dev/null; then trash "$@"; else rm -rf "$@"; fi; }
for d in logos fonts/montserrat fonts/barlow images reference/brand-guides reference/ad-banners; do
  [[ -d $O/$d ]] || { echo "skip $d (nothing built)" >&2; continue; }
  [[ -e $ROOT/$d ]] && remove "$ROOT/$d"
  mkdir -p "$(dirname "$ROOT/$d")"
  mv "$O/$d" "$ROOT/$d"
done
{ echo "# sha256	bytes	path   (source files at last sync: $(date +%F); written by scripts/sync-from-drive.sh)"; cat "$NEW_MANIFEST"; } \
  > "$ROOT/reference/source-manifest.tsv"
echo
echo "Synced. Guide size: $(du -sh "$ROOT" | cut -f1). Next: update 'Last synced' in AGENTS.md and open examples/index.html."
