#!/bin/env bash

set -euo pipefail

NETWORK_NAME='NETWORK-5G'
NETWORK_PASSWORD='PASSWORD'
TARGET_USER='opsrcode'

systemctl enable NetworkManager.service
systemctl start NetworkManager.service
nmcli device wifi connect "$NETWORK_NAME" password "$NETWORK_PASSWORD"

cat <<EOF > /etc/X11/xorg.conf.d/90-touchpad.conf
Section "InputClass"
Identifier "touchpad"
MatchIsTouchpad "on"
Driver "libinput"
Option "Tapping" "on"
EndSection
EOF

cd /tmp/
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
git clone https://aur.archlinux.org/yay.git

chown -R "$TARGET_USER:users" auto-cpufreq yay

./auto-cpufreq/auto-cpufreq-installer
auto-cpufreq --install

cd yay
runuser -u "$TARGET_USER" -- bash -c "$(cat <<EOF
makepkg -sri
yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save
EOF
)"

cd "$HOME"
rm -rf /tmp/{auto-cpufreq,yay}
	
ufw default deny incoming
systemctl enable ufw
ufw enable

powertop --calibrate --auto-tune
mkinitcpio -P

pacman -Syyuu --noconfirm
pacman -Rns "$(pacman -Qdtq)" --noconfirm
rm -rf /var/cache/pacman/pkg/*
