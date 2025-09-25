#!/bin/env bash

set -euo pipefail

systemctl enable systemd-networkd.service systemd-resolved.service
systemctl start systemd-networkd.service systemd-resolved.service

ufw default deny incoming
systemctl enable ufw.service
ufw enable

mkinitcpio -P

pacman -Syyuu --noconfirm
pacman -Rns "$(pacman -Qdtq)" --noconfirm
rm -rf /var/cache/pacman/pkg/*
