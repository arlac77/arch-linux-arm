pacman -Syu
pacman -S btrfs-progs
pacman -S git
pacman -S llvm
pacman -S clang
pacman -S nodejs
pacman -S mercurial
#wget http://de3.mirror.archlinuxarm.org/armv7h/extra/mercurial-3.3.2-1-armv7h.pkg.tar.xz
pacman -U mercurial-3.3.2-1-armv7h.pkg.tar.xz

pacman -S go

mkdir ~/go
export GOPATH=~/go
export PATH=$PATH:~/go/bin
go get code.google.com/p/go-tour/gotour
