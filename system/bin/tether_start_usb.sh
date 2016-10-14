#!/bin/sh

# $1 is the user (not a mandatory argument)
# $2 is the password (not a mandatory argument)

PORT3G=`getprop "3Gmod.usbPort"`

####### PPP over USB mode  (Archos default and only-one) #######

#
# Ver: 1.1 (06.05.2011)
#

log -t USBTether "Trying PPP USB tethering mode"

modprobe musb_hdrc mode_default=1
modprobe cdc-acm

sleep 1

if [ -c "/dev/ttyACM0" ]; then
	if [ $# -eq 0 ]; then
		/system/bin/pppd /dev/ttyACM0 460800 call tether
		RET=$?
	else
		/system/bin/pppd /dev/ttyACM0 460800 name $1 password $2 debug call tether
		RET=$?
	fi
	log -t USBTether "pppd exited with code $RET. PPP tethering finished."
else
	####### RNDIS over USB mode #######

	log -t USBTether "No PPP USB tethering device detected. Trying RNDIS USB tethering mode"
	if [ `cat /proc/modules | grep -c cdc_acm` -ne 0 ]; then
		rmmod cdc-acm
	fi
	if [ `cat /proc/modules | grep -c rndis_host` -ne 0 ]; then
		log -t USBTether "RNDIS support already loaded."
	else
		modprobe mii
		modprobe usbnet
		modprobe cdc_ether
		modprobe rndis_host
	fi
	if [ `cat /proc/modules | grep -c rndis_host` -eq 0 ]; then
		log -t USBTether "Unable to load RNDIS support"
		exit -1
	fi
	N=1
	while [ $N -le 2 ]
	do
		if [ `ifconfig -a | grep -c usb0` -eq 0 ]; then
			log -t USBTether "1st waiting for RNDIS device to show up max 2 sec. Elapsed: $N"
			N=`expr $N + 1`
			sleep 1
		else 
			log -t USBTether "Found RNDIS device usb0"
			break
		fi
	done
	if [ `ifconfig -a | grep -c usb0` -eq 0 ]; then

		####### 3G modem mode #######

		log -t USBTether "No RNDIS capable device detected. Trying 3G modem USB tethering mode"
		modprobe -r rndis_host
		modprobe -r cdc_ether
		modprobe -r usbnet
		modprobe -r mii
		/system/xbin/3Gmodem_init.sh
		RET=$?
		if [ $RET -ne 0 ]; then
			log -t USBTether "Unable to initialize 3G modem"
			exit $RET
		fi
		log -t USBTether "Starting pppd on modem port /dev/ttyUSB${PORT3G}"
		if [ $# -eq 0 ]; then
			/system/bin/pppd /dev/ttyUSB${PORT3G} 921600 call tether
			RET=$?
		else
			/system/bin/pppd /dev/ttyUSB${PORT3G} 921600 name $1 password $2 call tether
			RET=$?
		fi
		if [ `cat /proc/modules | grep -c usbserial` -ne 0 ]; then
			rmmod usbserial
		fi
		log -t USBTether "pppd exited with status $RET. 3G modem tethering stopped."
		exit 0
	fi

	####### RNDIS over USB mode continued #######

	log -t USBTether "Reloading USB controller driver to PIO mode"
	modprobe -r musb_hdrc && modprobe musb_hdrc mode_default=1 use_dma=n
	if [ `cat /proc/modules | grep -c musb_hdrc` -eq 0 ]; then
		log -t USBTether "Unable to re-load USB driver in PIO mode"
		exit -1
	fi
	N=1
	while [ $N -le 3 ]
	do
		if [ `ifconfig -a | grep -c usb0` -eq 0 ]; then
			log -t USBTether "2nd waiting for usb0 to show up max 3 sec. Elapsed: $N"
			N=`expr $N + 1`
			sleep 1
		else 
			log -t USBTether "Found usb0 device"
			break
		fi
	done
	if [ `ifconfig -a | grep -c usb0` -eq 0 ]; then
		log -t USBTether "No RNDIS capable device detected after USB controllerd driver re-load."
		exit -1
	fi
	dhcpcd usb0
	if [ `ifconfig -a usb0 | grep -c 'inet addr:'` -eq 0 ]; then
		log -t USBTether "Unable to connect remote DHCP"
		exit -1
	else
		DNS1=`getprop "dhcp.usb0.dns1"`
		log -t USBTether "Got DNS Server: $DNS1"
		setprop "archos.tetherState" "connected"
		log -t USBTether "Connected by Ethernet over USB tethering"
		setprop "net.dns1" $DNS1
		log -t USBTether "Updated net.dns1 to $DNS1"
		while [ 1 ]
		do
			CURR_DNS1=`getprop "net.dns1"`
			if [ "$CURR_DNS1" != "$DNS1" ]; then
				setprop "net.dns1" "$DNS1"
				log -t USBTether "Updated net.dns1 because something changed it"
			fi
			sleep 10
		done
	fi		
fi

