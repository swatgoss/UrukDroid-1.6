#!/bin/bash
#
# This is part of UrukDroid
#
# 1.4 (19.02.2011) Adrian (Sauron) Siemieniak
#
test_bin="/usr/local/sbin/bonnie++"
test_dir="/data/test/"

#test_bin="./bonnie++"
#test_arg="-s 128 -r 64 -b -u root -n '25:10:1:1'"
test_arg="-s 20 -r 10 -b -u root -n '1:10:1:1'"
find_pat="1.96,1.96"
count=12

cpu_min=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`
cpu_max=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`
echo "Turning on max CPU frequency: $cpu_max hz"
echo $cpu_max >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

test_dir="/data/test/"

if [ "$1" != "" -a -d "$1" ]; then
	test_dir="$1"
fi
cd $test_dir

echo "Performing disk ($test_dir) IO test. Test make take about 1h on slower systems - please connect device to power supply!"
echo -n "Done: 0%..."
max_count=$count
/usr/local/sbin/bonnie++ -s 128 -r 64 -b -u root -n '25:10:1:1' 2>&1 | while read progress; do
	if [ `echo $progress | grep -c "done"` -gt 0 ]; then
		let count=$count-1
		let prct="100-(100/$max_count*$count)"
		if [ $prct -gt 99 ]; then
			echo "100%"
		else
			echo -n "$prct%..."
		fi
	fi
# Final report
	if [ `echo $progress | grep -c $find_pat` -gt 0 ]; then
		echo "------------------- Please report this data (V2) -------------------"
#		progress_n=`echo $progress | /usr/local/bin/sed 's/+++++/1000/g' | /usr/local/bin/sed 's/+++/0/g'`
# Remove spaces
		progress_n=`echo $progress | /usr/local/bin/sed 's/ //g'`
		echo -n "Your throughput score is: "
#		echo $progress_n | awk -F"," '{print ($3+$5+$7+$9+$11)/5-($4+$6+$8+$10+$12)*10}'
		echo $progress_n | awk -F"," '{print ($8+$10+$12+$14+$16+$18)/6-($9+$11+$13+$15+$17+$19)}'
		echo -n "Your metadata score is: "
# Removed some ++ score :/
#		echo $progress_n | awk -F"," '{print $13+$16+$20+$22+$26-($14+$17+$21+$23+$27)*10}'
		echo $progress_n | awk -F"," '{print ($25+$27+$29+$31+$33+$35)/6-($26+$28+$30+$32+$34+$36)}'
		echo $progress
	fi
done

#echo "localhost,128M,2037,72,6689,10,4229,7,2886,96,18142,12,19.9,0,32:10:1,38,1,1060,18,52,1,37,1,1056,21,43,1" |
# awk -F"," '{print ($3+$5+$7+$9+$11)/5-($4+$6+$8+$10+$12)*10}'

#echo "localhost,128M,2037,72,6689,10,4229,7,2886,96,18142,12,19.9,0,32:10:1,38,1,1060,18,52,1,37,1,1056,21,43,1" |
# awk -F"," '{print $13+$16+$18+$20+$22+$24+$26-($14+$17+$19+$21+$23+$25+$27)*10}'

cd /sys/bus/mmc/devices/mmc1*

sd_brand=`cat name`
sd_hwrev=`cat hwrev`
sd_fwrev=`cat fwrev`
sd_date=`cat date`
sd_oem=`cat oemid`

echo "SDCard by $sd_brand ($sd_hwrev:$sd_fbrew) manufacture date $sd_date, oemid $sd_oem"
echo "------------------------------------------------------------------"
echo "Restoring previous cpu setting...."
echo $cpu_min > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

# Just in case make some cleaups
/usr/local/bin/find $test_dir -type f -name "Bonnie.*" -exec rm -f {} ";"

