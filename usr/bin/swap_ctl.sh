#!/system/bin/sh

LOCAL_SWAP=/dev/block/mmcblk0p3

SWAP_PROP=persist.sys.archos.swapctl.en
SWAP_STATUS_PROP=sys.archos.swapctl.st

SWAPPINESS=40

ECHO=/bin/echo
SWAPON=/sbin/swapon
SWAPOFF=/sbin/swapoff
SETPROP=/system/bin/setprop
GETPROP=/system/bin/getprop
MKSWAP=/sbin/mkswap

enable_swap()
{
	if [ "`$GETPROP $SWAP_STATUS_PROP`" = "1" ] ; then
		return 0;
	fi

	$ECHO $SWAPPINESS > /proc/sys/vm/swappiness

	$SWAPON $LOCAL_SWAP || $MKSWAP $LOCAL_SWAP && $SWAPON $LOCAL_SWAP || return 255

	$SETPROP $SWAP_STATUS_PROP 1

	return 0;
}

disable_swap()
{
	$SWAPOFF $LOCAL_SWAP || return 255

	$SETPROP $SWAP_STATUS_PROP 0

	return 0;
}

# Deal with the type of invocation we get.
#
case "$1" in
start)
	enable_swap
	;;
stop)
	disable_swap
	;;
reload|restart)
	disable_swap
	enable_swap
	;;
*)
	echo "$0: unknown argument $1.";
	;;
esac

