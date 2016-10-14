#!/bin/sh

# $1 is the mac address of the phone
/system/bin/pand --connect $1 -n
if [ `/system/bin/pand --list | wc -l` -ne 0 ]
then
    /system/bin/dhcpcd bnep0
    DNS1=$(/system/bin/getprop "dhcp.bnep0.dns1")
    DNS2=$(/system/bin/getprop "dhcp.bnep0.dns2")
    /system/bin/setprop "net.dns1" "$DNS1"
    /system/bin/setprop "net.dns2" "$DNS2"
    /system/bin/setprop "archos.tetherState" "connected"
fi
