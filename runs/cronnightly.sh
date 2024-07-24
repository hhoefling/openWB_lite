#!/bin/bash
########## Re-Run as PI if not
USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" -- "$@"
##########

# von cron aus /home/pi als dir
cd /var/www/html/openWB
OPENWBBASEDIR=/var/www/html/openWB
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

. loadconfig.sh
. helperFunctions.sh


if [ -e ramdisk/updateinprogress ] && [ -e ramdisk/bootinprogress ]; then
    read -r updateinprogress <ramdisk/updateinprogress
    read -r bootinprogress  <ramdisk/bootinprogress
    if (( updateinprogress == "1" )); then
        openwbDebugLog "MAIN" 0 "Update in progress (EXIT 0)"
        exit 0
    elif (( bootinprogress == "1" )); then
        openwbDebugLog "MAIN" 0 "Boot in progress (EXIT 0)"
        exit 0
    fi
else
    openwbDebugLog "MAIN" 0 "Ramdisk not set up. Maybe we are still booting. (EXIT 0)"
    exit 0
fi


idd=`id -un`
openwbDebugLog "MAIN" 0 "##### croninighly.sh started as $idd #####"
# echo "Start cron nightly @ $(date)"

#logfile aufräumen, rechte und owner erhalten
# Macht nun cleanup
## echo "$(tail -2000 /var/log/openWB.log)" > /var/log/openWB.log
# sudo printf '%s\n' '1,$-5000d' w | ed -s /var/log/openWB.log

# echo 1 > /var/www/html/openWB/ramdisk/reloaddisplay
mosquitto_pub -t openWB/system/reloadDisplay -m "1"
# echo "reset" > /var/www/html/openWB/ramdisk/mqtt.log

monthlyhead="web/logging/data/monthly/monthly_header.csv"
monthlyfile="web/logging/data/monthly/$(date +%Y%m).csv"

read bezug <ramdisk/bezugkwh
read einspeisung <ramdisk/einspeisungkwh
if [[ $pv2wattmodul != "none" ]]; then
	read pv <ramdisk/pvallwh
else
	read pv <ramdisk/pvkwh
fi

read ll1 <ramdisk/llkwh    # Zählerstand LP1
read ll2 <ramdisk/llkwhs1  # Zählerstand LP2
read ll3 <ramdisk/llkwhs2  # Zählerstand LP3
ll4=0 # $(<$RAMDISKDIR/llkwhlp4)  # Zählerstand LP4
ll5=0 # $(<$RAMDISKDIR/llkwhlp5)  # Zählerstand LP5
ll6=0 # $(<$RAMDISKDIR/llkwhlp6)  # Zählerstand LP6
ll7=0 # $(<$RAMDISKDIR/llkwhlp7)  # Zählerstand LP7
ll8=0 # $(<$RAMDISKDIR/llkwhlp8)  # Zählerstand LP8
read llg <ramdisk/llkwhges   # Zählerstand Gesamt

is_configured_cp1="1"                 #Ladepunkt 1 ist immer konfiguriert
is_configured_cp2=$lastmanagement     # LP2 konfiguriert?
is_configured_cp3=$lastmanagements2   # LP3 konfiguriert?
is_configured_cp4=0 # $lastmanagementlp4  # LP4 konfiguriert?
is_configured_cp5=0 # $lastmanagementlp5  # ...
is_configured_cp6=0 # $lastmanagementlp6
is_configured_cp7=0 # $lastmanagementlp7
is_configured_cp8=0 # $lastmanagementlp8

# wenn Pushover aktiviert, Zählerstände senden
if (( pushbenachrichtigung == "1" )) ; then
	if [ $(date +%d) == "01" ] ; then
		msg_header="Zählerstände zum $(date +%d.%m.%y:)"$'\n'
		msg_text=""
		lp_count=0
		for (( i=1; i<=8; i++ ))
		do
			var_name_energy="ll$i"
			var_name_cpname="lp${i}name"
			var_name_cp_configured="is_configured_cp${i}"
			if (( ${!var_name_cp_configured} == "1" )) ; then
				((lp_count++))
				msg_text+="LP$i (${!var_name_cpname}): ${!var_name_energy} kWh"$'\n'
			fi
		done
		if (( lp_count > 1 )) ; then
			msg_text+="Gesamtzähler: $llg kWh"
		fi
		runs/pushover.sh "$msg_header$msg_text"
	fi
fi

# ins Log als Wh
ll1=$(echo "$ll1 * 1000" | bc)
ll2=$(echo "$ll2 * 1000" | bc)
ll3=$(echo "$ll3 * 1000" | bc)
ll4=0 # $(echo "$ll4 * 1000" | bc)
ll5=0 # $(echo "$ll5 * 1000" | bc)
ll6=0 # $(echo "$ll6 * 1000" | bc)
ll7=0 # $(echo "$ll7 * 1000" | bc)
ll8=0 # $(echo "$ll8 * 1000" | bc)
llg=$(echo "$llg * 1000" | bc)

