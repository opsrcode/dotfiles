#!/bin/sh

function section_title (
  function border {
    printf " ~~~~~%s\n" $(for i in $@ ; do for j in $(seq 1 ${#i}) ; do printf '~'
                          done ; printf '~' ; done)
  } ; printf "\n" ; border $@ ; echo -e '~~~ '$@' ~~~' ; border $@ ; printf "\n"
)

section_title 'Arquivos de configuração'
mv .bash* .Xresources .vim* ~ ; mv .config/i3/config ~/.config/i3
 
section_title 'Configurações de Notificação e Touchpad'
sudo sh -c 'printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\
\tMatchIsTouchpad \"on\"\n\tDriver \"libinput\"\n\tOption \"Tapping\" \"on\"\n\
EndSection" > /etc/X11/xorg.conf.d/90-touchpad.conf'
 
sudo sh -c 'printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > \
/usr/share/dbus-1/services/org.freedesktop.Notifications.service'
 
section_title 'Software Essenciais'
sudo pacman --noconfirm -Syyuu
sudo pacman --noconfirm -S base-devel network-manager-applet xss-lock dex \
xdg-utils notification-daemon libnotify bash-completion brightnessctl \
rxvt-unicode powertop ufw man man-pages texinfo ttc-iosevka chromium mupdf

section_title 'Compilação VIM'
sudo pacman --noconfirm -R vim nano
cd /tmp ; git clone https://github.com/vim/vim.git ; cd ./vim
./configure --with-features=huge --enable-multibyte --enable-python3interp=yes \
            --with-python3-command=$PYTHON_VER \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes --enable-luainterp=yes \
            --with-lua-prefix=/usr/local --enable-gui=gtk2 --prefix=/usr/local
make && sudo make install ; cd /tmp ; sudo mv vim /usr/local/src/
sudo pacman --noconfirm -S ctags ; mkdir -p ~/.vim/pack/downloads/start
git clone https://github.com/yegappan/taglist.git
mv ./taglist ~/.vim/pack/downloads/start

section_title 'Compilação YAY (Gerenciador de pacotes AUR)'
git clone https://aur.archlinux.org/yay.git ; cd /tmp/yay ; makepkg -si
cd /tmp ; rm -rf yay ; yay -Y --gendb ; yay -Syu --devel ; yay -Y --devel --save
   
section_title 'Compilação Auto CPU Freq'
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq ; sudo ./auto-cpufreq-installer ; cd /tmp ; rm -rf auto-cpufreq

section_title 'Compilação TeX Live'
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - ; cd install-tl-2*
sudo perl ./install-tl --no-interaction ; cd /tmp ; rm -rf install-tl-*

section_title 'Instalação e Configuração MariaDB'
sudo pacman --noconfirm -S mariadb
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mariadb ; sudo mysql_secure_installation 
printf "\n\nConnects to the MariaDB Server on the 'localhost':\n\t\
mariadb -h [hostname] -u [username] -p[password] [database_name]\n\n"
 
section_title 'Configuração UFW, Powertop e Auto CPU Freq'
sudo ufw default deny incoming ; sudo systemctl enable ufw ; sudo ufw enable 
sudo ufw status verbose ; sudo powertop --calibrate ; sudo powertop --auto-tune
sudo auto-cpufreq --install
