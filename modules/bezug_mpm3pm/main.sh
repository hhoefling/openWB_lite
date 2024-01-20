#!/bin/bash

if [[ $mpm3pmevusource = *virtual* ]]
then
	if ps ax |grep -v grep |grep "socat pty,link=$mpm3pmevusource,raw tcp:$sdm630modbuslllanip:26" > /dev/null
	then
		echo "test" > /dev/null
	else
		sudo socat pty,link=$mpm3pmevusource,raw tcp:$sdm630modbuslllanip:26 &
	fi
else
	echo "echo" > /dev/null
fi
sudo python /var/www/html/openWB/modules/bezug_mpm3pm/readmpm3pm.py $mpm3pmevusource $mpm3pmevuid
read wattbezug </var/www/html/openWB/ramdisk/wattbezug
echo $wattbezug

if (( mpm3pmevuhaus == 1 )); then
	read evua1 </var/www/html/openWB/ramdisk/bezuga1
	read evua2 </var/www/html/openWB/ramdisk/bezuga2
	read evua3 </var/www/html/openWB/ramdisk/bezuga3
	read lla1 </var/www/html/openWB/ramdisk/lla1
	read lla2 </var/www/html/openWB/ramdisk/lla2
	read lla3 </var/www/html/openWB/ramdisk/lla3
	read llas11 </var/www/html/openWB/ramdisk/llas11
	read llas12 </var/www/html/openWB/ramdisk/llas12
	read llas13 </var/www/html/openWB/ramdisk/llas13
	
	bezuga1=$(echo "($evua1+$lla1+$llas12)" |bc)	
	bezuga2=$(echo "($evua2+$lla2+$llas13)" |bc)	
	bezuga3=$(echo "($evua3+$lla3+$llas11)" |bc)	
	echo $bezuga1 > /var/www/html/openWB/ramdisk/bezuga1
	echo $bezuga2 > /var/www/html/openWB/ramdisk/bezuga2
	echo $bezuga3 > /var/www/html/openWB/ramdisk/bezuga3

fi

