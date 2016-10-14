#!/bin/sh
#
#### Information
#  Ver: 1.0 (6.05.2011)
#   By: Adrian (Sauron) Siemieniak
# Desc: Common definition and function for UrukDroid services
####

if [ -f $URUKCONFIG ]; then
        . $URUKCONFIG
else
        echo "No required config file in $URUKCONFIG"
        exit 1
fi

# Check is service is enabled at all
if [ "$service_enabled" != "1" -a "$2" != "force" -a "$1" != "status" -a "$1" != "stats" ]; then
        echo "Uruk-Iptables: This module is disabled in $URUKCONFIG"
        exit 1
fi


check_fail(){
        status="$1"
	msg_fail="$2"
	msg_ok="$3"

	if [ "$status" != "0" ]; then
		if [ "$msg_fail" != "" ]; then
			echo $msg_fail
		fi
		exit 1
	else
		if [ "$msg_ok" != "" ]; then
			echo $msg_ok
		fi
	fi
}

