#!/bin/bash
# dies ist utf8 äöüäöü

# Gloval und sofort beim sourcen
read lademodus <ramdisk/lademodus


# locale bash Variablen zum pubmqtt.sh exportieren
export dailychargelp1
export dailychargelp2
export dailychargelp3
export  ladeleistung    # die summe
export  ladeleistunglp1
export  ladeleistungs1
export  ladeleistungs2

function awokedisplay()
{
  openwbDebugLog "MAIN" 0 "Awoke internal Display"
  export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
  sudo -u pi XAUTHORITY=~pi/.Xauthority DISPLAY=:0 xset dpms force on
}


function timerun()  # time cmd paras
{
 local time=$1
 shift;
 local cmd=$1
 shift;
 
# openwbDebugLog "MAIN" 0 "EXEC:timout $time $cmd $*"
 if timeout -k $time $time $cmd $*  >/dev/null
 then
   rc=$? 	# 0
   # log Ok $rc
 else
   rc=$?	# err or 124
   openwbDebugLog "ERR" 0 "TIMEOUT:$rc $time [$cmd] [$*]  "
   openwbDebugLog "MAIN" 0 "ERROR TIMEOUT:$rc $time [$cmd] [$*]  "
 fi
 return $rc
}

function dotimed(){
 local mod=$1
 local time=${2:-0}
 if [[ -x $mod ]] ; then
	if (( time > 0 ))  ; then
		xpt=$ptx 
		ptstart
		timerun $time $mod
		rc=$?
		ptend $mod 100
		ptx=$xpt 
	else
		$mod &
		rc=0
	fi	   
 else	 
	openwbDebugLog "MAIN" 1 "NO $mod found"
	rc=0
 fi

 return $rc
}

ra='^-?[0-9]+$'


##########################################################
# !!!! Nicht aus $(...) heraus aufrufen, da sonst kein Nebeneffect moeglich
# read ramdisk/ramname  to vname , default from mqtt_topic if none 
##########################################################
readrdmqtt()  # vname, ramname,  topic 
{
	declare -n np="$1"
	if [[ -e ramdisk/$2 ]] ; then
		read -r np <ramdisk/$2
		# openwbDebugLog "MAIN" 0 "$1 read from ramdisk/$2 : [$np]"
	else
		np=$(timeout 2 mosquitto_sub -C 1 -t openWB/$3)
		# openwbDebugLog "MAIN" 0 "loadvars read openWB/$3 from mosquito $1 [$np]"
		if ! [[ $np =~ $ra ]] ; then
			np="0"
		fi
		openwbDebugLog "MAIN" 0 "readrdmqtt read openWB/$3 to $1 [$np]"
		echo $np > ramdisk/$2
	fi
}


##########################################################
# !!!! Nicht aus $(...) heraus aufrufen, da sonst kein Nebeneffect moeglich
# Write to mqtt if ramdisk has changed 
##########################################################
writerdmqtt()  # vname, ramname,  topic 
{
	declare -n np="$1"
	if [[ -e ramdisk/$2 ]] ; then
		read -r temp1 <ramdisk/$2
		# openwbDebugLog "MAIN" 0 "writerdmqtt read $2 [$temp1]  old:[$np]"
		if [[ $np !=  $temp1 ]]; then
			# openwbDebugLog "MAIN" 0 "writerdmqtt publish $temp1 to $3"
			mosquitto_pub -t openWB/$3 -r -m "$temp1"
		fi
	fi	
}


