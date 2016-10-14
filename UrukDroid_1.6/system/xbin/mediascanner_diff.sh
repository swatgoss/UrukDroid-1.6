#!/bin/sh
#
# UrukDroid subsystem
# 1.0 (31.01.2011) Adrian (Sauron) Siemieniak
#
# Not best thing to do - but bettery anyway that orignal ;)
#

# Archos software does strange things while this file missing
touch /tmp/mediascanner.diff.final

#echo "Arg:"$@ >>/cos.log

MEDIA_LOCK="/var/run/mediascanner.lock"
MEDIA_UNLOCK="/tmp/mediascanner-unlock.key"

# Load config file
. /etc/uruk.conf/mediascanner

# Check if there is no another scan in progress
if [ -f $MEDIA_LOCK ]; then
	echo "MediaScanner already running..."
	exit
fi
touch $MEDIA_LOCK

# If request came from UrukService
if [ "$1" = "ondemand" ]; then
	nice -19 ionice -c3 /system/xbin/mediascanner_diff-uruk.sh 2
	nice -19 ionice -c3 /system/xbin/mediascanner_diff-uruk.sh 3
fi

# If service is enabled - let Archos updater go
#if [ $service_enabled -gt 0 ]; then
#	nice -19 ionice -c3 /system/xbin/mediascanner_diff-uruk.sh $@
#fi

# Check if we have temporary permision for scan...
if [ $service_enabled -gt 0 -o `find /tmp -cmin -5 -name mediascanner-unlock.key | wc -l` -gt 0 ]; then
	nice -19 ionice -c3 /system/xbin/mediascanner_diff-uruk.sh $@
fi

if [ "$1" = "3" ];then
	rm $MEDIA_UNLOCK 2>/dev/null
fi

rm $MEDIA_LOCK
