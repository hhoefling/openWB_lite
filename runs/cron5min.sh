#!/bin/bash
########## Re-Run as PI if not
USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" -- "$@"
##########

# von cron aus /home/pi als dir 
# must be called  as pi from /var/www/html/openWB
cd /var/www/html/openWB
OPENWBBASEDIR=/var/www/html/openWB
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

. loadconfig.sh
. helperFunctions.sh

if [ -e "ramdisk/updateinprogress" ] && [ -e "ramdisk/bootinprogress" ]; then
    read updateinprogress <ramdisk/updateinprogress
    read bootinprogress  <ramdisk/bootinprogress
    if (( updateinprogress == "1" )); then
        openwbDebugLog "MAIN" 0 "##### cron5min.sh Update in progress EXIT 0"
        exit 0
    elif (( bootinprogress == "1" )); then
        openwbDebugLog "MAIN" 0 "##### cron5min.sh Boot in progress EXIT 0"
        exit 0
    fi
else
    openwbDebugLog "MAIN" 0 "##### cron5min.sh Ramdisk not set up. Maybe we are still booting. EXIT 0"
    exit 0
fi


startregel=$(date +%s)
function cleanup()
{
    local endregel=$(date +%s)
    local t=$((endregel-startregel))
    openwbDebugLog "MAIN" 0 "cron5min needs $t Sekunden"
    rm -f ramdisk/cron5runs
    echo "done" >ramdisk/lastcron5time

}
trap cleanup EXIT
touch ramdisk/cron5runs
echo "start" >ramdisk/lastcron5time

idd=`id -un`
openwbDebugLog "MAIN" 0 "##### cron5min.sh started as $idd #####"

headfile="web/logging/data/daily/daily_header"
dailyfile="web/logging/data/daily/$(date +%Y%m%d)"
monthlyladelogfile="web/logging/data/ladelog/$(date +%Y%m).csv"

# check if a monthly logfile exists and create a new one if not
linesladelog=$(cat $monthlyladelogfile | wc -l)
if [[ "$linesladelog" == 0 ]]; then
	openwbDebugLog "MAIN" 1 "creating new monthly chargelog: $monthlyladelogfile"
	echo > $monthlyladelogfile
fi

read ll1 <ramdisk/llkwh      # Zählerstand LP1        # 6044.241 = 6044,24 Kwh
read ll2 <ramdisk/llkwhs1    # Zählerstand LP2
read ll3 <ramdisk/llkwhs2    # Zählerstand LP3
NCll4=0 # $(<$RAMDISKDIR/llkwhlp4)  # Zählerstand LP4
NCll5=0 # $(<$RAMDISKDIR/llkwhlp5)  # Zählerstand LP5
NCll6=0 # $(<$RAMDISKDIR/llkwhlp6)  # Zählerstand LP6
NCll7=0 # $(<$RAMDISKDIR/llkwhlp7)  # Zählerstand LP7
NCll8=0 # $(<$RAMDISKDIR/llkwhlp8)  # Zählerstand LP8
read llg <ramdisk/llkwhges

# ins Log als Wh
# ll1=$(echo "$ll1 * 1000" | bc)      # mow 6044241.000 Wh
# ll2=$(echo "$ll2 * 1000" | bc)
# ll3=$(echo "$ll3 * 1000" | bc)
ll1=$(echo "scale = 0; ($ll1 * 1000)/1" | bc)      # mow 6044241 Wh
ll2=$(echo "scale = 0; ($ll2 * 1000)/1" | bc)      # mow 6044241 Wh
ll3=$(echo "scale = 0; ($ll3 * 1000)/1" | bc)      # mow 6044241 Wh
#NCll4=$(echo "$NCll4 * 1000" | bc)
#NCll5=$(echo "$NCll5 * 1000" | bc)
#NCll6=$(echo "$NCll6 * 1000" | bc)
#NCll7=$(echo "$NCll7 * 1000" | bc)
#NCll8=$(echo "$NCll8 * 1000" | bc)

#llg=$(echo "$llg * 1000" | bc)
llg=$(echo "scale = 0; ($llg * 1000)/1" | bc)      # mow 6044241 Wh

