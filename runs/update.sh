#!/bin/bash
OPENWBBASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)

# Called:
# 1)  von mqttsub.py mit /home/pi und User pi
# 2)  von updatePeformNow.php mit /var/www/html/openWB/web/settings  und User pi


function Log()
{
 level=$1;
 shift;
 echo  "$0 $*"
 echo  "$0 $*" >>/var/www/html/openWB/ramdisk/openWB.log
}
 
cd /var/www/html/openWB
. /var/www/html/openWB/loadconfig.sh

Log 1 "starting... "

# set mode to stop and flags in ramdisk and broker to indicate current update state
mosquitto_pub -t openWB/set/ChargeMode -r -m "3"
mosquitto_pub -t openWB/system/updateInProgress -r -m "1"
echo 1 > /var/www/html/openWB/ramdisk/updateinprogress
echo 1 > /var/www/html/openWB/ramdisk/bootinprogress
echo "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist" > /var/www/html/openWB/ramdisk/lastregelungaktiv
mosquitto_pub -t "openWB/global/strLastmanagementActive" -r -m "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist"
echo "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist" > /var/www/html/openWB/ramdisk/mqttlastregelungaktiv
chmod 777 /var/www/html/openWB/ramdisk/mqttlastregelungaktiv

Log "Stop legacy_run Server if running"
# The update might replace a number of files which might currently be in use by the continuously running legacy-run
# server. If we replace the source files while the process is running, funny things might happen.
# Thus we shut-down the legacy run server before performing the update.

# sudo pkill -f "/var/www/html/openWB/packages/legacy_run_server.py" >/dev/null


if [[ "$releasetrain" == "stable17" ]]; then
	train=stable
else
	train=$releasetrain
fi

# check for ext openWB on configured chargepoints and start update
if [[ "$evsecon" == "extopenwb" ]]; then
	Log 1 "starting update on extOpenWB on LP1"
	mosquitto_pub -t openWB/set/system/releaseTrain -r -h $chargep1ip -m "$releasetrain"
	mosquitto_pub -t openWB/set/system/PerformUpdate -r -h $chargep1ip -m "1"
fi
if [[ $lastmanagement == "1" ]]; then
	if [[ "$evsecons1" == "extopenwb" ]]; then
		Log 1 "starting update on extOpenWB on LP2"
		mosquitto_pub -t openWB/set/system/releaseTrain -r -h $chargep2ip -m "$releasetrain"
		mosquitto_pub -t openWB/set/system/PerformUpdate -r -h $chargep2ip -m "1"
	fi
fi
if [[ $lastmanagements2 == "1" ]]; then
	if [[ "$evsecons2" == "extopenwb" ]]; then
		Log 1 "starting update on extOpenWB on LP3"
		mosquitto_pub -t openWB/set/system/releaseTrain -r -h $chargep3ip -m "$releasetrain"
		mosquitto_pub -t openWB/set/system/PerformUpdate -r -h $chargep3ip -m "1"
	fi
fi

#for i in $(seq 4 8); do
#	lastmanagementVar="lastmanagementlp$i"
#	evseconVar="evseconlp$i"
#	if [[ ${!lastmanagementVar} == "1" ]]; then
#		if [[ ${!evseconVar} == "extopenwb" ]]; then
#			Log 1  "starting update on extOpenWB on LP$i"
#			chargepIpVar="chargep${i}ip"
#			mosquitto_pub -t openWB/set/system/releaseTrain -r -h ${!chargepIpVar} -m "$releasetrain"
#			mosquitto_pub -t openWB/set/system/PerformUpdate -r -h ${!chargepIpVar} -m "1"
#		fi
#	fi
#done

sleep 15

Log 1 "backup some files before fetching new release"
# module soc_eq
cp modules/soc_eq/soc_eq_acc_lp1 /tmp/soc_eq_acc_lp1
cp modules/soc_eq/soc_eq_acc_lp2 /tmp/soc_eq_acc_lp2
cp openwb.conf /tmp/openwb.conf

Log 1 "fetch new release from GitHub"
sudo git fetch origin
sudo git reset --hard origin/$train

Log 1 "set permissions"
cd /var/www/html/
sudo chown -R pi:pi openWB 
sudo chown -R www-data:www-data /var/www/html/openWB/web/backup
sudo chown -R www-data:www-data /var/www/html/openWB/web/tools/upload
sudo cp /tmp/openwb.conf /var/www/html/openWB/openwb.conf

Log 1 "restore saved files after fetching new release"
# module soc_eq
sudo cp /tmp/soc_eq_acc_lp1 /var/www/html/openWB/modules/soc_eq/soc_eq_acc_lp1
sudo cp /tmp/soc_eq_acc_lp2 /var/www/html/openWB/modules/soc_eq/soc_eq_acc_lp2

Log 1 "set permissions"
sudo chmod 777 /var/www/html/openWB/openwb.conf
sudo chmod +x /var/www/html/openWB/modules/*
sudo chmod +x /var/www/html/openWB/runs/*
sudo chmod +x /var/www/html/openWB/*.sh
sudo chmod 777 /var/www/html/openWB/ramdisk/*
sudo chmod 777 /var/www/html/openWB/ramdisk/lade.log
sleep 2

Log 1 "check links for standart theme"
(
 cd /var/www/html/openWB/web/themes/standard
 [ ! -r theme.html ]           && ln -s  ../dark/theme.html .
)


Log 1 "end. now calling atreboot.sh as pi "

# now treat system as in booting state
nohup sudo -u pi /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1 &


	   
