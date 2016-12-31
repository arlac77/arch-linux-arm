mkfs.vfat /dev/sdX1
mkdir boot
mount /dev/sdX1 boot

mkfs.ext4 /dev/sdX2
mkdir root
mount /dev/sdX2 root

wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root
sync

mv root/boot/* boot

umount boot root