# calculate daily stats
read bezug <ramdisk/bezugkwh
read einspeisung <ramdisk/einspeisungkwh
if [[ $pv2wattmodul != "none" ]]; then
	read pv <ramdisk/pvallwh
else
	read pv <ramdisk/pvkwh
fi
soc=$(<ramdisk/soc)
soc1=$(<ramdisk/soc1)
speicheri=$(<ramdisk/speicherikwh)
speichere=$(<ramdisk/speicherekwh)
speichersoc=$(<ramdisk/speichersoc)
verbraucher1=$(<ramdisk/verbraucher1_wh)
verbraucher2=$(<ramdisk/verbraucher2_wh)
NCverbraucher3=0  # $(<ramdisk/verbraucher3_wh)
verbrauchere1=$(<ramdisk/verbraucher1_whe)
verbrauchere2=$(<ramdisk/verbraucher2_whe)
temp1=$(<ramdisk/device1_temp0)
temp2=$(<ramdisk/device1_temp1)
temp3=$(<ramdisk/device1_temp2)
temp4=$(<ramdisk/device2_temp0)
temp5=$(<ramdisk/device2_temp1)
temp6=$(<ramdisk/device2_temp2)
d1=$(<ramdisk/device1_wh)
d2=$(<ramdisk/device2_wh)
d3=$(<ramdisk/device3_wh)
d4=$(<ramdisk/device4_wh)
d5=$(<ramdisk/device5_wh)
d6=$(<ramdisk/device6_wh)
d7=$(<ramdisk/device7_wh)
d8=$(<ramdisk/device8_wh)
d9=$(<ramdisk/device9_wh)
NCd10="0"
d1haus=$(<ramdisk/smarthome_device_minhaus_1)
d2haus=$(<ramdisk/smarthome_device_minhaus_2)
d3haus=$(<ramdisk/smarthome_device_minhaus_3)
d4haus=$(<ramdisk/smarthome_device_minhaus_4)
d5haus=$(<ramdisk/smarthome_device_minhaus_5)
d6haus=$(<ramdisk/smarthome_device_minhaus_6)
d7haus=$(<ramdisk/smarthome_device_minhaus_7)
d8haus=$(<ramdisk/smarthome_device_minhaus_8)
d9haus=$(<ramdisk/smarthome_device_minhaus_9)

# now add a line to our daily csv
if ! [[ -e "$headfile.csv" ]] ; then
  echo "date,bezug,einspeisung,pv,ll1,ll2,ll3,llg,speicheri,speichere,verbraucher1,verbrauchere1,verbraucher2,verbrauchere2,NCverbraucher3,NCll4,NCll5,NCll6,NCll7,NCll8,speichersoc,soc,soc1,temp1,temp2,temp3,d1,d2,d3,d4,d5,d6,d7,d8,d9,NCd10,temp4,temp5,temp6" >> $headfile.csv
  openwbDebugLog "MAIN" 1 "daily headline created: $headfile.csv"
fi
echo $(date +%H%M),$bezug,$einspeisung,$pv,$ll1,$ll2,$ll3,$llg,$speicheri,$speichere,$verbraucher1,$verbrauchere1,$verbraucher2,$verbrauchere2,$NCverbraucher3,$NCll4,$NCll5,$NCll6,$NCll7,$NCll8,$speichersoc,$soc,$soc1,$temp1,$temp2,$temp3,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$NCd10,$temp4,$temp5,$temp6 >> $dailyfile.csv
openwbDebugLog "MAIN" 1 "daily csv updated: $dailyfile.csv"

