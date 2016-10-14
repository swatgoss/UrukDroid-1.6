#!/bin/sh

KNOWNMODEMS=`ls /system/etc/usb_modeswitch.d`
USBDEVICES=`cat /proc/bus/usb/devices`

if [ "${KNOWNMODEMS}" = "" -o "${USBDEVICES}" = "" ]; then
	echo "No '/system/etc/usbmodeswitch.d/*' files or no USB device list"
	exit 25
fi

DEVFOUND=0
for MODEL in ${KNOWNMODEMS}
do
	DEFIDVENDOR=`echo ${MODEL} | cut -d _ -f 1`
	DEFIDPRODUCT=`echo ${MODEL} | cut -d _ -f 2`
	if [ `echo $USBDEVICES | grep -c "Vendor=${DEFIDVENDOR} ProdID=${DEFIDPRODUCT}"` -ne 0 ]; then
		echo "Supported USB device found !!!! VendorID: ${DEFIDVENDOR} - ProductID: ${DEFIDPRODUCT}"
		DEVFOUND=1
		break
	fi
done

if [ ${DEVFOUND} -ne 1 ]; then
	echo "3Gmodem_detect.sh did not found usable USB device connected"
	exit 20
fi

NEWIDVENDOR=`cat /system/etc/usb_modeswitch.d/$MODEL | grep "TargetVendor=" | cut -d x -f 2`
NEWIDPRODUCT=`cat /system/etc/usb_modeswitch.d/$MODEL | grep "TargetProduct=" | cut -d x -f 2`

if [ -z $NEWIDVENDOR ]; then
	NEWIDVENDOR=${DEFIDVENDOR}
	echo "New VendorID not detected in usb-modeswitch config file. Set to value of old one !"
else
	echo "New VendorID: ${NEWIDVENDOR}"
fi
if [ -z $NEWIDPRODUCT ]; then
	NEWIDPRODUCT="not-detected"
	echo "New ProductID not detected in usb-modeswitch config file. Try to detect it later !"
else
	echo "New ProductID: ${NEWIDPRODUCT}"
fi

if [ `cat /proc/modules | grep -c "option"` -ne 0 ]; then
	rmmod option
fi
if [ `cat /proc/modules | grep -c "usbserial"` -ne 0 ]; then
	rmmod usbserial
fi
if [ `cat /proc/modules | grep -c "usbstorage"` -ne 0 ]; then
	rmmod usbstorage
fi
echo "Switching device to usbserial mode !"
/usr/local/sbin/usb_modeswitch -c /system/etc/usb_modeswitch.d/${MODEL}

sleep 2

if [ "$NEWIDPRODUCT" = "not-detected" ]; then
	NEWIDPRODUCT=`cat /proc/bus/usb/devices | grep "Vendor=${NEWIDVENDOR} ProdID=" | cut -d = -f 3 | cut -c 1-4`
	echo "Detected ProductID of a switched device: ${NEWIDPRODUCT}"
fi
if [ "${DEFIDPRODUCT}" = "${NEWIDPRODUCT}" ]; then
	echo "ProductID before and after usb-switching is same. Meybe device doesn't need switching !"
fi
if [ "${NEWIDVENDOR}" = "" -o "${NEWIDPRODUCT}" = "" ]; then
	echo "Couldn't detect Vendor or Product ID of switched device. Exiting."
	exit 10 
fi
if [ `cat /proc/bus/usb/devices | grep -c "Vendor=${NEWIDVENDOR} ProdID=${NEWIDPRODUCT}"` -ne 0 ]; then
	echo "USB device VendorID: ${NEWIDVENDOR} ProdID: ${NEWIDPRODUCT}. Probing serial mode"
	insmod /lib/modules/usbserial.ko vendor=0x${NEWIDVENDOR} product=0x${NEWIDPRODUCT}
	if [ `cat /proc/modules | grep -c "usbserial"` -eq 0 ]; then
		echo "Failed inserting usbserial.ko module with adequate parameters. Exiting."
		exit 15
	fi
	N=1
	while [ $N -le 5 ]
	do
		if [ `ls -l /dev/ttyUSB* | wc -l` -ne 0 ]; then
			echo "Found required /dev/ttyUSB{X} device nodes."
			break
		else
			echo "Failed to find required /dev/ttyUSB{X} device nodes in max 5 sec. Elapsed $N."
			sleep 1
			N=`expr $N + 1`
		fi
	done
	echo "usbserial.ko module registered and /dev/ttyUSB{X} device nodes created sucessfully." 
	echo -n "Writing default configuration to '/data/local.prop' file ....."
	echo "#" >> /data/local.prop
	echo "# START of Uruk-Droid USB 3G modem tethering support" >> /data/local.prop
	echo "#" >> /data/local.prop
	echo "3Gmod.enable=on" >> /data/local.prop
	echo "3Gmod.defVendorID=${DEFIDVENDOR}" >> /data/local.prop
	echo "3Gmod.defProductID=${DEFIDPRODUCT}" >> /data/local.prop
	echo "3Gmod.modemVendorID=${NEWIDVENDOR}" >> /data/local.prop
	echo "3Gmod.modemProductID=${NEWIDPRODUCT}" >> /data/local.prop
	echo "# Change this port value if tethering attempt fails. Valid values from 0-5." >> /data/local.prop
	echo "3Gmod.usbPort=0" >> /data/local.prop
	echo "#" >> /data/local.prop
	echo "# END of Uruk-Droid USB 3G modem tethering support" >> /data/local.prop
	echo "#" >> /data/local.prop
	echo "" >> /data/local.prop
	echo ""
	echo "" !!!!!!   R E B O O T   for configuration to become active   !!!!!!
        echo "Done."
	exit 0
else
	echo "3Gmodem_detect.sh didn't found USB device of adequate Vendor and Product after switching. Exitig."
	exit 15
fi

