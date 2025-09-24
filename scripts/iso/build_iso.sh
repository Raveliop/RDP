#!/usr/bin/env bash
set -euo pipefail
ARCH=${ARCH:-${1:-amd64}}
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WORK_DIR="$REPO_ROOT/../out/work/${ARCH}"
ROOTFS="$WORK_DIR/chroot"
ISO_DIR="$REPO_ROOT/../out/iso/${ARCH}"
STAGING="$ISO_DIR/staging"
mkdir -p "$ISO_DIR" "$STAGING/casper" "$STAGING/boot/grub"
chroot "$ROOTFS" bash -euo pipefail -c "update-initramfs -u"
KERNEL_PATH=$(chroot "$ROOTFS" bash -c 'ls -1t /boot/vmlinuz-* | head -n1')
INITRD_PATH=$(chroot "$ROOTFS" bash -c 'ls -1t /boot/initrd.img-* | head -n1')
cp -f "$ROOTFS/${KERNEL_PATH#/}" "$STAGING/casper/vmlinuz"
cp -f "$ROOTFS/${INITRD_PATH#/}" "$STAGING/casper/initrd"
EXCLUDES=(/boot /proc /sys /dev /run /tmp)
mksquashfs "$ROOTFS" "$STAGING/casper/filesystem.squashfs" -noappend -comp zstd -e boot proc sys dev run tmp || mksquashfs "$ROOTFS" "$STAGING/casper/filesystem.squashfs" -noappend -e boot proc sys dev run tmp
cat > "$STAGING/boot/grub/grub.cfg" <<'EOF'
set default=0
set timeout=5
menuentry "KERNELOS Live" {
  linux /casper/vmlinuz boot=casper quiet splash ---
  initrd /casper/initrd
}
EOF
ISO_NAME="kernelos-24.04-${ARCH}.iso"
VOLID="KERNELOS_24_04_${ARCH^^}"
if [[ "$ARCH" == "amd64" ]]; then
  grub-mkrescue -o "$ISO_DIR/$ISO_NAME" "$STAGING" --xorriso=xorriso --compress=xz || grub-mkrescue -o "$ISO_DIR/$ISO_NAME" "$STAGING"
else
  grub-mkrescue -o "$ISO_DIR/$ISO_NAME" "$STAGING" -d /usr/lib/grub/arm64-efi --xorriso=xorriso --compress=xz || grub-mkrescue -o "$ISO_DIR/$ISO_NAME" "$STAGING" -d /usr/lib/grub/arm64-efi
fi
sha256sum "$ISO_DIR/$ISO_NAME" | awk '{print $1}' > "$ISO_DIR/$ISO_NAME.sha256"