# grid protection
# temporary disabled
# netzabschaltunghz=0
if (( netzabschaltunghz == 1 )); then
	hz=$(<ramdisk/llhz)
	hz=$(echo "$hz * 100" | bc | sed 's/\..*$//')
	openwbDebugLog "MAIN" 1 "Netzschutz konfiguriert; aktuelle Frequenz: ${hz}"
	netzschutz=$(<ramdisk/netzschutz)
	if (( netzschutz == 0 )); then
		# grid protection is not set
		if (( hz > 4500 )) && (( hz < 5300 )); then
			if (( hz > 5180 )); then
				# grid power overload detected
				# store current charge mode
				lademodus=$(<ramdisk/lademodus)
				echo $lademodus > ramdisk/templademodus
				# set charge mode to stop
				echo 3 > ramdisk/lademodus
				openwbDebugLog "MAIN" 0 "Netzschutz aktiviert, Frequenz: ${hz}"
				# set grid protection
				echo 1 > ramdisk/netzschutz
				echo "!!! Netzschutz aktiv !!!" > ramdisk/lastregelungaktiv
			fi
			if (( hz < 4920 )); then
				# grid power underload detected
				# store current charge mode
				lademodus=$(<ramdisk/lademodus)
				echo $lademodus > ramdisk/templademodus
				# set grid protection
				echo 1 > ramdisk/netzschutz
				echo "!!! Netzschutz aktiv !!!" > ramdisk/lastregelungaktiv
				openwbDebugLog "MAIN" 0 "Netzschutz aktiviert, Frequenz: ${hz}, schedule a STOP"

				# wait a random interval and set charge mode to stop
				(sleep $(shuf -i1-90 -n1) && echo 3 > ramdisk/lademodus) &
			fi
		fi
	else
		# grid protection is set
		if (( hz > 4960 )) && (( hz < 5100 )); then
			# grid is in normal load range
			# restore last charge mode
			templademodus=$(<ramdisk/templademodus)
			echo $templademodus > ramdisk/lademodus
			# remove grid protection
			echo 0 > ramdisk/netzschutz
			openwbDebugLog "MAIN" 0 "Netzschutz deaktiviert, Frequenz: ${hz}"
			echo "Netzfrequenz wieder im normalen Bereich." > ramdisk/lastregelungaktiv
		fi
	fi
fi

# update electricity provider prices
if (( etprovideraktiv == 1 )); then
	openwbDebugLog "MAIN" 1 "electricity provider configured; trigger price update"
	modules/$etprovider/main.sh &
else
	openwbDebugLog "MAIN" 2 "electricity provider not set up; skipping price update"
fi

