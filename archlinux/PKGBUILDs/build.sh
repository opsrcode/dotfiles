#!/bin/env bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <username> <pkg_name> [pkg_name...]" >&2
  exit 1
fi

TARGET_USER="$1"
shift

if ! id "$TARGET_USER" >/dev/null 2>&1 ; then
  echo "Error: User '$TARGET_USER' doees not exist." >&2
  exit 1
fi

PKGBUILDS_DIR="/home/$TARGET_USER/.cache/builds"
PACMAN_CONFIG='/etc/pacman.conf'

sed -i '/#IgnorePkg/s/#//' "$PACMAN_CONFIG"
for pkg in "$@"; do
  PKG_DIR="$PKGBUILDS_DIR/$pkg"
  if [ ! -d "$PKG_DIR" ]; then
    echo "Warning: Directory for package '$pkg' not found. Skipping." >&2
    continue
  fi

  cd "$PKG_DIR"
  runuser -u "$TARGET_USER" -- makepkg -sri --noconfirm
  sed -i "/^IgnorePkg/s/=/= $pkg/" "$PACMAN_CONFIG"
done
