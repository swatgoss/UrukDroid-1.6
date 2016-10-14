#!/bin/sh

services="compcache cpugovernor dvb incrond iptables ntfs cifs samba sshd swap openvpn mediascanner vpnc nfs4 wpa"

for a in $services; do
	echo -n $a" "
	status=`/etc/uruk.d/$a UIstatus force`
	echo $status
	setprop urukdroid.services.$a $status
done
