#!/usr/bin/env bash
set -euo pipefail
ARCH=${ARCH:-${1:-amd64}}
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
OUT_DIR="$REPO_ROOT/out/iso/${ARCH}"
STAGE="$OUT_DIR/stage"
mkdir -p "$OUT_DIR" "$STAGE"
cp -f "$REPO_ROOT/assets/wallpapers/kernelos-dark-3840x2160.jpg" "$STAGE/wallpaper.jpg" 2>/dev/null || true
printf "KERNELOS 24.04 LTS minimal ISO placeholder for %s\n" "$ARCH" > "$STAGE/README.txt"
ISO_NAME="kernelos-24.04-${ARCH}.iso"
xorriso -as mkisofs -iso-level 3 -volid "KERNELOS_24_04_${ARCH^^}" -output "$OUT_DIR/$ISO_NAME" "$STAGE"
sha256sum "$OUT_DIR/$ISO_NAME" | awk '{print $1}' > "$OUT_DIR/$ISO_NAME.sha256"
echo "$OUT_DIR/$ISO_NAME"