#!/bin/bash

########## Re-Run as PI if not
USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" -- "$@"

# called as user pi
OPENWBBASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
LOGFILE="/var/log/openWB.log"
# always check for existing log file!, (shout be never needed)
if [[ ! -f $LOGFILE ]]; then
	sudo touch $LOGFILE
	sudo chmod 777 $LOGFILE
fi


. "$OPENWBBASEDIR/helperFunctions.sh"

# Definitve setzen
cd $OPENWBBASEDIR

SELF=`basename $0`
function log()
{
 timestamp=`date +"%Y-%m-%d %H:%M:%S: "`
 echo $timestamp $SELF $*
}


at_reboot() {

	versionMatch() {
		file=$1
		target=$2
		currentVersion=$(grep -o "openwb-version:[0-9]\+" "$file" | grep -o "[0-9]\+$")
		installedVersion=$(grep -o "openwb-version:[0-9]\+" "$target" | grep -o "[0-9]\+$")
		if (( currentVersion == installedVersion )); then
			return 0
		else
			return 1
		fi
	}
	log "started $$"

	# (sleep 600; sudo kill $(ps aux |grep '[a]treboot.sh' | awk '{print $2}') >/dev/null 2>&1; echo 0 > /var/www/html/openWB/ramdisk/bootinprogress; echo 0 > /var/www/html/openWB/ramdisk/updateinprogress) &
	# start Watchdog
	( pid=$$; cnt=0; 
	  while  ps -p $pid >/dev/null  && (( cnt < 600));  do  (( cnt++ )); sleep 1; done ;
	  if ps -p $pid >/dev/null ; then  
	    log "Watchdog TIMEOUT now kill $pid [$0]" 
	    sudo kill -9 "$pid" >/dev/null 2>&1 ;
  	    echo 0 >/var/www/html/openWB/ramdisk/bootinprogress;  
	    echo 0 >/var/www/html/openWB/ramdisk/updateinprogress
	  else 
	    log "Watchdog stoped" # parent finished before timeout 	 
	  fi	  
	 ) &
	# 
	# backup-Marker ist Hostname + SerienNr vom sd/usb Device
	# daruber wird die Ablage im Backup-Server gesteuert.
	sudo /bin/su -c "echo -n ${HOSTNAME}_ >/var/www/html/rinfo.txt"
	sudo chmod a+rw  /var/www/html/rinfo.txt
	cat /etc/fstab |grep "/boot" | cut -d " " -f 1 | cut -d "-" -f 1 | grep -o -E '[0-9a-f]*' >>/var/www/html/rinfo.txt

	# read openwb.conf
	log "loading config"
	. "$OPENWBBASEDIR/loadconfig.sh"

	# load some helper functions
	# no code will run here, functions need to be called
	. "$OPENWBBASEDIR/runs/initRamdisk.sh"
	. "$OPENWBBASEDIR/runs/updateConfig.sh"
#	. "$OPENWBBASEDIR/runs/rfid/rfidHelper.sh"
#	. "$OPENWBBASEDIR/runs/pushButtons/pushButtonsHelper.sh"
#	. "$OPENWBBASEDIR/runs/rse/rseHelper.sh"
		
	
	log Set bootinprogress and updateinprogress
	# if called from update (without reboot) block regel.sh 
	if [ -d "$OPENWBBASEDIR/ramdisk" ] ; then
		echo 1 > "$OPENWBBASEDIR/ramdisk/bootinprogress"
		echo 1 > "$OPENWBBASEDIR/ramdisk/updateinprogress"
	fi
	log "wait 10 Seconds for end of active regel.sh if any"
	sleep 10

	if [ ! -d "$OPENWBBASEDIR/web/backup" ] ; then
  		log "making backup direcotry"
  		mkdir -p "$OPENWBBASEDIR/web/backup"
	else
 		log "backupdir exists"  
	fi
	sudo touch "$OPENWBBASEDIR/web/backup/.donotdelete"
	log "checking rights und modes"
	# web/backup and web/tools/upload are used to (temporarily) store backup files for download and for restoring.
	# files are created from PHP as user www-data, thus www-data needs write permissions.
	sudo chown -R pi:www-data "$OPENWBBASEDIR/"{web/backup,web/tools/upload}
	sudo chmod -R g+w "$OPENWBBASEDIR/"{web/backup,web/tools/upload}

	sudo chmod 0777 "$OPENWBBASEDIR/openwb.conf"
	sudo chmod 0777 "$OPENWBBASEDIR/web/tools/upload"
	sudo chmod 0777 "$OPENWBBASEDIR/smarthome.ini"
	sudo chmod 0777 "$OPENWBBASEDIR/ramdisk"
	sudo chmod 0777 "$OPENWBBASEDIR/ramdisk/"
	sudo chmod 0777 "$OPENWBBASEDIR/web/files/"*
	sudo find "$OPENWBBASEDIR" \( -name "*.sh"  -or -name "*.py" \)  -exec chmod 0755 {} \; 
		
	# die schreiben in ihr verzeichniss
	sudo chmod -R 0777 "$OPENWBBASEDIR/modules/soc_i3"
	sudo chmod -R 0777 "$OPENWBBASEDIR/modules/soc_eq"
	sudo chmod -R 0777 "$OPENWBBASEDIR/modules/soc_tesla"

	sudo chmod 0777 "$OPENWBBASEDIR/web/files/"*
	
	mkdir -p "$OPENWBBASEDIR/web/logging/data/daily"
	mkdir -p "$OPENWBBASEDIR/web/logging/data/monthly"
	mkdir -p "$OPENWBBASEDIR/web/logging/data/ladelog"
	mkdir -p "$OPENWBBASEDIR/web/logging/data/v001"
	sudo chmod -R 0777 "$OPENWBBASEDIR/web/logging/data/"
	
	sudo touch $RAMDISKDIR/smarthome.log
	sudo chown pi:pi $RAMDISKDIR/smarthome.log 
	sudo chmod -R 0777 $RAMDISKDIR/smarthome.log


	# update openwb.conf
	log "update openwb.conf"
	updateConfig
	updated=$?
	if  (( updated )) ; then
		log "reload changed openwb.conf"
		. "$OPENWBBASEDIR/loadconfig.sh"
	fi
	# now setup all files in ramdisk
	initRamdisk

	# standard socket - activated after reboot due to RASPI init defaults so we need to disable it as soon as we can
	#if [[ $standardSocketInstalled == "1" ]]; then
	#	log "turning off standard socket ..."
	#	sudo python /var/www/html/openWB/runs/standardSocket.py off
	#fi

	# initialize automatic phase switching
	if (( u1p3paktiv == 1 )); then
		log "triginit...quick init of phase switching with default pause duration 2s"
		# quick init of phase switching with default pause duration (2s)
		sudo python3 "$OPENWBBASEDIR/runs/triginit.py" 2>&1 
	fi



	# check if tesla wall connector is configured and start daemon
	if [[ $evsecon == twcmanager ]]; then
		log "twcmanager..."
		if [[ $twcmanagerlp1ip == "localhost/TWC" ]]; then
			screen -dm -S TWCManager /var/www/html/TWC/TWCManager.py &
		fi
	fi

    #######---->>>>> Services.sh weiter unten
	# check if our modbus server is running
	# if Variable not set -> server active (old config)
#	if [[ "$modbus502enabled" == "0" ]]; then
#	  	log "modbus tcp server not enabled"
#	   	if ps ax |grep -v grep |grep "python3 /var/www/html/openWB/runs/modbusserver/modbusserver.py" > /dev/null
#	  	then
#    		log "kill running modbus tcp server"
#     		sudo pkill -f '^python.*/modbusserver.py' >/dev/null
#	  	fi
#	else
#	    if ps ax |grep -v grep |grep "sudo python3 /var/www/html/openWB/runs/modbusserver/modbusserver.py" > /dev/null
#	    then
#  	   		log "modbus tcp server already running"
#    	else
#	        log "modbus tcp server not running! restarting process"
#          	sudo bash -c "python3 \"$OPENWBBASEDIR/runs/modbusserver/modbusserver.py\" >>\"$LOGFILE\" 2>&1 & "
#    	fi
#	fi


	if ! [ -x "$(command -v tsp)" ];then
		sudo apt-get -qq update
		sleep 1
		sudo apt-get -qq install task-spooler
	fi
	# check if our task-scheduler is running
	if ((taskerenabled == 0 )); then
	  	log "tasker not enabled, stop Service if running"
	   	sudo -u pi tsp -K
	else
		if pgrep tsp >/dev/null 
	    #if ps ax |grep -v grep |grep "[t]sp" > /dev/null
	    then
  	   		log "tasker already running"
    	else
	        log "tasker not running! restarting a new tsp process"
          	sudo -u pi runs/tasker/start.sh
    	fi
	fi



	log "detect if LCD is avail."
	if which tvservice >/dev/null 2>&1  && sudo tvservice -s | grep -qF "[LCD], 800x480 @ 60.00Hz" ; then
		log "LCD detected"
	else
		if (( displayaktiv == 1 )) ; then
			log "No LCD detcted, disable displayaktiv"
			/var/www/html/openWB/runs/replaceinconfig.sh "displayaktiv=" "0"
		fi
		displayaktiv=0
		if (( isPC == 0 )) ; then 
			log "No LCD detcted on Raspi, stop lighttdm "	   
			sudo service lightdm stop >/dev/null 2>%1 # ignore error 
		fi	       
	fi

	# check if display is configured and setup timeout
	if (( displayaktiv == 1 )); then
		log "display..."

		if [ ! -d /home/pi/.config/lxsession ] ; then
			cp -rp /etc/xdg/lxsession /home/pi/.config/.
		fi
		if ! grep -Fq "pinch" /home/pi/.config/lxsession/LXDE-pi/autostart
		then
			log "not found"
			echo "@xscreensaver -no-splash" > /home/pi/.config/lxsession/LXDE-pi/autostart
			echo "@point-rpi" >> /home/pi/.config/lxsession/LXDE-pi/autostart
			echo "@xset s 600" >> /home/pi/.config/lxsession/LXDE-pi/autostart
			echo "@chromium-browser --incognito --disable-pinch --overscroll-history-navigation=0 --kiosk http://localhost/openWB/web/display.php" >> /home/pi/.config/lxsession/LXDE-pi/autostart
		fi
		log "deleting browser cache"
		rm -rf /home/pi/.cache/chromium
		sudo /var/www/html/openWB/runs/displaybacklight.sh $displayLight
	fi
	
	
        
    # setup push buttons handler if needed -->services.sh
    # pushButtonsSetup "$ladetaster" 1

    # setup rse handler if needed -->services.sh
    # rseSetup "$rseenabled" 1

    # log rfidhandler...
    # setup rfid handler if needed -->services.sh
    # rfidSetup "$rfidakt" 1 "$rfidlist"


    
#	# restart smarthomehandler -->services.sh
#	log "smarthome handler..."
#	# we need sudo to kill in case of an update from an older version where this script was not run as user `pi`:
#	sudo pkill -f '^python.*/smarthomehandler.py' >/dev/null
#	sudo pkill -f '^python.*/smarthomemq.py' >/dev/null
#	smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
#	if (( smartmq == 0 )); then
#		log "starting legacy smarthome handler"
#		nohup python3 "$OPENWBBASEDIR/runs/smarthomehandler.py" >> "$OPENWBBASEDIR/ramdisk/smarthome.log" 2>&1 &
#	else
#		log  "starting smarthomemq handler"
#		nohup python3 "$OPENWBBASEDIR/runs/smarthomemq.py" >> "$OPENWBBASEDIR/ramdisk/smarthome.log" 2>&1 &
#	fi

	# restart mqttsub handler -->services.sh
	#log "mqtt handler..."
	# we need sudo to kill in case of an update from an older version where this script was not run as user `pi`:
	# sudo pkill -f '^python.*/mqttsub.py'
	# nohup python3 "$OPENWBBASEDIR/runs/mqttsub.py" >>"$LOGFILE" 2>&1 &


    # -->services.sh
    #(
    # cd "$OPENWBBASEDIR"
    # openwbDebugLog "MAIN" 0 "##### start/restart sysdaem"
    # runs/sysdaem.sh restart &
    #)

	# restart legacy run server -->services.sh
	# log"legacy run server..."
	#bash "$OPENWBBASEDIR/packages/legacy_run_server.sh"


	# check crontab for user pi   ***OLD***
	# log "crontab 1..."
	# crontab -l -u pi > /var/www/html/openWB/ramdisk/tmpcrontab
	# if grep -Fq "lade.log" /var/www/html/openWB/ramdisk/tmpcrontab
	# then
	#	log "crontab modified"
	#	sed -i '/lade.log/d' /var/www/html/openWB/ramdisk/tmpcrontab
	#	echo "* * * * * /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1" >> /var/www/html/openWB/ramdisk/tmpcrontab
	#	cat /var/www/html/openWB/ramdisk/tmpcrontab | crontab -u pi -
	# fi

	# check crontab for user root and remove old @reboot entry
	# sudo crontab -l > /var/www/html/openWB/ramdisk/tmprootcrontab
	# if grep -Fq "atreboot.sh" /var/www/html/openWB/ramdisk/tmprootcrontab
	# then
	#	log "executed"
	#	sed -i '/atreboot.sh/d' /var/www/html/openWB/ramdisk/tmprootcrontab
	#	cat /var/www/html/openWB/ramdisk/tmprootcrontab | sudo crontab -
	# fi

	# check for LAN/WLAN connection
	log "LAN/WLAN..."
	ethstate=$(</sys/class/net/eth0/carrier)
	if (( ethstate == 1 )); then
		sudo ifconfig eth0:0 "$virtual_ip_eth0" netmask 255.255.255.0 up
	else
		sudo ifconfig wlan0:0 "$virtual_ip_wlan0" netmask 255.255.255.0 up
	fi

	# check for apache configuration
	log "apache..."
	restartService=0
	if grep -q "openwb-lite-version:1$" /etc/apache2/sites-available/000-default.conf >/dev/null 2>&1
	then
		log "...ok"
	else
		sudo cp "/var/www/html/openWB/web/tools/000-default.conf" /etc/apache2/sites-available/
		log "...updated"
		restartService=1
	fi
	
	if grep -q "openwb-lite-version:1$" /etc/apache2/sites-available/001-openwb_ssl.conf >/dev/null 2>&1
	then
		log "...ok"
	else
		sudo cp "/var/www/html/openWB/web/tools/001-openwb_ssl.conf" /etc/apache2/sites-available/
		log "...updated"
		restartService=1
	fi
	
	log "checking required apache modules..."
	if sudo a2query -m headers >/dev/null 2>&1
	then
		log "headers already enabled"
	else
		log "headers currently disabled; enabling module"
		sudo a2enmod headers
		restartService=1
	fi
	
	if sudo a2query -m proxy_wstunnel >/dev/null 2>&1
	then
		log "proxy_wstunnel already enabled"
	else
		log "proxy_wstunnel currently disabled; enabling module"
		sudo a2enmod proxy_wstunnel
		restartService=1
	fi
	
	if sudo a2query -m ssl >/dev/null 2>&1
	then
		log "ssl already enabled"
	else
		log "ssl currently disabled; enabling module"
		sudo a2enmod ssl
		sudo a2dissite default-ssl
		sudo a2ensite 001-openwb_ssl
		restartService=1
	fi
	# set upload limit in php
	log  "fix upload limit..."
	for d in /etc/php/*/apache2/conf.d ; do
		fn="$d/21-uploadlimit.ini"
		fnold="$d/20-uploadlimit.ini"
		[ -f "$fnold" ] && sudo rm "$fnold"
		if [ ! -f "$fn" ]; then
			sudo /bin/su -c " echo -e 'upload_max_filesize = 300M\npost_max_size = 300M' >\"$fn\" "
			log "Fix upload limit in $d and switch to v. 21"
			restartService=1
		fi
	done
		
	if (( restartService == 1 )); then
		log  "restarting apache..."
		sudo systemctl restart apache2
		log "done"
	fi
	

	# add some crontab entries for user pi
	log "crontab 2..."
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


	# check for email
	#if (dpkg -l | grep "ii.*msmtp" >/dev/null) ; then
	#  log "msmtp found. Please check config"
	#else
	#  log "install a simple smtp client"
	#  sudo apt-get -q -y install bsd-mailx msmtp msmtp-mta
	#  # check for configuration
	#   if [ ! -f /etc/msmtprc ] ; then
	#     if [ -f /home/pi/msmtp/msmtprc  ] ; then
	#	    log "updating global msmtprc config file"
  	#		sudo cp /home/pi/msmtp/msmtprc /etc/msmtprc#
	#   	sudo chown root:mail /etc/msmtprc
	#    	sudo chmod 0644 /etc/msmtprc
	#	    log "updating mail.rc and aliaes file"
	#		sudo cp -p /home/pi/msmtp/mail.rc /etc/mail.rc 
	#		sudo cp -p /home/pi/msmtp/aliases /etc/aliases
	#	 fi		 
	#   fi
	#fi
		

	# check for needed packages
	log "packages 1..."
	if python -c "import evdev" &> /dev/null 2>&1 ; then
		log 'evdev for python2 installed...'
	else
		sudo pip install evdev
	fi
	if python3 -c "import evdev" &> /dev/null 2>&1 ; then
		log 'evdev for python3 installed...'
	else
		sudo pip3 install evdev
	fi
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
	# . $OPENWBBASEDIR/loadconfig.sh

	# update old ladelog
	"$OPENWBBASEDIR/runs/transferladelog.sh"

	# check for led handler
	if (( ledsakt == 1 )); then
		log "led..."
		sudo python "$OPENWBBASEDIR/runs/leds.py" startup &
	fi

	# setup timezone
	log "timezone..."
	sudo cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime >/dev/null 2>&1

	if [ ! -f /home/pi/ssl_patched ]; then
		log "ssh patch neeeded" 
		sudo apt-get -qq update 
		sudo apt-get -qq install -y openssl libcurl3 curl libgcrypt20 libgnutls30 libssl1.1 libcurl3-gnutls libssl1.0.2 php7.0-cli php7.0-gd php7.0-opcache php7.0 php7.0-common php7.0-json php7.0-readline php7.0-xml php7.0-curl libapache2-mod-php7.0 
		touch /home/pi/ssl_patched
	fi



	# check for mosquitto packages
	log "mosquitto..."
	if [ ! -f /etc/mosquitto/mosquitto.conf ]; then
		sudo apt-get -qq update
		sudo apt-get -qq install -y mosquitto mosquitto-clients
		sudo service mosquitto start
	fi




	log  "check mosquitto installation..."

	restartService=0

	# check for mosquitto configuration
#	if ! sudo grep -q "openwb-lite-version:1$" /etc/mosquitto/mosquitto.conf; then
#		log "you need to updating mosquitto.conf!!!! "
#		sudo cp "/var/www/html/openWB/web/files/main_mosquitto.conf" /etc/mosquitto/mosquitto.conf
#		restartService=1
#	fi

	if ! sudo grep -q "openwb-lite-version:1$" /etc/mosquitto/conf.d/openwb.conf; then
		log "updating mosquitto openwb.conf"
		sudo cp "/var/www/html/openWB/web/files/mosquitto.conf" /etc/mosquitto/conf.d/openwb.conf
		restartService=1
	fi
	if [[ ! -f /etc/mosquitto/certs/openwb.key ]]; then
		log  "copy ssl certs..."
		sudo cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/mosquitto/certs/openwb.pem
		sudo cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/mosquitto/certs/openwb.key
		sudo chgrp mosquitto /etc/mosquitto/certs/openwb.key
		restartService=1
		log "done"
	fi
	if (( restartService == 1 )); then
		log  "restarting mosquitto service..."
		sudo systemctl stop mosquitto
		sleep 2
		sudo systemctl start mosquitto
		log "done"
	fi
	


	# check for other dependencies
	log "packages 2..."
	if python3 -c "import paho.mqtt.publish as publish" &> /dev/null; then
		log 'mqtt installed...'
	else
		sudo apt-get -qq install -y python3-pip
		sudo pip3 install paho-mqtt
		# restart needed!!!
	fi
	if python3 -c "import docopt" &> /dev/null; then
		log 'docopt installed...'
	else
		sudo pip3 install docopt
	fi
	if python3 -c "import certifi" &> /dev/null; then
		log 'certifi installed...'
	else
		sudo pip3 install certifi
	fi
	if python3 -c "import aiohttp" &> /dev/null; then
		log 'aiohttp installed...'
	else
		sudo pip3 install aiohttp
		# restart needed!!!
	fi
	if python3 -c "import pymodbus" &> /dev/null; then
		log 'pymodbus installed...'
	else
		sudo pip3 install pymodbus
		# restart needed!!!
	fi
	if python3 -c "import requests" &> /dev/null; then
		log 'python requests installed...'
	else
		sudo pip3 install requests
	fi
	#Prepare for jq in Python
	if python3 -c "import jq" &> /dev/null; then
		log 'jq installed...'
	else
		sudo pip3 install jq
		# restart needed!!!
	fi
	#Prepare for ipparser in Python
	if python3 -c "import ipparser" &> /dev/null; then
		log 'ipparser installed...'
	else
		sudo pip3 install ipparser
	fi
	#Prepare for lxml used in soc module libvwid in Python
	if python3 -c "import lxml" &> /dev/null; then
		log 'lxml installed...'
	else
		sudo pip3 install lxml
	fi
# vorgezogen, siehe oben    
	#Prepare for evdev used in readrfid
#	if python3 -c "import evdev" &> /dev/null; then
#		log 'evdev installed...'
#	else
#		sudo pip3 install evdev
#		# restart needed!!!
#	fi
	#Prepare for secrets used in soc module libvwid in Python
	VWIDMODULEDIR="$OPENWBBASEDIR/modules/soc_vwid"
	if python3 -c "import secrets" &> /dev/null; then
		log 'soc_vwid: python3 secrets installed...'
		if [ -L "$VWIDMODULEDIR/secrets.py" ]; then
			log 'soc_vwid: remove local python3 secrets.py...'
			rm "$VWIDMODULEDIR/secrets.py"
		fi
	else
		if [ ! -L "$VWIDMODULEDIR/secrets.py" ]; then
			log 'soc_vwid: enable local python3 secrets.py...'
			ln -s "$VWIDMODULEDIR/_secrets.py" "$VWIDMODULEDIR/secrets.py"
		fi
	fi
	# update outdated urllib3 for Tesla Powerwall
	pip3 install --upgrade urllib3
	pip3 install --upgrade requests
	
	# update version
	log "version..."
	uuid=$(</sys/class/net/eth0/address)
	owbv=$(<"$OPENWBBASEDIR/web/version")
	# NO curl --connect-timeout 10 -d "update=\"${releasetrain}${uuid}vers${owbv}\"" -H "Content-Type: application/x-www-form-urlencoded" -X POST https://openwb.de/tools/update.php
    log "version ${releasetrain}${uuid}vers${owbv} not published"

	# all done, remove warning in display
	log "clear warning..."
	echo " " > /var/www/html/openWB/ramdisk/lastregelungaktiv
	chmod 777 /var/www/html/openWB/ramdisk/lastregelungaktiv
	echo "" > /var/www/html/openWB/ramdisk/mqttlastregelungaktiv
	chmod 777 /var/www/html/openWB/ramdisk/mqttlastregelungaktiv
	
	echo " " > /var/www/html/openWB/ramdisk/LadereglerTxt
	chmod 777 /var/www/html/openWB/ramdisk/LadereglerTxt
	echo "" > /var/www/html/openWB/ramdisk/mqttLadereglerTxt
	chmod 777 /var/www/html/openWB/ramdisk/mqttLadereglerTxt



    ###############################################################
    # Make sure all services are running (restart crashed services etc.):
    # Used for: smartmq, rse, rfid, modbus, button, mqtt_sub, tasker, sysdaem
    # noch nicht f?r isss.py
    # 
    log restart all daemons with services.sh
    source "/var/www/html/openWB/runs/services.sh"
    service_main reboot all
    ###############################################################


#	# check for slave config and start handler
#	# we need sudo to kill in case of an update from an older version where this script was not run as user `pi`:
	sudo pkill -f '^python.*/isss.py'
	
	if (( isss == 1 )); then
		log "isss..."
		echo "$lastmanagement" > "$OPENWBBASEDIR/ramdisk/issslp2act"
		nohup python3 "$OPENWBBASEDIR/runs/isss.py" >>"$OPENWBBASEDIR/ramdisk/isss.log" 2>&1 &
		#     python3 "$OPENWBBASEDIR/runs/isss.py" &
		# second IP already set up !
		ethstate=$(</sys/class/net/eth0/carrier)
		if (( ethstate == 1 )); then
			sudo ifconfig eth0:0 "$virtual_ip_eth0" netmask 255.255.255.0 down
		else
			sudo ifconfig wlan0:0 "$virtual_ip_wlan0" netmask 255.255.255.0 down
		fi
	fi

	# check for socket system and start handler
	# we need sudo to kill in case of an update from an older version where this script was not run as user `pi`:
	sudo pkill -f '^python.*/buchse.py'
	if [[ "$evsecon" == "buchse" ]]  && [[ "$isss" == "0" ]]; then
		log "socket..."
		# ppbuchse is used in issss.py to detect "openWB Buchse"
		if [ ! -f /home/pi/ppbuchse ]; then
			echo "32" > /home/pi/ppbuchse
		fi
		nohup python3 "$OPENWBBASEDIR/runs/buchse.py" >>"$LOGFILE" 2>&1 &
	fi


	# update display configuration
	if (( displayaktiv == 1 )); then
		log "display update..."
		if grep -Fq "@chromium-browser --incognito --disable-pinch --kiosk http://localhost/openWB/web/display.php" /home/pi/.config/lxsession/LXDE-pi/autostart
		then
			sed -i "s,@chromium-browser --incognito --disable-pinch --kiosk http://localhost/openWB/web/display.php,@chromium-browser --incognito --disable-pinch --overscroll-history-navigation=0 --kiosk http://localhost/openWB/web/display.php,g" /home/pi/.config/lxsession/LXDE-pi/autostart
		fi
	else 
	    log "display not active"
	fi

	# get local ip
	ip route get 1 | awk '{print $7;exit}' > /var/www/html/openWB/ramdisk/ipaddress
	# 2.0
	# mosquitto_pub -t openWB/system/ip_address -p 1883 -r -m "\"$(ip route get 1 | awk '{print $7;exit}')\""
	# 1.9
	mosquitto_pub -t openWB/system/IpAddress -p 1883 -r -m "\"$(ip route get 1 | awk '{print $7;exit}')\""

	# update our local version
	sudo git -C "$OPENWBBASEDIR" show --pretty='format:%ci [%h]' | head -n1 > "$OPENWBBASEDIR/web/lastcommit"
	# and record the current commit details
	commitId=$(git -C "$OPENWBBASEDIR" log --format="%h" -n 1)
	echo "$commitId" > "$OPENWBBASEDIR/ramdisk/currentCommitHash"
	git -C "$OPENWBBASEDIR" branch -a --contains "$commitId" | perl -nle 'm|.*origin/(.+).*|; print $1' | uniq | xargs > "$OPENWBBASEDIR/ramdisk/currentCommitBranches"
	sudo chmod a+r "$OPENWBBASEDIR/ramdisk/currentCommitHash"
	sudo chmod a+r "$OPENWBBASEDIR/ramdisk/currentCommitBranches"

    rm -rf /var/www/html/openWB/web/themes/dark19_01 >/dev/null 2>&1

	# update broker
	log "update broker..."
	for i in $(seq 1 9);
	do
		configured=$(timeout 1 mosquitto_sub -C 1 -t "openWB/config/get/SmartHome/Devices/$i/device_configured")
		if ! [[ "$configured" == 0 || "$configured" == 1 ]]; then
			mosquitto_pub -r -t "openWB/config/get/SmartHome/Devices/$i/device_configured" -m "0"
		fi
	done
	mosquitto_pub -r -t openWB/graph/boolDisplayLiveGraph -m "1"
	mosquitto_pub -t openWB/global/strLastmanagementActive -r -m " "
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
	mosquitto_pub -r -t openWB/set/graph/RequestLLiveGraph -m "0"
	mosquitto_pub -r -t openWB/set/graph/RequestDayGraph -m "0"
	mosquitto_pub -r -t openWB/set/graph/RequestMonthGraphv1 -m "0"
	mosquitto_pub -r -t openWB/set/graph/RequestYearGraph -m "0"
	mosquitto_pub -r -t openWB/set/graph/RequestMonthLadelog -m "0"

	(sleep 10; mosquitto_pub -t openWB/set/ChargeMode -r -m "$bootmodus") &
	(sleep 10; mosquitto_pub -t openWB/global/ChargeMode -r -m "$bootmodus") &
	echo " " > "$OPENWBBASEDIR/ramdisk/lastregelungaktiv"
	sudo chmod 777 "$OPENWBBASEDIR/ramdisk/lastregelungaktiv"
	sudo chmod 777 "$OPENWBBASEDIR/ramdisk/smarthome.log"
	sudo chmod 777 "$OPENWBBASEDIR/ramdisk/smarthomehandlerloglevel"

	# update etprovider pricelist
	log "etprovider..."
	if [[ "$etprovideraktiv" == "1" ]]; then
		log "update electricity pricelist..."
		echo "" > /var/www/html/openWB/ramdisk/etprovidergraphlist
		mosquitto_pub -r -t openWB/global/ETProvider/modulePath -m "$etprovider"
		nohup "$OPENWBBASEDIR/modules/$etprovider/main.sh" >>"$LOGFILE" 2>&1 &
	else
		log "not activated, skipping"
		mosquitto_pub -r -t openWB/global/awattar/pricelist -m ""
	fi


	# all done, remove boot and update status
	log "remove boot und update marker"
	echo 0 > /var/www/html/openWB/ramdisk/bootinprogress
	echo 0 > /var/www/html/openWB/ramdisk/updateinprogress
	mosquitto_pub -t openWB/system/updateInProgress -r -m "0"
	mosquitto_pub -t openWB/system/reloadDisplay -m "1"
	log "boot done :-)"
}

# now call the defined function 
at_reboot

