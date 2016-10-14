#!/bin/sh

nofiles ()
{
echo 'fichier : $1'

sed -i -e '/.*\/\..*\//d' $1

while read line
do
if [ -n "$line" ]
then
pattern=`echo $line | sed -e 's/^[0-9]*#\(.*\/\).*/\1/g'`
pattern2=`echo $pattern | sed -e 's/'"'"'/\\\\'"'"'/g'`
pattern3=`echo $pattern2 | sed -e 's/\//\\\\\\//g'`
sed -i -e "/$pattern3/d" $1
fi
done <<EOF
`grep ".nomedia" $1`
EOF

while read line
do
if [ -n "$line" ]
then
pattern=`echo $line | sed -e 's/^[0-9]*#\(.*\/\).*/\1/g'`
pattern2=`echo $pattern | sed -e 's/'"'"'/\\\\'"'"'/g'`
pattern3=`echo $pattern2 | sed -e 's/\//\\\\\\//g'`
sed -i -e "/$pattern3.*[Mm][Pp]3/d" $1
sed -i -e "/$pattern3.*[Ff][Ll][Aa][Cc]/d" $1
sed -i -e "/$pattern3.*[Aa][Aa][Cc]/d" $1
sed -i -e "/$pattern3.*[Ww][Mm][Aa]/d" $1
sed -i -e "/$pattern3.*[Mm]4[Aa]/d" $1
sed -i -e "/$pattern3.*[Oo][Gg][Gg]/d" $1
sed -i -e "/$pattern3.*[Mm][Ii][Dd]/d" $1
fi
done <<EOF
`grep ".noaudio" $1`
EOF

while read line
do
if [ -n "$line" ]
then
pattern=`echo $line | sed -e 's/^[0-9]*#\(.*\/\).*/\1/g'`
pattern2=`echo $pattern | sed -e 's/'"'"'/\\\\'"'"'/g'`
pattern3=`echo $pattern2 | sed -e 's/\//\\\\\\//g'`
sed -i -e "/$pattern3.*[Aa][Vv][Ii]/d" $1
sed -i -e "/$pattern3.*[Ww][Mm][Vv]/d" $1
sed -i -e "/$pattern3.*[Mm][Kk][Vv]/d" $1
sed -i -e "/$pattern3.*[Vv][Oo][Bb]/d" $1
sed -i -e "/$pattern3.*[Mm][Oo][Vv]/d" $1
sed -i -e "/$pattern3.*[Mm][Pp][Ee][Gg]/d" $1
sed -i -e "/$pattern3.*[Mm][Pp]2[Pp]/d" $1
sed -i -e "/$pattern3.*[Mm][Pp]2[Tt]/d" $1
sed -i -e "/$pattern3.*[Ff][Ll][Vv]/d" $1
sed -i -e "/$pattern3.*[Mm][Pp]4/d" $1
sed -i -e "/$pattern3.*3[Gg][Pp][Pp]/d" $1
sed -i -e "/$pattern3.*3[Gg][Pp][Pp]2/d" $1
fi
done <<EOF
`grep ".novideo" $1`
EOF

while read line
do
if [ -n "$line" ]
then
pattern=`echo $line | sed -e 's/^[0-9]*#\(.*\/\).*/\1/g'`
pattern2=`echo $pattern | sed -e 's/'"'"'/\\\\'"'"'/g'`
pattern3=`echo $pattern2 | sed -e 's/\//\\\\\\//g'`
sed -i -e "/$pattern3.*[Jj][Pp][Gg]/d" $1
sed -i -e "/$pattern3.*[Bb][Mm][Pp]/d" $1
sed -i -e "/$pattern3.*[Jj][Pp][Ee][Gg]/d" $1
sed -i -e "/$pattern3.*[Pp][Nn][Gg]/d" $1
fi
done <<EOF
`grep ".noimage" $1`
EOF
}

case $1 in
1)
/usr/bin/find /mnt/storage/ -xdev -type f -a -printf "%s#%h/%f\n" > /data/misc/mediascanner/mediascanner_find_reference_storage
nofiles "/data/misc/mediascanner/mediascanner_find_reference_storage"
;;
2)
/usr/bin/find /mnt/storage/ -xdev -type f -a -printf "%s#%h/%f\n" > /tmp/mediascanner_find_tmp
nofiles "/tmp/mediascanner_find_tmp"
/usr/bin/diff /data/misc/mediascanner/mediascanner_find_reference_storage /tmp/mediascanner_find_tmp > /tmp/mediascanner.diff.final
sed -i -e '/^[<>]/!d' /tmp/mediascanner.diff.final
sed -i -e 's/^\([<>]\).*#\/mnt\/storage/\1\/mnt\/storage/g' /tmp/mediascanner.diff.final
;;
3)
rm /data/misc/mediascanner/mediascanner_find_reference_storage
cp /tmp/mediascanner_find_tmp /data/misc/mediascanner/mediascanner_find_reference_storage
rm /tmp/mediascanner-unlock.key 2>/dev/null
;;
4)
/usr/bin/find /mnt/storage/sdcard/ -xdev -type f -a -printf "%s#%h/%f\n" > /data/misc/mediascanner/mediascanner_find_reference_sdcard
nofiles "/data/misc/mediascanner/mediascanner_find_reference_sdcard"
;;
5)
/usr/bin/find /mnt/storage/sdcard -xdev -type f -a -printf "%s#%h/%f\n" > /tmp/mediascanner_find_tmp
nofiles "/tmp/mediascanner_find_tmp"
/usr/bin/diff /data/misc/mediascanner/mediascanner_find_reference_sdcard /tmp/mediascanner_find_tmp > /tmp/mediascanner.diff.final
sed -i -e '/^[<>]/!d' /tmp/mediascanner.diff.final
sed -i -e 's/^\([<>]\).*#\/mnt\/storage/\1\/mnt\/storage/g' /tmp/mediascanner.diff.final
;;
6)
rm /data/misc/mediascanner/mediascanner_find_reference_sdcard
cp /tmp/mediascanner_find_tmp /data/misc/mediascanner/mediascanner_find_reference_sdcard
;;
esac


