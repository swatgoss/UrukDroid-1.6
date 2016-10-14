#!/bin/sh


# Sometimes Uruk gets up in ro... fix
while [ `mount | grep "on / type ext" | grep -c ro` -gt 0 ]; do
	echo "Remount rootfs RW mode..."
        mount -o remount,rw /
	date >>/remount.log
	sleep 2
done

