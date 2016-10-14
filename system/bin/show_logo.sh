#!/bin/sh
#
# UrukDroid boot logo display service
# Ver: 1.0 (27.07.2011) Adrian Siemieniak
#

FBDEV=/dev/graphics/fb0
DEVICE=`/usr/bin/get_info p`
BOOTLOGO1=$LOGODIR$DEVICE"_UrukDroid_1.rgz"
BOOTLOGO2=$LOGODIR$DEVICE"_UrukDroid_2.rgz"
INSTALL_LOCK="/postinstall.lock"
VERSION=`/usr/local/bin/cat /etc/urukdroid-version|/usr/local/bin/awk '{print $2}'`

/usr/local/bin/pkill -9 auid
mknod /dev/fb0 c 29 0
/system/bin/auid
/system/bin/aui --setvideooutput 1
/system/bin/aui -c bannerprogress -t "UrukDroid $VERSION Rootfs: Init..."

chown root /mnt/rawfs/params 
/usr/local/sbin/reboot_into -s "sde"

if [ -f $INSTALL_LOCK ]; then
	/system/bin/aui -c bannerprogress -t "UrukDroid $VERSION Rootfs: Postinstallation in progress. Please wait..."
	sleep 180
	rm $INSTALL_LOCK
else
	sleep 20
fi
/usr/local/bin/pkill -9 auid

# Sometimes Uruk gets up in ro... fix
if [ `mount | grep "on / type ext" | grep -c ro` -gt 0 ]; then
	/system/bin/remount_rw.sh &
fi
