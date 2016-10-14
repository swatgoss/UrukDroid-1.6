#!/bin/sh
#
# UrukDroid - to clean system for lame google apps installers....
#

path=`pwd`

cd system/app
rm -f 0*
ln -s /data/test/froyo/system/app/GenieWidget.apk 0GenieWidget.apk
ln -s /data/test/froyo/system/app/Gmail.apk 0Gmail.apk
ln -s /data/test/froyo/system/app/GoogleBackupTransport.apk 0GoogleBackupTransport.apk
ln -s /data/test/froyo/system/app/GoogleCalendarSyncAdapter.apk 0GoogleCalendarSyncAdapter.apk
ln -s /data/test/froyo/system/app/GoogleContactsSyncAdapter.apk 0GoogleContactsSyncAdapter.apk
ln -s /data/test/froyo/system/app/GoogleFeedback.apk 0GoogleFeedback.apk
ln -s /data/test/froyo/system/app/GoogleServicesFramework.apk 0GoogleServicesFramework.apk
ln -s /data/test/froyo/system/app/googlevoice.apk 0googlevoice.apk
ln -s /data/test/froyo/system/app/Maps.apk 0Maps.apk
ln -s /data/test/froyo/system/app/MarketUpdater.apk 0MarketUpdater.apk
ln -s /data/test/froyo/system/app/MediaUploader.apkla 0MediaUploader.apk
ln -s /data/test/froyo/system/app/NetworkLocation.apk 0NetworkLocation.apk
ln -s /data/test/froyo/system/app/SetupWizard.apk 0SetupWizard.apk
ln -s /data/test/froyo/system/app/Talk.apk 0Talk.apk
ln -s /data/test/froyo/system/app/Vending.apk 0Vending.apk
ln -s /data/test/froyo/system/app/VoiceSearch.apk 0VoiceSearch.apk
ln -s /data/test/froyo/system/app/YouTube.apk 0YouTube.apk
cd $path

cd system/framework
rm -f com.google.android.maps.jar
ln -s /data/test/froyo/system/framework/com.google.android.maps.jar com.google.android.maps.jar

cd $path
cd system/lib
rm -f libimageutils.so libinterstitial.so libspeech.so libvoicesearch.so libzxing.so
ln -s /data/test/froyo/system/lib/libimageutils.so libimageutils.so
ln -s /data/test/froyo/system/lib/libinterstitial.so libinterstitial.so
ln -s /data/test/froyo/system/lib/libspeech.so libspeech.so
ln -s /data/test/froyo/system/lib/libvoicesearch.so libvoicesearch.so
ln -s /data/test/froyo/system/lib/libzxing.so libzxing.so


cd $path
# Other none google stuff
rm system/etc/vpnc/archos.conf
cat /dev/null > system/etc/openvpn/archos_ca.crt
cat /dev/null > system/etc/openvpn/archos.key
cat /dev/null > system/etc/openvpn/archos.crt

cat system/etc/openvpn/archos.conf | sed 's/ordugh.org/PutYourServerIP_here/' >cos
cat cos > system/etc/openvpn/archos.conf

rm system/etc/ssh/dropbear_*_key
cat system/etc/uruk.conf/sshd | sed s/qaz/UrukDroid/ >cos
cat cos > system/etc/uruk.conf/sshd

rm cos

cd system/etc
rm vold.fstab
ln -s /system/etc/vold.fstab-stock vold.fstab
cd -

# Clean root
cd $path/root/
rm *
rm -rf .ssh .bash_history >/dev/null 2>&1
cd -

# Clean /var/lib
rm var/lib/urukdroid/update.*
rm var/lib/urukdroid/update/*
rm var/lib/urukdroid/kernel/*
rm var/lib/urukdroid/upgrade/*
