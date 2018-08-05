SDX=/dev/mmcblk1
SDX1=/dev/mmcblk1p1
SDX2=/dev/mmcblk1p2

#SDX=/dev/mmcblk0
#SDX1=/dev/mmcblk0p1

umount $SDX1

dd if=/dev/zero of=$SDX bs=1M count=16

fdisk $SDX << __EOF__ >> /dev/null
o
p
n
p
1

+100M

t
c

n
p
2


w
__EOF__



mkfs.vfat $SDX1
mkdir boot
mount $SDX1 boot

mkfs.ext4 $SDX2
mkdir root
mount $SDX2 root

ARCHLINUX_MIRROR="nl2.mirror.archlinuxarm.org"
ARCHLINUX_MIRROR="os.archlinuxarm.org"
ARCHLINUX_MIRROR="dk.mirror.archlinuxarm.org"
PLATFORM=rpi-3

curl -O http://${ARCHLINUX_MIRROR}/os/ArchLinuxARM-${PLATFORM}-latest.tar.gz

bsdtar -xzvf ArchLinuxARM-${PLATFORM}-latest.tar.gz -C root

sync

mv root/boot/* boot

umount boot root
