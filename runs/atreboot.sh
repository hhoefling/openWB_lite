#!/bin/bash

USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" -- "$@"

# called from cron as user  pi
# called from update.sh as pi
OPENWBBASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
SELF=`basename $0`
LOGFILE="/var/log/openWB.log"
ERRFILE="/var/log/openwb.error.log"
# always check for existing log file!, (shout be never needed)
if [[ ! -f $LOGFILE ]]; then
	sudo touch $LOGFILE
	sudo chown pi:pi $LOGFILE
	sudo chmod 777 $LOGFILE
fi
# always check for existing error file!, (shout be never needed)
if [[ ! -f $ERRFILE ]]; then
	sudo touch $ERRFILE
	sudo chown pi:pi $ERRFILE
	sudo chmod 777 $ERRFILE
fi

cd $OPENWBBASEDIR || exit 1
source "./helperFunctions.sh"



function log()
{
# sollte nicht genutzt werden, da sonst zeilennummern nicht stimmen.
# also direkt openwbDebugLog aufrufen
 openwbDebugLog "MAIN" 0 "$*"
}

function dostop()
{
    echo 0 > ramdisk/bootinprogress
    echo 0 > ramdisk/updateinprogress
    mosquitto_pub -t openWB/system/updateInProgress -r -m "0"
    mosquitto_pub -t openWB/system/reloadDisplay -m "1"
}

# (sleep 600; sudo kill $(ps aux |grep '[a]treboot.sh' | awk '{print $2}'); echo 0 > /var/www/html/openWB/ramdisk/bootinprogress; echo 0 > /var/www/html/openWB/ramdisk/updateinprogress)  </dev/null >/dev/null 2>&1 &
# (sleep 600; sudo kill $(ps aux |grep '[a]treboot.sh' | awk '{print $2}') >/dev/null 2>&1; echo 0 > /var/www/html/openWB/ramdisk/bootinprogress; echo 0 > /var/www/html/openWB/ramdisk/updateinprogress) &
# start Watchdog
( pid=$$; cnt=0; 
  openwbDebugLog "MAIN" 2 "Watchdog started" 
  while  ps -p $pid >/dev/null  && (( cnt < 600));  do  (( cnt++ )); sleep 1; done ;
  if ps -p $pid >/dev/null ; then  
       openwbDebugLog "MAIN" 2 "Watchdog TIMEOUT now kill $pid [$0]" 
       sudo kill -9 "$pid" >/dev/null 2>&1 ;
       dostop
  else 
       openwbDebugLog "MAIN" 2 "Watchdog normal end" # parent finished before timeout      
  fi      
) &
 
    
PWD=$(pwd)
openwbDebugLog "MAIN" 2 "started, pwd: $PWD as: $USER "

########### Laufzeit protokolieren
start=$(date +%s)
function cleanup()
{
	local end=$(date +%s)
	local t=$((end-start))
	openwbDebugLog "MAIN" 0 "**** atreboot needs $t Sekunden"
	openwbDebugLog "DEB" 0 "**** atreboot needs $t Sekunden"
    dostop
}
trap cleanup EXIT
########### End Laufzeit protokolieren





# check for outdated sources.list (Stretch only)
if grep -q -e "^deb http://raspbian.raspberrypi.org/raspbian/ stretch" /etc/apt/sources.list; then
	openwbDebugLog "MAIN" 0 "sources.list outdated! upgrading..."
	sudo sed -i "s/^deb http:\/\/raspbian.raspberrypi.org\/raspbian\/ stretch/deb http:\/\/legacy.raspbian.org\/raspbian\/ stretch/g" /etc/apt/sources.list
else
	openwbDebugLog "MAIN" 0 "sources.list already updated"
fi
	

# read openwb.conf

if [ -d ramdisk ] ; then
	echo 1 > ramdisk/bootinprogress
	echo 1 > ramdisk/updateinprogress
fi
openwbDebugLog "MAIN" 2 "wait 10 Seconds for end of active regel.sh if any"
sleep 10
PWD=$(pwd)
openwbDebugLog "MAIN" 2 "run at $PWD"

# load functions to init ramdisk and update config
# no code will run here, functions need to be called
openwbDebugLog "MAIN" 2 "loading modules"
source runs/initRamdisk.sh
source runs/updateConfig.sh
# source runs/rfid/rfidHelper.sh



openwbDebugLog "MAIN" 2 "loading config"
source loadconfig.sh

if [ ! -d web/backup ] ; then
  openwbDebugLog "MAIN" 2 "making backup direcotry"
  mkdir -p web/backup
