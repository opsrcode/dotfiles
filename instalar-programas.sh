#!/usr/bin/bash
 
echo "Inicializando script de instalação...\n"

sudo pacman -S man man-pages texinfo qutebrowser\
	ctags cscope cmake fzf git nasm gdb

echo "Sessão Pacman finalizada!"

# YAY
cd /tmp ; git clone https://aur.archlinux.org/yay.git
cd yay ; makepkg -si ; cd ..

# auto-cpufreq
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer ; cd ..

# LaTeX
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf -
cd install-tl-*
sudo perl ./install-tl --no-interaction

echo 'export PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux' >> ~/.bash_profile
echo 'export MANPATH="$MANPATH:/usr/local/texlive/2023/texmf-dist/doc/man' >> ~/.bash_profile
echo 'export INFOPATH="$INFOPATH:/usr/local/texlive/2023/texmf-dist/doc/info' >> ~/.bash_profile
source ~/.bash_profile

cd .. ; rm -rf yay auto-cpufreq install-tl-unx.tar.gz install-tl-* ; cd 

echo "Sessão de Compilação finalizada!"

yay sioyek chromium-widevine vi
echo "Sessão YAY finalizada!"
