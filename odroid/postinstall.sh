pacman -Syu
pacman -S ansible


cd /usr/bin;
rm python
ln -s python2.7 python

#pacman -S mercurial
#pacman -U mercurial-3.3.2-1-armv7h.pkg.tar.xz

hostnamectl set-hostname odroidx
