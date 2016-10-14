#!/bin/sh

PREFS="/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml"
IS_BLUETOOTH=$(grep '<string name="connection">Bluetooth' $PREFS | wc -l)

if [ "$IS_BLUETOOTH" -eq 1 ]
then
    PHONE_ID=$(grep '<string name="phone_id">' $PREFS | sed -e 's#<string name="phone_id">\(.*\)</string>$#\1#')
    CHANNEL=$(grep '<int name="channel"' $PREFS | sed -e 's#<int name="channel" value="\(.*\)" />$#\1#')

    if [ "$CHANNEL" -le -1 ]
    then
        /system/xbin/pand --connect $PHONE_ID -n
        if [ `/system/xbin/pand --list | wc -l` -ne 0 ]
        then
            /system/bin/dhcpcd bnep0
            DNS1=$(/system/bin/getprop "dhcp.bnep0.dns1")
            DNS2=$(/system/bin/getprop "dhcp.bnep0.dns2")
            /system/bin/setprop "net.dns1" "$DNS1"
            /system/bin/setprop "net.dns2" "$DNS2"
            /system/bin/setprop "archos.tetherState" "connected"
        fi
    else
        /system/xbin/dund --connect $PHONE_ID --channel $CHANNEL --pppd /system/bin/pppd /dev/rfcomm0 115200 mru 1280 mtu 1280 call tether
    fi
else
    insmod /lib/modules/musb_hdrc.ko mode_default=1
    insmod /lib/modules/cdc-acm.ko
    /system/bin/pppd /dev/ttyACM0 460800 call tether
fi
