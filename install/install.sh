# see http://archlinuxarm.org/platforms/armv7/samsung/odroid-xu3
# https://magazine.odroid.com/article/emmc-recovery-resetting-the-odroid-xu4-emmc-module-to-fix-boot-issues/

if [ -z $1 ]; then
        echo "no hostname given"
        exit 1
fi

HOSTNAME=$1

read HOSTNAME IP GATEWAY MACADDR PLATFORM PART_SCHEME <<< $(grep $HOSTNAME<<EOF
odroid0   10.0.6.0/16    10.0.0.2      0:1e:6:10:06:0    odroid-xu3         ext4_only
odroid1   10.0.6.1/16    10.0.0.2      00:1e:06:31:08:57 odroid-xu3         ext4_only
odroid2   10.0.6.2/16    10.0.0.2      0:1e:6:10:06:2    odroid-xu3         ext4_only
odroid3   10.0.6.3/16    10.0.0.2      0:1e:6:10:06:3    odroid-xu3         ext4_only
odroid4   10.0.6.4/16    10.0.0.2      0:1e:6:10:06:4    odroid-xu3         ext4_only
odroid5   10.0.6.5/16    10.0.0.2      0:1e:6:10:06:5    odroid-xu3         ext4_only
odroid6   10.0.6.6/16    10.0.0.2      0:1e:6:10:06:6    odroid-n2          ext4_only
odroid8   192.168.1.2/24 192.168.1.254 00:1e:06:49:05:77 odroid-hc4         ext4_only
odroid11  10.0.6.11/16   10.0.0.2      0:1e:6:10:06:11   odroid-c2          ext4_only
pine1     10.0.6.21/16   10.0.0.2      0:1e:6:10:06:21   pine64             ext4_only
pine2     10.0.6.22/16   10.0.0.2      0:1e:6:10:06:22   pine64             ext4_only
pine3     192.168.1.7/24 192.168.1.254 0:1e:6:10:06:23   pine64             ext4_only
rock1     10.0.6.24/16   10.0.0.2      3e:2a:57:bf:39:46 rock64             ext4_only
rpi1      10.0.6.31/16   10.0.0.2      b8:27:eb:5c:84:bd rpi-3              vfat_ext2
orangepi2 10.0.6.42/16   10.0.0.2      02:01:63:69:fe:74 orangepi-zero-plus ext4_only
EOF
)

MACADDR_WITH_SPACES=$(echo $MACADDR|sed 's/:/ /g')

case $PLATFORM in
rock64)
  ARCH_LINUX_PLATFORM=aarch64
  SED_CMD="sed -i \"s/setenv macaddr .*/setenv macaddr ${MACADDR_WITH_SPACES}/\""
  EXTRA_FIRSTBOOT="pacman -Sy uboot-rock64 --noconfirm; $SED_CMD /boot/boot.txt"
  ;;
pine64)
  ARCH_LINUX_PLATFORM=aarch64
  # pacman -S ethtool
  # ethtool -s eth0 autoneg off speed 100 duplex full
  EXTRA_FIRSTBOOT="pacman -Sy uboot-pine64 --noconfirm"
  ;;
orangepi-zero-plus)
  ARCH_LINUX_PLATFORM=aarch64
  UBOOT_VERSION="2019.04-1"
  EXTRA_FIRSTBOOT="pacman -Sy uboot-${PLATFORM}-${UBOOT_VERSION}-aarch64.pkg.tar.xz"
  ;;
odroid-hc4)
  ;;
odroid-c2)
  ARCH_LINUX_PLATFORM=$PLATFORM
  EXTRA_FIRSTBOOT="sed -i 's/setenv nographics \"0\"/setenv nographics \"1\"/' /boot/boot.ini"
  ;;
*)
  ARCH_LINUX_PLATFORM=$PLATFORM
  ;;
esac


echo $HOSTNAME $IP $GATEWAY $MACADDR $PLATFORM $ARCH_LINUX_PLATFORM $PART_SCHEME


SDX=/dev/mmcblk0
SDX1=${SDX}p1
SDX2=${SDX}p2

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


w
__EOF__


#cd /tmp
mkdir -p root

