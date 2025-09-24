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
chroot "$ROOTFS" bash -euo pipefail -c "apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y locales tzdata gnupg ca-certificates"
chroot "$ROOTFS" bash -euo pipefail -c "locale-gen fr_FR.UTF-8 && update-locale LANG=fr_FR.UTF-8"
chroot "$ROOTFS" bash -euo pipefail -c "echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections; echo 'tzdata tzdata/Zones/Europe select Paris' | debconf-set-selections; dpkg-reconfigure -f noninteractive tzdata"
cat > "$ROOTFS/etc/default/keyboard" <<EOF
XKBMODEL=pc105
XKBLAYOUT=fr
XKBVARIANT=oss
XKBOPTIONS=
EOF
chroot "$ROOTFS" bash -euo pipefail -c "apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo systemd-sysv network-manager dbus-user-session rsync curl wget"
chroot "$ROOTFS" bash -euo pipefail -c "DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-generic initramfs-tools squashfs-tools casper grub-pc-bin"
chroot "$ROOTFS" bash -euo pipefail -c "DEBIAN_FRONTEND=noninteractive apt-get install -y sddm kde-standard kde-config-sddm kde-graphics kde-multimedia kdeconnect plasma-desktop plasma-workspace plasma-discover plasma-nm konsole dolphin"
chroot "$ROOTFS" bash -euo pipefail -c "DEBIAN_FRONTEND=noninteractive apt-get install -y firefox libreoffice git docker.io docker-compose-plugin"
VSCODE_FLAVOR_ENV=${VSCODE_FLAVOR:-code}
if [[ "$VSCODE_FLAVOR_ENV" == "code" ]]; then
  chroot "$ROOTFS" bash -euo pipefail -c "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/usr/share/keyrings/microsoft.gpg && echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main' >/etc/apt/sources.list.d/vscode.list && apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y code"
else
  chroot "$ROOTFS" bash -euo pipefail -c "wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor >/usr/share/keyrings/vscodium.gpg && echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main' >/etc/apt/sources.list.d/vscodium.list && apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y codium"
fi
chroot "$ROOTFS" bash -euo pipefail -c "useradd -m -s /bin/bash kernelos || true; echo 'kernelos ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99-kernelos; passwd -d kernelos || true"
mkdir -p "$ROOTFS/etc/sddm.conf.d"
cat > "$ROOTFS/etc/sddm.conf.d/10-autologin.conf" <<EOF
[Autologin]
User=kernelos
Session=plasma.desktop
EOF
mkdir -p "$ROOTFS/opt/bytebot" "$ROOTFS/usr/share/applications"
cp -f "$REPO_ROOT/../bytebot/docker-compose.yml" "$ROOTFS/opt/bytebot/docker-compose.yml" || true
cp -f "$REPO_ROOT/../bytebot/systemd/bytebot.service" "$ROOTFS/etc/systemd/system/bytebot.service" || true
cp -f "$REPO_ROOT/../bytebot/desktop/bytebot.desktop" "$ROOTFS/usr/share/applications/bytebot.desktop" || true
bash "$REPO_ROOT/theme/apply.sh" TARGET_ROOT="$ROOTFS"
