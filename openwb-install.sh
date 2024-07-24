#!/bin/bash

## now with lf

if (( $(id -u) != 0 )); then
        echo "this script has to be run as user root or with sudo"
        exit 1
fi
if uname -a | grep -q x86_64 ; then isPC=1; else isPC=0; fi;
OPENWBBASEDIR=/var/www/html/openWB
# openwbgiturl="https://github.com/snaptec/openWB.git"
export openwbgiturl="http://www.hhoefling.local:3000/gitea/openwb67.git"
echo "installing openWB from $openwbgiturl into \"${OPENWBBASEDIR}\""
echo "isPC:$isPC"

if uname -a | grep -q 5.15 ; then isBullseye=1; else isBullseye=0; fi;


echo "install required packages..."
# check for outdated sources.list (Stretch only)
if grep -q -e "^deb http://raspbian.raspberrypi.org/raspbian/ stretch" /etc/apt/sources.list; then
	echo "sources.list outdated! upgrading..."
	sudo sed -i "s/^deb http:\/\/raspbian.raspberrypi.org\/raspbian\/ stretch/deb http:\/\/legacy.raspbian.org\/raspbian\/ stretch/g" /etc/apt/sources.list
else
	echo "sources.list already updated"
fi
	
apt-get update
apt-get -q -y install libapache2-mod-php jq raspberrypi-kernel-headers i2c-tools git mosquitto mosquitto-clients socat sshpass
# bullseye hat kein python-pip mehr, daher einzeln da sonst abbruch
apt-get -q -y install python-pip
apt-get -q -y install python3-pip
apt-get -q -y install vim at bc apache2 php php-gd php-curl php-xml php-json git
echo "...done"

echo "check for timezone"
if  grep -Fxq "Europe/Berlin" /etc/timezone
then
	echo "...ok"
else
	echo 'Europe/Berlin' > /etc/timezone
	dpkg-reconfigure -f noninteractive tzdata
	cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
	echo "...changed"
fi

echo "check for i2c bus"
if grep -Fxq "i2c-bcm2835" /etc/modules
then
	echo "...ok"
else
	echo "i2c-dev" >> /etc/modules
	echo "i2c-bcm2708" >> /etc/modules
	echo "snd-bcm2835" >> /etc/modules
	echo "dtparam=i2c1=on" >> /etc/modules
	echo "dtparam=i2c_arm=on" >> /etc/modules
fi

echo "check for tmp"
if [ ! -d /var/www/html/tmp ]; then
	cd /var/www/html/
	mkdir tmp
	chown www-data:www-data tmp
	chmod 0777 tmp
	echo "/var/www/html/tmp created"
else
	echo "...ok"
fi
echo "check for initial git clone"
if [ ! -d /var/www/html/openWB/web ]; then
	cd /var/www/html/
	mkdir openWB
 	chown pi:pi openWB
	chmod 0777 openWB
	sudo -u pi git clone --branch master ${openwbgiturl} openWB
	chown -R pi:pi openWB 
   	sudo -u pi git config --global --add safe.directory /var/www/html/openWB
	sudo -u pi git config --global credential.helper store
	echo "... git cloned"
	cd /var/www/html/openWB
	sudo cp -p openwb.conf.default openwb.conf
	ls -l openwb.*
	echo "... openwb.conf activated"
else
	echo "...ok"
fi

if ! grep -Fq "bootmodus=" /var/www/html/openWB/openwb.conf
then
	echo "bootmodus=3" >> /var/www/html/openWB/openwb.conf
fi

echo "check for ramdisk" 
if grep -Fxq "tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0" /etc/fstab 
then
	echo "...ok"
else
	mkdir -p /var/www/html/openWB/ramdisk
	echo "tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0" >> /etc/fstab
	mount -a
	echo "0" > /var/www/html/openWB/ramdisk/ladestatus
	echo "0" > /var/www/html/openWB/ramdisk/llsoll
	echo "0" > /var/www/html/openWB/ramdisk/soc
	echo "...created"
fi

echo "check for crontab root"
if grep -Fxq "@reboot /var/www/html/openWB/runs/atreboot.sh &" /var/spool/cron/crontabs/root
then
	echo "...ok"
