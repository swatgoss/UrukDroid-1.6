#!/bin/sh
#
# 1.1 (29.04.2011) Adrian (Sauron) Siemieniak
#
# Script copies external UrukDroid installation to internal


# Check if internal looks ok
cnt=`fdisk -l /dev/block/mmcblk1 | grep /dev/block/mmcblk1p | grep -c Linux`
if [ $cnt -lt 2 ]; then
	echo "Error: Your internal installation does not seems to be right"
	exit 1
fi

# Check if we booted external
cnt=`head -3 /proc/mounts |grep " / " | grep ext4 | grep -c mmcblk2`
if [ $cnt -ne 1 ]; then
	echo "Error: To copy installation you must boot from external Uruk"
	exit 1
fi


old_root=/dev/block/mmcblk2p2
old_data=/dev/block/mmcblk2p3
new_root=/dev/block/mmcblk1p2
new_data=/dev/block/mmcblk1p3

echo "Mounting rootfs partitions..."
cd /mnt
mkdir disk1 disk2 2>/dev/null
mount $old_root disk1
mount $new_root disk2
echo "Erasing old filesystem..."
rm -rf disk2/*
echo "Copying rootfs..."
rm -f disk1/cache/* >/dev/null 2>&1
ionice -c3 cp -rp disk1/* disk2/
umount disk1
umount disk2

echo "Mounting datafs partitions..."
mount $old_data disk1
mount $new_data disk2
echo "Erasing old filesystem..."
rm -rf disk2/*
echo "Copying datafs..."
ionice -c3 cp -rp disk1/* disk2/
umount disk1
umount disk2

rm -rf disk1 disk2
echo "You can poweroff device, remove SDcard and boot to internal..."
