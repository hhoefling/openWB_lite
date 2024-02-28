#!/bin/bash
OPENWBBASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

# Called:
# 1)  von mqttsub.py mit /home/pi und User pi
# 2)  von updatePeformNow.php mit /var/www/html/openWB/web/settings  und User pi


function Log()
{
 level=$1;
 shift;
 timestamp=$(date +"%Y-%m-%d %H:%M:%S")
 echo  "$timestamp: $$ $0 $*"
 echo  "$timestamp: $$ $0 $*" >>/var/log/openWB.log
 echo  "$timestamp: $$ $0 $*" >>/var/www/html/openWB/ramdisk/openWB_update.log
}
 
cd /var/www/html/openWB
. /var/www/html/openWB/loadconfig.sh
date "+%Y-%m-%d %H:%m:%S: start" >/var/www/html/openWB/ramdisk/openWB_update.log

# fallls das Script "überschrieben" wird statt mit "Delete/Write" neu erzeugt zu werden
# dann wird mittendrin die neue Version ausgeführt
# Die folgenden Zeilen sorgen dafür das auch ein geändertes Update Script keine Probleme macht

SELF=`basename $0`
if [[ $SELF != 'copyfromupdate.sh' ]] ; then
  ORG=$0
  export ORG
  [ -f /var/www/html/openWB/copyfromupdate.sh ] && rm /var/www/html/openWB/copyfromupdate.sh
  cp -p $0 /var/www/html/openWB/copyfromupdate.sh
  Log 0 "$SELF terminates now."
  exec /var/www/html/openWB/copyfromupdate.sh
  exit 0 # never reached
fi

function cleanup()
{
  Log 0 "now remove copyfromupdate.sh"
  rm  /var/www/html/openWB/copyfromupdate.sh
}
trap cleanup EXIT
Log 0 "Running, now it is save to override $ORG"


################# Check and Wait if cron job running.
cnt=0
while  (( cnt<20)) && ([ -f "$RAMDISKDIR/cronnighlyruns" ] || [ -f "$RAMDISKDIR/cron5runs" ] ) 
do
  Log 0 "###############  cron5min or cronnigly running. Wait....(max 120Sek)"
  sleep 1
  (( cnt++))
done

# in case of timeout
if [ -f "$RAMDISKDIR/cronnighlyruns" ] ; then 
  Log 0 "############### Now Killing background Job cronnighly.sh"
  sudo pkill 'cronnighly.sh' >/dev/null
  sudo rm -f "$RAMDISKDIR/cronnighlyruns" 
fi
if [ -f "$RAMDISKDIR/cron5runs" ]  ; then 
  Log 0 "############### Now Killing background Job cron5mins.sh"
  sudo pkill 'cron5mins.sh' >/dev/null
  sudo rm -f "$RAMDISKDIR/cron5runs" 
fi

Log 1 "######################## Send Stop to MQTT"
mosquitto_pub -t openWB/set/ChargeMode -r -m "3"


Log 1 "######################## Update starting... "

# set mode to stop and flags in ramdisk and broker to indicate current update state
echo 1 > /var/www/html/openWB/ramdisk/updateinprogress
echo 1 > /var/www/html/openWB/ramdisk/bootinprogress
mosquitto_pub -t openWB/system/updateInProgress -r -m "1"

echo "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist" > /var/www/html/openWB/ramdisk/lastregelungaktiv
mosquitto_pub -t "openWB/global/strLastmanagementActive" -r -m "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist"
echo "Update im Gange, bitte warten bis die Meldung nicht mehr sichtbar ist" > /var/www/html/openWB/ramdisk/mqttlastregelungaktiv
chmod 777 /var/www/html/openWB/ramdisk/mqttlastregelungaktiv

Log 1 "Stop legacy_run Server if running"
# The update might replace a number of files which might currently be in use by the continuously running legacy-run
# server. If we replace the source files while the process is running, funny things might happen.
# Thus we shut-down the legacy run server before performing the update.

# sudo pkill -u pi -f "/var/www/html/openWB/packages/legacy_run_server.py" >/dev/null

Log 1 "Wait 15 Sec. for regel.sh to accept the updatemode"
sleep 15


if [[ "$releasetrain" == "stable17" ]]; then
	train="stable"
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


Log 1 "backup some files before fetching new release"
# module soc_eq
cp -p modules/soc_eq/soc_eq_acc_lp1 /tmp/soc_eq_acc_lp1
cp -p modules/soc_eq/soc_eq_acc_lp2 /tmp/soc_eq_acc_lp2
cp -p openwb.conf /tmp/openwb.conf

Log 1 "fetch new release from GitHub as pi"

Log 1 "RUN git fetch origin"
git fetch origin

Log 1 "RUN git reset --hard origin/$train"
git reset --hard origin/$train

Log 1 "set permissions, Don't trust the github permissions"
cd /var/www/html/
sudo chown -R pi:pi openWB 
sudo find openWB \( -name "*.sh"  -or -name "*.py" \)  -exec chmod 0755 {} \; 

# Restore config 
sudo cp -p /tmp/openwb.conf /var/www/html/openWB/openwb.conf
sudo chmod 777 /var/www/html/openWB/openwb.conf
sudo chmod 777 /var/www/html/openWB/ramdisk/*
sleep 1

sudo chown -R pi:www-data /var/www/html/openWB/web/backup
sudo chown -R pi:www-data /var/www/html/openWB/web/tools/upload
sudo chmod -R g+w /var/www/html/openWB/web/tools/upload


Log 1 "restore saved files after fetching new release"
# module soc_eq
sudo cp -p /tmp/soc_eq_acc_lp1 /var/www/html/openWB/modules/soc_eq/soc_eq_acc_lp1
sudo cp -p /tmp/soc_eq_acc_lp2 /var/www/html/openWB/modules/soc_eq/soc_eq_acc_lp2

Log 1 "check links for standart theme"
(
 cd /var/www/html/openWB/web/themes/standard
 [ ! -r theme.html ]           && ln -s  ../dark/theme.html .
)


Log 1 "ends. now calling atreboot.sh as pi "

# now treat system as in booting state
nohup sudo -u pi /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1 &


	   
