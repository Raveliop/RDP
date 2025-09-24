#!/usr/bin/env bash
set -euo pipefail
ARCH=${ARCH:-${1:-amd64}}
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WORK_DIR="$REPO_ROOT/../out/work/${ARCH}"
ROOTFS="$WORK_DIR/chroot"
mountpoint -q "$ROOTFS/proc" || mount -t proc proc "$ROOTFS/proc"
mountpoint -q "$ROOTFS/sys" || mount -t sysfs sys "$ROOTFS/sys"
mountpoint -q "$ROOTFS/dev" || mount --bind /dev "$ROOTFS/dev"
mountpoint -q "$ROOTFS/run" || mount --bind /run "$ROOTFS/run"
trap 'umount -lf "$ROOTFS/proc" "$ROOTFS/sys" "$ROOTFS/dev" "$ROOTFS/run" 2>/dev/null || true' EXIT
if ! chroot "$ROOTFS" bash -euo pipefail -c "apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y calamares"; then
  echo "[WARN] calamares package not found on Ubuntu Noble; proceeding without installing it."
  # Provide a stub so the desktop entry doesn't break in Live
  cat > "$ROOTFS/usr/bin/calamares" <<'EOS'
#!/usr/bin/env bash
echo "Calamares n'est pas installé dans cette build."
exit 0
EOS
  chmod +x "$ROOTFS/usr/bin/calamares"
fi
install -d "$ROOTFS/usr/share/calamares/branding/kernelos"
rsync -a "$REPO_ROOT/../../assets/calamares/branding/kernelos/" "$ROOTFS/usr/share/calamares/branding/kernelos/"
cat > "$ROOTFS/usr/share/applications/calamares.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Calamares Installer
Exec=pkexec /usr/bin/calamares
Icon=system-software-install
Terminal=false
Categories=System;Utility;
EOF
install -d "$ROOTFS/etc/polkit-1/rules.d"
cat > "$ROOTFS/etc/polkit-1/rules.d/10-calamares.rules" <<'EOF'
polkit.addRule(function(action, subject) {
  if (subject.isInGroup("sudo") && action.id.indexOf("org.freedesktop.policykit.exec") == 0) {
    return polkit.Result.YES;
  }
});
EOF
