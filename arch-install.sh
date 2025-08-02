#!/bin/sh

set -euo pipefail

DOTFILES=$(pwd)

# GLOBAL VARIABLES

SDA_BLOCK="/dev/sda"           # SSD 223.6G
BOOT_PARTITION="${SDA_BLOCK}1" # FAT (F32) EFI System Partition (GPT)
SWAP_AREA="${SDA_BLOCK}2"      # Swap Area (2x RAM)
ROOT_PARTITION="${SDA_BLOCK}3" # EXT4 Root Partition (GPT)

SDB_BLOCK="/dev/sdb"           # SSD 223.6G
HOME_PARTITION="${SDB_BLOCK}1" # EXT4 Home Partition (GPT)

read -p "Username: " USER
USER_HOME="/mnt/home/$USER"


# CONFIGURATION SECTION

loadkeys us
setfont ter-114n
timedatectl set-timezone "America/Sao_Paulo"
timedatectl set-ntp true 


# PARTITION SECTION

# Delete partitions and wipe signatures from sda and sdb
sfdisk --delete "$SDA_BLOCK"
sfdisk --delete "$SDB_BLOCK"
wipefs -a "$SDA_BLOCK" "$SDB_BLOCK"

# Create new partitions for sda and sdb
sfdisk "$SDA_BLOCK" <<EOF
label: gpt
device: $SDA_BLOCK
unit:sectors
1:size=1GiB, type=U, name="EFI System Partition"
2:size=16GiB, type=S, name="Swap Area"
3:size=+, type=L, name="Root Partition"
EOF

sfdisk "$SDB_BLOCK" <<EOF
label: gpt
device: $SDB_BLOCK
unit:sectors
1:size=+, type=H, name="Home Partition"
EOF

# Build file systems for partitions and create swap area
mkfs.fat -F32 "$BOOT_PARTITION"
mkfs.ext4 "$ROOT_PARTITION"
mkfs.ext4 "$HOME_PARTITION"
mkswap "$SWAP_AREA"

# Mount partitions and enable swap area for swapping
mount "$ROOT_PARTITION" /mnt/
mount --mkdir "$BOOT_PARTITION" /mnt/boot/
mount --mkdir "$HOME_PARTITION" /mnt/home/
swapon "$SWAP_AREA"


# PACKAGES SECTION

# Retrieve and filter the latest Pacman mirror list
reflector --latest 20 --sort rate --country Brazil \
          --save /etc/pacman.d/mirrorlist

# Set up the base system and install necessary packages
pacstrap -K /mnt base base-devel linux linux-firmware \
                 xf86-video-amdgpu xf86-video-ati amd-ucode dhclient \
                 mesa polkit vulkan-radeon powertop terminus-font ufw \
                 git openssh xorg-server xorg-xinit libx11 libxinerama \
                 libxft freetype2 man-db man-pages texinfo

genfstab -U /mnt >> /mnt/etc/fstab


# MOUNTED BLOCK CONFIGURATION

etc="/mnt/etc"
xinitrc="$USER_HOME/.xinitrc"

cat <<EOF > "$etc/vconsole.conf"
KEYMAP=us
FONT=ter-114n
EOF

cat <<EOF > "$etc/hosts"
127.0.0.1	localhost
::1		localhost
EOF

# Intel => MODULES=(i915)
sed -i '/^MODULES/s/()/(amd radeon)/' "$etc/mkinitcpio.conf"
sed -i '/en_US.UTF-8/s/^#//' "$etc/locale.gen"
sed -i -e '/VerbosePkgLists$/s/^#//' \
       -e '/multilib\]/,/Include.*mirrorlist/s/^#//' \
       "$etc/pacman.conf"

printf "LANG=en_US.UTF-8" > "$etc/locale.conf"
printf "archlinux" > "$etc/hostname"

mv PKGBUILDs post-arch-install.sh /mnt/root/
chroot_user_home="/home/$USER/"
pkgbuilds="$chroot_user_home/.builds"
arch-chroot /mnt /bin/bash -c "$(cat <<EOF
passwd root
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
locale-gen
useradd -m -g users -G wheel -s /bin/bash $USER
passwd $USER
bootctl install
pacman -Syu
mv /root/post-arch-install.sh $chroot_user_home
mv /root/PKGBUILDs $pkgbuilds
chmod +x $pkgbuilds/build.sh $chroot_user_home/post-arch-install.sh
./$pkgbuilds/build.sh dwm st dmenu ed
EOF
)"

sed -i '/%wheel.*) ALL/s/^# //' "$etc/sudoers"
sed -e '/^"\$twm"/,$d' -e '/^xclock/,+2d' \
  "$etc/X11/xinit/xinitrc" > "$xinitrc"
printf 'exec "$dwm"' >> "$xinitrc"

cat <<EOF > "$USER_HOME/.bashrc"
[[ \$- != *i* ]] && return
alias ls="ls --classify --color=never"
alias grep="grep --color=never"
PS1='[\u@\h \W]\$ '
EOF

cat <<EOF > "$USER_HOME/.bash_profile"
[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -z "\$DISPLAY" ] && [ "\$XDG_VTNR" = 1 ]; then
  exec startx
fi
EOF


# BOOT SECTION

loader_dir="/mnt/boot/loader"
pid=$(
  blkid $ROOT_PARTITION | awk -F'PARTUUID=' {print $2} | sed 's/"//g'
)

# Intel => initrd  /intel-ucode.img
cat <<EOF > "$loader_dir/entries/arch.conf"
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$pid rootfstype=ext4 rw
EOF

cat <<EOF > "$loader_dir/loader.conf"
default arch.conf
console-mode auto
EOF

umount -R /mnt
