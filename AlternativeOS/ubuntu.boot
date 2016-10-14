#!/bin/sh

#
# Script to boot alternative OS: Debian
#
# OS_Name: Ubuntu
# OS_Desc: Ubuntu 11.10 (Oneiric Ocelot)
#
# Ver: 1.0 (11.01.2012) Adrian (Sauron) Siemieniak
#

set -xv

# Device where ubuntu image reside (storagefs on sdcard in example)
ubuntu_dev="/dev/mmcblk2p1"
ubuntu_dev_mountp="/mnt/card"
# Debian image file
ubuntu_img="ubuntu.img"
ubuntu_mountp="/AlternativeOS"

# Mounting device where image file reside
$MOUNT $ubuntu_dev $ubuntu_dev_mountp || log_msg "Failed to mount device with ubuntu file"

sync

# Creating loop device
$LOSETUP /dev/loop0 $ubuntu_dev_mountp"/"$ubuntu_img || log_msg "Mounting AlternativeOS partition failed"

sync

# Mounting debian rootfs disk
$MOUNT /dev/loop0 $ubuntu_mountp

# It mount went ok
if [ `mount | grep -c /dev/loop0` -eq 1 ]; then
	# Switching to debian
	sync
	exec /sbin/switch_root $ubuntu_mountp /sbin/init
fi

# IF it fails - we can do some clean ups
$UMOUNT $ubuntu_mountp
$UMOUNT $ubuntu_dev_mountp
