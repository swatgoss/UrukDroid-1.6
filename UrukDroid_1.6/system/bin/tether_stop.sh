#!/bin/sh

if [ "$1" = "DUN" ]
then
    /system/xbin/dund --killall
elif  [ "$1" = "PAN" ]
then
    /system/bin/pand --killall
else
	if [ `cat /proc/modules | grep -c rndis_host` -ne 0 ]; then

		########## RNDIS over USB mode ##########
		TETHER_PID=`/usr/local/bin/busybox pidof tether_start_usb.sh`
		log -t USBTether "PID of tether_start_usb.sh is: $TETHER_PID"
		kill -9 $TETHER_PID
		if [ $? -eq 0 ]; then
			log -t USBTether "tether_start_usb.sh terminated succesffully"
		else
			log -t USBTether "Unable to terminate tether_start_usb.sh"
		fi
		setprop "archos.tetherState" "disconnected"
		log -t USBTether "Set tethering state to disconnected"
		/system/bin/rmmod rndis_host
		/system/bin/rmmod cdc_ether
		/system/bin/rmmod usbnet
		/system/bin/rmmod mii
		/system/bin/rmmod musb_hdrc && /system/bin/insmod /lib/modules/musb_hdrc.ko mode_default=1
		log -t USBTether "Re-loaded USB controller driver in DMA mode"
		setprop "dhcp.usb0.pid" ""
		setprop "dhcp.usb0.reason" ""
		setprop "dhcp.usb0.dns1" ""
		setprop "dhcp.usb0.dns2" ""
		setprop "dhcp.usb0.dns3" ""
		setprop "dhcp.usb0.dns4" ""
		setprop "dhcp.usb0.ipaddress" ""
		setprop "dhcp.usb0.gateway" ""
		setprop "dhcp.usb0.mask" ""
		setprop "dhcp.usb0.leasetime" ""
		setprop "dhcp.usb0.server" ""
		setprop "dhcp.usb0.result" ""
		log -t USBTether "Nulled dhcp.usb0 class of properties"
	elif [ `cat /proc/modules | grep -c usbserial` -ne 0 ]; then

			########## 3G modem mode  ##########
			TETHER_PID=`/usr/local/bin/busybox pidof pppd`
			log -t USBTether "PID of pppd is: $TETHER_PID"
			kill -15 $TETHER_PID
			if [ $? -eq 0 ]; then
				log -t USBTether "pppd terminated succesffully"
			else
				log -t USBTether "Unable to terminate pppd"
			fi
			rmmod usbserial
			log -t USBTether "Unloaded usbserial module"
		elif [ "`getprop "3Gmod.enable"`" != "on" ]; then

			########## PPP over USB (Archos default mode) ##########
			kill -9 $(pidof pppd)
			/system/bin/rmmod cdc_acm

			# !!!! Following command might be a bug on Archos side since it completly unloads USB driver until reboot,
			# !!!! or next tethering attempt.
			# !!!! Comment it out, based on own preference and expirience. 
			/system/bin/rmmod musb_hdrc
		fi
fi
