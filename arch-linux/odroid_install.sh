SDX=/dev/mmcblk1
SDX1=/dev/mmcblk1p1

umount $SDX1

dd if=/dev/zero of=$SDX bs=1M count=8
fdisk $SDX

# At the fdisk prompt, create the new partitions:
# Type o. This will clear out any partitions on the drive.
# Type p to list partitions. There should be no partitions left.
# Type n, then p for primary, 1 for the first partition on the drive, and enter twice to accept the default starting and ending sectors.
# Write the partition table and exit by typing w.


mkfs.ext4 $SDX1
mkdir root
mount $SDX1 root


wget http://archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz
#bsdtar -xpf ArchLinuxARM-odroid-xu3-latest.tar.gz -C root
tar -xzvf ArchLinuxARM-odroid-xu3-latest.tar.gz -C root


cd root/boot
./sd_fusing.sh $SDX
cd ../..


umount root
