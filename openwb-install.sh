#!/bin/bash

if (( $(id -u) != 0 )); then
	echo "this script has to be run as user root or with sudo"
	exit 1
fi

OPENWBBASEDIR=/var/www/html/openWB
OPENWB_USER=pi
OPENWB_GROUP=pi
echo "installing openWB 1.9_lite into \"${OPENWBBASEDIR}\""

if which tvservice >/dev/null 2>&1  && sudo tvservice -s | grep -qF "[LCD], 800x480 @ 60.00Hz" ; then
    echo "LCD detected"
    hasLCD=1
else
    echo "no LCD detected"
    hasLCD=0
fi
if uname -a | grep -q x86_64 ; then isPC=1; else isPC=0; fi; 

echo "install required packages..."

apt-get update
dpkg -l >/home/pi/firstdpkg.txt
apt-get -q -y install whois dnsmasq hostapd openssl vim bc sshpass apache2 php php-gd php-curl php-xml php-json  
apt-get -q -y install libapache2-mod-php jq raspberrypi-kernel-headers i2c-tools git mosquitto mosquitto-clients 
apt-get -q -y install socat python-pip python3-pip python-pip-whl python-rpi.gpioa

# on Bullseye
apt-get -q -y install python2-pip python2
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
python2 get-pip.py
 

if (( hasLCD > 0 )) ; then
   echo "install chrome browser..."
   apt-get -q -y install chromium-browser
lse
   echo "no LCD, no chrome"
   apt-get -q -y install multitail
fi   
echo "...done"

needreboot=0
if ! grep -Fq "ipv6.disable=1" /boot/cmdline.txt
then
 echo "Disable ipv6, need reboot"
 line="$(</boot/cmdline.txt)"
 echo "$line ipv6.disable=1" >/boot/cmdline.txt
 needreboot=1
else
 echo "ipv6 allready disabled via cmdline.txt"
fi

if ! grep -Fq "dtoverlay=vc4-fkms-v3d"  /boot/config.txt
then
  echo "switch to dtoverlay=vc4-fkms-v3d"
  sed -i "s/^dtoverlay=vc4-kms-v3d/dtoverlay=vc4-fkms-v3d/" /boot/config.txt
  needreboot=1
else
  echo "allready use dtoverlay=vc4-fkms-v3d"
fi




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

echo "check for initial git clone"
if [ ! -d /var/www/html/openWB/web ]; then
	cd /var/www/html/
	git clone https://github.com/hhoefling/openWB_lite.git --branch master openWB
	chown -R pi:pi openWB 
	echo "... git cloned"
else
	echo "...ok"
fi

if ! grep -Fq "bootmodus=" /var/www/html/openWB/openwb.conf
then
	sudo -u pi /var/www/html/openWB//runs/replaceinconfig.sh "bootmodus=" "3"
fi
sudo -u pi /var/www/html/openWB//runs/replaceinconfig.sh "isPC=" "$isPC"
sudo -u pi /var/www/html/openWB//runs/replaceinconfig.sh "hasLCD=" "$hasLCD"


echo "check for ramdisk" 
if grep -Fxq "tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0" /etc/fstab 
then
	echo "...ok"
else
	mkdir -p /var/www/html/openWB/ramdisk
	echo "tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0" >> /etc/fstab
	mount -a
 	echo '0' > /var/www/html/openWB/ramdisk/ladestatus
	echo '0' > /var/www/html/openWB/ramdisk/llsoll
	echo '0' > /var/www/html/openWB/ramdisk/soc
	chown pi:pi /var/www/html/openWB/ramdisk/*
	chmod 0777 /var/www/html/openWB/ramdisk/*
	echo "...created"
fi

echo "check for crontab root"
if grep -Fq "@reboot sleep 10 && /home/pi/wlan.sh" /var/spool/cron/crontabs/root
then
	echo "...ok"
else
	echo "@reboot sleep 10 && /home/pi/wlan.sh" > /tmp/tocrontab
	crontab -l -u root | cat - /tmp/tocrontab | crontab -u root -
	rm /tmp/tocrontab
	echo "...added"
	crontab -l -u root
fi
echo "check for crontab pi"
if grep -Fq "/var/www/html/openWB/runs/atreboot.sh" /var/spool/cron/crontabs/pi
then
	echo "...ok"
else
	(
	echo "# openWB Crontab for user pi"
	echo "@reboot /var/www/html/openWB/runs/atreboot.sh >> /var/log/openWB.log 2>&1 "
	echo "1 0 * * * /var/www/html/openWB/runs/cronnightly.sh >> /var/log/openWB.log 2>&1 " 
	echo "*/5 * * * * /var/www/html/openWB/runs/cron5min.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * sleep 10 && /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * sleep 20 && /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * sleep 30 && /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * sleep 40 && /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
	echo "* * * * * sleep 50 && /var/www/html/openWB/regel.sh >> /var/log/openWB.log 2>&1 "
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

