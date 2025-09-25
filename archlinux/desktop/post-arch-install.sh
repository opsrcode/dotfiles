#!/bin/env bash

set -euo pipefail

cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service

ufw default deny incoming
systemctl enable ufw.service
ufw enable

mkinitcpio -P

pacman -Syyuu --noconfirm
pacman -Rns "$(pacman -Qdtq)" --noconfirm
rm -rf ~/.cache/* /var/cache/pacman/pkg/*
