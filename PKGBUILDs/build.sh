#!/bin/sh

set -euo pipefail

PKGBUILDS="/home/$USER/.builds/"

for pkg in "$@"; do
  cd "$PKGBUILDS/$pkg"
  runuser -u "$USER" -- makepkg -sr
  pacman -U *.pkg.tar.zst
  cd "$PKGBUILDS"
done

pkgs="/^IgnorePkg/s/=/= $@/"
sed -i -e '/#IgnorePkg/s/#//' -e "$pkgs" /etc/pacman.conf