else
 openwbDebugLog "MAIN" 2 "backupdir exists"  
fi

openwbDebugLog "MAIN" 2 "checking rights und modes"
sudo chown  -R pi:pi /var/www/html/openWB/
sudo chown pi:pi web/backup/.donotdelete
sudo chown -R www-data:www-data web/tools/upload
sudo chown -R www-data:www-data web/backup
sudo chmod 777 web/backup
sudo chmod 777 web/tools/upload
sudo touch web/backup/.donotdelete
sudo chmod 777 openwb.conf
if [[ ! -f smarthome.conf ]]  ; then
  cp -p web/files/smarthome.conf smarthome.conf 
  openwbDebugLog "MAIN" 2 "smarthome.conf added"
fi
sudo chmod 777 smarthome.conf
sudo chmod 777 ramdisk
sudo chmod 777 ramdisk/
sudo chmod 777 web/files/*
sudo chmod -R +x modules/*
sudo chmod -R +x runs/*
sudo chmod    +x *.sh


# die schreiben in ihr verzeichniss
sudo chmod -R 777 modules/soc_i3
sudo chmod -R 777 modules/soc_eq
sudo chmod -R 777 modules/soc_tesla


mkdir -p web/logging/data/daily
mkdir -p web/logging/data/monthly
mkdir -p web/logging/data/ladelog
mkdir -p web/logging/data/v001
sudo chmod -R 777 web/logging/data/

# update openwb.conf
updateConfig
updated=$?
if  (( updated )) ; then
  openwbDebugLog "MAIN" 2 "reload changed openwb.conf"
   source loadconfig.sh
fi

# now setup all files in ramdisk
initRamdisk


# initialize automatic phase switching
if (( u1p3paktiv == 1 )); then
	openwbDebugLog "MAIN" 2 "triginit...quick init of phase switching with default pause duration 2s"
	# quick init of phase switching with default pause duration (2s)
	sudo python runs/triginit.py 2>&1 
fi

# check if buttons are configured and start daemon
# if (( ladetaster == 1 )); then
# 	openwbDebugLog "MAIN" 2 "pushbuttons..."
# 	if ! [ -x "$(command -v nmcli)" ]; then
# 		if ps ax |grep -v grep |grep "runs/ladetaster.py" > /dev/null
# 		then
# 			echo "test" > /dev/null
# 		else
# 			sudo python runs/ladetaster.py  </dev/null >/dev/null 2>&1 &
# 		fi
# 	fi
# fi


# openwbDebugLog "MAIN" 2 "rfidhandler..."
# rfidSetup "$rfidakt" 1 "$rfidlist"

# check if tesla wall connector is configured and start daemon
# if [[ $evsecon == twcmanager ]]; then
#	echo "twcmanager..."
#	if [[ $twcmanagerlp1ip == "localhost/TWC" ]]; then
#		screen -dm -S TWCManager /var/www/html/TWC/TWCManager.py  </dev/null >/dev/null 2>&1 &
#	fi
# fi

#  macht jetzt services.sh 
# check for rse and start daemon
# if (( rseenabled == 1 )); then
# 	openwbDebugLog "MAIN" 2 "rse..."
# 	if ! [ -x "$(command -v nmcli)" ]; then
# 		if ps ax |grep -v grep |grep "runs/rse.py" > /dev/null
# 		then
# 			echo "test" > /dev/null
# 		else
# 			sudo python runs/rse.py  </dev/null >/dev/null 2>&1 &
# 		fi
# 	fi
# fi


openwbDebugLog "MAIN" 2 "detect if LCD is avail."
 
if which tvservice >/dev/null 2>&1  && sudo tvservice -s | grep -qF "[LCD], 800x480 @ 60.00Hz" ; then
     openwbDebugLog "MAIN" 2 "LCD detected"
else
    if (( displayaktiv == 1 )) ; then
      openwbDebugLog "MAIN" 2 "No LCD detcted, disable displayaktiv"
      runs/replaceinconfig.sh "displayaktiv=" "0"
    fi
    openwbDebugLog "MAIN" 2 "No LCD detcted, stop lighttdm "
    sudo service lightdm stop >/dev/null 2>&1 # ignore error
    displayaktiv=0
fi

# check if tesla wall connector is configured and start daemon
# if [[ $evsecon == twcmanager ]]; then
#	openwbDebugLog "MAIN" 2 "twcmanager..."
#	if [[ $twcmanagerlp1ip == "localhost/TWC" ]]; then
#		screen -dm -S TWCManager /var/www/html/TWC/TWCManager.py  </dev/null >/dev/null 2>&1 &
#	fi
# fi


# check if display is configured and setup timeout
if (( displayaktiv == 1 )); then
	openwbDebugLog "MAIN" 2 "display..."

	if [ ! -d /home/pi/.config/lxsession ] ; then
 	   cp -rp /etc/xdg/lxsession /home/pi/.config/.
	fi
	if ! grep -Fq "pinch" /home/pi/.config/lxsession/LXDE-pi/autostart
	then
		openwbDebugLog "MAIN" 2 "not found"
		echo "@xscreensaver -no-splash" > /home/pi/.config/lxsession/LXDE-pi/autostart
		echo "@point-rpi" >> /home/pi/.config/lxsession/LXDE-pi/autostart
		echo "@xset s 600" >> /home/pi/.config/lxsession/LXDE-pi/autostart
		echo "@chromium-browser --incognito --disable-pinch --kiosk http://localhost/openWB/web/display.php" >> /home/pi/.config/lxsession/LXDE-pi/autostart
	fi
	openwbDebugLog "MAIN" 2 "deleting browser cache"
	rm -rf /home/pi/.cache/chromium
	sudo runs/displaybacklight.sh $displayLight
fi

# restart smarthomehandler
# openwbDebugLog "MAIN" 2 "smarthome handler..."
# if ps ax |grep -v grep |grep "runs/smarthomehandler.py" > /dev/null
# then
# 	sudo kill $(ps aux |grep '[s]marthomehandler.py' | awk '{print $2}')
# fi
# python3 runs/smarthomehandler.py >> ramdisk/smarthome.log 2>&1 &


# # restart mqttsub handler
# openwbDebugLog "MAIN" 2 "mqtt handler..."
# if ps ax |grep -v grep |grep "runs/mqttsub.py" > /dev/null
# then
# 	sudo kill $(ps aux |grep '[m]qttsub.py' | awk '{print $2}')
# fi
# python3 runs/mqttsub.py  </dev/null >/dev/null 2>&1 &


# check for LAN/WLAN connection
openwbDebugLog "MAIN" 2 "LAN/WLAN..."
ethstate=$(</sys/class/net/eth0/carrier)
if (( ethstate == 1 )); then
	sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 up
else
	sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 up
fi

# check for apache configuration
openwbDebugLog "MAIN" 2 "apache..."
if ( sudo grep -Fq "AllowOverride" /etc/apache2/sites-available/000-default.conf )
then
	openwbDebugLog "MAIN" 2  "...ok"
else
	sudo cp /var/www/html/openWB/web/tools/000-default.conf /etc/apache2/sites-available/
	openwbDebugLog "MAIN" 2  "...changed"
fi

# add some crontab entries for user pi
openwbDebugLog "MAIN" 2  "crontab 2..."
# remove old regel.sh
if sudo grep -Fq "regel.sh" /var/spool/cron/crontabs/pi
then
	crontab -l -u pi | grep -v regel.sh | crontab -u pi -
fi
if ! sudo grep -Fq "cronnightly.sh" /var/spool/cron/crontabs/pi
then
	(crontab -l -u pi ; echo "1 0 * * * /var/www/html/openWB/runs/cronnightly.sh >> /var/log/openWB.log 2>&1")| crontab -u pi -
fi
if ! sudo grep -Fq "cron5min.sh" /var/spool/cron/crontabs/pi
then
	(crontab -l -u pi ; echo "*/5 * * * * /var/www/html/openWB/runs/cron5min.sh >> /var/log/openWB.log 2>&1")| crontab -u pi -
