#!/bin/sh

# Deactivate full fsck every 20 mounts or every 6 months.
# Do it only if it isnecessary (It takes 2 seconds on boot).

TUNE2FS_CMD="/system/bin/tune2fs"
DEV="/dev/block/sda1"

setopt()
{
	$TUNE2FS_CMD -c -1 -i 0 $DEV
}

result="`$TUNE2FS_CMD -l $DEV`"

echo -e "$result"|grep "Maximum mount count"|grep -q "\-1"
if [ $? -ne 0 ];then
	setopt
	exit 0
fi

echo -e "$result"|grep "Check interval"|grep -q "none"
if [ $? -ne 0 ];then
	setopt
fi

exit 0
