pacman -Syu
pacman -S ansible


cd /usr/bin;
rm python
ln -s python2.7 python

hostnamectl set-hostname odroidx
