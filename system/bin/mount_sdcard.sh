#!/bin/sh
#
# Service that waits for Vold to mount /mnt/storage AND mount's sdcard manually
#
# This is part of Uruk-Droid Android distribution
# Ver: 1.3 (22.03.2011) by Adrian (Sauron) Siemieniak
#

wait_counter=10
wait_delay=10
mount_dir=/mnt/storage/sdcard
mount_dev=/dev/block/mmcblk2p1
mount_opt_ext4="-t ext4 -o noatime,nodiratime,nosuid,user_xattr"
#mount_opt_ext4="-t ext4 -o noatime,nodiratime,nosuid"
mount_opt_vfat="-t vfat -o rw,nosuid,nodev,noexec,noatime,nodiratime,uid=1000,gid=1015,dmask=0000,allow_utime=0022,iocharset=iso8859-1,utf8,errors=remount-ro"

# To check vold stuff
vold_file=/system/etc/vold.fstab
vold_stock=/system/etc/vold.fstab-stock
vold_ext4=/system/etc/vold.fstab-ext4

# To enable debug - uncomment line below or enter argument debug
#DEBUG=1

if [ "$1" = "debug" ]; then
	DEBUG=1
fi

if [ $DEBUG ] ; then echo "--- Running in debug mode ---"; fi

if [ `/bin/mount | grep -c $mount_dir` -gt 0 ] ; then
	echo "Device already mounted"
	exit
fi

if [ $DEBUG ] ; then echo "Debug: now will wait for device..."; fi

while [  $wait_counter -gt 0 ]; do
	if [ `grep -c '/mnt/storage vfat' /proc/mounts` -gt 0 -o `grep -c '/mnt/storage ext' /proc/mounts` -gt 0 ]; then
		# If not $mount_dir - try to create it
		if [ ! -d $mount_dir ]; then
			if [ $DEBUG ] ; then echo "Debug: No $mount_dir found, creating proper directory"; fi
			mkdir $mount_dir
		fi
		# To be sure mkdir of $mount_dir has successed
		if [ -d $mount_dir ]; then
			if [ -b $mount_dev ]; then
				dev_scan=`dd if=$mount_dev bs=1k count=10 2>/dev/null | file -`
				if [ $DEBUG ] ; then echo "Debug: $dev_scan"; fi
				is_ext4=`echo $dev_scan | grep -c ext4`
				# This will also work for not vfat formatted partitions (like camera sdcard etc)
				is_vfat=`echo $dev_scan | egrep -c 'FAT|mkdos'`
				if [ $is_ext4 -gt 0 ]; then
					echo "Mounting "$mount_dev" as ext4"
					# Just check if symlinks are ok for ext4
					if [ ! $vold_file -ef $vold_ext4 ]; then
						echo "Fixing vold fstab link"
						rm $vold_file
						ln -s $vold_ext4 $vold_file
					fi
					fsck.ext4 -y $mount_dev
					mount $mount_opt_ext4 $mount_dev $mount_dir
					# Make sure it's writtable
					if [ $DEBUG ] ; then echo "Debug: ".`ls -ld $mount_dir`; fi
					chown 1000:1015 $mount_dir
					chmod ug=rwx $mount_dir
					# Call swap service - if it happend to use sdcard filesystem
					/etc/uruk.d/swap start
				else
					if [ $DEBUG ] ; then echo "Debug: It's not ext4 device"; fi
					# Just check if symlinks are ok for vfat
					# It's was orignaly in vfat section - but since it can be "any" other filesystem then ext4 - it's moved here
					if [ ! $vold_file -ef $vold_stock ]; then
						echo "Fixing vold fstab link"
						rm $vold_file
						ln -s $vold_stock $vold_file
					fi					
				fi
				if [ $is_vfat -gt 0 ]; then
					echo "NOT mounting vfat - leaving for Vold"
#					echo "Mounting "$mount_dev" as vfat"
#					/bin/mount $mount_opt_vfat $mount_dev $mount_dir
				else
					if [ $DEBUG ] ; then echo "Debug: It's not vfat device"; fi
				fi
			else
				if [ $DEBUG ] ; then echo "Debug: No $mount_dev found"; fi
			fi
		# If no $mount_dir - make it verbose
		else
			echo "Failed to create $mount_dir"
		fi
		break
	fi
	if [ $DEBUG ] ; then echo "Debug: waiting $wait_delay seconds for mount point ($wait_counter to go)"; fi
	sleep $wait_delay
	let wait_counter-=1
done

