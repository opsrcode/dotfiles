#!/bin/sh

set -euo pipefail

if [[ "$USER" == "root" ]]; then
  read -p "Username: " USER
fi
PKGBUILDS="/home/$USER/.builds"

pacman_conf="/etc/pacman.conf"
sed -i '/#IgnorePkg/s/#//' "$pacman_conf"
for pkg in "$@"; do
  cd "$PKGBUILDS/$pkg"
  runuser -u "$USER" -- makepkg -sr
  pacman -U *.pkg.tar.zst
  sed -i "/^IgnorePkg/s/=/= $pkg/" "$pacman_conf"
  cd "$PKGBUILDS"
done