mkfs.ext4 -O ^metadata_csum,^64bit $SDX1
mount $SDX1 root

ARCHLINUX_MIRROR="nl2.mirror.archlinuxarm.org"
ARCHLINUX_MIRROR="os.archlinuxarm.org"
ARCHLINUX_MIRROR="dk.mirror.archlinuxarm.org"

curl -L -O http://${ARCHLINUX_MIRROR}/os/ArchLinuxARM-${ARCH_LINUX_PLATFORM}-latest.tar.gz

bsdtar -xzvpf ArchLinuxARM-${ARCH_LINUX_PLATFORM}-latest.tar.gz -C root

(cd root
 cat >firstboot.sh <<EOF
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu --noconfirm
pacman -S uboot-tools --noconfirm
pacman -S ansible --noconfirm
$EXTRA_FIRSTBOOT
EOF
 chmod +x firstboot.sh
 tar cvfp - /etc/systemd/network/eth0.network /root/.ssh /etc/ssh/sshd_config /etc/ssh/ssh_host_* | tar xvfp -
 echo $HOSTNAME >etc/hostname
 #perl setenv macaddr "$MACADDR" boot/boot.txt
 cat >etc/systemd/network/eth0.network <<EOF
[Match]
Name=eth0

[Network]
Address=$IP
Gateway=$GATEWAY
EOF
 mkdir -p root/.ssh
 cat >root/.ssh/authorized_keys<<EOF
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPzHP3wE8qlmB9QLwKMK5dIb/Azej+aIg6UmL6YRoHE51ISI4SQc6gBYCfucB9isVns/ucejDRdVQBtthZd/RTM= markus@pro
EOF

cat <<EOF >>etc/systemd/resolved.conf
DNSSEC=false
EOF
)


case $PLATFORM in
orangepi-zero-plus)
# from https://github.com/RoEdAl/alarm-uboot-sunxi-aarch64
  curl -L -O https://github.com/RoEdAl/alarm-uboot-sunxi-aarch64/releases/download/v${UBOOT_VERSION}/uboot-${PLATFORM}-${UBOOT_VERSION}-aarch64.pkg.tar.xz
  bsdtar -xf uboot-${PLATFORM}-${UBOOT_VERSION}-aarch64.pkg.tar.xz boot/u-boot-sunxi-with-spl.bin boot/boot.scr
  dd if=boot/u-boot-sunxi-with-spl.bin of=$SDX bs=8k seek=1
  cp boot/boot.scr root/boot
  sync
  umount root
  ;;
rock64)
  curl http://${ARCHLINUX_MIRROR}/os/rockchip/boot/rock64/boot.scr > root/boot/boot.scr
  umount root
  curl -L -O http://${ARCHLINUX_MIRROR}/os/rockchip/boot/rock64/idbloader.img
  curl -L -O http://${ARCHLINUX_MIRROR}/os/rockchip/boot/rock64/uboot.img
  curl -L -O http://${ARCHLINUX_MIRROR}/os/rockchip/boot/rock64/trust.img
  dd if=idbloader.img of=$SDX seek=64 conv=notrunc
  dd if=uboot.img of=$SDX seek=16384 conv=notrunc
  dd if=trust.img of=$SDX seek=24576 conv=notrunc
  ;;
odroid-xu3)
  cd root/boot
  ./sd_fusing.sh $SDX
  cd ../..
  umount root
  ;;
odroid-c2)
  cd root/boot
  ./sd_fusing.sh $SDX
  cd ../..
  umount root
  ;;
odroid-n2)
  mkdir boot
  mv root/boot/* boot
  dd if=boot/u-boot.bin of=/dev/sdX conv=fsync,notrunc bs=512 seek=1
  ;;
pine64)
  curl http://${ARCHLINUX_MIRROR}/os/allwinner/boot/pine64/boot.scr > root/boot/boot.scr
  umount root
  curl -L -O http://${ARCHLINUX_MIRROR}/os/allwinner/boot/pine64/u-boot-sunxi-with-spl.bin
  dd if=u-boot-sunxi-with-spl.bin of=$SDX bs=8k seek=1
  ;;
*)
  ;;
esac
