#!/bin/sh

set -euo pipefail

read -p "Device type: " DEVICE_TYPE
if [[ "$DEVICE_TYPE" == "laptop" ]]; then
  read -p "Username: " USER
  read -p "Network-Name: " NETWORK_NAME

  systemctl enable NetworkManager.service
  systemctl start NetworkManager.service

  nmcli device wifi connect "$NETWORK_NAME" --ask

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
  cd auto-cpufreq/
  ./auto-cpufreq-installer
  auto-cpufreq --install

  git clone https://github.com/jguer/yay.git
  cd yay/
  runuser -u "$USER" -- /bin/bash -c "$(cat <<EOF
makepkg -sri
yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save
EOF
)"

  cd "$HOME"
else
  dhclient
fi
	
ufw default deny incoming
systemctl enable ufw
ufw enable
mkinitcpio
pacman -Syu
powertop --calibrate --auto-tune
rm -rf .cache/* /var/cache/pacman/pkg/*
pacman -Rns $(pacman -Qdtq)
