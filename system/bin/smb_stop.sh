#!/bin/sh

///usr/bin/fusermount -u /mnt/storage/network/smb
//stop fusesmb
rmdir /mnt/storage/network/smb
rm /mnt/storage/network/.nomedia
rm /tmp/smb_search_in_progress
rm -fr /tmp/nbtscan
rmdir /mnt/storage/network
