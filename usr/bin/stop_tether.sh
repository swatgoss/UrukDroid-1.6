#!/bin/sh

FILE="/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml"
IS_BLUETOOTH=$(grep '<string name="connection">Bluetooth' $FILE | wc -l)

if [ "$IS_BLUETOOTH" -eq 1 ]
then
    # Bluetooth tethering
    if [ `/system/xbin/dund --list | wc -l` -ne 0 ]
    then
        # dund is running
        /system/xbin/dund --killall
    elif [ `/system/xbin/pand --list | wc -l` -ne 0 ]
    then
        # pand is running
        /system/xbin/pand --killall
    fi
else
    # USB tethering
    kill -9 $(pidof pppd)
    /system/bin/rmmod cdc_acm
    /system/bin/rmmod musb_hdrc
fi

/system/bin/setprop net.dns1 ""
/system/bin/setprop net.dns2 ""