else
	echo "@reboot /var/www/html/openWB/runs/atreboot.sh &" >> /tmp/tocrontab
	crontab -l -u root | cat - /tmp/tocrontab | crontab -u root -
	rm /tmp/tocrontab
	echo "...added"
fi

echo "check for crontab pi"
if grep -Fq "/var/www/html/openWB/runs/regler.sh" /var/spool/cron/crontabs/pi
then
	echo "...ok"
else
	(
	echo "# openWB Crontab for user pi"
	echo "@reboot /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1 "
	echo "1 0 * * * /var/www/html/openWB/runs/cronnightly.sh >> /var/log/openWB.log 2>&1 " 
	echo "*/5 * * * * /var/www/html/openWB/runs/cron5min.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * /var/www/html/openWB/regler.sh >> /var/log/openWB.log 2>&1 "
	) >/tmp/tocrontab
# ersetzen statt anhaengen
    #### crontab -l -u pi | cat - /tmp/tocrontab | crontab -u pi -
	cat /tmp/tocrontab | crontab -u pi -
	rm /tmp/tocrontab
	echo "...replaced"
	crontab -l -u pi
fi

# start mosquitto
sudo service mosquitto start

# check for mosquitto configuration
if [ ! -f /etc/mosquitto/conf.d/openwb.conf ]; then
	echo "updating mosquitto config file"
	sudo cp /var/www/html/openWB/web/files/mosquitto.conf /etc/mosquitto/conf.d/openwb.conf
#	sudo service mosquitto reload
	sudo service mosquitto restart
fi

echo "disable cronjob logging"
if grep -Fxq "EXTRA_OPTS=\"-L 0\"" /etc/default/cron
then
	echo "...ok"
else
	echo "EXTRA_OPTS=\"-L 0\"" >> /etc/default/cron
fi


# set upload limit in php
echo "fix upload limit..."
for d in /etc/php/*/apache2/conf.d ; do
	fn="$d/21-uploadlimit.ini"
	fnold="$d/20-uploadlimit.ini"
	[ -f "$fnold" ] && rm "$fnold"
	if [ ! -f "$fn" ]; then
		echo -e 'upload_max_filesize = 300M\npost_max_size = 300M' >$fn
		echo "Fix upload limit in $d and switch to v. 21"
        echo "$fn fixed"
		#restartService=1
	fi
done

echo "installing pymodbus"
if (( isBullseye == 0 )) ; then
    # Buster/Stretch
    sudo pip install  -U pymodbus
    sudo pip3 install -U --force-reinstall pymodbus==2.4.0
else
    # bullseye
    sudo pip3 install -U --force-reinstall pymodbus==2.5.3
fi
sudo pip3 install --upgrade requests

echo "check for paho-mqtt"
if python3 -c "import paho.mqtt.publish as publish" &> /dev/null; then
	echo 'mqtt installed...'
else
	# sudo pip3 install paho-mqtt
	# use latest 1.x (1.6.1)
	sudo pip3 install "paho-mqtt<2.0.0"
fi

if (( isBullseye == 0 )) ; then
    # Buster/Stretch
	#Adafruit install
	echo "check for MCP4725"
	if python -c "import Adafruit_MCP4725" &> /dev/null; then
		echo 'Adafruit_MCP4725 installed...'
	else
		sudo pip install Adafruit_MCP4725
	fi
fi

echo "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_pi-nopasswd
echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd

chmod 777 /var/www/html/openWB/openwb.conf
chmod +x /var/www/html/openWB/modules/*
chmod +x /var/www/html/openWB/runs/*
chmod +x /var/www/html/openWB/*.sh
touch /var/log/openWB.log
chmod 777 /var/log/openWB.log
touch /var/log/openwb.error.log
chmod 777 /var/log/openwb.error.log


# check links for standart theme
(
 cd /var/www/html/openWB/web/themes/standard
 [ ! -r theme.html ]           && ln -s  ../dark/theme.html .
)

if ! grep -Fq "openwbgiturl=" /var/www/html/openWB/openwb.conf
then
	echo "openwbgiturl=$openwbgiturl" >> /var/www/html/openWB/openwb.conf
else
  /var/www/html/openWB/runs/replaceinconfig.sh "openwbgiturl=" "$openwbgiturl"
fi

 
echo
echo Now calling atreboot.sh as user pi ... 
echo
sudo -u pi /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1
