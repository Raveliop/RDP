#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ASSETS="$REPO_ROOT/assets"
# Generate assets first
"$REPO_ROOT/scripts/branding/generate_assets.sh"

# Target root (chroot) or overlay directory
TARGET_ROOT="${TARGET_ROOT:-}"
if [[ -z "${TARGET_ROOT}" ]]; then
  TARGET_ROOT="$REPO_ROOT/root-overlay"
fi
mkdir -p "$TARGET_ROOT"

# KDE: color scheme
install -d "$TARGET_ROOT/usr/share/color-schemes"
install -m 0644 "$ASSETS/kde/colors/Kernelos.colors" "$TARGET_ROOT/usr/share/color-schemes/Kernelos.colors"

# KDE: Look-and-Feel package
install -d "$TARGET_ROOT/usr/share/plasma/look-and-feel/org.kernelos.desktop/contents/splash"
install -m 0644 "$ASSETS/kde/lookandfeel/org.kernelos.desktop/metadata.desktop" "$TARGET_ROOT/usr/share/plasma/look-and-feel/org.kernelos.desktop/metadata.desktop"
install -m 0644 "$ASSETS/kde/lookandfeel/org.kernelos.desktop/contents/defaults" "$TARGET_ROOT/usr/share/plasma/look-and-feel/org.kernelos.desktop/contents/defaults"
install -m 0644 "$ASSETS/kde/lookandfeel/org.kernelos.desktop/contents/splash/Splash.qml" "$TARGET_ROOT/usr/share/plasma/look-and-feel/org.kernelos.desktop/contents/splash/Splash.qml"
cp -f "$ASSETS/calamares/branding/kernelos/logo.png" "$TARGET_ROOT/usr/share/plasma/look-and-feel/org.kernelos.desktop/contents/splash/logo.png" || true

# Wallpapers
install -d "$TARGET_ROOT/usr/share/wallpapers/KernelosDark/contents/images"
install -m 0644 "$ASSETS/wallpapers/kernelos-dark-3840x2160.jpg" "$TARGET_ROOT/usr/share/wallpapers/KernelosDark/contents/images/3840x2160.jpg"

# Default KDE for new users
install -d "$TARGET_ROOT/etc/skel/.config"
cat > "$TARGET_ROOT/etc/skel/.config/kdeglobals" <<'EOF'
[General]
ColorScheme=Kernelos

[Icons]
Theme=breeze-dark

[KDE]
LookAndFeelPackage=org.kernelos.desktop
EOF
cat > "$TARGET_ROOT/etc/skel/.config/kcminputrc" <<'EOF'
[Mouse]
cursorTheme=Breeze
cursorSize=24
EOF

# SDDM theme
install -d "$TARGET_ROOT/usr/share/sddm/themes/kernelos"
install -m 0644 "$ASSETS/sddm/theme/theme.conf" "$TARGET_ROOT/usr/share/sddm/themes/kernelos/theme.conf"
install -m 0644 "$ASSETS/sddm/theme/Main.qml" "$TARGET_ROOT/usr/share/sddm/themes/kernelos/Main.qml"
install -m 0644 "$ASSETS/sddm/theme/background.jpg" "$TARGET_ROOT/usr/share/sddm/themes/kernelos/background.jpg"
install -m 0644 "$ASSETS/sddm/theme/logo.png" "$TARGET_ROOT/usr/share/sddm/themes/kernelos/logo.png"
install -d "$TARGET_ROOT/etc/sddm.conf.d"
cat > "$TARGET_ROOT/etc/sddm.conf.d/10-kernelos.conf" <<'EOF'
[Theme]
Current=kernelos
EOF

# Calamares branding
install -d "$TARGET_ROOT/usr/share/calamares/branding/kernelos"
install -m 0644 "$ASSETS/calamares/branding/kernelos/branding.desc" "$TARGET_ROOT/usr/share/calamares/branding/kernelos/branding.desc"
install -m 0644 "$ASSETS/calamares/branding/kernelos/banner.jpg" "$TARGET_ROOT/usr/share/calamares/branding/kernelos/banner.jpg"
install -m 0644 "$ASSETS/calamares/branding/kernelos/logo.png" "$TARGET_ROOT/usr/share/calamares/branding/kernelos/logo.png"
install -m 0644 "$ASSETS/calamares/branding/kernelos/slideshow.qml" "$TARGET_ROOT/usr/share/calamares/branding/kernelos/slideshow.qml"
install -d "$TARGET_ROOT/etc/calamares"
# Minimal settings to enforce branding name
if [[ ! -f "$TARGET_ROOT/etc/calamares/settings.conf" ]]; then
cat > "$TARGET_ROOT/etc/calamares/settings.conf" <<'EOF'
---
branding: kernelos
EOF
fi

# GRUB theme
install -d "$TARGET_ROOT/boot/grub/themes/kernelos"
install -m 0644 "$ASSETS/grub/kernelos/background.jpg" "$TARGET_ROOT/boot/grub/themes/kernelos/background.jpg"
install -m 0644 "$ASSETS/grub/kernelos/theme.txt" "$TARGET_ROOT/boot/grub/themes/kernelos/theme.txt"
install -m 0644 "$ASSETS/grub/kernelos/logo-256.png" "$TARGET_ROOT/boot/grub/themes/kernelos/logo-256.png"
install -d "$TARGET_ROOT/etc/default/grub.d"
cat > "$TARGET_ROOT/etc/default/grub.d/10_kernelos_theme.cfg" <<'EOF'
GRUB_THEME="/boot/grub/themes/kernelos/theme.txt"
EOF

printf "Branding applied to %s\n" "$TARGET_ROOT"
