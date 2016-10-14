#!/bin/sh 
# tiwlan_check.sh : 25/01/10
# g.revaillot, revaillot@archos.com

TIWLAN_TEMPLATE="/etc/tiwlan.ini"
TIWLAN_USER="/data/misc/wifi/tiwlan.ini"

if [ ! -f $TIWLAN_USER ] ; then
	cp $TIWLAN_TEMPLATE $TIWLAN_USER
fi

chmod a+rx /data/misc/wifi/
chmod 666 $TIWLAN_USER

