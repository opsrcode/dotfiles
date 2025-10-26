#!/bin/env bash

set -euo pipefail

ln -sf /usr/lib/systemd/network/89-ethernet.network.example \
       /etc/systemd/network/89-ethernet.network
ln -sf /usr/lib/systemd/resolv.conf /etc/resolv.conf
systemctl enable systemd-networkd.service systemd-resolved.service
systemctl start systemd-networkd.service systemd-resolved.service

mkdir -p /etc/wireplumber/wireplumber.conf.d/
cp /usr/share/wireplumber/wireplumber.conf /etc/wireplumber/
cat <<EOF > /etc/wireplumber/wireplumber.conf.d/51-disable-ucm.conf
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.*"
      }
    ]
    actions = {
      update-props = {
        api.alsa.use-acp = false
      }
    }
  }
]
EOF

ufw default deny incoming
systemctl enable ufw.service
ufw enable

mkinitcpio -P

pacman -Syyuu --noconfirm
pacman -Rns "$(pacman -Qdtq)" --noconfirm
rm -rf /var/cache/pacman/pkg/*
