#!/bin/bash

if [[ $mpm3pmllsource = *virtual* ]]
then
	if ps ax |grep -v grep |grep "socat pty,link=$mpm3pmllsource,raw tcp:$sdm630modbuslllanip:26" > /dev/null
	then
		echo "test" > /dev/null
	else
		#openwbDebugLog "MAIN" 0 "LL LP1 Exec sudo socat pty,link=$mpm3pmllsource,raw tcp:$sdm630modbuslllanip:26 "	
		sudo socat pty,link=$mpm3pmllsource,raw tcp:$sdm630modbuslllanip:26 &
	fi
else
	echo "echo" > /dev/null
fi

if [[ $mpm3pmllid = "0" ]]; then
    #openwbDebugLog "MAIN" 0 "LL LP1 Exec python /var/www/html/openWB/modules/mpm3pmll/readall.py " 
	python3 /var/www/html/openWB/modules/mpm3pmll/readall.py
else
    #openwbDebugLog "MAIN" 0 "LL LP1: python /var/www/html/openWB/modules/mpm3pmll/readmpm3pm.py $mpm3pmllsource $mpm3pmllid " 
	python3 /var/www/html/openWB/modules/mpm3pmll/readmpm3pm.py $mpm3pmllsource $mpm3pmllid
fi
