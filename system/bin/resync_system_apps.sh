#!/bin/sh
#
# 1.0 (20.12.2011) Adrian (Sauron) Siemieniak
#
# Script moves application from /system/app to /system/app.old
# As a patter it uses files already present in app.ol

cd /system/app.old
for a in *; do
	if [ -f "/system/app/$a" ]; then
		echo "Moving file "$a
		mv -fv "/system/app/$a" .
	fi
done

cd - >/dev/null 2>&1
