#!/bin/sh

set -euo pipefail

if [[ "$USER" == "root" ]]; then
  read -p "Username: " USER
fi
PKGBUILDS="/home/$USER/.builds"

for pkg in "$@"; do
  cd "$PKGBUILDS/$pkg"
  runuser -u "$USER" -- makepkg -sr
  pacman -U *.pkg.tar.zst
  cd "$PKGBUILDS"
done

pacman_conf="/etc/pacman.conf"
sed -i '/#IgnorePkg/s/#//' "$pacman_conf"
sed -i "/^IgnorePkg/s/=/= $@/" "$pacman_conf"