read speicherikwh <ramdisk/speicherikwh
read speicherekwh <ramdisk/speicherekwh
read verbraucher1iwh <ramdisk/verbraucher1_wh
read verbraucher1ewh <ramdisk/verbraucher1_whe
read verbraucher2iwh <ramdisk/verbraucher2_wh
read verbraucher2ewh <ramdisk/verbraucher2_whe
read d1 <ramdisk/device1_wh
read d2 <ramdisk/device2_wh
read d3 <ramdisk/device3_wh
read d4 <ramdisk/device4_wh
read d5 <ramdisk/device5_wh
read d6 <ramdisk/device6_wh
read d7 <ramdisk/device7_wh
read d8 <ramdisk/device8_wh
read d9 <ramdisk/device9_wh
d10="0"

# now add a line to our monthly csv
if ! [[ -e "$monthlyhead" ]] ; then
  echo "date,bezug,einspeisung,pv-wh,ll1-wh,ll2-wh,ll3-wh,llg-wh,verb1-iwh,verb1-ewh,verb2-iwh,verb2-ewh,ll4,ll5,ll6,ll7,ll8,bat-I-kwh,bat-E-kwh,d1-Wh,d2-Wh,d3-Wh,d4-Wh,d5-Wh,d6-Wh,d7-Wh,d8-Wh,d9-Wh,dx" > "$monthlyhead"
  openwbDebugLog "MAIN" 1 "monthly headline created: $monthlyhead"
fi

openwbDebugLog "MAIN" 0 "now add a line to our monthly csv"
echo $(date +%Y%m%d),$bezug,$einspeisung,$pv,$ll1,$ll2,$ll3,$llg,$verbraucher1iwh,$verbraucher1ewh,$verbraucher2iwh,$verbraucher2ewh,$ll4,$ll5,$ll6,$ll7,$ll8,$speicherikwh,$speicherekwh,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$d10 >> $monthlyfile

if [[ $verbraucher1_typ == "tasmota" ]]; then
	verbraucher1_oldwh=$(curl -s http://$verbraucher1_ip/cm?cmnd=Status%208 | jq '.StatusSNS.ENERGY.Total')
	if [[ $? == "0" ]]; then
		if [ -z "$verbraucher1_tempwh" ]; then
			verbraucher1_writewh=$(echo "scale=0;($verbraucher1_oldwh * 1000) / 1" | bc)
		else
			verbraucher1_writewh=$(echo "scale=0;(($verbraucher1_oldwh * 1000) + $verbraucher1_tempwh) / 1" | bc)
		fi
		sed -i "s/verbraucher1_tempwh=.*/verbraucher1_tempwh=$verbraucher1_writewh/" openwb.conf
		curl -s http://$verbraucher1_ip/cm?cmnd=EnergyReset1%200
		curl -s http://$verbraucher1_ip/cm?cmnd=EnergyReset2%200
		curl -s http://$verbraucher1_ip/cm?cmnd=EnergyReset3%200
	fi
fi
if [[ $verbraucher2_typ == "tasmota" ]]; then
	verbraucher2_oldwh=$(curl -s http://$verbraucher2_ip/cm?cmnd=Status%208 | jq '.StatusSNS.ENERGY.Total')
	if [[ $? == "0" ]]; then
		if [ -z "$verbraucher2_tempwh" ]; then
			verbraucher2_writewh=$(echo "scale=0;($verbraucher2_oldwh * 1000) / 1" | bc)
		else
			verbraucher2_writewh=$(echo "scale=0;(($verbraucher2_oldwh * 1000) + $verbraucher2_tempwh) / 1" | bc)
		fi
		sed -i "s/verbraucher2_tempwh=.*/verbraucher2_tempwh=$verbraucher2_writewh/" openwb.conf
		curl -s http://$verbraucher2_ip/cm?cmnd=EnergyReset1%200
		curl -s http://$verbraucher2_ip/cm?cmnd=EnergyReset2%200
		curl -s http://$verbraucher2_ip/cm?cmnd=EnergyReset3%200
	fi
fi


openwbDebugLog "MAIN" 0 "clear journald logfiles..."
sudo journalctl --rotate >>/var/log/openWB.log 2>&1
sudo journalctl --vacuum-time=1d >>/var/log/openWB.log 2>&1



openwbDebugLog "MAIN" 0 "monthly . csv updaten"
python3 runs/csvcalc.py --input /var/www/html/openWB/web/logging/data/daily/ --output /var/www/html/openWB/web/logging/data/v001/ --partial /var/www/html/openWB/ramdisk/ --mode A >> ramdisk/csvcalc.log 2>&1 &

openwbDebugLog "MAIN" 0 "rotate openWB.log"
[[ -f /var/log/openWB.log.4 ]] && sudo rm  /var/log/openWB.log.4
[[ -f /var/log/openWB.log.3 ]] && sudo cp -p /var/log/openWB.log.3 /var/log/openWB.log.4
[[ -f /var/log/openWB.log.2 ]] && sudo cp -p /var/log/openWB.log.2 /var/log/openWB.log.3
[[ -f /var/log/openWB.log.1 ]] && sudo cp -p /var/log/openWB.log.1 /var/log/openWB.log.2
sudo cp -p /var/log/openWB.log /var/log/openWB.log.1

openwbDebugLog "MAIN" 0 "##### croninighly.sh ends"
