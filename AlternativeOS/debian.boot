#!/bin/sh

#
# Script to boot alternative OS: Debian
#
# OS_Name: Debian
# OS_Desc: Debian armel
#
# Ver: 1.3 (19.08.2011) Adrian (Sauron) Siemieniak
#

set -xv

# Device where debian image reside (storagefs on sdcard in example)
debian_dev="/dev/mmcblk2p1"
debian_dev_mountp="/mnt/card"
# Debian image file
debian_img="rootfs.img"
debian_mountp="/AlternativeOS"

# Mounting device where image file reside
$MOUNT $debian_dev $debian_dev_mountp || log_msg "Failed to mount device with debian file"

sync

# Creating loop device
$LOSETUP /dev/loop0 $debian_dev_mountp"/"$debian_img || log_msg "Mounting AlternativeOS partition failed"

sync

# Mounting debian rootfs disk
$MOUNT /dev/loop0 $debian_mountp

# It mount went ok
if [ $! -eq 0 ]; then
	# Switching to debian
	exec /sbin/switch_root $debian_mountp /sbin/init
fi

# IF it fails - we can do some clean ups
$UMOUNT $debian_mountp
$UMOUNT $debian_dev_mountp
