#!/bin/sh

set -euo pipefail

function def_vars
{
	repo=$(pwd)

	based='/dev/sda'
	bootd=$based"1"
	swapd=$based"2"
	rootd=$based"3"

	font='ter-114n'
	keymap='us'
	timezone='America/Sao_Paulo'
	user='opsrcode'
	shell='/usr/bin/bash'
	pkgs="$(cat <<EOF
base base-devel linux linux-firmware xf86-video-amdgpu xf86-video-ati
amd-ucode dhclient openssh ufw powertop mesa vulkan-radeon polkit git
libx11 libxinerama libxft freetype2 xorg-xinit xorg-server 
terminus-font man-db man-pages texinfo
EOF
)"

	boot="/mnt/boot"
	etc="/mnt/etc"
	pac="$etc/pacman.d"
	home="/mnt/home/$user"
}

function def_ctts
{
	vconsole="KEYMAP=us\nFONT=ter-114n"
	locale='LANG=en_US.UTF-8'
	hosts="$(cat <<EOF
127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
EOF
)"
	sudoers="$user ALL=(ALL:ALL) ALL"
	local pid="$(blkid $rootd | awk -F'PARTUUID=' '{print $2}' | sed 's/"//g')"
	arch="$(cat <<EOF
title	Arch Linux
linux	/vmlinuz-linux
initrd	/amd-ucode.img
initrd	/initramfs-linux.img
options	root=PARTUUID=$pid rootfstype=ext4 rw
EOF
)"
	loader="$(cat <<EOF
default arch.conf
console-mode auto
EOF
)"
	brc="$(cat <<EOF
VISUAL='/usr/bin/vim'
export EDITOR=\"\$VISUAL\"
set -o vi
EOF
)"
	bprc="$(cat <<EOF
[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -z \"\$DISPLAY\" ] && [ \"\$XDG_VTNR\" = 1 ]; then
	exec startx
fi
EOF
)"
}

function basics
{
	loadkeys "$keymap" && set font "$font" && \
	timedatectl set-timezone "$timezone" && timedatectl set-ntp true 
}

function partition
{
	sfdisk --delete "$based" && wipefs -a "$based" && \
	sfdisk "$based" <<EOF
label: gpt
size=1GiB, type=U, name="EFI System Partition"
size=10GiB, type=S, name="Linux Swap Partition"
size=+, type=L, name="Linux Filesystem Partition"
EOF
	mkfs.fat -F32 "$bootd" && mkfs.ext4 "$rootd" && \
	mkswap "$swapd" && mount "$rootd" /mnt && \
	mount --mkdir "$bootd" "$boot" && swapon "$swapd"
}

function load_pkgs
{
	reflector --latest 20 --sort rate --country Brazil --save "$pac/mirrorlist" && \
	pacstrap -K /mnt "$pkgs" && genfstab -U mnt >> "$etc/fstab"
}

function change_files
{
	local xi='./.xinitrc'
	printf "$vconsole" > "$etc/vconsole.conf"
	sed -i '/en_US.UTF-8/s/^# //' "$etc/locale.gen"
	printf "$locale" > "$etc/locale.conf"
	printf "$arch" > "$etc/hostname"
	printf "$hosts" >> "$etc/hosts"
	printf "$sudoers" >> "$etc/sudoers"
	sed -i -e '/^#VerbosePkgLists/s/^#//' \
 	       -e '/^#\[multilib\]/,/^#Include/s/^#//' "$etc/pacman.conf"
	sed -i -e '/^MODULES=()/s/()/(amd radeon)/' "$etc/mkinitcpio.conf"
	mkdir "$home" && cd "$home" &&
	cp "$etc/X11/xinit/xinitrc" "$xi" && \
	sed -i '/\$twm \&/,$d' "$xi" && echo 'exec dwm' >> "$xi"
	cd $repo
}

function chroot_config
{
	local pkgs=('vim-git' 'dwm-git' 'st-git' 'dmenu-git')

	cd "$home" && for pkg in "${pkgs[@]}"; do
		mkdir $pkg && mv "$repo/$pkg" "$pkg/PKGBUILD"
       	done && cd "$repo" && cp ".vim*" "$home"

	arch-chroot mnt && passwd
	ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
	hwclock --systohc && locale-gen

	useradd -m -g users -s "$shell" "$user" && passwd "$user" && su opsrcode
	for pkg in "${pkgs[@]}"; do cd "~/$pkg" && makepkg -sri ; done && cd /tmp
	printf "$brc" >> "~/.bashrc" && printf "$bprc" >> "~/.bash_profile"
	git clone https://aur.archlinux.org/yay.git && cd ./yay && makepkg -sri 
	yay -Y --gendb && yay -Syu --devel && yay -Y --devel --save && exit

       	bootctl install && exit
}

function boot_config
{
	local ldir="$boot/loader"
	printf "$loader" > "$ldir/loader.conf" && \
	printf "$arch" > "$ldir/entries/arch.conf"
	umount -R /mnt && reboot
}

function main
{
	def_vars && def_ctts && basics && partition && load_pkgs && \
	change_files && chroot_config && boot_config
}
main
