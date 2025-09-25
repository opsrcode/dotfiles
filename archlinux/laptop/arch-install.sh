#!/bin/env bash

set -euo pipefail

# GLOBAL VARIABLES

SDA_BLOCK="/dev/sda"
BOOT_PARTITION="${SDA_BLOCK}1"
SWAP_AREA="${SDA_BLOCK}2"
ROOT_PARTITION="${SDA_BLOCK}3"

USERNAME='opsrcode'
USER_HOME="/mnt/home/$USERNAME"

ETC=/mnt/etc
CHROOT_UHOME="/home/$USERNAME"
PKGBUILDS="$CHROOT_UHOME/.cache/builds"
XINITRC="$USER_HOME/.xinitrc"
LOADER_DIR=/mnt/boot/loader
PID=$(
  blkid $ROOT_PARTITION | awk -F'PARTUUID=' '{print $2}' | sed 's/"//g'
)


# CONFIGURATION SECTION

loadkeys us
setfont ter-114n
timedatectl set-timezone "America/Sao_Paulo"
timedatectl set-ntp true 


# PARTITION SECTION

sfdisk --delete "$SDA_BLOCK"
wipefs --all "$SDA_BLOCK"

sfdisk "$SDA_BLOCK" <<EOF
label: gpt
device: $SDA_BLOCK
unit: sectors
1: size=512MiB, type=uefi, name="EFI System Partition"
2: size=16GiB, type=uefi, name="Swap Area"
3: size=+, type=linux, name="Root Partition"
EOF

mkfs.fat -F32 "$BOOT_PARTITION"
mkswap "$SWAP_AREA"
mkfs.ext4 "$ROOT_PARTITION"

mount "$ROOT_PARTITION" /mnt/
swapon "$SWAP_AREA"
mount --mkdir "$BOOT_PARTITION" /mnt/boot/


# PACKAGES SECTION

reflector --protocol https --age 6 --latest 20 --sort rate \
          --country Brazil --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware-intel \
                 xf86-video-intel intel-ucode networkmanager mesa \
                 polkit pipewire-pulse powertop terminus-font ufw \
                 brightnessctl vulkan-intel xorg-server xorg-xinit \
                 man-db man-pages

genfstab -U /mnt >> "$ETC/fstab"


# MOUNTED BLOCK CONFIGURATION

cat <<EOF > "$ETC/vconsole.conf"
KEYMAP=us
FONT=ter-114n
EOF

cat <<EOF > "$ETC/hosts"
127.0.0.1 localhost
::1       localhost ip6-localhost ip6-loopback
EOF

sed -i '/^MODULES/s/()/(i915)/' "$ETC/mkinitcpio.conf"
sed -i '/en_US.UTF-8/s/^#//' "$ETC/locale.gen"
sed -i -e '/VerbosePkgLists$/s/^#//' \
       -e '/multilib\]/,/Include.*mirrorlist/s/^#//' \
          "$ETC/pacman.conf"

printf 'LANG=en_US.UTF-8' > "$ETC/locale.conf"
printf 'archlinux' > "$ETC/hostname"
sed -i '/%wheel.*) ALL/s/^# //' "$ETC/sudoers"

mkdir -pv "$PKGBUILDS"
mv ../PKGBUILDs ./post-arch-install.sh "/mnt${PKGBUILDS}"

arch-chroot /mnt /bin/bash -c "$(cat <<EOF
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
locale-gen

useradd -m -g users -G wheel -s /bin/bash $USERNAME
echo 'root:f00b4r' | chpasswd
echo "$USERNAME:f00b4r" | chpasswd

bootctl install

chown -R "$USERNAME:users" "$CHROOT_UHOME"
chmod +x "$PKGBUILDS/*.sh"

sh "$PKGBUILDS/build.sh" "$USERNAME" dwm st dmenu ed
EOF
)"

sed -e '/^xclock/,+1d' -e 's/twm/dwm/g' -e '/^"\$dwm"/,$d' \
       "$ETC/X11/xinit/xinitrc" > "$XINITRC"
printf 'exec "$dwm"' >> "$XINITRC"

cat <<EOF > "$USER_HOME/.bash_aliases"
alias ls='ls --classify --color=never'
alias grep='grep --color=never'
alias volume='pactl set-sink-volume @DEFAULT_SINK@'
EOF

cat <<'EOF' > "$USER_HOME/.bashrc"
[[ $- != *i* ]] && return
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
PS1='[\u@\h \w $?]$ '
EOF

cat <<'EOF' > "$USER_HOME/.bash_profile"
[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi
EOF


# BOOT SECTION

cat <<EOF > "$LOADER_DIR/entries/arch.conf"
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$pid rootfstype=ext4 rw
EOF

cat <<EOF > "$LOADER_DIR/loader.conf"
default arch.conf
timeout 0
editor no
console-mode auto
EOF

umount -R /mnt
