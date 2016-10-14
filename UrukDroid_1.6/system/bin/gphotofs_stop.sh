#!/bin/sh

/usr/bin/fusermount -u /mnt/storage/extcamera
stop gphotofs
rmdir /mnt/storage/extcamera