fi
if ! sudo grep -Fq "atreboot.sh" /var/spool/cron/crontabs/pi
then
	(crontab -l -u pi ; echo "@reboot /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1")| crontab -u pi -
fi
# add new regler.sh
if ! sudo grep -Fq "regler.sh" /var/spool/cron/crontabs/pi
then
	(crontab -l -u pi ; echo "* * * * * /var/www/html/openWB/regler.sh 2>&1")| crontab -u pi -
fi


# check for email
#if [[ -x /usr/bin/msmtp ]] ; then
#  openwbDebugLog "MAIN" 2  "msmtp found. Please check config"
#else
#  openwbDebugLog "MAIN" 2  "install a simple smtp client"
#  sudo apt-get -q -y install bsd-mailx msmtp msmtp-mta
#  # check for configuration
#   if [ ! -f /etc/msmtprc ] ; then
#	openwbDebugLog "MAIN" 2  "updating global msmtprc config file"
#	sudo cp /var/www/html/openWB/web/files/msmtprc /etc/msmtprc
#    sudo chown root:mail /etc/msmtprc
#    sudo chmod 0640 /etc/msmtprc
#   fi
#fi


if [[ ! -x /usr/sbin/atd ]] ; then
  openwbDebugLog "MAIN" 2  "install at tool"
  sudo apt-get -q -y install at
