#!/bin/sh

mv .bash* .Xresources .vimrc ~ ; mv .config/i3/config ~/.config/i3

# sudo sh -c 'printf "Section \"InputClass\"\n\tIdentifier \"touchpad\"\n\
# \tMatchIsTouchpad \"on\"\n\tDriver \"libinput\"\n\tOption \"Tapping\" \"on\"\n\
# EndSection" > /etc/X11/xorg.conf.d/90-touchpad.conf'

sudo sh -c 'printf "[D-BUS Service]\nName=org.freedesktop.Notifications\n\
Exec=/usr/lib/notification-daemon-1.0/notification-daemon" > \
/usr/share/dbus-1/services/org.freedesktop.Notifications.service'

sudo pacman -Syyuu --noconfirm && sudo pacman -S --noconfirm \
base-devel network-manager-applet dex notification-daemon libnotify \
bash-completion rxvt-unicode powertop ufw man man-pages texinfo \
ttc-iosevka # firefox mupdf brightnessctl

sudo pacman -R --noconfirm vim nano
cd /tmp && git clone https://github.com/vim/vim.git && cd ./vim
./configure --with-features=huge --enable-multibyte \
            --enable-python3interp=yes \
            --with-python3-command=$PYTHON_VER \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes --enable-luainterp=yes \
            --with-lua-prefix=/usr/local --enable-gui=gtk2 \
            --prefix=/usr/local
make && sudo make install && cd /tmp && sudo mv vim /usr/local/src/

git clone https://aur.archlinux.org/yay.git && cd ./yay && makepkg -si
cd /tmp && rm -rf yay
yay -Y --gendb && yay -Syu --devel && yay -Y --devel --save
yay -S --noconfirm ungoogled-chromium-bin

# git clone https://github.com/AdnanHodzic/auto-cpufreq.git
# cd auto-cpufreq && sudo ./auto-cpufreq-installer
# cd /tmp && rm -rf auto-cpufreq

sudo ufw default deny incoming && sudo systemctl enable ufw && sudo ufw enable
sudo powertop --calibrate && sudo powertop --auto-tune
# sudo auto-cpufreq --install
