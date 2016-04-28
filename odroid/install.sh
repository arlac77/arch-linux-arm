# see http://archlinuxarm.org/platforms/armv7/samsung/odroid-xu3

PLATFORM=odroid-xu3
PLATFORM=odroid-c2

SDX=/dev/mmcblk1
SDX1=/dev/mmcblk1p1

#SDX=/dev/mmcblk0
#SDX1=/dev/mmcblk0p1

umount $SDX1

dd if=/dev/zero of=$SDX bs=1M count=16

cat >mmcblk1.format <<EOF
label: dos
label-id: 0x3ce7bafd
device: /dev/mmcblk1
unit: sectors

/dev/mmcblk1p1 : start=        2048, size=    15267840, type=83
EOF

# o
# p
# n
# 1
#

fdisk $SDX

# At the fdisk prompt, create the new partitions:
# Type o. This will clear out any partitions on the drive.
# Type p to list partitions. There should be no partitions left.
# Type n, then p for primary, 1 for the first partition on the drive, and enter twice to accept the default starting and ending sectors.
# Write the partition table and exit by typing w.

cd /tmp
mkdir -p root

mkfs.ext4 $SDX1
mount $SDX1 root


#curl -O http://os.archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz
#curl -O http://nl2.mirror.archlinuxarm.org/os/ArchLinuxARM-odroid-xu3-latest.tar.gz
#curl -O http://archlinuxarm.org/os/ArchLinuxARM-${PLATFORM}-latest.tar.gz

curl -O http://nl2.mirror.archlinuxarm.org/os/ArchLinuxARM-${PLATFORM}-latest.tar.gz

tar -xzvf ArchLinuxARM-${PLATFORM}-latest.tar.gz -C root

(cd root
 tar cvfp - /etc/systemd/network/eth0.network /root/.ssh /etc/ssh/sshd_config /etc/ssh/ssh_host_* | tar xvfp -
 cd usr/bin;ln -s python2.7 python
)

cd root/boot
./sd_fusing.sh $SDX
cd ../..


umount root