fi
if [[ ! -x /usr/bin/mmc ]] ; then
  openwbDebugLog "MAIN" 2  "install mmc tool"
  sudo apt-get -q -y install mmc-utils
fi


# check for python2 needed packages  
# disabled becorse rfid use now python3
# unter buster geht's nicht mehr (syntax error)
#openwbDebugLog "MAIN" 2  "packages 1..."
#if python -c "import evdev" &> /dev/null; then
#	openwbDebugLog "MAIN" 2  'python2 evdev installed...'
#else
#	sudo pip install evdev
#fi

if ! [ -x "$(command -v sshpass)" ];then
	sudo apt-get -qq update
	sleep 1
	sudo apt-get -qq install sshpass
fi
if [ $(dpkg-query -W -f='${Status}' php-gd 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get -qq update
	sleep 1
	sudo apt-get -qq install -y php-gd
	sleep 1
	sudo apt-get -qq install -y php7.0-xml
fi
# required package for soc_vwid
if [ $(dpkg-query -W -f='${Status}' libxslt1-dev 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get -qq update 
	sudo apt-get -qq install -y libxslt1-dev
fi
# no need to reload config
# source /var/www/html/openWB/loadconfig.sh

# update old ladelog
./runs/transferladelog.sh

# check for led handler
if (( ledsakt == 1 )); then
	openwbDebugLog "MAIN" 2  "led..."
	sudo python runs/leds.py startup
fi

# setup timezone
openwbDebugLog "MAIN" 2  "timezone..."
sudo cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

if [ ! -f /home/pi/ssl_patched ]; then
	openwbDebugLog "MAIN" 2  "ssh patch neeeded" 
	sudo apt-get -qq update 
	sudo apt-get -qq install -y openssl libcurl3 curl libgcrypt20 libgnutls30 libssl1.1 libcurl3-gnutls libssl1.0.2 php7.0-cli php7.0-gd php7.0-opcache php7.0 php7.0-common php7.0-json php7.0-readline php7.0-xml php7.0-curl libapache2-mod-php7.0 
	touch /home/pi/ssl_patched 
fi

# check for mosquitto packages
openwbDebugLog "MAIN" 2  "mosquitto..."
if [ ! -f /etc/mosquitto/mosquitto.conf ]; then
	sudo apt-get -qq update
	sudo apt-get -qq install -y mosquitto mosquitto-clients
	sudo service mosquitto start
fi

# check for mosquitto configuration
if [ ! -f /etc/mosquitto/conf.d/openwb.conf ] || ! sudo grep -Fq "persistent_client_expiration" /etc/mosquitto/mosquitto.conf; then
	openwbDebugLog "MAIN" 2  "updating mosquitto config file"
	sudo cp /var/www/html/openWB/web/files/mosquitto.conf /etc/mosquitto/conf.d/openwb.conf
	sudo service mosquitto stop
	sudo service mosquitto start
fi

# check for other dependencies
openwbDebugLog "MAIN" 2  "packages 2..."
if python3 -c "import paho.mqtt.publish as publish" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'mqtt installed...'
else
	sudo apt-get -qq install -y python3-pip
	sudo pip3 install paho-mqtt
fi
if python3 -c "import docopt" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'docopt installed...'
else
	sudo pip3 install docopt
fi
if python3 -c "import certifi" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'certifi installed...'
else
	sudo pip3 install certifi
fi
if python3 -c "import aiohttp" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'aiohttp installed...'
else
	sudo pip3 install aiohttp
fi
if python3 -c "import pymodbus" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'pymodbus installed...'
else
	sudo pip3 install pymodbus
fi
if python3 -c "import requests" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'python requests installed...'
else
	sudo pip3 install requests
fi
#Prepare for jq in Python
if python3 -c "import jq" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'jq installed...'
else
	sudo pip3 install jq
fi
#Prepare for ipparser in Python
if python3 -c "import ipparser" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'ipparser installed...'
else
	sudo pip3 install ipparser
fi
#Prepare for lxml used in soc module libvwid in Python
if python3 -c "import lxml" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'lxml installed...'
else
	sudo pip3 install lxml
fi
#Prepare for evdev used in readrfid
if python3 -c "import evdev" &> /dev/null; then
	openwbDebugLog "MAIN" 2  'python3 evdev installed...'
else
	sudo pip3 install evdev
fi
### update outdated urllib3 for Tesla Powerwall
# pip3 install --upgrade urllib3


# update version
openwbDebugLog "MAIN" 2  "version..."
uuid=$(</sys/class/net/eth0/address)
owbv=$(</var/www/html/openWB/web/version)

sudo -u pi echo "update=${releasetrain}${uuid}vers${owbv}" >/home/pi/curldata
# No
# curl -d "update="$releasetrain$uuid"vers"$owbv"" -H "Content-Type: application/x-www-form-urlencoded" -X POST https://openwb.de/tools/update.php

# all done, remove warning in display
openwbDebugLog "MAIN" 2  "clear warning..."
echo " " > ramdisk/lastregelungaktiv
chmod 777 ramdisk/lastregelungaktiv
# echo "" > ramdisk/mqttv/lastregelungaktiv wird automatisch erzeugt
# chmod 777 ramdisk/mqttv/lastregelungaktiv


# check for slave config and start handler
#if (( isss == 1 )); then
#	openwbDebugLog "MAIN" 2  "isss..."
#	echo $lastmanagement > ramdisk/issslp2act
#	if ps ax |grep -v grep |grep "runs/isss.py" > /dev/null
#	then
#		sudo kill $(ps aux |grep '[i]sss.py' | awk '{print $2}')
#	fi
#	python3 runs/isss.py  </dev/null >/dev/null 2>&1 &
#	# second IP already set up !
#	ethstate=$(</sys/class/net/eth0/carrier)
#	if (( ethstate == 1 )); then
#		sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 down
#	else
#		sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 down
#	fi
#fi

## check for socket system and start handler
#if [[ "$evsecon" == "buchse" ]]  && [[ "$isss" == "0" ]]; then
#	openwbDebugLog "MAIN" 2  "socket..."
#	# ppbuchse is used in issss.py to detect "openWB Buchse"
#	if [ ! -f /home/pi/ppbuchse ]; then
#		echo "32" > /home/pi/ppbuchse
#	fi
#	if ps ax |grep -v grep |grep "runs/buchse.py" > /dev/null
#	then
#		sudo kill $(ps aux |grep '[b]uchse.py' | awk '{print $2}')
#	fi
#	python3 runs/buchse.py  </dev/null >/dev/null 2>&1 &
#fi


if (( displayaktiv == 1 )); then
	# update display configuration
	openwbDebugLog "MAIN" 2  "display update..."
	if grep -Fq "@chromium-browser --incognito --disable-pinch --kiosk http://localhost/openWB/web/display.php" /home/pi/.config/lxsession/LXDE-pi/autostart
	then
		sed -i "s,@chromium-browser --incognito --disable-pinch --kiosk http://localhost/openWB/web/display.php,@chromium-browser --incognito --disable-pinch --overscroll-history-navigation=0 --kiosk http://localhost/openWB/web/display.php,g" /home/pi/.config/lxsession/LXDE-pi/autostart
	fi
else 
    openwbDebugLog "MAIN" 2  "display not active"
fi



    ###############################################################
    # Make sure all services are running (restart crashed services etc.):
    # Used for: smartmq, rse, rfid, modbus, button, mqtt_sub, tasker, sysdaem, isss
    # 
    log restart all daemons with services.sh
    source runs/services.sh
    service_main reboot all
    ###############################################################


# get local ip
ip route get 1 | awk '{print $7;exit}' > ramdisk/ipaddress


# update our local version
sudo git -C /var/www/html/openWB show --pretty='format:%ci [%h]' | head -n1 > web/lastcommit
# and record the current commit details
commitId=`git -C /var/www/html/openWB log --format="%h" -n 1`
echo $commitId > ramdisk/currentCommitHash
echo `git -C /var/www/html/openWB branch -a --contains $commitId | perl -nle 'm|.*origin/(.+).*|; print $1' | uniq | xargs` > ramdisk/currentCommitBranches
sudo chmod 777 ramdisk/currentCommitHash
sudo chmod 777 ramdisk/currentCommitBranches

# update broker
openwbDebugLog "MAIN" 2  "update broker..."
for i in $(seq 1 9);
do
	configured=$(timeout 1 mosquitto_sub -C 1 -t openWB/config/get/SmartHome/Devices/$i/device_configured)
	if ! [[ "$configured" == 0 || "$configured" == 1 ]]; then
		mosquitto_pub -r -t openWB/config/get/SmartHome/Devices/$i/device_configured -m "0"
	fi
done
mosquitto_pub -r -t openWB/graph/boolDisplayLiveGraph -m "1"
mosquitto_pub -t openWB/global/strLastmanagementActive -r -m ""
mosquitto_pub -t openWB/global/strLaderegler -r -m " "
mosquitto_pub -t openWB/lp/1/W -r -m "0"
mosquitto_pub -t openWB/lp/2/W -r -m "0"
mosquitto_pub -t openWB/lp/3/W -r -m "0"
mosquitto_pub -t openWB/lp/1/boolChargePointConfigured -r -m "1"
mosquitto_pub -r -t openWB/SmartHome/Devices/1/TemperatureSensor0 -m ""
mosquitto_pub -r -t openWB/SmartHome/Devices/1/TemperatureSensor1 -m ""
mosquitto_pub -r -t openWB/SmartHome/Devices/1/TemperatureSensor2 -m ""
mosquitto_pub -r -t openWB/SmartHome/Devices/2/TemperatureSensor0 -m ""
mosquitto_pub -r -t openWB/SmartHome/Devices/2/TemperatureSensor1 -m ""
mosquitto_pub -r -t openWB/SmartHome/Devices/2/TemperatureSensor2 -m ""
# lasse die leeren Graphicn anlegen
mosquitto_pub -r -t openWB/set/graph/RequestMonthGraph -m "0"
mosquitto_pub -r -t openWB/set/graph/RequestDayGraph -m "0"
mosquitto_pub -r -t openWB/set/graph/RequestMonthGraphv1 -m "0"
mosquitto_pub -r -t openWB/set/graph/RequestYearGraph -m "0"
mosquitto_pub -r -t openWB/set/graph/RequestMonthLadelog -m "0"
# NC 
# mosquitto_pub -r -t openWB/set/graph/RequestLLiveGraph -m "0"




rm -rf /var/www/html/openWB/web/themes/dark19_01
(sleep 10; mosquitto_pub -t openWB/set/ChargeMode -r -m "$bootmodus") &
(sleep 10; mosquitto_pub -t openWB/global/ChargeMode -r -m "$bootmodus") &
echo " " > ramdisk/lastregelungaktiv
chmod 777 ramdisk/lastregelungaktiv
chmod 777 ramdisk/smarthome.log
chmod 777 ramdisk/smarthomehandlerloglevel

# update etprovider pricelist
openwbDebugLog "MAIN" 2  "etprovider..."
if [[ "$etprovideraktiv" == "1" ]]; then
	echo "" > ramdisk/etprovidergraphlist
	mosquitto_pub -r -t openWB/global/ETProvider/modulePath -m "$etprovider"
    openwbDebugLog "MAIN" 2  "update electricity pricelist..."
	/var/www/html/openWB/modules/$etprovider/main.sh >>/var/log/openWB.log 2>&1 &
else
	openwbDebugLog "MAIN" 2  "not activated, skipping"
	mosquitto_pub -r -t openWB/global/awattar/pricelist -m ""
fi

# set upload limit in php
#prepare for Buster
openwbDebugLog "MAIN" 2  "fix upload limit..."
if [ -d "/etc/php/7.0/" ]; then
	openwbDebugLog "MAIN" 2  "OS Stretch"
	sudo /bin/su -c "echo 'upload_max_filesize = 300M' > /etc/php/7.0/apache2/conf.d/20-uploadlimit.ini"
	sudo /bin/su -c "echo 'post_max_size = 300M' >> /etc/php/7.0/apache2/conf.d/20-uploadlimit.ini"
elif [ -d "/etc/php/7.3/" ]; then
	openwbDebugLog "MAIN" 2  "OS Buster"
	sudo /bin/su -c "echo 'upload_max_filesize = 300M' > /etc/php/7.3/apache2/conf.d/20-uploadlimit.ini"
	sudo /bin/su -c "echo 'post_max_size = 300M' >> /etc/php/7.3/apache2/conf.d/20-uploadlimit.ini"
fi
sudo /usr/sbin/apachectl -k graceful

# Syncron init mqtt
runs/pubmqtt.sh  2>&1


# all done, remove boot and update status
openwbDebugLog "MAIN" 2 "boot done :-)"
# cleanup macht rest

