#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
SRC_DIR="$REPO_ROOT/assets/source"
OUT_LOGO="$REPO_ROOT/assets/logo.png"
OUT_LOGO_INV="$REPO_ROOT/assets/logo-invert.png"
ICON_DIR="$REPO_ROOT/assets/icons"
ICON_PNG_DIR="$ICON_DIR/png"
ICON_MAIN="$ICON_DIR/kernelos-icon.png"
WALL_DIR="$REPO_ROOT/assets/wallpapers"
SDDM_DIR="$REPO_ROOT/assets/sddm/theme"
CAL_DIR="$REPO_ROOT/assets/calamares/branding/kernelos"
GRUB_DIR="$REPO_ROOT/assets/grub/kernelos"
BG="#24292f"
ACCENT="#d8b9ff"
LOGO_PNG="$SRC_DIR/logo-original.png"
LOGO_SVG="$SRC_DIR/logo-original.svg"
# Optional external wallpaper override
WP_SRC=""
if [[ -f "$SRC_DIR/wallpaper-original.png" ]]; then WP_SRC="$SRC_DIR/wallpaper-original.png"; fi
if [[ -z "$WP_SRC" && -f "$SRC_DIR/wallpaper-original.jpg" ]]; then WP_SRC="$SRC_DIR/wallpaper-original.jpg"; fi
GEN_INVERT="${GENERATE_INVERT:-1}"
mkdir -p "$ICON_PNG_DIR" "$WALL_DIR" "$SDDM_DIR" "$CAL_DIR" "$GRUB_DIR"
need() { command -v "$1" >/dev/null 2>&1; }
if ! need convert; then echo "missing: imagemagick (convert)"; exit 1; fi
if ! need optipng; then echo "missing: optipng"; exit 1; fi
USE_SVG=0
if [[ -f "$LOGO_SVG" ]]; then USE_SVG=1; fi
if [[ $USE_SVG -eq 1 ]]; then echo "SVG detected but not required" >/dev/null; fi
if [[ ! -f "$LOGO_PNG" ]]; then echo "missing: $LOGO_PNG"; exit 1; fi
convert "$LOGO_PNG" -resize 2048x2048\> -strip PNG32:"$OUT_LOGO"
optipng -o7 -quiet "$OUT_LOGO" || true
if [[ "$GEN_INVERT" = "1" ]]; then convert "$OUT_LOGO" -alpha on -channel RGB -negate -channel A -evaluate set 100% +channel PNG32:"$OUT_LOGO_INV"; optipng -o7 -quiet "$OUT_LOGO_INV" || true; fi
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
TRIM="$TMP_DIR/trim.png"
convert "$OUT_LOGO" -alpha on -fuzz 5% -trim +repage PNG32:"$TRIM"
W=$(identify -format "%w" "$TRIM") || W=0
H=$(identify -format "%h" "$TRIM") || H=0
CROP_SRC="$TRIM"
if (( W > H*3/2 )); then convert "$TRIM" -crop "${H}x${H}+0+0" +repage "$TMP_DIR/crop.png"; CROP_SRC="$TMP_DIR/crop.png"; elif (( H > W*3/2 )); then convert "$TRIM" -crop "${W}x${W}+0+0" +repage "$TMP_DIR/crop.png"; CROP_SRC="$TMP_DIR/crop.png"; fi
convert "$CROP_SRC" -resize 819x819 -background none -gravity center -extent 1024x1024 PNG32:"$ICON_MAIN"
optipng -o7 -quiet "$ICON_MAIN" || true
for s in 512 256 128 64 32; do convert "$ICON_MAIN" -resize ${s}x${s} PNG32:"$ICON_PNG_DIR/${s}.png"; optipng -o7 -quiet "$ICON_PNG_DIR/${s}.png" || true; done
mk_wall() { local W=$1 H=$2 OUT=$3; if [[ -n "$WP_SRC" ]]; then convert "$WP_SRC" -auto-orient -resize ${W}x${H}^ -gravity center -extent ${W}x${H} "$TMP_DIR/wall.png"; else convert -size ${W}x${H} xc:"$BG" "$TMP_DIR/bg.png"; convert -size ${W}x${H} radial-gradient:#00000000-"$ACCENT" "$TMP_DIR/grad.png"; convert "$TMP_DIR/bg.png" "$TMP_DIR/grad.png" -compose softlight -define compose:args=25 -composite "$TMP_DIR/soft.png"; convert -size ${W}x${H} granite: -colorspace sRGB -brightness-contrast -15x-15 -alpha set -channel a -evaluate set 8% +channel "$TMP_DIR/tex.png"; convert "$TMP_DIR/soft.png" "$TMP_DIR/tex.png" -compose overlay -define compose:args=20 -composite "$TMP_DIR/wall.png"; fi; local LSIZE; if (( W < H )); then LSIZE=$(( W/4 )); else LSIZE=$(( H/4 )); fi; convert "$OUT_LOGO" -alpha on -resize ${LSIZE}x${LSIZE} "$TMP_DIR/logo_w.png"; composite -dissolve 8 -gravity center "$TMP_DIR/logo_w.png" "$TMP_DIR/wall.png" "$TMP_DIR/with_logo.png"; convert "$TMP_DIR/with_logo.png" -strip -quality 92 "$OUT"; };
mk_wall 3840 2160 "$WALL_DIR/kernelos-dark-3840x2160.jpg"
mk_wall 2560 1440 "$WALL_DIR/kernelos-dark-2560x1440.jpg"
mk_wall 1920 1080 "$WALL_DIR/kernelos-dark-1920x1080.jpg"
convert "$WALL_DIR/kernelos-dark-3840x2160.jpg" -resize 3840x2160 "$SDDM_DIR/background.jpg"
convert "$ICON_MAIN" -resize 256x256 PNG32:"$SDDM_DIR/logo.png"; optipng -o7 -quiet "$SDDM_DIR/logo.png" || true
convert "$WALL_DIR/kernelos-dark-1920x1080.jpg" -resize 1920x1080 "$GRUB_DIR/background.jpg"
convert "$ICON_MAIN" -resize 256x256 PNG32:"$GRUB_DIR/logo-256.png"; optipng -o7 -quiet "$GRUB_DIR/logo-256.png" || true
convert "$WALL_DIR/kernelos-dark-1920x1080.jpg" -resize 1600x300^ -gravity center -extent 1600x300 "$CAL_DIR/banner.jpg"
convert "$ICON_MAIN" -resize 256x256 PNG32:"$CAL_DIR/logo.png"; optipng -o7 -quiet "$CAL_DIR/logo.png" || true
