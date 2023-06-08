#!/usr/bin/bash
 
### 
### Script simples de pós instalação Archlinux (i3, archinstall)
### para setup básico.
### 
### Thiago C Silva, @opsrcode
### 
 
sudo pacman -Syyuu
sudo pacman -S man man-pages texinfo qutebrowser firefox ufw ctags cscope\
	cmake fzf git nasm gdb bash-completion ttf-dejavu-nerd dex xss-lock\
	notification-daemon brightnessctl powertop tlp tlp-rdw p7zip lib32-libltdl

# Configuração ufw
sudo ufw default deny incoming; sudo systemctl enable ufw
sudo systemctl start ufw; sudo ufw enable

# Configuração TLP services
sudo systemctl enable tlp.service && sudo systemctl start tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# YAY, instalação e configuração inicial
cd /tmp; git clone https://aur.archlinux.org/yay.git; cd yay;
makepkg -si; cd ..; yay -Y --gendb; yay -Syu --devel; yay -Y --devel --save
yay sioyek chromium-widevine vi

# auto-cpufreq, instalação e configuração inicial
git clone https://github.com/AdnanHodzic/auto-cpufreq.git; cd auto-cpufreq
sudo ./auto-cpufreq-installer; cd ..; sudo auto-cpufreq --install

# LaTeX, compilação e configurações de variáveis (PATH, MANPATH e INFOPATH)
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - 
cd install-tl-2023* ; sudo perl ./install-tl --no-interaction
echo 'export PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux"' >> ~/.bash_profile
echo 'export MANPATH="$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man"' >> ~/.bash_profile
echo 'export INFOPATH="$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info"' >> ~/.bash_profile
source ~/.bash_profile; cd ..; rm -rf yay auto-cpufreq install-tl-*; cd 

# VIM, compilação
pacman -R vim; orphans
cd /usr/local/src; git clone https://github.com/vim/vim.git;
sudo ./configure && sudo make install

# Corrigindo click com touchpad
sudo printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\tDriver \"libinput\"\n\
	\tMatchIsTouchpad \"on\"\n\tOption \"Tapping\" \"on\"\nEndSection" > /etc/X11/xorg.conf.d/90-touchpad.conf

# Erro daemon de notificação (.xsession-errors)
sudo printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
	Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > /usr/share/dbus-1/services
