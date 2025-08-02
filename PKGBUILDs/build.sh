#!/bin/sh

set -euo pipefail

PKGBUILDS="/home/$USER/.builds"
if [[ "$USER" == "root" ]]; then
  read -p "Username: " USER
fi

for pkg in "$@"; do
  cd "$PKGBUILDS/$pkg"
  runuser -u "$USER" -- makepkg -sr
  pacman -U *.pkg.tar.zst
  cd "$PKGBUILDS"
done

pacman_conf="/etc/pacman.conf"
sed -i '/#IgnorePkg/s/#//' "$pacman_conf"
sed -i "/^IgnorePkg/s/=/= $@/" "$pacman_conf"