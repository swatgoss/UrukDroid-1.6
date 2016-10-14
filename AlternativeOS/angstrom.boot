#!/bin/sh

#
# Script to boot alternative OS: Debian
#
# OS_Name: Angstrom
# OS_Desc: Angstrom 11.10 (Oneiric Ocelot)
#
# Ver: 1.0 (11.01.2012) Adrian (Sauron) Siemieniak
#

set -xv

# Device where Angstrom image reside (storagefs on sdcard in example)
angstrom_dev="/dev/mmcblk2p1"
angstrom_dev_mountp="/mnt/card"
# Debian image file
angstrom_img="angstrom.img"
angstrom_mountp="/AlternativeOS"

# Mounting device where image file reside
$MOUNT $angstrom_dev $angstrom_dev_mountp || log_msg "Failed to mount device with Angstrom file"

sync

# Creating loop device
$LOSETUP /dev/loop0 $angstrom_dev_mountp"/"$angstrom_img || log_msg "Mounting AlternativeOS partition failed"

sync

# Mounting angstrom rootfs disk
$MOUNT /dev/loop0 $angstrom_mountp

# It mount went ok
if [ `mount | grep -c /dev/loop0` -eq 1 ]; then
	# Switching to debian
	sync
	exec /sbin/switch_root $angstrom_mountp /sbin/init.sysvinit
fi

# IF it fails - we can do some clean ups
$UMOUNT $angstrom_mountp
$UMOUNT $angstrom_dev_mountp
