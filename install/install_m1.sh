SD=/dev/mmcblk0
SD_PART1=${SD}p1

echo $SD
echo $SD_PART1

cd /tmp

exit 0

dd if=/dev/zero of=$SD bs=1M count=8

fdisk $SD << __EOF__ >> /dev/null
o
p
n
p
1
16384

w
__EOF__


mkfs.ext4 $SD_PART1

mkdir -p /tmp/root
mount $SD_PART1 /tmp/root


wget http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
bsdtar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C /tmp/root

mkdir -p /tmp/root/boot/extlinux
wget http://os.archlinuxarm.org/os/rockchip/boot/odroid-m1/extlinux.conf -O /tmp/root/boot/extlinux/extlinux.conf

umount /tmp/root

wget http://os.archlinuxarm.org/os/rockchip/boot/odroid-m1/u-boot-rockchip.bin
dd if=u-boot-rockchip.bin of=$SD conv=fsync,notrunc bs=512 skip=1 seek=1