# update all daily yield stats
openwbDebugLog "MAIN" 1 "updating daily yield stats"
pvkwh=$pv
pvdailyyieldstart=$(head -n 1 web/logging/data/daily/$(date +%Y%m%d).csv)
pvyieldcount=0
for i in ${pvdailyyieldstart//,/ }
do
# pv
# "1 date,2 bezug,3 einspeisung,4 pv,5 ll1,6 ll2,7 ll3,8 llg,9 speicheri,10 speichere,11 verbraucher1,12 verbrauchere1,13 verbraucher2,14 verbrauchere2,15 NCverbraucher3,16 NCll4,17 NCll5,18 NCll6,19 NCll7,20 NCll8,21 speichersoc,22 soc,23 soc1,24 temp1,25 temp2,26 temp3,27 d1, 28 d2, 29 d3, 30 d4, 31 d5, 32 d6, 33 d7, 34 d8, 35 d9, 36 NCd10, 37 temp4, 38 temp5, 39 temp6" >> $headfile.csv

	pvyieldcount=$((pvyieldcount + 1 ))			# 1..x 1=time
	if (( pvyieldcount == 2 )); then
		bezugdailyyield=$(echo "scale=2;($bezug - $i) / 1000" |bc)
		echo $bezugdailyyield > ramdisk/daily_bezugkwh
		#echo  "bezugdailyyield= (bezug - i) / 1000 " 
		#echo  "$bezug - $i"
		#echo  "$bezugdailyyield"
	fi
	if (( pvyieldcount == 3 )); then
		einspeisungdailyyield=$(echo "scale=2;($einspeisung - $i) / 1000" |bc)
		echo $einspeisungdailyyield > ramdisk/daily_einspeisungkwh
	fi
	if (( pvyieldcount == 4 )); then
		pvdailyyield=$(echo "scale=2;($pvkwh - $i) / 1000" |bc)
		echo $pvdailyyield > ramdisk/daily_pvkwhk
	fi
	# all charge points
	if (( pvyieldcount == 8 )); then
		lladailyyield=$(echo "scale=2;($llg - $i) / 1000" |bc)
		echo $lladailyyield > ramdisk/daily_llakwh
		openwbDebugLog "MAIN" 1 "updating daily_llakwh  to $lladailyyield ($llg - $i)"
	fi
	# house battery
	if (( pvyieldcount == 9 )); then
		sidailyyield=$(echo "scale=2;($speicheri - $i) / 1000" |bc)
		echo $sidailyyield > ramdisk/daily_sikwh
	fi
	if (( pvyieldcount == 10 )); then
		sedailyyield=$(echo "scale=2;($speichere - $i) / 1000" |bc)
		echo $sedailyyield > ramdisk/daily_sekwh
	fi
	# old smarthome devices
	if (( pvyieldcount == 11 )); then
		verbraucher1dailyyield=$(echo "scale=2;($verbraucher1 - $i) / 1000" |bc)
		echo $verbraucher1dailyyield > ramdisk/daily_verbraucher1ikwh
	fi
	if (( pvyieldcount == 12 )); then
		verbrauchere1dailyyield=$(echo "scale=2;($verbrauchere1 - $i) / 1000" |bc)
		echo $verbrauchere1dailyyield > ramdisk/daily_verbraucher1ekwh
	fi
	if (( pvyieldcount == 13 )); then
		verbraucher2dailyyield=$(echo "scale=2;($verbraucher2 - $i) / 1000" |bc)
		echo $verbraucher2dailyyield > ramdisk/daily_verbraucher2ikwh
	fi
	if (( pvyieldcount == 14 )); then
		verbrauchere2dailyyield=$(echo "scale=2;($verbrauchere2 - $i) / 1000" |bc)
		echo $verbrauchere2dailyyield > ramdisk/daily_verbraucher2ekwh
	fi
#	if (( pvyieldcount == 15 )); then
#		verbraucher3dailyyield=$(echo "scale=2;($NCverbraucher3 - $i) / 1000" |bc)
#		echo $NCverbraucher3dailyyield > ramdisk/daily_verbraucher3ikwh
#	fi
	# smarthome 2.0 devices
	if (( pvyieldcount == 27 )); then
		d1dailyyield=$(echo "scale=2;($d1 - $i) / 1000" |bc)
		echo $d1dailyyield > ramdisk/daily_d1kwh
	fi
	if (( pvyieldcount == 28 )); then
		d2dailyyield=$(echo "scale=2;($d2 - $i) / 1000" |bc)
		echo $d2dailyyield > ramdisk/daily_d2kwh
	fi
	if (( pvyieldcount == 29 )); then
		d3dailyyield=$(echo "scale=2;($d3 - $i) / 1000" |bc)
		echo $d3dailyyield > ramdisk/daily_d3kwh
	fi
	if (( pvyieldcount == 30 )); then
		d4dailyyield=$(echo "scale=2;($d4 - $i) / 1000" |bc)
		echo $d4dailyyield > ramdisk/daily_d4kwh
	fi
	if (( pvyieldcount == 31 )); then
		d5dailyyield=$(echo "scale=2;($d5 - $i) / 1000" |bc)
		echo $d5dailyyield > ramdisk/daily_d5kwh
	fi
	if (( pvyieldcount == 32 )); then
		d6dailyyield=$(echo "scale=2;($d6 - $i) / 1000" |bc)
		echo $d6dailyyield > ramdisk/daily_d6kwh
	fi
	if (( pvyieldcount == 33 )); then
		d7dailyyield=$(echo "scale=2;($d7 - $i) / 1000" |bc)
		echo $d7dailyyield > ramdisk/daily_d7kwh
	fi
	if (( pvyieldcount == 34 )); then
		d8dailyyield=$(echo "scale=2;($d8 - $i) / 1000" |bc)
		echo $d8dailyyield > ramdisk/daily_d8kwh
	fi
	if (( pvyieldcount == 35 )); then
		d9dailyyield=$(echo "scale=2;($d9 - $i) / 1000" |bc)
		echo $d9dailyyield > ramdisk/daily_d9kwh
	fi
done

# zero out devices were kwh should be included in house consumtion
if (( d1haus == 1 )); then
 d1dailyyield=0
fi
if (( d2haus == 1 )); then
 d2dailyyield=0
fi
if (( d3haus == 1 )); then
 d3dailyyield=0
fi
if (( d4haus == 1 )); then
 d4dailyyield=0
fi
if (( d5haus == 1 )); then
 d5dailyyield=0
fi
if (( d6haus == 1 )); then
 d6dailyyield=0
fi
if (( d7haus == 1 )); then
 d7dailyyield=0
fi
if (( d8haus == 1 )); then
 d8dailyyield=0
fi
if (( d9haus == 1 )); then
 d9dailyyield=0
fi
#          echo $(date +%H%M), $bezugdailyyield + $pvdailyyield - $lladailyyield + $sedailyyield - $sidailyyield - $einspeisungdailyyield - $d1dailyyield - $d2dailyyield - $d3dailyyield - $d4dailyyield - $d5dailyyield - $d6dailyyield - $d7dailyyield - $d8dailyyield - $d9dailyyield - $verbraucher1dailyyield + $verbrauchere1dailyyield - $verbraucher2dailyyield + $verbrauchere2dailyyield  >> ramdisk/alog.log
# now calculate the house consumption daily yield as difference of measured input and output
hausdailyyield=$(echo "scale=2;$bezugdailyyield + $pvdailyyield - $lladailyyield + $sedailyyield - $sidailyyield - $einspeisungdailyyield - $d1dailyyield - $d2dailyyield - $d3dailyyield - $d4dailyyield - $d5dailyyield - $d6dailyyield - $d7dailyyield - $d8dailyyield - $d9dailyyield - $verbraucher1dailyyield + $verbrauchere1dailyyield - $verbraucher2dailyyield + $verbrauchere2dailyyield" | bc)
echo $hausdailyyield > ramdisk/daily_hausverbrauchkwh

openwbDebugLog "MAIN" 2 "Haus: bezugdailyyield + pvdailyyield - lladailyyield + sedailyyield - sidailyyield - einspeisungdailyyield - d1dailyyield - d2dailyyield - d3dailyyield - d4dailyyield - d5dailyyield - d6dailyyield - d7dailyyield - d8dailyyield - d9dailyyield - verbraucher1dailyyield + verbrauchere1dailyyield - verbraucher2dailyyield + verbrauchere2dailyyield "
openwbDebugLog "MAIN" 2 "Haus: $bezugdailyyield + $pvdailyyield - $lladailyyield + $sedailyyield - $sidailyyield - $einspeisungdailyyield - $d1dailyyield - $d2dailyyield - $d3dailyyield - $d4dailyyield - $d5dailyyield - $d6dailyyield - $d7dailyyield - $d8dailyyield - $d9dailyyield - $verbraucher1dailyyield + $verbrauchere1dailyyield - $verbraucher2dailyyield + $verbrauchere2dailyyield "
openwbDebugLog "MAIN" 2 "Haus: $hausdailyyield"


# get our current ip address (prepared for Buster)
ip route get 1 |  awk '{print $7;exit}' > ramdisk/ipaddress
openwbDebugLog "MAIN" 1 "current ip: $(<ramdisk/ipaddress)"

###############################################################
# Make sure all services are running (restart crashed services etc.):
source runs/services.sh
service_main cron5 all
###############################################################

# if this is a remote controlled system check if our isss handler is running
if (( isss == 1 )) || [[ "$evsecon" == "daemon" ]]; then
	openwbDebugLog "MAIN" 1 "external openWB or daemon mode configured"
	# if ps ax |grep -v grep |grep "python3 $OPENWBBASEDIR/runs/isss.py" > /dev/null
	# then
	# 	openwbDebugLog "MAIN" 1 "isss handler already running"
	# else
	# 	openwbDebugLog "MAIN" 0 "isss handler not running! restarting process"
	# 	python3 $OPENWBBASEDIR/runs/isss.py &
	# fi
else
	openwbDebugLog "MAIN" 1 "external openWB or daemon mode not configured; checking network setup"
	ethstate=$(</sys/class/net/eth0/carrier)
	if (( ethstate == 1 )); then
		sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 up
		if [ -d /sys/class/net/wlan0 ]; then
			wlanstate=$(</sys/class/net/wlan0/carrier)
			if (( wlanstate == 1 )); then
				sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 down
				wlanstate=$(</sys/class/net/wlan0/carrier)
				if (( wlanstate == 1 )); then
					sudo systemctl stop hostapd
					sudo systemctl stop dnsmasq
				fi
			fi
		fi
	else
		if [ -d /sys/class/net/wlan0 ]; then
			sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 up
		fi
		sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 down
	fi
	# check for obsolete isss handler
	# if ps ax |grep -v grep |grep "python3 /var/www/html/openWB/runs/isss.py" > /dev/null
	# then
	#	sudo kill $(ps aux |grep '[i]sss.py' | awk '{print $2}')
	# fi
fi


# EVSE Check
openwbDebugLog "MAIN" 1 "starting evsecheck"
runs/evsecheck

# truncate all logs in ramdisk
openwbDebugLog "MAIN" 1 "logfile cleanup triggered"
# die mqtt logdatei gehört www-data und kann von pi nicht geöndert werden.
sudo runs/cleanup.sh >> ramdisk/cleanup.log 2>&1

openwbDebugLog "MAIN" 0 "##### cron5min.sh Publish Systemstate to MQTT #####"

sysinfo=$(cd /var/www/html/openWB/web/tools; sudo php programmloggerinfo.php 2>/dev/null)
tempPubList="openWB/global/cpuModel=$(cat /proc/cpuinfo | grep -m 1 "model name" | sed "s/^.*: //")"
tempPubList="${tempPubList}\nopenWB/global/cpuUse=$(echo ${sysinfo} | jq -r '.cpuuse')"
tempPubList="${tempPubList}\nopenWB/global/cpuTemp=$(echo "scale=2; $(echo ${sysinfo} | jq -r '.cputemp') / 1000" | bc)"
tempPubList="${tempPubList}\nopenWB/global/cpuFreq=$(($(echo ${sysinfo} | jq -r '.cpufreq') / 1000))"
tempPubList="${tempPubList}\nopenWB/global/memTotal=$(echo ${sysinfo} | jq -r '.memtot')"
tempPubList="${tempPubList}\nopenWB/global/memUse=$(echo ${sysinfo} | jq -r '.memuse')"
tempPubList="${tempPubList}\nopenWB/global/memFree=$(echo ${sysinfo} | jq -r '.memfree')"
tempPubList="${tempPubList}\nopenWB/global/rootDev=$(echo ${sysinfo} | jq -r '.rootdev')"

tempPubList="${tempPubList}\nopenWB/global/diskTot=$(echo ${sysinfo} | jq -r '.disktot')"
tempPubList="${tempPubList}\nopenWB/global/diskUse=$(echo ${sysinfo} | jq -r '.diskuse')"
tempPubList="${tempPubList}\nopenWB/global/diskUsedPrz=$(echo ${sysinfo} | jq -r '.diskusedprz')"
tempPubList="${tempPubList}\nopenWB/global/diskFree=$(echo ${sysinfo} | jq -r '.diskfree')"

tempPubList="${tempPubList}\nopenWB/global/tmpTot=$(echo ${sysinfo} | jq -r '.tmptot')"
tempPubList="${tempPubList}\nopenWB/global/tmpUse=$(echo ${sysinfo} | jq -r '.tmpuse')"
tempPubList="${tempPubList}\nopenWB/global/tmpUsedPrz=$(echo ${sysinfo} | jq -r '.tmpusedprz')"
tempPubList="${tempPubList}\nopenWB/global/tmpFree=$(echo ${sysinfo} | jq -r '.tmpfree')"

tempPubList="${tempPubList}\nopenWB/global/ethaddr=$(echo ${sysinfo} | jq -r '.ethaddr')"
tempPubList="${tempPubList}\nopenWB/global/ethaddr2=$(echo ${sysinfo} | jq -r '.ethaddr2')"
tempPubList="${tempPubList}\nopenWB/global/wlanaddr=$(echo ${sysinfo} | jq -r '.wlanaddr')"
tempPubList="${tempPubList}\nopenWB/global/wlanaddr2=$(echo ${sysinfo} | jq -r '.wlanaddr2')"



echo "Cron5Min.Publist:"
echo -e $tempPubList
echo "Running Python:  runs/mqttpub.py -q 0 -r &"

echo -e $tempPubList | python3 runs/mqttpub.py -q 0 -r &


openwbDebugLog "MAIN" 0 "##### cron5min.sh finished #####"
