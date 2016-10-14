#!/bin/bash

log -t USBTether "No 3G USB modem support initialized. Will try to initialize modem."

ENABLED=`getprop "3Gmod.enable"`
DEFIDVENDOR=`getprop "3Gmod.defVendorID"`
DEFIDPRODUCT=`getprop "3Gmod.defProductID"`
NEWIDVENDOR=`getprop "3Gmod.modemVendorID"`
NEWIDPRODUCT=`getprop "3Gmod.modemProductID"`
ORIGCONFFILE=${DEFIDVENDOR}_${DEFIDPRODUCT}

log -t USBTether "3G modem support: $ENABLED"
log -t USBTether "3G modem def.  VendorID: $DEFIDVENDOR" 
log -t USBTether "3G modem def.  ProdID  : $DEFIDPRODUCT" 
log -t USBTether "3G modem modem VendorID: $NEWIDVENDOR" 
log -t USBTether "3G modem modem ProdID  : $NEWIDPRODUCT" 
 

if [ -z ${ENABLED} -o "${ENABLED}" = "off" ]; then
	log -t USBTether "3Gsupport not enabled. Exiting."
	exit 30
fi

if [ -z ${DEFIDVENDOR} -o -z ${DEFIDPRODUCT} -o -z ${NEWIDVENDOR} -o -z ${NEWIDPRODUCT} ]; then 
	log -t USBTether "Missing 3G modem configuration parameters. Exiting"
	exit 25
fi

if [ `cat /proc/bus/usb/devices | grep -c "Vendor=${DEFIDVENDOR} ProdID=${DEFIDPRODUCT}"` -eq 0 ]; then
    if [ `cat /proc/bus/usb/devices | grep -c "Vendor=${NEWIDVENDOR} ProdID=${NEWIDPRODUCT}"` -ne 0 ]; then
        log -t USBTether "Seems that modem is already in serial mode. Reloading kernel module."
        if [ `cat /proc/modules | grep -c "usbserial"` -ne 0 ]; then
		rmmod usbserial
	fi
	modprobe usbserial vendor=0x${NEWIDVENDOR} product=0x${NEWIDPRODUCT}
	if [ `cat /proc/modules | grep -c "usbserial"` -eq 0 ]; then
    	    log -t USBSerial "Kernel module load failed. Exiting."
    	    exit 20
	fi
	N=1
	while [ $N -le 3 ]
	do
            if [ `ls -l /dev/ttyUSB* | wc -l` -ne 0 ]; then
                log -t USBTether "ttyUSB devices found. 3G modem ready for use."
                exit 0
            else
                log -t USBTether "Waiting for /dev/ttyUSB* devices to show up for max 3 sec. Elapsed: $N"
                sleep 1
                N=`expr $N + 1`
            fi
        done
        log -t USBTether "No /dev/ttyUSB{X} devices found. 3G modem not ready for use. Exiting"
	exit 10
    fi
    log -t USBTether "It seems that 3G modem is not connected to device. Exiting."
    exit 5
fi

log -t USBTether "Found USB 3Gmodem dongle in default mode connected to device."
if [ "${NEWIDVENDOR}" = "${DEFIDVENDOR}" -a "${NEWIDPRODUCT}" = "${DEFIDPRODUCT}" ]; then
        log -t USBTether "Seems that modem doesn't need switching. Loading kernel module."
        if [ `cat /proc/modules | grep -c "usbserial"` -ne 0 ]; then
		rmmod usbserial
	fi
	modprobe usbserial vendor=0x${NEWIDVENDOR} product=0x${NEWIDPRODUCT}
	if [ `cat /proc/modules | grep -c "usbserial"` -eq 0 ]; then
    	    log -t USBTether "Kernel module load failed. Exiting."
    	    exit 20
	fi
        N=1
        while [ $N -le 3 ]
        do
	    if [ `ls -l /dev/ttyUSB* | wc -l` -ne 0 ]; then
    	        log -t USBTether "/dev/ttyUSB devices found. 3G modem ready for use."
					exit 0
            else
                log -t USBTether "Waiting for /dev/ttyUSB* devices to show up for max 3 sec. Elapsed: $N"
                sleep 1
                N=`expr $N + 1`
	    fi
        done
        log -t USBTether "No /dev/ttyUSB{X} devices found. 3G modem not ready for use. Exiting"
	exit 10
fi

log -t USBTether "Starting usb-modeswitching."
if [ `cat /proc/modules | grep -c "option"` -ne 0 ]; then 
	rmmod option
fi
if [ `cat /proc/modules | grep -c "usbserial"` -ne 0 ]; then 
	rmmod usbserial
fi

/usr/local/sbin/usb_modeswitch -c /system/etc/usb_modeswitch.d/${ORIGCONFFILE}

N=1
while [ $N -le 2 ]
do
    if [ `cat /proc/bus/usb/devices | grep -c "Vendor=${NEWIDVENDOR} ProdID=${NEWIDPRODUCT}"` -ne 0 ]; then
        log -t USBTether "USB device with expected Vendor/Product ID connected. Switching SUCCESFULL."
        break
    else
        log -t USBTether "Waiting for adequate VendorID/ProdID device to show up for max 2 sec. Elapsed: $N"
        sleep 1
        N=`expr $N + 1`
    fi
done
if [ `cat /proc/bus/usb/devices | grep -c "Vendor=${NEWIDVENDOR} ProdID=${NEWIDPRODUCT}"` -eq 0 ]; then
    log -t USBTether "NO USB device with expected VendorID/ProdID connected. Switching UNSUCCESFULL. Exiting."
    exit 20
fi

log -t USBTether "Loading 3G modem kernel driver with adeqate configuration"
insmod /lib/modules/usbserial.ko vendor=0x${NEWIDVENDOR} product=0x${NEWIDPRODUCT}
if [ `cat /proc/modules | grep -c "usbserial"` -eq 0 ]; then
    log -t USBTether "Kernel module load failed. Exiting."
    exit 20
fi
N=1
while [ $N -le 3 ]
do
    if [ `ls -l /dev/ttyUSB* | wc -l` -ne 0 ]; then
        log -t USBTether "ttyUSB devices found. USB modeswitch SUCCESFULL - 3G modem ready for use."
        exit 0
    else
        log -t USBTether "Waiting for /dev/ttyUSB* devices to show up for max 3 sec. Elapsed: $N"
        sleep 1
        N=`expr $N + 1`
    fi
done
exit 10
