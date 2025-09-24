#!/usr/bin/env bash
set -euo pipefail
ARCH=${ARCH:-${1:-amd64}}
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WORK_DIR="$REPO_ROOT/../out/work/${ARCH}"
ROOTFS="$WORK_DIR/chroot"
MIRROR_AMD64="http://archive.ubuntu.com/ubuntu"
MIRROR_ARM64="http://ports.ubuntu.com/ubuntu-ports"
if [[ "$ARCH" == "amd64" ]]; then MIRROR="$MIRROR_AMD64"; DEBARCH=amd64; else MIRROR="$MIRROR_ARM64"; DEBARCH=arm64; fi
mkdir -p "$ROOTFS"
if [[ "$DEBARCH" == "arm64" ]]; then
  if [[ ! -e "$ROOTFS/debootstrap/debootstrap" && ! -e "$ROOTFS/etc/os-release" ]]; then
    debootstrap --arch=arm64 --foreign noble "$ROOTFS" "$MIRROR"
    install -D /usr/bin/qemu-aarch64-static "$ROOTFS/usr/bin/qemu-aarch64-static"
    chroot "$ROOTFS" /debootstrap/debootstrap --second-stage
  fi
else
  if [[ ! -e "$ROOTFS/etc/os-release" ]]; then
    debootstrap --arch=amd64 noble "$ROOTFS" "$MIRROR"
  fi
fi
cat > "$ROOTFS/etc/apt/sources.list" <<EOF
deb $MIRROR noble main restricted universe multiverse
deb $MIRROR noble-updates main restricted universe multiverse
deb $MIRROR noble-security main restricted universe multiverse
EOF
printf "kernelos-live\n" > "$ROOTFS/etc/hostname"
cat > "$ROOTFS/etc/hosts" <<EOF
127.0.0.1 localhost
127.0.1.1 kernelos-live
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
EOF
mkdir -p "$ROOTFS/etc/resolvconf" || true
printf "nameserver 1.1.1.1\n" > "$ROOTFS/etc/resolv.conf"