#prepare for Buster
echo -n "fix upload limit..."
if [ -d "/etc/php/7.0/" ]; then
	echo "OS Stretch"
	apt-get -q -y install -y libcurl3 curl libgcrypt20 libgnutls30 libssl1.1 libcurl3-gnutls libssl1.0.2 libapache2-mod-php7.0 php-curl php7.0-cli php7.0-gd php7.0-opcache php7.0 php7.0-common php7.0-json php7.0-readline php7.0-xml php7.0-curl php7.0-xml 
	sudo /bin/su -c "echo 'upload_max_filesize = 300M' > /etc/php/7.0/apache2/conf.d/20-uploadlimit.ini"
	sudo /bin/su -c "echo 'post_max_size = 300M' >> /etc/php/7.0/apache2/conf.d/20-uploadlimit.ini"
elif [ -d "/etc/php/7.3/" ]; then
	echo "OS Buster"
	apt-get -q -y install -y libcurl3-gnutls curl libgcrypt20 libgnutls30 libssl1.1 libcurl3-gnutls libssl1.0.2 libapache2-mod-php7.3 php-curl php7.3-cli php7.3-gd php7.3-opcache php7.3 php7.3-common php7.3-json php7.3-readline php7.3-xml php7.3-curl php7.3-xml 
	sudo /bin/su -c "echo 'upload_max_filesize = 300M' > /etc/php/7.3/apache2/conf.d/20-uploadlimit.ini"
	sudo /bin/su -c "echo 'post_max_size = 300M' >> /etc/php/7.3/apache2/conf.d/20-uploadlimit.ini"
fi

echo "installing pymodbus"
sudo pip install  -U pymodbus
sudo pip3 install  -U pymodbus
sudo pip3 install --upgrade requests

echo "check for paho-mqtt"
if python3 -c "import paho.mqtt.publish as publish" &> /dev/null; then
	echo 'mqtt installed...'
else
	sudo pip3 install paho-mqtt
fi


#Adafruit install
#echo "check for MCP4725"
#if python -c "import Adafruit_MCP4725" &> /dev/null; then
#	echo 'Adafruit_MCP4725 installed...'
#else
#	sudo pip install Adafruit_MCP4725
#fi

echo "pi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_pi-nopasswd
echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/010_pi-nopasswd

chmod 777 /var/www/html/openWB/openwb.conf
chmod +x /var/www/html/openWB/modules/*
chmod +x /var/www/html/openWB/runs/*
chmod +x /var/www/html/openWB/*.sh
touch /var/log/openWB.log
chmod 777 /var/log/openWB.log


# check links for standart theme
(
 cd /var/www/html/openWB/web/themes/standard
 [ ! -r theme.html ]           && ln -s  ../dark/theme.html .
)

dpkg -l >/home/pi/lastdpkg.txt
diff  /home/pi/firstdpkg.txt /home/pi/lastdpkg.txt >/home/pi/diffdpkg.txt
rm /home/pi/firstdpkg.txt /home/pi/lastdpkg.txt

if (( needreboot == 1 )); then
  echo "***************************"
  echo "please reboot and restart installation"A
  echo "***************************"
  echo "do reboot"
  exit 0
fi
echo
echo Now calling atreboot.sh as user pi ... 
echo
sudo -u pi /var/www/html/openWB/runs/atreboot.sh


