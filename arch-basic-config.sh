#!/bin/sh

# set -xe

printf "===Arquivos=de=configuração==============>>\n"
mv .bash* .Xresources .vim .vimrc ~
mv .config/qutebrowser ~/.config ; mv .config/i3/config ~/.config/i3
printf "===Reparos=Instalação=e=Touchpad=========>>\n"
printf "Gerando arquivo de configuração do touchpad\n"
sudo sh -c 'printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\
\tMatchIsTouchpad \"on\"\n\tDriver \"libinput\"\n\
\tOption \"Tapping\" \"on\"\nEndSection" > /etc/X11/xorg.conf.d/90-touchpad.conf'
printf "Gerando arquivo de configuração das notificações\n"
sudo sh -c 'printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > \
/usr/share/dbus-1/services/org.freedesktop.Notifications.service'
printf "===Download=Softwares=Essenciais=========>>\n"
sudo pacman -Syyuu
sudo pacman -S base-devel network-manager-applet xss-lock xdg-utils dex \
               notification-daemon libnotify bash-completion brightnessctl \
               rxvt-unicode powertop ufw p7zip
printf "===Download=Softwares=de=Desenvolvimento=>>\n"
sudo pacman -S man man-pages texinfo ttf-dejavu-nerd qutebrowser mupdf
sudo pacman -S gdb flawfinder splint valgrind fzf php nodejs npm jdk-openjdk
printf "===Download=e=Instalação=VIM=============>>\n"
sudo pacman -R vim nano
cd /tmp ; git clone https://github.com/vim/vim.git ; cd /tmp/vim
./configure --with-features=huge --enable-multibyte --enable-python3interp=yes \
            --with-python3-command=$PYTHON_VER \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes --enable-luainterp=yes \
            --with-lua-prefix=/usr/local --enable-gui=gtk2 --prefix=/usr/local
make && sudo make install ; cd /tmp ; sudo mv vim /usr/local/src/
printf "===Download=e=Instalação=YAY=============>>\n"
cd /tmp ; git clone https://aur.archlinux.org/yay.git ; cd /tmp/yay ; makepkg -si
cd /tmp ; rm -rf yay ; yay -Y --gendb ; yay -Syu --devel ; yay -Y --devel --save
yay -S chromium-widevine
printf "===Download=e=Instalação=Auto=CPU=Freq===>>\n"
cd /tmp ; git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq ; sudo ./auto-cpufreq-installer ; cd /tmp ; rm -rf auto-cpufreq
printf "===Download=e=Instalação=TeX=Live========>>\n"
cd /tmp ; wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - ; cd install-tl-2*
sudo perl ./install-tl --no-interaction ; cd /tmp ; rm -rf install-tl-*
printf "===Download=e=Instalação=MariaDB=========>>\n"
sudo pacman -S mariadb
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mariadb ; sudo mysql_secure_installation 
printf "\n\nConnects to the MariaDB Server on the 'localhost':\n\t\
mariadb -h [hostname] -u [username] -p[password] [database_name]\n\n"
printf "===Configurações=Firewall=e=Bateria======>>\n"
sudo ufw default deny incoming ; sudo systemctl enable ufw ; sudo ufw enable 
sudo ufw status verbose
sudo powertop --calibrate ; sudo powertop --auto-tune
sudo auto-cpufreq --install
