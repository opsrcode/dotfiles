#!/bin/env bash

set -euo pipefail

# GLOBAL VARIABLES

NVME_BLOCK='/dev/nvme0n1'
BOOT_PARTITION="${NVME_BLOCK}p1"
ROOT_PARTITION="${NVME_BLOCK}p2"

USERNAME='opsrcode'
USER_HOME="/mnt/home/$USERNAME"

ETC='/mnt/etc'
CHROOT_UHOME="/home/$USERNAME"
PKGBUILDS="$CHROOT_UHOME/.cache/builds"
CHROOT_PKGBUILDS="/mnt${PKGBUILDS}"
XINITRC="$USER_HOME/.xinitrc"
LOADER_DIR=/mnt/boot/loader


# CONFIGURATION SECTION

loadkeys us
setfont ter-114n
timedatectl set-timezone 'America/Sao_Paulo'
timedatectl set-ntp true 


# PARTITION SECTION

sfdisk --delete "$NVME_BLOCK"
wipefs --all "$NVME_BLOCK"

sfdisk "$NVME_BLOCK" <<EOF
label: gpt
device: $NVME_BLOCK
unit: sectors
1: size=512MiB, type=uefi, name="EFI System Partition"
2: size=+, type=linux, name="Root Partition"
EOF

mkfs.fat -F32 "$BOOT_PARTITION"
mkfs.ext4 "$ROOT_PARTITION"
mount "$ROOT_PARTITION" /mnt/
mkdir -v /mnt/boot/
chmod 700 /mnt/boot/
mount -o uid=0,gid=0,fmask=0077,dmask=0077 "$BOOT_PARTITION" /mnt/boot/


# PACKAGES SECTION

reflector --protocol https --age 6 --latest 20 --sort rate \
          --country Brazil --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware-amdgpu \
                 linux-firmware-radeon xf86-video-amdgpu amd-ucode \
                 mesa vulkan-radeon polkit ufw terminus-font \
                 xorg-server xorg-xinit man-db man-pages

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

sed -i '/^MODULES/s/()/(amdgpu)/' "$ETC/mkinitcpio.conf"
sed -i '/en_US.UTF-8/s/^#//' "$ETC/locale.gen"
sed -i -e '/VerbosePkgLists$/s/^#//' \
       -e '/multilib\]/,/Include.*mirrorlist/s/^#//' \
          "$ETC/pacman.conf"

printf 'LANG=en_US.UTF-8' > "$ETC/locale.conf"
printf 'archlinux' > "$ETC/hostname"
sed -i '/%wheel.*) ALL/s/^# //' "$ETC/sudoers"

mkdir -pv "$CHROOT_PKGBUILDS"
mv ../PKGBUILDs/* ./post-arch-install.sh "$CHROOT_PKGBUILDS"

arch-chroot /mnt bash -c "$(cat <<EOF
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
locale-gen

useradd -m -g users -G wheel -s /bin/bash $USERNAME
echo 'root:f00b4r' | chpasswd
echo "$USERNAME:f00b4r" | chpasswd

bootctl install

chown -R "$USERNAME:users" "$CHROOT_UHOME"
chmod 755 "$PKGBUILDS"/*.sh

pacman -Syu
sh "$PKGBUILDS/build.sh" "$USERNAME" dwm st dmenu ed
EOF
)"

sed -e '/^xclock/,+1d' -e 's/twm/dwm/g' -e '/^"\$dwm"/,$d' \
       "$ETC/X11/xinit/xinitrc" > "$XINITRC"
printf 'exec "$dwm"' >> "$XINITRC"

cat <<EOF > "$USER_HOME/.bash_aliases"
alias ls='ls --classify --color=never'
alias grep='grep --color=never'
EOF

cat <<'EOF' > "$USER_HOME/.bashrc"
[[ $- != *i* ]] && return
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
PS1='[\u@\h \W]$ '
EOF

cat <<'EOF' > "$USER_HOME/.bash_profile"
[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi
EOF


# BOOT SECTION

PID=$(
  blkid $ROOT_PARTITION | awk -F'PARTUUID=' '{print $2}' | sed 's/"//g'
)
cat <<EOF > "$LOADER_DIR/entries/arch.conf"
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$PID rootfstype=ext4 rw cpufreq.default_governor=performance
EOF

cat <<EOF > "$LOADER_DIR/loader.conf"
default arch.conf
timeout 0
editor no
console-mode auto
EOF

umount -R /mnt
