#!/bin/sh

# This script is used to get simcard info by sending AT commands to
# the phone. Here we set up the /dev entry so the Java code can write
# and read on this entry.

if [ $1 = "up" ]
then
    if [ $# -eq 3 ]
    then
        rfcomm connect 0 $2 $3 &
        timeout=5
        /usr/bin/test -c /dev/rfcomm0
        while [ $? -gt 0 -a $timeout -gt 0 ]
        do
            sleep 1
            timeout=$(($timeout-1))
            /usr/bin/test -c /dev/rfcomm0
        done
        chmod 777 /dev/rfcomm0
    else
        insmod /lib/modules/cdc-acm.ko
        timeout=5
        /usr/bin/test -c /dev/ttyACM0
        while [ $? -gt 0 -a $timeout -gt 0 ]
        do
            sleep 1
            timeout=$(($timeout-1))
            /usr/bin/test -c /dev/ttyACM0
        done
        chmod 777 /dev/ttyACM0
    fi
else
    ret=$(lsmod | grep "cdc_acm" | wc -l)
    if [ $ret -eq 0 ]
    then
        killall -9 rfcomm
    else
        rmmod cdc_acm
    fi
fi
