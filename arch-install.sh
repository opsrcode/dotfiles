#!/bin/sh

repo=$(pwd)
based='/dev/sda'
bootd=$based"1"
swapd=$based"2"
rootd=$based"3"
pac="/etc/pacman.d"
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
home="/mnt/home/$user"
vconsole="$(cat <<EOF
KEYMAP=us
FONT=ter-114n
EOF
)"
locale='LANG=en_US.UTF-8'
hostname='archlinux'
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
[[ \$- != *i* ]] && return
PS1='[\u@\h \W]\$ '
VISUAL='/usr/bin/vim'
export EDITOR="\$VISUAL"
set -o vi
EOF
)"
bprc="$(cat <<EOF
[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -z "\$DISPLAY" ] && [ "\$XDG_VTNR" = 1 ]; then
	exec startx
fi
EOF
)"
part="$(cat <<EOF
label: gpt
size=1GiB, type=U, name="EFI System Partition"
size=10GiB, type=S, name="Linux Swap Partition"
size=+, type=L, name="Linux Filesystem Partition"
EOF
)"

function basics
{
	loadkeys "$keymap" && setfont "$font" && \
	timedatectl set-timezone "$timezone" && timedatectl set-ntp true 
}

function partition
{
	sfdisk --delete "$based" && wipefs -a "$based" && \
	sfdisk "$based" "$part"
	mkfs.fat -F32 "$bootd" && mkfs.ext4 "$rootd" && \
	mkswap "$swapd" && mount "$rootd" /mnt && \
	mount --mkdir "$bootd" "$boot" && swapon "$swapd"
}

function load_pkgs
{
	reflector --latest 20 --sort rate --country Brazil --save "$pac/mirrorlist" && \
	pacstrap -K /mnt $pkgs && genfstab -U /mnt >> $etc/fstab
}

function change_files
{
	local xi='.xinitrc'
	printf "$vconsole" > "$etc/vconsole.conf"
	sed -i '/en_US.UTF-8/s/^#//' "$etc/locale.gen"
	printf "$locale" > "$etc/locale.conf"
	printf "$hostname" > "$etc/hostname"
	printf "$hosts" >> "$etc/hosts"
	printf "$sudoers" >> "$etc/sudoers"
	sed -i -e '/^#VerbosePkgLists/s/^#//' \
 	       -e '/^#\[multilib\]/,/^#Include/s/^#//' "$etc/pacman.conf"
	sed -i -e '/^MODULES=()/s/()/(amd radeon)/' "$etc/mkinitcpio.conf"
	mkdir "$home" && cd "$home" && cp "$etc/X11/xinit/xinitrc" "$xi" && \
	sed -i '/\$twm \&/,$d' "$xi" && echo 'exec dwm' >> "$xi"
	cd $repo
}

function chroot_config
{
	local mhome="/home/$user"
	local pkgs=('vim-git' 'dwm-git' 'st-git' 'dmenu-git')

	cd "$home" && for pkg in "${pkgs[@]}"; do
		mkdir $pkg && cp "$repo/$pkg" "$pkg/PKGBUILD"
       	done && cd "$repo" && cp -r .vim* "$home"

	arch-chroot /mnt "$shell" -c "$(cat <<EOF
passwd && ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
hwclock --systohc && locale-gen && useradd -m -g users -s "$shell" "$user"
passwd "$user" && pacman -Syyuu && chown -R "$user":users "$mhome" && cd "$mhome" 
pkgs=('vim-git' 'dwm-git' 'st-git' 'dmenu-git') && \
for pkg in \${pkgs[@]} ; do cd \$pkg && runuser -u "$user" -- makepkg -sri
cd "$mhome" && mv \$pkg /usr/src/ ; done && printf "$brc" > .bashrc && \
printf "$bprc" > .bash_profile && git clone https://aur.archlinux.org/yay.git && \
chown -R "$user:users" yay && cd yay && runuser -u "$user" -- makepkg -sri
runuser -u "$user" -- yay -Y --gendb && runuser -u "$user" -- yay -Syu --devel
runuser -u "$user" -- yay -Y --devel --save && cd "$mhome"
rm -rf yay && bootctl install
EOF
)"
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
	basics && partition && load_pkgs && change_files && chroot_config && boot_config
}
main