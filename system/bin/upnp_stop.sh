#!/bin/sh

/usr/bin/fusermount -u /mnt/storage/network/upnp
stop djmount
rmdir /mnt/storage/network/upnp
rm /mnt/storage/network/.nomedia
rm /tmp/upnp_search_in_progress
rmdir /mnt/storage/network
