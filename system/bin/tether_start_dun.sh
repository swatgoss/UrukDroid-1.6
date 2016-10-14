#!/bin/sh

# $1 is the mac address of the phone
# $2 is the channel
# $3 is the user (not a mandatory argument)
# $4 is the password (not a mandatory argument)
# $5 is the novj option
MAC=$1
CHANNEL=$2
USER=$3
PWD=$4
NOVJ=$5

if [ "$USER" = "" ]
then
    /system/xbin/dund --connect $MAC --channel $CHANNEL --pppd /system/bin/pppd /dev/rfcomm0 115200 mru 1280 mtu 1280 $NOVJ call tether
else
    /system/xbin/dund --connect $MAC --channel $CHANNEL --pppd /system/bin/pppd /dev/rfcomm0 115200 mru 1280 mtu 1280 $NOVJ name $USER password $PWD call tether
fi
