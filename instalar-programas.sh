#!/usr/bin/bash
 
### 
### Script simples de pós instalação Archlinux (i3, archinstall)
### para setup básico.
### 
### Thiago C Silva, @opsrcode
### 
 
printf "\n\t###################################################################
\t\tMOVENDO ARQUIVOS DE CONFIGURAÇÃO E INICIALIZANDO SCRIPT
\t###################################################################\n\n"
       
sudo mv .bash* .config .vim .vimrc .ctags .Xresources

printf "\n\t###################################################################
\t\tINSTALAÇÕES BÁSICAS
\t###################################################################\n\n"
       
sudo pacman -Syyuu
sudo pacman -S man man-pages texinfo ufw qutebrowser ctags cscope cmake fzf git\
	gdb bash-completion ttf-dejavu-nerd dex xss-lock notification-daemon\
	brightnessctl powertop tlp tlp-rdw p7zip wget lib32-gcc-libs mupdf perl

printf "\n\t###################################################################
\t\tCONFIGURAÇÃO UFW E TLP SERVICES
\t###################################################################\n\n"

sudo ufw default deny incoming; sudo systemctl enable ufw
sudo systemctl start ufw; sudo ufw enable
sudo systemctl enable tlp.service && sudo systemctl start tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

printf "\n\t###################################################################
\t\tDOWNLOAD E COMPILAÇÃO YAY E AUTO-CPUFREQ
\t###################################################################\n\n"
       
cd /tmp; git clone https://aur.archlinux.org/yay.git; cd yay
makepkg -si; cd ..; yay -Y --gendb; yay -Syu --devel
yay -Y --devel --save; yay chromium-widevine
git clone https://github.com/AdnanHodzic/auto-cpufreq.git; cd auto-cpufreq
sudo ./auto-cpufreq-installer; cd ..; sudo auto-cpufreq --install

printf "\n\t###################################################################
\t\tDOWNLOAD E COMPILAÇÃO TEXLIVE - LaTeX
\t###################################################################\n\n"
      
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - 
cd install-tl-2023* ; sudo perl ./install-tl --no-interaction
echo 'export PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux"' >> ~/.bash_profile
echo 'export MANPATH="$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man"' >> ~/.bash_profile
echo 'export INFOPATH="$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info"' >> ~/.bash_profile
source ~/.bash_profile; cd ..; rm -rf yay auto-cpufreq install-tl-*; cd 

printf "\n\t###################################################################
\t\tDOWNLOAD E COMPILAÇÃO VIM TEXT EDITOR
\t###################################################################\n\n"
       
sudo pacman -R vim; orphans
cd /usr/local/src; sudo git clone https://github.com/vim/vim.git; cd vim
sudo ./configure && sudo make install

printf "\n\t###################################################################
\t\tCONFIGURAÇÃO DE CLIQUE TOUCHPAD E ERRO DE NOTIFICAÇÃO
\t###################################################################\n\n"
       
sudo printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\tDriver \"libinput\"\n\
	\tMatchIsTouchpad \"on\"\n\tOption \"Tapping\" \"on\"\nEndSection" > /etc/X11/xorg.conf.d/90-touchpad.conf
sudo printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
	Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > /usr/share/dbus-1/service/org.freedesktop.Notifications.service

printf "\n\t###################################################################
\t\tCALIBRAÇÃO POWERTOP E AUTO-TUNE
\t###################################################################\n\n"
       
sudo powertop --calibrate; sudo powertop --auto-tune
