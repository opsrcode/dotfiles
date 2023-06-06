#!/usr/bin/bash
 
sudo pacman -Syyuu
sudo pacman -S man man-pages texinfo qutebrowser firefox ufw ctags cscope\
	cmake fzf git nasm gdb bash-completion ttf-dejavu-nerd dex xss-lock\
	notification-daemon tlp notification-daemon brightnessctl powertop
# Configuração ufw
sudo ufw default deny incoming; sudo systemctl enable ufw; sudo systemctl start ufw; sudo ufw enable
# YAY, instalação e configuração inicial
cd /tmp; git clone https://aur.archlinux.org/yay.git; cd yay; makepkg -si; cd ..
yay -Y --gendb; yay -Syu --devel; yay -Y --devel --save
# auto-cpufreq, instalação e configuração inicial
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer; cd ..
sudo auto-cpufreq --install
# LaTeX, compilação e configurações de variáveis (PATH, MANPATH e INFOPATH)
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - 
cd install-tl-2023* ; sudo perl ./install-tl --no-interaction
echo 'export PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux"' >> ~/.bash_profile
echo 'export MANPATH="$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man"' >> ~/.bash_profile
echo 'export INFOPATH="$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info"' >> ~/.bash_profile
source ~/.bash_profile; cd ..; rm -rf yay auto-cpufreq install-tl-unx.tar.gz install-tl-*; cd 
yay sioyek chromium-widevine vi
## Configurações gerais
# Tap to click
sudo printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\tDriver \"libinput\"\n\
	\tMatchIsTouchpad \"on\"\n\tOption \"Tapping\" \"on\"\nEndSection" > /etc/X11/xorg.conf.d/30-touchpad.conf
# Notification error
sudo printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
	Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > /usr/share/dbus-1/services
