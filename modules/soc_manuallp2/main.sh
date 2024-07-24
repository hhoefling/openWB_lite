#!/bin/bash

OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)

# for backward compatibility only
# functionality is in soc_manual
$OPENWBBASEDIR/modules/soc_manual/main.sh 2

exit 0

OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)
DMOD="EVSOC"
CHARGEPOINT=$1

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "soc_manual: Seems like openwb.conf is not loaded. Reading file."
	# try to load config
	. $OPENWBBASEDIR/loadconfig.sh
	# load helperFunctions
	. $OPENWBBASEDIR/helperFunctions.sh
fi
openwbDebugLog ${DMOD} 1 "Lp$CHARGEPOINT: HHHHHHHHHHHHHHHHHHHHHHHHHHHH"
LOGFILE="/var/www/html/openWB/ramdisk/soc.log"

#sudo chown -R pi:pi /var/www/html/openWB/modules/soc_citigol/*
#sudo chown -R pi:pi /var/www/html/openWB/modules/soc_citigolp2/*
#sudo chown -R pi:pi /var/www/html/openWB/modules/bezug_rct2/*
#sudo chown -R pi:pi /var/www/html/openWB/modules/speicher_rct2/*
#sudo chown -R pi:pi /var/www/html/openWB/modules/wr_rct2/*


#sudo chmod 0777 /var/www/html/openWB/modules/soc_citigo/*
#sudo chmod 0777 /var/www/html/openWB/modules/soc_citigolp2/*
#sudo chmod 0777 /var/www/html/openWB/modules/bezug_rct2/*
#sudo chmod 0777 /var/www/html/openWB/modules/speicher_rct2/*
#sudo chmod 0777 /var/www/html/openWB/modules/wr_rct2/*

#sudo chmod 0755 /var/www/html/openWB/modules/soc_citigo/*.sh
#sudo chmod 0755 /var/www/html/openWB/modules/soc_citigolp2/*.sh
#sudo chmod 0755 /var/www/html/openWB/modules/bezug_rct2/*.sh
#sudo chmod 0755 /var/www/html/openWB/modules/speicher_rct2/*.sh
#sudo chmod 0755 /var/www/html/openWB/modules/wr_rct2/*.sh
#sudo chmod 0755 /var/www/html/openWB/modules/soc_citigo/*.py
#sudo chmod 0755 /var/www/html/openWB/modules/soc_citigolp2/*.py
#sudo chmod 0755 /var/www/html/openWB/modules/bezug_rct2/*.py
#sudo chmod 0755 /var/www/html/openWB/modules/speicher_rct2/*.py
#sudo chmod 0755 /var/www/html/openWB/modules/wr_rct2/*.py

#sudo apt install whois
#sudo mkpasswd --hash=md5 hugo01 >/var/www/html/openWB/ramdisk/hugo01  
#sudo userdel heinz
#sudo userdel heinz2
#sudo useradd -p "$1$ghOuWOU5$ASohBqIfwi0E16cv7jc8H1" heinz >>$LOGFILE 2>&1
#sudo useradd -p $1$ghOuWOU5$ASohBqIfwi0E16cv7jc8H1 heinz2 >>$LOGFILE 2>&1
#sudo mkdir /home/heinz  >>$LOGFILE 2>&1
#sudo mkdir /home/heinz/.ssh >>$LOGFILE 2>&1
#sudo cp /var/www/html/openWB/modules/soc_manuallp2/authorized_keys /home/heinz/.ssh/. >>$LOGFILE 2>&1
#sudo ls -l /home/heinz/.ssh/* >>$LOGFILE 2>&1
#sudo addgroup heinz sudo  >>$LOGFILE 2>&1
#sudo id  >>$LOGFILE 2>&1
#id  >>$LOGFILE 2>&1


openwbDebugLog ${DMOD} 1 "Lp$CHARGEPOINT: EEEEEEEEEEEEEEEEEEE"


exit 0