loadvars(){
	#reload mqtt vars
	read renewmqtt <ramdisk/renewmqtt
	if (( renewmqtt == 1 )); then
		openwbDebugLog "MAIN" 0 "**** SYNC MQTT Rennew ******"
		openwbDebugLog "EVENT" 0 "**** SYNC MQTT Rennew ******"
		echo 0 > ramdisk/renewmqtt
		rm ramdisk/mqttv/nextsynctime        
		#echo 01 | tee ramdisk/mqttv/*
		#echo 01 | tee ramdisk/mqttc/*
	fi

	#get temp vars
    # ersetzt die openwb.conf Werte mit den aus der Ramdisk
    read sofortll <ramdisk/lp1sofortll     # fuer sofortldemidus.sh alt
    read sofortlls1 <ramdisk/lp2sofortll   # fuer sofortldemidus.sh
    read sofortlls2 <ramdisk/lp3sofortll   # fuer sofortldemidus.sh
    read lp1sofortll <ramdisk/lp1sofortll  # fuer sofortldemidus.sh neu
    read lp2sofortll <ramdisk/lp2sofortll  # fuer sofortldemidus.sh
    read lp3sofortll <ramdisk/lp3sofortll  # fuer sofortldemidus.sh
    
    
	read lp1enabled <ramdisk/lp1enabled
	read lp2enabled <ramdisk/lp2enabled
	read lp3enabled <ramdisk/lp3enabled
#	lp4enabled=0 #$(<ramdisk/lp4enabled)
#	lp5enabled=0 #$(<ramdisk/lp5enabled)
#	lp6enabled=0 #$(<ramdisk/lp6enabled)
#	lp7enabled=0 #$(<ramdisk/lp7enabled)
#	lp8enabled=0 #$(<ramdisk/lp8enabled)
	
	read ladestatus <ramdisk/ladestatus
    read etprovidermaxprice <ramdisk/etprovidermaxprice
	read etproviderprice  <ramdisk/etproviderprice

	

	
	# EVSE DIN Plug State
	declare -r IsNumberRegex='^[0-9]+$'
	if [[ $evsecon == "modbusevse" ]]; then
		if [[ "$modbusevseid" == 0 ]]; then
			if [ -f /var/www/html/openWB/ramdisk/evsemodulconfig ]; then
				read modbusevsesource<ramdisk/evsemodulconfig
				modbusevseid=1
			else
				if [[ -e "/dev/ttyUSB0" ]]; then
					echo "/dev/ttyUSB0" > ramdisk/evsemodulconfig
				else
					echo "/dev/serial0" > ramdisk/evsemodulconfig
				fi
				read modbusevsesource<ramdisk/evsemodulconfig
				modbusevseid=1

			fi
		fi
### 64  modbusevsesource=/dev/ttyUSB0 modbusevseid=1
		
##################### 1002 get Vehicle Status
		openwbDebugLog "MAIN" 1 "EXEC: modbusevse sudo python runs/readmodbus.py $modbusevsesource $modbusevseid 1002 1"
		evseplugstate=$(sudo python runs/readmodbus.py $modbusevsesource $modbusevseid 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			# EVSE read returned empty or non-numeric value --> use last state for this loop
			read evseplugstate<ramdisk/evseplugstate
            openwbDebugLog "MAIN" 0 "Modbus EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > /var/www/html/openWB/ramdisk/evseplugstate
		fi
		read ladestatuslp1 <ramdisk/ladestatus
		if [ "$evseplugstate" -ge "0" ] && [ "$evseplugstate" -le "10" ] ; then
		    read plugstat <ramdisk/plugstat
			if [[ $evseplugstate > "1" ]]; then
				if [[ $plugstat == "0" ]] ; then
					if [[ $pushbplug == "1" ]] && [[ $ladestatuslp1 == "0" ]] && [[ $pushbenachrichtigung == "1" ]] ; then
						message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
					    openwbDebugLog "MAIN" 1 "EXEC: /var/www/html/openWB/runs/pushover.sh"
						/var/www/html/openWB/runs/pushover.sh "$message"
#########################################################################						
					fi
					if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
						export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
					fi
					echo 20000 > /var/www/html/openWB/ramdisk/soctimer
				fi
				echo 1 > ramdisk/plugstat
				plugstat=1
			else
			    if ! [[ $plugstat == "0" ]] ; then
				  openwbDebugLog "MAIN" 0 "***** evse meldet unpluged(<=1), setze plugstat=0"
				  echo 0 > ramdisk/plugstat
				fi  
				plugstat=0
			fi
			if [[ $evseplugstate > "2" ]] && [[ $ladestatuslp1 == "1" ]] && [[ $lp1enabled == "1" ]]; then
				echo 1 > ramdisk/chargestat
				chargestat=1
			else
				echo 0 > ramdisk/chargestat
				chargestat=0
			fi
		fi
	else
		read pluggedin<ramdisk/pluggedin
		if [ "$pluggedin" -gt "0" ]; then
			if [[ $pushbplug == "1" ]] && [[ $ladestatuslp1 == "0" ]] && [[ $pushbenachrichtigung == "1" ]] ; then
				message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
				openwbDebugLog "MAIN" 1 "EXEC: /var/www/html/openWB/runs/pushover.sh"
				/var/www/html/openWB/runs/pushover.sh "$message"
#########################################################################						
			fi
			if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
				export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
			fi
			echo 20000 > /var/www/html/openWB/ramdisk/soctimer
			echo 0 > /var/www/html/openWB/ramdisk/pluggedin
		fi

		read plugstat <ramdisk/plugstat
		read chargestat <ramdisk/chargestat
	fi
	if [[ $evsecon == "ipevse" ]]; then
#########################################################################						
		openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1"
		evseplugstatelp1=$(sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			read evseplugstate<ramdisk/evseplugstate
			openwbDebugLog "MAIN" 0 "IP EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > ramdisk/evseplugstate
		fi
		read ladestatuslp1 <ramdisk/ladestatus
		if [[ $evseplugstatelp1 > "1" ]]; then
			echo 1 > ramdisk/plugstat
		else
			echo 0 > ramdisk/plugstat
		fi
		if [[ $evseplugstatelp1 > "2" ]] && [[ $ladestatuslp1 == "1" ]] && [[ $lp1enabled == "1" ]]; then
			echo 1 > ramdisk/chargestat
		else
			echo 0 > ramdisk/chargestat
		fi
	fi

	if [[ $lastmanagement == "1" ]]; then
		ConfiguredChargePoints=2
		if [[ $evsecons1 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readmodbus.py $evsesources1 $evseids1 1002 1"
			evseplugstatelp2=$(sudo python runs/readmodbus.py $evsesources1 $evseids1 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				read evseplugstatelp2<ramdisk/evseplugstatelp2
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > /var/www/html/openWB/ramdisk/evseplugstatelp2
			fi
			read ladestatuss1 <ramdisk/ladestatuss1
			if [[ $evseplugstatelp2 > "0" ]] && [[ $evseplugstatelp2 < "7" ]] ; then
				if [[ $evseplugstatelp2 > "1" ]]; then
					read plugstat2 <ramdisk/plugstats1

					if [[ $plugstat2 == "0" ]] ; then
						if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
							export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
						fi
						echo 20000 > /var/www/html/openWB/ramdisk/soctimer1
					fi
					echo 1 > ramdisk/plugstats1
					plugstat2=1
					plugstats1=$plugstat2
				else
					echo 0 > ramdisk/plugstats1
					plugstat2=0
					plugstats1=$plugstat2
				fi
				if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuss1 == "1" ]] ; then
					echo 1 > ramdisk/chargestats1
				else
					echo 0 > ramdisk/chargestats1
				fi

			fi
		fi
		if [[ $evsecons1 == "slaveeth" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readslave.py 1002 1"
			evseplugstatelp2=$(sudo python runs/readslave.py 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				read evseplugstatelp2<ramdisk/evseplugstatelp2
				openwbDebugLog "MAIN" 0 "Slaveeth EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > ramdisk/evseplugstatelp2
			fi
			read ladestatuss1 <ramdisk/ladestatuss1

			if [[ $evseplugstatelp2 > "1" ]]; then
				echo 1 > ramdisk/plugstats1
			else
				echo 0 > ramdisk/plugstats1
			fi
			if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuss1 == "1" ]] ; then
				echo 1 > ramdisk/chargestats1
			else
				echo 0 > /var/www/html/openWB/ramdisk/chargestats1
			fi
		fi
		if [[ $evsecons1 == "ipevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readipmodbus.py $evseiplp2 $evseidlp2 1002 1"
			evseplugstatelp2=$(sudo python runs/readipmodbus.py $evseiplp2 $evseidlp2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				read evseplugstatelp2<ramdisk/evseplugstatelp2
				openwbDebugLog "MAIN" 0 "IP EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > ramdisk/evseplugstatelp2
			fi
			read ladestatuslp2 <ramdisk/ladestatuss1

			if [[ $evseplugstatelp2 > "1" ]]; then
				echo 1 > ramdisk/plugstats1
			else
				echo 0 > ramdisk/plugstats1
			fi
			if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuslp2 == "1" ]] && [[ $lp2enabled == "1" ]]; then
				echo 1 > ramdisk/chargestats1
			else
				echo 0 > ramdisk/chargestats1
			fi
		fi
		read plugstatlp2 <ramdisk/plugstats1
		read chargestatlp2 <ramdisk/chargestats1
	else
		read plugstatlp2 <ramdisk/plugstats1
		read chargestatlp2 <ramdisk/chargestats1
		ConfiguredChargePoints=1
	fi

	if [[ $lastmanagements2 == "1" ]]; then
		ConfiguredChargePoints=3
		if [[ $evsecons2 == "ipevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readipmodbus.py $evseiplp3 $evseidlp3 1002 1"
			evseplugstatelp3=$(sudo python runs/readipmodbus.py $evseiplp3 $evseidlp3 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				read evseplugstatelp3<ramdisk/evseplugstatelp3
				openwbDebugLog "MAIN" 0 "IP EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > ramdisk/evseplugstatelp3
			fi
			read ladestatuslp3 <ramdisk/ladestatuss2

			if [[ $evseplugstatelp3 > "1" ]]; then
				echo 1 > ramdisk/plugstatlp3
			else
				echo 0 > ramdisk/plugstatlp3
			fi
			if [[ $evseplugstatelp3 > "2" ]] && [[ $ladestatuslp3 == "1" ]] && [[ $lp3enabled == "1" ]]; then
				echo 1 > ramdisk/chargestatlp3
			else
				echo 0 > ramdisk/chargestatlp3
			fi
		fi


		if [[ $evsecons2 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: sudo python runs/readmodbus.py $evsesources2 $evseids2 1002 1"
			evseplugstatelp3=$(sudo python runs/readmodbus.py $evsesources2 $evseids2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				read evseplugstatelp3<ramdisk/evseplugstatelp3
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > ramdisk/evseplugstatelp3
			fi
			read ladestatuss2 <ramdisk/ladestatuss2
			if [[ $evseplugstatelp3 > "1" ]]; then
				echo 1 > ramdisk/plugstatlp3
			else
				echo 0 > ramdisk/plugstatlp3
			fi
			if [[ $evseplugstatelp3 > "2" ]] && [[ $ladestatuss2 == "1" ]] ; then
				echo 1 > ramdisk/chargestatlp3
			else
				echo 0 > ramdisk/chargestatlp3
			fi
		fi
		read plugstatlp3 <ramdisk/plugstatlp3
		read chargestatlp3 <ramdisk/chargestatlp3
	else
		read plugstatlp3 <ramdisk/plugstatlp3
		read chargestatlp3 <ramdisk/chargestatlp3
	fi

	# LP4-LP8 gelöscht

	echo $ConfiguredChargePoints > ramdisk/ConfiguredChargePoints
	# Lastmanagement var check age
	if test $(find "ramdisk/lastregelungaktiv" -mmin +2); then
		echo " " > ramdisk/lastregelungaktiv
	fi

	# Werte für die Berechnung ermitteln
	read lademodus<ramdisk/lademodus
	if [ -z "$lademodus" ] ; then
		mosquitto_pub -r -t "openWB/set/ChargeMode" -m "$bootmodus"
		lademodus=$bootmodus
	fi
	read llalt<ramdisk/llsoll
	# llaltlp1=$llalt

	#PV Leistung ermitteln
    # pv1watt Leistung WR1
    # pv2watt Leistung WR2
    # pvwatt gesamtleistung WR1 und WR2
    # pvallwatt gesamtleistung WR1 und WR2 gleich zu pvwatt
	# pv Counter
	# pvkwh zaehler wr1
	# pv2kwh zaehler wr2
	# pvallwh summe von pvkwh und pv2kwh (wird in cron5 und cronnighly verwendet)
    pv1watt=0
    pv2watt=0
    pvwatt=0
    pvallwatt=0
    pvkwh=0
    pv2kwh=0
    pvallwh=0
	if [[ $pvwattmodul != "none" ]]; then
		pv1vorhanden="1"
#########################################################################
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$pvwattmodul/main.sh"
		dotimed "modules/$pvwattmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "PV" 2 "Die PV-1 Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 1
		fi
		read pvwatt <ramdisk/pvwatt
		openwbDebugLog "MAIN" 2 "pvwatt: $pvwatt"
#########################################################################						
		if ! [[ $pvwatt =~ $re ]] ; then
			pvwatt="0"
		fi
		pv1watt=$pvwatt
		echo $pv1watt > ramdisk/pv1watt
	else
	    pv1vorhanden="0"
	fi
    echo $pv1vorhanden > ramdisk/pv1vorhanden
    
	if [[ $pv2wattmodul != "none" ]]; then
		pv2vorhanden="1"
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$pv2wattmodul/main.sh"
		dotimed "modules/$pv2wattmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "PV" 2 "Die PV-2 Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 2
		fi
		read pv2watt <ramdisk/pv2watt
        read pv2kwh <ramdisk/pv2kwh
        openwbDebugLog "MAIN" 2 "pv2watt: $pv2watt pv2kwh: $pv2kwh"
#########################################################################						
        if ! [[ $pv2watt =~ $re ]] ; then
            pv2watt="0"
        fi
	else
		pv2vorhanden="0"
	fi
    echo $pv2vorhanden > ramdisk/pv2vorhanden
    
    
    pvallwh=$(( pvkwh + pv2kwh ))       #pvallwh=$(echo "$pvkwh + $pv2kwh" |bc)
    echo $pvallwh > ramdisk/pvallwh
    
    pvallwatt=$(( pvwatt + pv2watt ))
    echo $pvallwatt > ramdisk/pvallwatt
    echo $pvallwatt > ramdisk/pvwatt
    openwbDebugLog "MAIN" 2 "pv pv{all}watt:$pvallwatt pvallwh:$pvallwh "

	#Speicher werte
	if [[ $speichermodul != "none" ]] ; then
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$speichermodul/main.sh"
		dotimed "modules/$speichermodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "BAT" 2 "Die Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen."
		fi
#########################################################################						
		read speicherleistung <ramdisk/speicherleistung
		speicherleistung=$(echo $speicherleistung | sed 's/\..*$//')
		read speichersoc <ramdisk/speichersoc
		speichersoc=$(echo $speichersoc | sed 's/\..*$//')
		speichervorhanden="1"
		echo 1 > ramdisk/speichervorhanden
		if [[ $speichermodul == "speicher_e3dc" ]] ; then
            read pvwatt <ramdisk/pvwatt
			echo 1 > ramdisk/pv1vorhanden
			pv1vorhanden="1"
		fi
		if [[ $speichermodul == "speicher_sonneneco" ]] ; then
			read pvwatt <ramdisk/pvwatt
			echo 1 > ramdisk/pv1vorhanden
			pv1vorhanden="1"
		fi
	else
		speichervorhanden="0"
		echo 0 > /var/www/html/openWB/ramdisk/speichervorhanden
	fi

	llphaset=3
	
	#Ladeleistung Summe ermitteln
	if [[ $ladeleistungmodul != "none" ]]; then
#########################################################################						
		#openwbDebugLog "MAIN" 1 "EXEC: timeout 8 modules/$ladeleistungmodul/main.sh"
		#timeout 8 modules/$ladeleistungmodul/main.sh || true
		openwbDebugLog "MAIN" 0 "EXEC:timout 8: modules/$ladeleistungmodul/main.sh"
		timerun 8 modules/$ladeleistungmodul/main.sh
#########################################################################						
		read llkwh <ramdisk/llkwh
		llkwhges=$llkwh
		read lla1<ramdisk/lla1
		read lla2<ramdisk/lla2
		read lla3<ramdisk/lla3
		lla1=$(echo $lla1 | sed 's/\..*$//')
		lla2=$(echo $lla2 | sed 's/\..*$//')
		lla3=$(echo $lla3 | sed 's/\..*$//')
		read llv1<ramdisk/llv1
		read llv2<ramdisk/llv2
		read llv3<ramdisk/llv3
		read ladeleistung <ramdisk/llaktuell        # die summe
		if ! [[ $lla1 =~ $re ]] ; then
			lla1="0"
		fi
		if ! [[ $lla2 =~ $re ]] ; then
			lla2="0"
		fi

		if ! [[ $lla3 =~ $re ]] ; then
			lla3="0"
		fi

		lp1phasen=0
		if [ $lla1 -ge $llphaset ]; then
			lp1phasen=$((lp1phasen + 1 ))
		fi
		if [ $lla2 -ge $llphaset ]; then
			lp1phasen=$((lp1phasen + 1 ))
		fi
		if [ $lla3 -ge $llphaset ]; then
			lp1phasen=$((lp1phasen + 1 ))
		fi
		echo $lp1phasen > /var/www/html/openWB/ramdisk/lp1phasen
		if ! [[ $ladeleistung =~ $re ]] ; then
			ladeleistung="0"
		fi
		ladeleistunglp1=$ladeleistung
		read ladestatus <ramdisk/ladestatus

	else
		lla1=0
		lla2=0
		lla3=0
		llv1=0
		llv2=0
		llv3=0
		ladeleistung=0
		ladeleistunglp1=0
		llkwh=0
		llkwhges=$llkwh
	fi

	#zweiter ladepunkt
	if [[ $lastmanagement == "1" ]]; then
		if [[ $socmodul1 != "none" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC&: modules/$socmodul1/main.sh &"
			modules/$socmodul1/main.sh &
#########################################################################						
			read soc1 <ramdisk/soc1
			if ! [[ $soc1 =~ $re ]] ; then
				read soc1 <ramdisk/tmpsoc1
			else
				echo $soc1 > ramdisk/tmpsoc1
			fi
			soc1vorhanden=1
		else
			soc1=0
			soc1vorhanden=0
		fi
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$ladeleistungs1modul/main.sh"
		dotimed "modules/$ladeleistungs1modul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "LP" 2 "Die LL-Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 2
		fi
		#########################################################################						
		read llkwhs1 <ramdisk/llkwhs1
		llkwhges=$(echo "$llkwhges + $llkwhs1" |bc)
		read llalts1 <ramdisk/llsolls1
		read ladeleistungs1 <ramdisk/llaktuells1
		read llas11 <ramdisk/llas11
		read llas12 <ramdisk/llas12
		read llas13 <ramdisk/llas13
		llas11=$(echo $llas11 | sed 's/\..*$//')
		llas12=$(echo $llas12 | sed 's/\..*$//')
		llas13=$(echo $llas13 | sed 's/\..*$//')
		read ladestatuss1 <ramdisk/ladestatuss1
		if ! [[ $ladeleistungs1 =~ $re ]] ; then
		      ladeleistungs1="0"
		fi
		ladeleistunglp2=$ladeleistungs1
		ladeleistung=$(( ladeleistung + ladeleistungs1 ))  # summieren
		echo "$ladeleistung" > ramdisk/llkombiniert
		lp2phasen=0
		if [ $llas11 -ge $llphaset ]; then
			lp2phasen=$((lp2phasen + 1 ))
		fi
		if [ $llas12 -ge $llphaset ]; then
			lp2phasen=$((lp2phasen + 1 ))
		fi
		if [ $llas13 -ge $llphaset ]; then
			lp2phasen=$((lp2phasen + 1 ))
		fi
		echo $lp2phasen > ramdisk/lp2phasen
	else
		echo "$ladeleistung" > ramdisk/llkombiniert
		ladeleistunglp2=0
		soc1vorhanden=0
        ladestatuss1=0
        llas1=0
		llas11=0
		llas12=0
		llas13=0
        soc1=0
        ladeleistungs1=0
        llalts1=0
	fi
    echo $ladeleistungs1 >ramdisk/llaktuells1
    echo $soc1vorhanden > ramdisk/soc1vorhanden

	#dritter ladepunkt
	if [[ $lastmanagements2 == "1" ]]; then
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$ladeleistungs2modul/main.sh"
		dotimed "modules/$ladeleistungs2modul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "LP" 2 "Die LL-Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 3
		fi
#########################################################################						
		read llkwhs2<ramdisk/llkwhs2
		llkwhges=$(echo "$llkwhges + $llkwhs2" |bc)
		llalts2=$(cat /var/www/html/openWB/ramdisk/llsolls2)
		read ladeleistungs2 <ramdisk/llaktuells2
		read llas21<ramdisk/llas21
		read llas22<ramdisk/llas22
		read llas23<ramdisk/llas23
		llas21=$(echo $llas21 | sed 's/\..*$//')
		llas22=$(echo $llas22 | sed 's/\..*$//')
		llas23=$(echo $llas23 | sed 's/\..*$//')
		lp3phasen=0
		if [ $llas21 -ge $llphaset ]; then
			lp3phasen=$((lp3phasen + 1 ))
		fi
		if [ $llas22 -ge $llphaset ]; then
			lp3phasen=$((lp3phasen + 1 ))
		fi
		if [ $llas23 -ge $llphaset ]; then
			lp3phasen=$((lp3phasen + 1 ))
		fi
		echo $lp3phasen > /var/www/html/openWB/ramdisk/lp3phasen
		read ladestatuss2 <ramdisk/ladestatuss2
		if ! [[ $ladeleistungs2 =~ $re ]] ; then
		ladeleistungs2="0"
		fi
		ladeleistunglp3=$ladeleistungs2
		ladeleistung=$(( ladeleistung + ladeleistungs2 ))
		echo "$ladeleistung" > ramdisk/llkombiniert
	else
		echo "$ladeleistung" > ramdisk/llkombiniert
		ladeleistungs2="0"
		ladeleistunglp3=0
        llas21=0
        llas22=0
        llas23=0
        llalts2=0
	fi

  	#  lp3-lp8


	echo "$ladeleistung" >ramdisk/llkombiniert
	echo $llkwhges > ramdisk/llkwhges



	#Wattbezug
	if [[ $wattbezugmodul != "none" ]]; then
#########################################################################						
		#openwbDebugLog "MAIN" 1 "EXEC: timeout 5 modules/$wattbezugmodul/main.sh"
		#if
		#  timeout 5 modules/$wattbezugmodul/main.sh >/dev/null
		#then
		#	wattbezug=$(</var/www/html/openWB/ramdisk/wattbezug)
		#else
		#	openwbDebugLog "DEB" 0 " EVU > 5 !!! "
		#	wattbezug=$(</var/www/html/openWB/ramdisk/wattbezug)
		#fi
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$wattbezugmodul/main.sh"
		dotimed "modules/$wattbezugmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "EVU" 2 "Die EVU Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 
		fi
		read wattbezug <ramdisk/wattbezug
		openwbDebugLog "MAIN" 2 "Wattbezug: $wattbezug"
#########################################################################						
		if ! [[ $wattbezug =~ $re ]] ; then
			wattbezug="0"
		fi
		wattbezugint=$(printf "%.0f\n" $wattbezug)
		#evu glaettung
		if (( evuglaettungakt == 1 )); then
			if (( evuglaettung > 20 )); then
				ganzahl=$(( evuglaettung / 10 ))
				for ((i=ganzahl;i>=1;i--)); do
					i2=$(( i + 1 ))
					cp ramdisk/glaettung$i ramdisk/glaettung$i2
				done
				echo $wattbezug > ramdisk/glaettung1
				for ((i=1;i<=ganzahl;i++)); do
					read glaettung<ramdisk/glaettung$i
					glaettungw=$(( glaettung + glaettungw))
				done
				glaettungfinal=$((glaettungw / ganzahl))
				echo $glaettungfinal > ramdisk/glattwattbezug
				wattbezug=$glaettungfinal
				echo $wattbezug >ramdisk/wattbezug	# HH Neu
			fi
		fi

# speicherpveinbeziehen=0 = Speicherladen hat vorrang
# - speicherwattnurpv = 1500
# - speichersocnurpv = 30%    		
# speicherpveinbeziehen=1 = EV Laden hat vorang
# - speichermaxwatt 200   	(soviel soll troztzden nindestns in den speiher geaden werden	

		# uberschuss zur berechnung
		openwbDebugLog "PV" 0 "----------------------"
		# uberschuss=$(printf "%.0f\n" $((-wattbezug)))
		((uberschuss= -wattbezug))
		if (( uberschuss > 0  )) ; then
			openwbDebugLog "PV" 0 "1: UEBERSCHUSS [$uberschuss] Watt EXPORT aus wattbezug"
		else
			openwbDebugLog "PV" 0 "1: UEBERSCHUSS [$uberschuss] Watt IMPORT aus wattbezug"
		fi
		if [[ $speichervorhanden == "1" ]]; then
			openwbDebugLog "PV" 0 "2: SP/EV:$speicherpveinbeziehen  SPL:${speicherleistung}W [${speichersoc}% > ${speichersocnurpv}%] " 
			bmeld "U:${uberschuss}W"
			if [[ $speicherpveinbeziehen == "1" ]]; then
				# EV Vorrang
				openwbDebugLog "PV" 1 "3: Speicher vorhanden und EV Vorrang"				
				if (( speicherleistung > 0 )); then    # es wird gerade der hausakku geladen
					if (( speichersoc > speichersocnurpv )); then  # der hausakku ist voll genug
						speicherww=$((speicherleistung + speicherwattnurpv))  # Akt HauskakkuLadeleistung + Erlaubt Endladeleistung  
						uberschuss=$((uberschuss + speicherww))			# draufpacken
						openwbDebugLog "PV" 0 "4a: UEBERSCHUSS $uberschuss  +  ($speicherleistung + $speicherwattnurpv) Hausspeicher voll Genug, stelle ladeleistung und erlaubte Entladeleistung zur verfügung "		
						bmeld "BEV+ Lade erhohe um +${speicherleistung}W+${speicherwattnurpv}W EndLade => U:${uberschuss}W"   
					else
						# Lade, aber Akku nicht voll genug
						# 100%=AUs
						# verwende nur die aktelle Ladeleistung als reduziere Akku Ladung auf 0 oder minimum
						speicherww=$((speicherleistung - speichermaxwatt))
						uberschuss=$((uberschuss + speicherww))
						openwbDebugLog "PV" 0 "4b: UEBERSCHUSS $uberschuss ($speicherleistung - $speichermaxwatt) "		
						bmeld "BEV++ Lade +${speicherleistung}W-${speichermaxwatt}ReserveW => U:${uberschuss}W"
					fi
				fi
			else
				# Speicher Vorrang
				openwbDebugLog "PV" 0 "4c: UEBERSCHUSS $uberschuss , nix da Speichervorrang"		
				bmeld "BBAT++  nix U:${uberschuss}W"
			fi
		else
			bmeld "Bat:None"
		fi
		openwbDebugLog "PV" 0 "5: UEBERSCHUSS $uberschuss  nach speichereinbeziehung"

		read evua1<ramdisk/bezuga1
		read evua2<ramdisk/bezuga2
		read evua3<ramdisk/bezuga3
		evua1=$(echo $evua1 | sed 's/\..*$//')
		evua2=$(echo $evua2 | sed 's/\..*$//')
		evua3=$(echo $evua3 | sed 's/\..*$//')
		[[ $evua1 =~ $re ]] || evua1="0"
		[[ $evua2 =~ $re ]] || evua2="0"
		[[ $evua3 =~ $re ]] || evua3="0"
		evuas=($evua1 $evua2 $evua3)
		maxevu=${evuas[0]}
		lowevu=${evuas[0]}
		for v in "${evuas[@]}"; do
			if (( v < lowevu )); then lowevu=$v; fi;
			if (( v > maxevu )); then maxevu=$v; fi;
		done
		schieflast=$(( maxevu - lowevu ))
		echo $schieflast > ramdisk/schieflast
	else
		# Kein Wattbezug module da., simuliere wattbezug aus anderen daten
		uberschuss=$((-pvwatt - hausbezugnone - ladeleistung))
		echo $((-uberschuss)) > ramdisk/wattbezug
		openwbDebugLog "PV" 0 "5: UEBERSCHUSS $uberschuss  aus simulation (kein EVU Module)"
		wattbezugint=$((-uberschuss))
		wattbezug=$wattbezugint
		echo $wattbezug > ramdisk/wattbezug
	fi


	# Abschaltbare Smartdevices zum Ueberschuss rechnen
	## NC echo $uberschuss > ramdisk/ueberschuss_org
	read wattabs<ramdisk/devicetotal_watt
	if (( wattabs>0 )) ; then
		uberschuss=$((uberschuss + wattabs))
		## NC echo $uberschuss > ramdisk/ueberschuss_mitsmart
		openwbDebugLog "PV" 0 "6: UEBERSCHUSS $uberschuss  nach addierung der abschaltbaren smartdev"
		bmeld "Bat +${wattabs}W abschaltbare => U:${uberschuss}W"
	fi



	#Soc ermitteln
	if [[ $socmodul != "none" ]]; then
		socvorhanden=1
		if (( stopsocnotpluggedlp1 == 1 )); then
			read soctimer <ramdisk/soctimer
			# if (( plugstat == 1 )); then
			if [ $plugstat -eq 1 -o $soctimer -eq 20005 ]; then # force soc update button sends 20005
#########################################################################
				openwbDebugLog "MAIN" 1 "EXEC&: modules/$socmodul/main.sh &"
				"modules/$socmodul/main.sh" &
#########################################################################
				read soc <ramdisk/soc
				if ! [[ $soc =~ $re ]] ; then
					read soc <ramdisk/tmpsoc
				else
					echo $soc > ramdisk/tmpsoc
				fi
			else
				echo 600 > ramdisk/soctimer
				read soc <ramdisk/soc
			fi
		else
#########################################################################
			openwbDebugLog "MAIN" 1 "EXEC&: modules/$socmodul/main.sh &"
			"modules/$socmodul/main.sh" &
#########################################################################
			read soc <ramdisk/soc
			if ! [[ $soc =~ $re ]] ; then
				read soc <ramdisk/tmpsoc
			else
				echo $soc > ramdisk/tmpsoc
			fi
		fi
	else
		socvorhanden=0
		soc=0
	fi
    echo $soc > ramdisk/soc
    echo $socvorhanden > ramdisk/socvorhanden


ptstart
# verbraucher  
verbraucher
ptend verbraucher 30

# alles ausgelesen 



# for graphing.sh
	if [ -s "ramdisk/device1_watt" ]; then read shd1_w<ramdisk/device1_watt; else shd1_w=0; fi
	if [ -s "ramdisk/device2_watt" ]; then read shd2_w<ramdisk/device2_watt; else shd2_w=0; fi
	if [ -s "ramdisk/device3_watt" ]; then read shd3_w<ramdisk/device3_watt; else shd3_w=0; fi
	if [ -s "ramdisk/device4_watt" ]; then read shd4_w<ramdisk/device4_watt; else shd4_w=0; fi
	if [ -s "ramdisk/device5_watt" ]; then read shd5_w<ramdisk/device5_watt; else shd5_w=0; fi
	if [ -s "ramdisk/device6_watt" ]; then read shd6_w<ramdisk/device6_watt; else shd6_w=0; fi
	if [ -s "ramdisk/device7_watt" ]; then read shd7_w<ramdisk/device7_watt; else shd7_w=0; fi
	if [ -s "ramdisk/device8_watt" ]; then read shd8_w<ramdisk/device8_watt; else shd8_w=0; fi
	if [ -s "ramdisk/device9_watt" ]; then read shd9_w<ramdisk/device9_watt; else shd9_w=0; fi
	if [ -s "ramdisk/device1_temp0" ]; then read shd1_t0<ramdisk/device1_temp0; else shd1_t0=0; fi
	if [ -s "ramdisk/device1_temp1" ]; then read shd1_t1<ramdisk/device1_temp1; else shd1_t1=0; fi
	if [ -s "ramdisk/device1_temp2" ]; then read shd1_t2<ramdisk/device1_temp2; else shd1_t2=0; fi
	
	if [ -s "ramdisk/devicetotal_watt_hausmin" ]; then read shdall_w<ramdisk/devicetotal_watt_hausmin; else shdall_w=0; fi
	if [ -s "ramdisk/verbraucher1_watt" ]; then read verb1_w<ramdisk/verbraucher1_watt; else verb1_w=0; fi
	verb1_w=$(printf "%.0f\n" $verb1_w)
	if [ -s "ramdisk/verbraucher2_watt" ]; then read verb2_w<ramdisk/verbraucher2_watt; else verb2_w=0; fi
	verb2_w=$(printf "%.0f\n" $verb2_w)

## 
## wattbezug=			-319
## pvwatt=				-4304
## ladeleistung=		3348
## speicherleistung=	0
## shdall_w=			86
## verb1_w=				0
## verb2_w=				0

## hausverbrauch=		551


	hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shdall_w - verb1_w - verb2_w))
	if (( hausverbrauch < 0 )); then
		if [ -f ramdisk/hausverbrauch.invalid ]; then
			read hausverbrauchinvalid <ramdisk/hausverbrauch.invalid
			let hausverbrauchinvalid+=1
		else
			hausverbrauchinvalid=1
		fi
		echo "$hausverbrauchinvalid" > ramdisk/hausverbrauch.invalid
		if (( hausverbrauchinvalid < 3 )); then
			read hausverbrauch <ramdisk/hausverbrauch
		else
			hausverbrauch=0
		fi
	else
		echo "0" > ramdisk/hausverbrauch.invalid
	fi
	echo $hausverbrauch > ramdisk/hausverbrauch
    

	usesimbezug=0
	[[ -r modules/${wattbezugmodul}/usesim ]] && read usesimbezug <modules/${wattbezugmodul}/usesim
	
#	fronius_sm_bezug_meterlocation=$(<ramdisk/fronius_sm_bezug_meterlocation)
#    if [[ $fronius_sm_bezug_meterlocation == "1" ]]; then
#            usesimbezug=1
#    fi

#    needle=$wattbezugmodul
#    all=",bezug_e3dc,bezug_huawei,bezug_carlogavazzilan,bezug_siemens,bezug_solarwatt,bezug_rct"
#    all+=",bezug_sungrow,bezug_powerdog,bezug_varta,bezug_lgessv1,bezug_kostalpiko,bezug_kostalplenticoreem300haus"
#    all+=",bezug_sbs25,bezug_solarlog,bezug_sonneneco,"
#    if [ "${all/",$needle,"}" != "$all" ] ; then
#            usesimbezug=1
#    fi
#
#    if [[ $wattbezugmodul == "bezug_e3dc" ]] || [[ $wattbezugmodul == "bezug_huawei" ]] || [[ $wattbezugmodul == "bezug_carlogavazzilan" ]]|| [[ $wattbezugmodul == "bezug_siemens" ]] || [[ $wattbezugmodul == "bezug_solarwatt" ]]|| [[ $wattbezugmodul == "bezug_rct" ]]|| [[ $wattbezugmodul == "bezug_sungrow" ]] || [[ $wattbezugmodul == "bezug_powerdog" ]] || [[ $wattbezugmodul == "bezug_varta" ]] || [[ $wattbezugmodul == "bezug_lgessv1" ]] || [[ $wattbezugmodul == "bezug_kostalpiko" ]] || [[ $wattbezugmodul == "bezug_kostalplenticoreem300haus" ]] || [[ $wattbezugmodul == "bezug_sbs25" ]] || [[ $wattbezugmodul == "bezug_solarlog" ]] || [[ $wattbezugmodul == "bezug_sonneneco" ]] || [[ $fronius_sm_bezug_meterlocation == "1" ]]; then
#        usesimbezug=1
#    fi


	if [[ $usesimbezug == "1" ]]; then
		read watt2 <ramdisk/wattbezug

		readrdmqtt  "importtemp" "bezugwatt0pos" "evu/WHImported_temp" 
		readrdmqtt  "exporttemp" "bezugwatt0neg" "evu/WHExport_temp" 
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh
#########################################################################						
		writerdmqtt  "importtemp" "bezugwatt0pos" "evu/WHImported_temp" 
		writerdmqtt  "exporttemp" "bezugwatt0neg" "evu/WHExport_temp" 
	fi

	usesimpv=0

	if [[ $pvwattmodul == "none" ]] && [[ $speichermodul == "speicher_e3dc" ]]; then
		usesimpv=1
	fi
	if [[ $speichermodul == "speicher_kostalplenticore" ]] && [[ $pvwattmodul == "wr_plenticore" ]]; then
		usesimpv=1
	fi
	if [[ $speichermodul == "speicher_solaredge" ]] && [[ $pvwattmodul == "wr_solaredge" ]]; then
		usesimpv=1
	fi
	if [[ $pvwattmodul == "wr_fronius" ]] && [[ $speichermodul == "speicher_fronius" ]]; then
		usesimpv=1
	fi
	if [[ $pvwattmodul == "wr_fronius" ]] && [[ $wrfroniusisgen24 == "1" ]]; then
		usesimpv=1
	fi
	[[ -r modules/${pvwattmodul}/usesim ]] && read usesimpv <modules/${pvwattmodul}/usesim
#    needle=$pvwattmodul
#    all=",wr_kostalpiko,wr_siemens,wr_rct,wr_solarwatt,wr_shelly,wr_sungrow,wr_huawei,wr_powerdog,wr_lgessv1,wr_kostalpikovar2,"
#    if [ "${all/",$needle,"}" != "$all" ] ; then
#            usesimpv=1
#    fi
#	if [[ $pvwattmodul == "wr_kostalpiko" ]] || [[ $pvwattmodul == "wr_siemens" ]] || [[ $pvwattmodul == "wr_rct" ]]|| [[ $pvwattmodul == "wr_solarwatt" ]] || [[ $pvwattmodul == "wr_shelly" ]] || [[ $pvwattmodul == "wr_sungrow" ]] || [[ $pvwattmodul == "wr_huawei" ]] || [[ $pvwattmodul == "wr_powerdog" ]] || [[ $pvwattmodul == "wr_lgessv1" ]]|| [[ $pvwattmodul == "wr_kostalpikovar2" ]]; then
#		usesimpv=1
#	fi
	if [[ $usesimpv == "1" ]]; then
		read watt3<ramdisk/pvwatt

		readrdmqtt  "importtemp" "pvwatt0pos" "pv/WHImported_temp" 
		readrdmqtt  "exporttemp" "pvwatt0neg" "pv/WHExport_temp" 
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt3 pv pvposkwh pvkwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt3 pv pvposkwh pvkwh
#########################################################################						
		writerdmqtt  "importtemp" "pvwatt0pos" "pv/WHImported_temp" 
		writerdmqtt  "exporttemp" "pvwatt0neg" "pv/WHExport_temp" 
	fi

    usesimbat=0
    
	[[ -r modules/${speichermodul}/usesim ]] && read usesimbat <modules/${speichermodul}/usesim
#    needle=$speichermodul
#    all=",speicher_e3dc,speicher_huawei,speicher_tesvoltsma,speicher_solarwatt,speicher_rct,speicher_sungrow"
#    all+=",speicher_siemens,speicher_lgessv1,speicher_bydhv,speicher_kostalplenticore,speicher_powerwall"
#    all+=",speicher_sbs25,speicher_solaredge,speicher_sonneneco,speicher_varta,speicher_saxpower,speicher_victron"
#    all+=",speicher_fronius,"
#    if [ "${all/",$needle,"}" != "$all" ] ; then
#            usesimbat=1
#    fi
#	 if [[ $speichermodul == "speicher_e3dc" ]] || [[ $speichermodul == "speicher_huawei" ]] || [[ $speichermodul == "speicher_tesvoltsma" ]] || [[ $speichermodul == "speicher_solarwatt" ]] || [[ $speichermodul == "speicher_rct" ]]|| [[ $speichermodul == "speicher_sungrow" ]] || [[ $speichermodul == "speicher_siemens" ]]|| [[ $speichermodul == "speicher_lgessv1" ]] || [[ $speichermodul == "speicher_bydhv" ]] || [[ $speichermodul == "speicher_kostalplenticore" ]] || [[ $speichermodul == "speicher_powerwall" ]] || [[ $speichermodul == "speicher_sbs25" ]] || [[ $speichermodul == "speicher_solaredge" ]] || [[ $speichermodul == "speicher_sonneneco" ]] || [[ $speichermodul == "speicher_varta" ]] || [[ $speichermodul == "speicher_saxpower" ]] || [[ $speichermodul == "speicher_victron" ]] || [[ $speichermodul == "speicher_fronius" ]] ; then

	if [[ $usesimbat == "1" ]]; then
		read watt2 <ramdisk/speicherleistung

		readrdmqtt  "importtemp" "speicherwatt0pos" "housebattery/WHImported_temp" 
		readrdmqtt  "exporttemp" "speicherwatt0neg" "housebattery/WHExport_temp" 
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt2 speicher speicherikwh speicherekwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt2 speicher speicherikwh speicherekwh
#########################################################################						
		writerdmqtt  "importtemp" "speicherwatt0pos" "housebattery/WHImported_temp" 
		writerdmqtt  "exporttemp" "speicherwatt0neg" "housebattery/WHExport_temp" 
	fi


    usesimv1=0
	if [[ $verbraucher1_aktiv == "1" ]] && [[ $verbraucher1_typ == "shelly" ]]; then
		usesimv1=1
    fi
	if [[ $verbraucher1_aktiv == "1" ]] && [[ $verbraucher1_typ == "http" ]] &&  [[ $verbraucher1_urlh == "simcount"  ]] ; then
		usesimv1=1
    fi
	if [[ $verbraucher1_aktiv == "1" ]] && [[ $verbraucher1_typ == "bash" ]] &&  [[ $verbraucher1_scripth == "simcount"  ]] ; then
		usesimv1=1
    fi
    if [[ $usesimv1 == "1" ]]; then
		read watt3<ramdisk/verbraucher1_watt
		readrdmqtt  "importtemp" "verbraucher1watt0pos" "Verbraucher/1/WH1Imported_temp" 
		readrdmqtt  "exporttemp" "verbraucher1watt0neg" "Verbraucher/1/WH1Export_temp" 
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe"
		sudo python /var/www/html/openWB/runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe
#########################################################################						
		writerdmqtt  "importtemp" "verbraucher1watt0pos" "Verbraucher/1/WH1Imported_temp" 
		writerdmqtt  "exporttemp" "verbraucher1watt0neg" "Verbraucher/1/WH1Export_temp" 
	else
		openwbDebugLog "MAIN" 0 "verbraucher1 NO simcount "
	fi


# fuers logging
	read evuv1<ramdisk/evuv1
	read evuv2<ramdisk/evuv2
	read evuv3<ramdisk/evuv3
	read bezuga1<ramdisk/bezuga1
	read bezuga2<ramdisk/bezuga2
	read bezuga3<ramdisk/bezuga3
	t=$(echo -e "\t")

	#Uhrzeit
	date=$(date)
	H=$(date +%H)
#	if [[ $debug == "1" ]]; then
#		echo "$(tail -1500 /var/www/html/openWB/ramdisk/openWB.log)" > /var/www/html/openWB/ramdisk/openWB.log
#	fi
	if [[ $speichermodul != "none" ]] ; then
		openwbDebugLog "MAIN" 1 "speicherleistung $speicherleistung speichersoc $speichersoc"
	fi
	if (( $etprovideraktiv == 1 )) ; then
		openwbDebugLog "MAIN" 1 "etproviderprice $etproviderprice etprovidermaxprice $etprovidermaxprice"
	fi
	openwbDebugLog "MAIN" 1 "pv1watt $pv1watt pv2watt $pv2watt pvwatt $pvwatt ladeleistung $ladeleistung"
	openwbDebugLog "MAIN" 1 "llalt $llalt nachtladen $nachtladen nachtladen $nachtladens1 minimalA $minimalstromstaerke maximalA $maximalstromstaerke"
	openwbDebugLog "MAIN" 1 "lla1 $lla1${t}llv1 $llv1${t}llas11 $llas11${t}llas21 $llas21"
	openwbDebugLog "MAIN" 1 "lla2 $lla2${t}llv2 $llv2${t}llas12 $llas12${t}llas22 $llas22"
	openwbDebugLog "MAIN" 1 "lla3 $lla3${t}llv3 $llv3${t}llas13 $llas13${t}llas23 $llas23"
	openwbDebugLog "MAIN" 1 "mindestuberschuss $mindestuberschuss abschaltuberschuss $abschaltuberschuss lademodus $lademodus"
	openwbDebugLog "MAIN" 1 "sofortll $sofortll hausverbrauch $hausverbrauch  wattbezug $wattbezug uberschuss $uberschuss"
	openwbDebugLog "MAIN" 1 "soclp1 ${soc}${t}soclp2 ${soc1}"
	openwbDebugLog "MAIN" 1 "EVU ${evuv1}V/${bezuga1}A${t}${evuv2}V/${bezuga2}A${t}${evuv3}V/${bezuga3}A"
	openwbDebugLog "MAIN" 1 "lp1enabled $lp1enabled${t}lp2enabled $lp2enabled${t}lp3enabled $lp3enabled"
	openwbDebugLog "MAIN" 1 "plugstatlp1 $plugstat${t}plugstatlp2 $plugstatlp2${t}plugstatlp3 $plugstatlp3"
	openwbDebugLog "MAIN" 1 "chargestatlp1 $chargestat${t}chargestatlp2 $chargestatlp2${t}chargestatlp3 $chargestatlp3"

	if [[ $rfidakt == "1" ]]; then
		rfid      # verändert u.a lp1enabled, und speichert dieses wieder
	fi

	csvfile="/var/www/html/openWB/web/logging/data/daily/$(date +%Y%m%d).csv"
	first=$(head -n 1 "$csvfile")
	last=$(tail -n 1 "$csvfile")
	dailychargelp1=$(echo "$(echo "$first" | cut -d , -f 5) $(echo "$last" | cut -d , -f 5)" | awk '{printf "%0.2f", ($2 - $1)/1000}')
	dailychargelp2=$(echo "$(echo "$first" | cut -d , -f 6) $(echo "$last" | cut -d , -f 6)" | awk '{printf "%0.2f", ($2 - $1)/1000}')
	dailychargelp3=$(echo "$(echo "$first" | cut -d , -f 7) $(echo "$last" | cut -d , -f 7)" | awk '{printf "%0.2f", ($2 - $1)/1000}')

	# restzeitlp1=$(<ramdisk/restzeitlp1)
	# restzeitlp2=$(<ramdisk/restzeitlp2)
	# restzeitlp3=$(<ramdisk/restzeitlp3)
	# gelrlp1=$(<ramdisk/gelrlp1)
	# gelrlp2=$(<ramdisk/gelrlp2)
	# gelrlp3=$(<ramdisk/gelrlp3)

	lastregelungaktiv=$(<ramdisk/lastregelungaktiv)
	hook1akt=$(<ramdisk/hook1akt)
	hook2akt=$(<ramdisk/hook2akt)
	hook3akt=$(<ramdisk/hook3akt)


#########################################################################
runs/pubmqtt.sh >>/var/www/html/openWB/ramdisk/openWB.log 2>&1 &
#########################################################################

}  # func loadvars end


