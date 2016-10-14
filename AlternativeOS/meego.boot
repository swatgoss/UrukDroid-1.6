#!/bin/sh

#
# Script to boot alternative OS: Debian
#
# OS_Name: Meego
# OS_Desc: Meego arm
#
# Ver: 1.0 (06.05.2011) Adrian (Sauron) Siemieniak
#

mount /dev/mmcblk2p1 /AlternativeOS
exec switch_root /AlternativeOS/meego /sbin/init
