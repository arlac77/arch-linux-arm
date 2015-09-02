SDX=/dev/mmcblk1
SDX1=/dev/mmcblk1p1

dd if=/dev/zero of=$SDX bs=1M count=8
fdisk $SDX


mkfs.ext4 $SDX1
mkdir root
mount $SDX1 root


#wget http://archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz
#bsdtar -xpf ArchLinuxARM-odroid-xu3-latest.tar.gz -C root
tar -xzvf ArchLinuxARM-odroid-xu3-latest.tar.gz -C root


cd root/boot
./sd_fusing.sh $SDX
cd ../..


umount root
