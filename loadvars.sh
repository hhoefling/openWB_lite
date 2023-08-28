#!/bin/bash
# dies ist utf8 äöüäöü

# Gloval und sofort beim sourcen
lademodus=$(<ramdisk/lademodus)

openwbDebugLog "MAIN" 2 "Source loadvars.sh (mode:$lademodus)"


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


function dotimed()
{
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


#########################################################
### Openwb.conf Sync module 
#########################################################
source ./openwbconf.sh

loadvars(){
	#reload mqtt vars
	renewmqtt=$(<ramdisk/renewmqtt)
	if (( renewmqtt == 1 )); then
		echo 0 > ramdisk/renewmqtt
		echo 01 | tee ramdisk/mqtt*
		openwbDebugLog "MAIN" 1 "RenewMQTT copy 01 to all ramdiskvalues"
		openwbDebugLog "MAIN" 1 "RenewMQTT so all mqtt var are set new at end of loadvar."
	fi

	#get temp vars
	sofortll=$(<ramdisk/lp1sofortll)
	sofortlls1=$(<ramdisk/lp2sofortll)
	sofortlls2=$(<ramdisk/lp3sofortll)


#NC   oaktgeladens1=$(<ramdisk/mqttaktgeladens1)
#NC   oaktgeladens2=$(<ramdisk/mqttaktgeladens2)
#NC   oaktgeladen=$(<ramdisk/mqttaktgeladen)
    
#NC	olastregelungaktiv=$(<ramdisk/lastregelungaktiv)
#NC	oLadereglerTxt=$(<ramdisk/LadereglerTxt)
	ohook1akt=$(<ramdisk/hook1akt)
	ohook2akt=$(<ramdisk/hook2akt)
	ohook3akt=$(<ramdisk/hook3akt)

	ladestatus=$(<ramdisk/ladestatus)
	ladestatuss1=$(<ramdisk/ladestatuss1)
	ladestatuss2=$(<ramdisk/ladestatuss2)
	lp1enabled=$(<ramdisk/lp1enabled)
	lp2enabled=$(<ramdisk/lp2enabled)
	lp3enabled=$(<ramdisk/lp3enabled)

	etproviderprice=$(<ramdisk/etproviderprice) 
    etprovidermaxprice=$(<ramdisk/etprovidermaxprice)    

    verbraucher1_watt=$(<ramdisk/verbraucher1_watt)
    verbraucher2_watt=$(<ramdisk/verbraucher2_watt)

	
    #ollkombiniert=$(<ramdisk/llkombiniert)
	
	version=$(<web/version)
	# EVSE DIN Plug State
	declare -r IsNumberRegex='^[0-9]+$'
	if [[ $evsecon == "modbusevse" ]]; then
		if ((modbusevseid == 0)); then
			if [ -f ramdisk/evsemodulconfig ]; then
				modbusevsesource=$(<ramdisk/evsemodulconfig)
				modbusevseid=1
			else
				if [[ -e "/dev/ttyUSB0" ]]; then
					echo "/dev/ttyUSB0" > ramdisk/evsemodulconfig
				else
					echo "/dev/serial0" > ramdisk/evsemodulconfig
				fi
				modbusevsesource=$(<ramdisk/evsemodulconfig)
				modbusevseid=1

			fi
		fi
### 64  modbusevsesource=/dev/ttyUSB0 modbusevseid=1
		
##################### 1002 get Vehicle Status
		openwbDebugLog "MAIN" 1 "EXEC: modbusevse sudo python3 runs/readmodbus.py ip:$modbusevsesource id:$modbusevseid reg:1002 cnt:1"
		evseplugstate=$(sudo python3 runs/readmodbus.py $modbusevsesource $modbusevseid 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			# EVSE read returned empty or non-numeric value --> use last state for this loop
			evseplugstate=$(<ramdisk/evseplugstate)
			openwbDebugLog "MAIN" 0 "Modbus EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > ramdisk/evseplugstate
		fi
		ladestatuslp1=$(<ramdisk/ladestatus)
		if ((evseplugstate >= 0)) && ((evseplugstate <= 10)); then
		    plugstat=$(<ramdisk/plugstat)
			if ((evseplugstate > 1)); then
				if ((plugstat == 0)) ; then
					if ((pushbplug == 1)) && ((ladestatuslp1 == 0)) && ((pushbenachrichtigung == 1)) ; then
						message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
					    openwbDebugLog "MAIN" 2 "EXEC: runs/pushover.sh"
						runs/pushover.sh "$message"
#########################################################################						
					fi
					if ((displayconfigured == 1)) && ((displayEinBeimAnstecken == 1)) ; then
			           openwbDebugLog "MAIN" 0 "Awoke1 internal Display"
					   awokedisplay
					fi
					echo 20000 > ramdisk/soctimer
				fi
				echo 1 > ramdisk/plugstat
				plugstat=1
			else
			    if ((plugstat >0 )); then
				  openwbDebugLog "MAIN" 0 "***** evse meldet unpluged(<=1), korrigiere plugstat=0"
				  echo 0 > ramdisk/plugstat
				fi  
				plugstat=0
			fi
			if ((evseplugstate > 2)) && ((ladestatuslp1 == 1)) && ((lp1enabled == 1)); then
				echo 1 > ramdisk/chargestat
				chargestat=1
			else
				echo 0 > ramdisk/chargestat
				chargestat=0
			fi
		fi
	else
		pluggedin=$(<ramdisk/pluggedin)
		if ((pluggedin > 0)); then
			if ((pushbplug == 1)) && ((ladestatuslp1 == 0)) && ((pushbenachrichtigung == 1)) ; then
				message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
				openwbDebugLog "MAIN" 1 "EXEC: runs/pushover.sh"
				runs/pushover.sh "$message"
#########################################################################						
			fi
			if ((displayconfigured == 1)) && ((displayEinBeimAnstecken == 1)) ; then
			           openwbDebugLog "MAIN" 0 "Awoke2 internal Display"
					   awokedisplay
			fi
			echo 20000 > ramdisk/soctimer
			echo 0 > ramdisk/pluggedin
		fi
		plugstat=$(<ramdisk/plugstat)
		chargestat=$(<ramdisk/chargestat)
	fi
	if [[ $evsecon == "ipevse" ]]; then ## Alter Satellit ohne Pi3
#########################################################################						
		openwbDebugLog "MAIN" 1 "EXEC: ipevse sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1"
		evseplugstatelp1=$(sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			evseplugstate=$(<ramdisk/evseplugstate)
			openwbDebugLog "MAIN" 0 "IP EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > ramdisk/evseplugstate
		fi
		ladestatuslp1=$(<ramdisk/ladestatus)
		if ((evseplugstatelp1 > 1)); then
			echo 1 > ramdisk/plugstat
		else
			echo 0 > ramdisk/plugstat
		fi
		if ((evseplugstatelp1 > 2)) && ((ladestatuslp1 == 1)) && ((lp1enabled == 1)); then
			echo 1 > ramdisk/chargestat
		else
			echo 0 > ramdisk/chargestat
		fi
	fi

	if ((lastmanagement == 1)); then
		ConfiguredChargePoints=2
		if [[ $evsecons1 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: modbusevse sudo python runs/readmodbus.py ip:$evsesources1 id:$evseids1 reg:1002 cnt:1"
			evseplugstatelp2=$(sudo python runs/readmodbus.py $evsesources1 $evseids1 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				evseplugstatelp2=$(<ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > ramdisk/evseplugstatelp2
			fi
			ladestatuss1=$(<ramdisk/ladestatuss1)
			if ((evseplugstatelp2 > 0)) && ((evseplugstatelp2 < 7)); then
				if ((evseplugstatelp2 > 1)); then
					plugstat2=$(<ramdisk/plugstats1)

					if ((plugstat2 == 0)) ; then
						if ((displayconfigured == 1)) && ((displayEinBeimAnstecken == 1)) ; then
			           		openwbDebugLog "MAIN" 0 "Awoke3 internal Display"
					   	    awokedisplay
						fi
						echo 20000 > ramdisk/soctimer1
					fi
					echo 1 > ramdisk/plugstats1
					plugstat2=1
					plugstats1=$plugstat2
				else
					echo 0 > ramdisk/plugstats1
					plugstat2=0
					plugstats1=$plugstat2
				fi
				if ((evseplugstatelp2 > 2)) && ((ladestatuss1 == 1)); then
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
				evseplugstatelp2=$(<ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "Slaveeth EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > ramdisk/evseplugstatelp2
			fi
			ladestatuss1=$(<ramdisk/ladestatuss1)

			if ((evseplugstatelp2 > 1)); then
				echo 1 > ramdisk/plugstats1
			else
				echo 0 > ramdisk/plugstats1
			fi
			if ((evseplugstatelp2 > 2)) && ((ladestatuss1 == 1)); then
				echo 1 > ramdisk/chargestats1
			else
				echo 0 > ramdisk/chargestats1
			fi
		fi
		if [[ $evsecons1 == "ipevse" ]]; then ## Alter Satellit ohne Pi3
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: ipevse sudo python runs/readipmodbus.py ip:$evseiplp2 id:$evseidlp2 reg:1002 cnt:1"
			evseplugstatelp2=$(sudo python runs/readipmodbus.py $evseiplp2 $evseidlp2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				evseplugstatelp2=$(<ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "IP EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > ramdisk/evseplugstatelp2
			fi
			ladestatuslp2=$(<ramdisk/ladestatuss1)

			if ((evseplugstatelp2 > 1)); then
				echo 1 > ramdisk/plugstats1
			else
				echo 0 > ramdisk/plugstats1
			fi
			if ((evseplugstatelp2 > 2)) && ((ladestatuslp2 == 1)) && ((lp2enabled == 1)); then
				echo 1 > ramdisk/chargestats1
			else
				echo 0 > ramdisk/chargestats1
			fi
		fi
		plugstatlp2=$(<ramdisk/plugstats1)
		chargestatlp2=$(<ramdisk/chargestats1)
		plugstats1=$(<ramdisk/plugstats1)
		chargestats1=$(<ramdisk/chargestats1)
	else
		plugstatlp2=$(<ramdisk/plugstats1)
		chargestatlp2=$(<ramdisk/chargestats1)
		plugstats1=$(<ramdisk/plugstats1)
		chargestats1=$(<ramdisk/chargestats1)
		ConfiguredChargePoints=1
	fi

	if ((lastmanagements2 == 1)); then
		ConfiguredChargePoints=3
		if [[ $evsecons2 == "ipevse" ]]; then ## Alter Satellit ohne Pi3
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: ipevse sudo python runs/readipmodbus.py ip:$evseiplp3 id:$evseidlp3 reg:1002 cnt:1"
			evseplugstatelp3=$(sudo python runs/readipmodbus.py $evseiplp3 $evseidlp3 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				evseplugstatelp3=$(<ramdisk/evseplugstatelp3)
				openwbDebugLog "MAIN" 0 "IP EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > ramdisk/evseplugstatelp3
			fi
			ladestatuslp3=$(<ramdisk/ladestatuss2)

			if ((evseplugstatelp3 > 1)); then
				echo 1 > ramdisk/plugstatlp3
			else
				echo 0 > ramdisk/plugstatlp3
			fi
			if ((evseplugstatelp3 > 2)) && ((ladestatuslp3 == 1)) && ((lp3enabled == 1)); then
				echo 1 > ramdisk/chargestatlp3
			else
				echo 0 > ramdisk/chargestatlp3
			fi
		fi


		if [[ $evsecons2 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 1 "EXEC: modbusevse sudo python runs/readmodbus.py ip:$evsesources2 id:$evseids2 reg:1002 cnt:1"
			evseplugstatelp3=$(sudo python runs/readmodbus.py $evsesources2 $evseids2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				evseplugstatelp3=$(<ramdisk/evseplugstatelp3)
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > ramdisk/evseplugstatelp3
			fi
			ladestatuss2=$(<ramdisk/ladestatuss2)
			if ((evseplugstatelp3 > 1)); then
				echo 1 > ramdisk/plugstatlp3
			else
				echo 0 > ramdisk/plugstatlp3
			fi
			if ((evseplugstatelp3 > 2)) && ((ladestatuss2 == 1)) ; then
				echo 1 > ramdisk/chargestatlp3
			else
					echo 0 > ramdisk/chargestatlp3
			fi
		fi
		plugstatlp3=$(<ramdisk/plugstatlp3)
		chargestatlp3=$(<ramdisk/chargestatlp3)
	else
		plugstatlp3=$(<ramdisk/plugstatlp3)
		chargestatlp3=$(<ramdisk/chargestatlp3)
	fi
	

	# LP4 - LP8

	echo $ConfiguredChargePoints > ramdisk/ConfiguredChargePoints
	# Lastmanagement var check age   Lasse Meldung 2 Minuten stehen
	if test $(find "ramdisk/lastregelungaktiv" -mmin +2); then
		openwbDebugLog "MAIN" 1 "Clear Lastreglegelungstext (>2Min)"
		echo " " > ramdisk/lastregelungaktiv
	fi

	# Werte für die Berechnung ermitteln
	lademodus=$(<ramdisk/lademodus)        # haben wir oben schon eingelesen, sollte noch der selbe sein
	if [ -z "$lademodus" ] ; then
		mosquitto_pub -r -t "openWB/set/ChargeMode" -m "$bootmodus"  # > ../set/.. Write to Ramdisk und mqtt 
		lademodus=$bootmodus
	fi
	llalt=$(cat ramdisk/llsoll)
	llaltlp1=$llalt

	#PV Leistung ermitteln
	# pv1watt Leistung WR1
	# pv2watt Leistung WR2
	# pvwatt gesamtleistung WR1 und WR2
	# pvallwatt gleich zu pvwatt
	# pv Counter
	# pvkwh zaehler wr1
	# pv2kwh zaehler wr2
	# pvallwh summe von pvkwh und pv2kwh (wird in cron5 und cronnighly verwendet)
	if [[ $pvwattmodul != "none" ]]; then
		pv1vorhanden="1"
		echo 1 > ramdisk/pv1vorhanden
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$pvwattmodul/main.sh"
	    dotimed "modules/$pvwattmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "PV" 2 "Die PV-1 Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 1
		fi
		pvwatt=$(</var/www/html/openWB/ramdisk/pvwatt)
		openwbDebugLog "MAIN" 2 "pvwatt: $pvwatt"
#########################################################################						
		if ! [[ $pvwatt =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für pvwatt: $pvwatt"
			pvwatt="0"
		fi
		pv1watt=$pvwatt
		echo $pv1watt > ramdisk/pv1watt
	else
        pvwatt="0"
        pv1watt="0"
		pv1vorhanden="0"
		echo 0 > ramdisk/pv1vorhanden
		pvwatt=$(<ramdisk/pvwatt)
	fi
	if [[ $pv2wattmodul != "none" ]]; then
		pv2vorhanden="1"
		echo 1 > ramdisk/pv2vorhanden
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$pv2wattmodul/main.sh"
	    dotimed "modules/$pv2wattmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "PV" 2 "Die PV-2 Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 2
		fi
		pv2watt=$(</var/www/html/openWB/ramdisk/pv2watt)
		openwbDebugLog "MAIN" 2 "pv2watt: $pv2watt"
#########################################################################						
		if ! [[ $pv2watt =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für pv2watt: $pv2watt"
			pv2watt="0"
		fi
		echo $pv2watt > ramdisk/pv2watt
		pvwatt=$(( pvwatt + pv2watt ))
		if ! [[ $pvwatt =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für PV Gesamtleistung: $pvwatt"
			pvwatt="0"
		fi
		echo $pvwatt > ramdisk/pvallwatt
		pvkwh=$(<ramdisk/pvkwh)
		pv2kwh=$(<ramdisk/pv2kwh)
		pvallwh=$(echo "$pvkwh + $pv2kwh" |bc)
		echo $pvallwh > ramdisk/pvallwh
	else
		pvkwh=$(<ramdisk/pvkwh)
		pv2vorhanden="0"
        pv2watt=0
		echo 0 > ramdisk/pv2vorhanden
		echo $pvkwh > ramdisk/pvallwh
		echo $pvwatt > ramdisk/pvallwatt
	fi

	speicherleistung=0
	#Speicher werte
	if [[ $speichermodul != "none" ]] ; then
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$speichermodul/main.sh"
		dotimed "modules/$speichermodul/main.sh" 5 
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "BAT" 2 "Die Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen."
		fi
#########################################################################						
		speicherleistung=$(<ramdisk/speicherleistung)
        speicherleistung=${speicherleistung%%[.,]*}
		speichersoc=$(<ramdisk/speichersoc)
        speichersoc=${speichersoc%%[.,]*}
        
		speichervorhanden=1
		echo 1 > ramdisk/speichervorhanden
		
#		if [[ $speichermodul == "speicher_alphaess" ]] ; then
#			pvwatt=$(<ramdisk/pvwatt)
#			echo 1 > ramdisk/pv1vorhanden
#			pv1vorhanden="1"
#		fi
#		if [[ $speichermodul == "speicher_e3dc" ]] ; then
#			pvwatt=$(<ramdisk/pvwatt)
#			echo 1 > ramdisk/pv1vorhanden
#			pv1vorhanden="1"
# 		fi
#		if [[ $speichermodul == "speicher_sonneneco" ]] ; then
#			pvwatt=$(<ramdisk/pvwatt)
#			echo 1 > ramdisk/pv1vorhanden
#			pv1vorhanden="1"
#		fi
	else
        speichersoc=0
		speichervorhanden=0
		echo 0 > ramdisk/speichervorhanden
	fi
	#addition pv nach Speicherauslesung
	if [[ $pv2vorhanden == "1" ]]; then
		pv1watt=$(<ramdisk/pv1watt)
		pv2watt=$(<ramdisk/pv2watt)
		pvwatt=$(( pv1watt + pv2watt ))
		echo $pvwatt > ramdisk/pvallwatt
		echo $pvwatt > ramdisk/pvwatt
	else
		if [[ $pv1vorhanden == "1" ]]; then
			pv1watt=$(<ramdisk/pv1watt)
			pvwatt=$pv1watt
			echo $pvwatt > ramdisk/pvallwatt
			echo $pvwatt > ramdisk/pvwatt
		fi
	fi

	llphaset=3

	#Ladeleistung ermitteln
	if [[ $ladeleistungmodul != "none" ]]; then
#########################################################################						
		dotimed "modules/$ladeleistungmodul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "LP" 2 "Die LL-Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 1
		fi
#########################################################################						
		llkwh=$(<ramdisk/llkwh)
		llkwhges=$llkwh
		lla1=$(cat ramdisk/lla1)
		lla2=$(cat ramdisk/lla2)
		lla3=$(cat ramdisk/lla3)
        lla1=${lla1%%[.,]*}
        lla2=${lla2%%[.,]*}
        lla3=${lla3%%[.,]*}
		llv1=$(cat ramdisk/llv1)
		llv2=$(cat ramdisk/llv2)
		llv3=$(cat ramdisk/llv3)
		ladeleistung=$(cat ramdisk/llaktuell)
		ladeleistunglp1=$ladeleistung
		if ! [[ $lla1 =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für lla1: $lla1"
			lla1="0"
		fi
		if ! [[ $lla2 =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für lla2: $lla2"
			lla2="0"
		fi

		if ! [[ $lla3 =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für lla3: $lla3"
			lla3="0"
		fi

		lp1phasen=0
		if ((lla1 >= llphaset)); then
			((lp1phasen++))
		fi
		if ((lla2 >= llphaset)); then
			((lp1phasen++))
		fi
		if ((lla3 >= llphaset)); then
			((lp1phasen++))
		fi
		echo "$lp1phasen" > ramdisk/lp1phasen
		if ! [[ $ladeleistung =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für ladeleistung: $ladeleistung"
			ladeleistung="0"
		fi
		ladestatus=$(<ramdisk/ladestatus)

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
	if ((lastmanagement == 1)); then
		if [[ $socmodul1 != "none" ]]; then
#########################################################################						
			#openwbDebugLog "MAIN" 1 "EXEC&: modules/$socmodul1/main.sh &"
			dotimed "modules/$socmodul1/main.sh"
			if [[ $? -eq 124 ]] ; then
				openwbModulePublishState "EVSOC" 2 "Die SOC-2 Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 2
			fi
#########################################################################						
			soc1=$(<ramdisk/soc1)
			tmpsoc1=$(<ramdisk/tmpsoc1)
			if ! [[ $soc1 =~ $re ]] ; then
				openwbDebugLog "MAIN" 0 "ungültiger Wert für soc1: $soc1"
				soc1=$tmpsoc1
			else
				echo $soc1 > ramdisk/tmpsoc1
			fi
			soc1vorhanden=1
			echo 1 > ramdisk/soc1vorhanden
		else
			echo 0 > ramdisk/soc1vorhanden
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
		llkwhs1=$(<ramdisk/llkwhs1)
		llkwhges=$(echo "$llkwhges + $llkwhs1" |bc)
		llalts1=$(cat ramdisk/llsolls1)
		ladeleistungs1=$(cat ramdisk/llaktuells1)
		ladeleistunglp2=$ladeleistungs1
		llas11=$(cat ramdisk/llas11)
		llas12=$(cat ramdisk/llas12)
		llas13=$(cat ramdisk/llas13)
        llas11=${llas11%%[.,]*}
        llas12=${llas12%%[.,]*}
        llas13=${llas13%%[.,]*}
		ladestatuss1=$(<ramdisk/ladestatuss1)
		if ! [[ $ladeleistungs1 =~ $re ]] ; then
			ladeleistungs1="0"
		fi
		ladeleistung=$(( ladeleistung + ladeleistungs1 ))
		echo "$ladeleistung" > ramdisk/llkombiniert
		lp2phasen=0
		if ((llas11 >= llphaset)); then
			((lp2phasen++))
		fi
		if ((llas12 >= llphaset)); then
			((lp2phasen++))
		fi
		if ((llas13 >= llphaset)); then
			((lp2phasen++))
		fi
		echo "$lp2phasen" > ramdisk/lp2phasen
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

	#dritter ladepunkt
	if ((lastmanagements2 == 1)); then
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC:timerun 5: modules/$ladeleistungs2modul/main.sh"
		dotimed "modules/$ladeleistungs2modul/main.sh" 5
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "LP" 2 "Die LL-Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 3
		fi
#########################################################################						
		llkwhs2=$(<ramdisk/llkwhs2)
		llkwhges=$(echo "$llkwhges + $llkwhs2" |bc)
		llalts2=$(cat ramdisk/llsolls2)
		ladeleistungs2=$(cat ramdisk/llaktuells2)
		ladeleistunglp3=$ladeleistungs2
		llas21=$(cat ramdisk/llas21)
		llas22=$(cat ramdisk/llas22)
		llas23=$(cat ramdisk/llas23)
        llas21=${llas21%%[.,]*}
        llas22=${llas22%%[.,]*}
        llas23=${llas23%%[.,]*}
		lp3phasen=0
		if ((llas21 >= llphaset)); then
			((lp3phasen++))
		fi
		if ((llas22 >= llphaset)); then
			((lp3phasen++))
		fi
		if ((llas23 >= llphaset)); then
			((lp3phasen++))
		fi
		echo $lp3phasen > ramdisk/lp3phasen
		ladestatuss2=$(<ramdisk/ladestatuss2)
		if ! [[ $ladeleistungs2 =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für ladeleistungs2: $ladeleistungs2"
			ladeleistungs2="0"
		fi
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


	echo "$ladeleistung" > ramdisk/llkombiniert
	echo $llkwhges > ramdisk/llkwhges

	#Schuko-Steckdose an openWB als CP2 (Duo)
#	if [[ $standardSocketInstalled == "1" ]]; then
#########################################################################						
#		#openwbDebugLog "MAIN" 1 "EXEC: timeout 8 modules/sdm120modbusSocket/main.sh"
#		#timeout 8 modules/sdm120modbusSocket/main.sh || true
#		timerun 8 modules/sdm120modbusSocket/main.sh 
#########################################################################						
#		socketkwh=$(<ramdisk/socketkwh)
#		socketp=$(cat ramdisk/socketp)
#		socketa=$(cat ramdisk/socketa)
#       socketa=${socketa%%[.,]*}
#		socketv=$(cat ramdisk/socketv)
#		if ! [[ $socketa =~ $re ]] ; then
#			openwbDebugLog "MAIN" 0 "ungültiger Wert für socketa: $socketa"
#			socketa="0"
#		fi
#	fi

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
		wattbezug=$(</var/www/html/openWB/ramdisk/wattbezug)
		openwbDebugLog "MAIN" 2 "Wattbezug: $wattbezug"
#########################################################################						
		if ! [[ $wattbezug =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für wattbezug: $wattbezug"
			wattbezug="0"
		fi
		wattbezugint=$(printf "%.0f\n" $wattbezug)
		#evu glaettung
        local glaettungw=0
		if (( evuglaettungakt == 1 )); then
			if (( evuglaettung > 20 )); then
				ganzahl=$(( evuglaettung / 10 ))
				for ((i=ganzahl;i>=1;i--)); do
					i2=$(( i + 1 ))
					cp ramdisk/glaettung$i ramdisk/glaettung$i2
				done
				echo $wattbezug > ramdisk/glaettung1
				for ((i=1;i<=ganzahl;i++)); do
					glaettung=$(<ramdisk/glaettung$i)
					glaettungw=$(( glaettung + glaettungw))
				done
				glaettungfinal=$((glaettungw / ganzahl))
				echo $glaettungfinal > ramdisk/glattwattbezug
				wattbezug=$glaettungfinal
                openwbDebugLog "MAIN" 2 "Nach Glättung Wattbezug: $wattbezug"
			fi
		fi
		
# speicherpveinbeziehen=0 = Speicherladen hat vorrang
# - speicherwattnurpv = 1500
# - speichersocnurpv = 30%    		
# speicherpveinbeziehen=1 = EV Laden hat vorang
# - speichermaxwatt 200   	(soviel soll troztzden nindestns in den speiher geaden werden	
	
		#uberschuss zur berechnung
		openwbDebugLog "PV" 0 "----------------------" 
		uberschuss=$(printf "%.0f\n" $((-wattbezug)))
		if (( uberschuss > 0  )) ; then
		    openwbDebugLog "PV" 0 "1: UEBERSCHUSS $uberschuss Watt EXPORT aus wattbezug "				
		else
		    openwbDebugLog "PV" 0 "1: UEBERSCHUSS $uberschuss Watt IMPORT aus wattbezug "
        fi			 				
		if ((speichervorhanden == 1)); then
			openwbDebugLog "PV" 0 "2: SP/EV:$speicherpveinbeziehen  SPL:${speicherleistung}W [${speichersoc}% > ${speichersocnurpv}%] " 
		    bmeld "U:${uberschuss}W"
			if ((speicherpveinbeziehen == 1)); then
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
		openwbDebugLog "PV" 0 "5: UEBERSCHUSS $uberschuss  nach now"		
		evuv1=$(cat ramdisk/evuv1)
		evuv2=$(cat ramdisk/evuv2)
		evuv3=$(cat ramdisk/evuv3)
		evua1=$(cat ramdisk/bezuga1)
		evua2=$(cat ramdisk/bezuga2)
		evua3=$(cat ramdisk/bezuga3)
        evua1=${evua1%%[.,]*}
        evua2=${evua2%%[.,]*}
        evua3=${evua3%%[.,]*}
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
        evuv1=0
        evuv2=0
        evuv3=0
        evua1=0
        evua2=0
        evua3=0
        
	fi

	# Abschaltbare Smartdevices zum Ueberschuss rechnen
	## NC echo $uberschuss > ramdisk/ueberschuss_org
	wattabs=$(cat ramdisk/devicetotal_watt)
	if (( wattabs>0 )) ; then
	   uberschuss=$((uberschuss + wattabs))
	   ## NC echo $uberschuss > ramdisk/ueberschuss_mitsmart
	   openwbDebugLog "PV" 0 "6: UEBERSCHUSS $uberschuss  nach addierung der abschaltbaren smartdev"
	   bmeld "Bat +${wattabs}W abschaltbare => U:${uberschuss}W"
    fi
	
	#Soc ermitteln
	if [[ "$socmodul" != "none" ]]; then
		socvorhanden=1
		echo 1 > ramdisk/socvorhanden
		if (( stopsocnotpluggedlp1 == 1 )); then
			soctimer=$(<ramdisk/soctimer)
			# if (( plugstat == 1 )); then
			if ((plugstat == 1)) || ((soctimer == 20005)); then # force soc update button sends 20005
#########################################################################						
				#openwbD	ebugLog "MAIN" 1 "EXEC&: modules/$socmodul/main.sh &"
				dotimed "modules/$socmodul/main.sh"
				if [[ $? -eq 124 ]] ; then
					openwbModulePublishState "EVSOC" 2 "Die SOC Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 1
				fi
#########################################################################					
				soc=$(<ramdisk/soc)
				tmpsoc=$(<ramdisk/tmpsoc)
				if ! [[ $soc =~ $re ]] ; then
					openwbDebugLog "MAIN" 0 "ungültiger Wert für soc: $soc"
					soc=$tmpsoc
				else
					echo "$soc" > ramdisk/tmpsoc
				fi
			else
				echo 600 > ramdisk/soctimer
				soc=$(<ramdisk/soc)
			fi
		else
#########################################################################						
			# openwbDebugLog "MAIN" 1 "EXEC&: modules/$socmodul/main.sh &"
			dotimed "modules/$socmodul/main.sh"
			if [[ $? -eq 124 ]] ; then
				openwbModulePublishState "EVSOC" 2 "Die SOC Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen." 1
			fi
#########################################################################						
			soc=$(<ramdisk/soc)
			tmpsoc=$(<ramdisk/tmpsoc)
			if ! [[ $soc =~ $re ]] ; then
				openwbDebugLog "MAIN" 0 "ungültiger Wert für soc: $soc"
				soc=$tmpsoc
			else
				echo "$soc" > ramdisk/tmpsoc
			fi
		fi
	else
		socvorhanden=0
		echo 0 > ramdisk/socvorhanden
		soc=0
	fi



# for graphing.sh
	if [ -s "ramdisk/device1_watt" ]; then shd1_w=$(<ramdisk/device1_watt); else shd1_w=0; fi
	if [ -s "ramdisk/device2_watt" ]; then shd2_w=$(<ramdisk/device2_watt); else shd2_w=0; fi
	if [ -s "ramdisk/device3_watt" ]; then shd3_w=$(<ramdisk/device3_watt); else shd3_w=0; fi
	if [ -s "ramdisk/device4_watt" ]; then shd4_w=$(<ramdisk/device4_watt); else shd4_w=0; fi
	if [ -s "ramdisk/device5_watt" ]; then shd5_w=$(<ramdisk/device5_watt); else shd5_w=0; fi
	if [ -s "ramdisk/device6_watt" ]; then shd6_w=$(<ramdisk/device6_watt); else shd6_w=0; fi
	if [ -s "ramdisk/device7_watt" ]; then shd7_w=$(<ramdisk/device7_watt); else shd7_w=0; fi
	if [ -s "ramdisk/device8_watt" ]; then shd8_w=$(<ramdisk/device8_watt); else shd8_w=0; fi
	if [ -s "ramdisk/device9_watt" ]; then shd9_w=$(<ramdisk/device9_watt); else shd9_w=0; fi
	if [ -s "ramdisk/devicetotal_watt_hausmin" ]; then shdall_w=$(<ramdisk/devicetotal_watt_hausmin); else shdall_w=0; fi
	if [ -s "ramdisk/device1_temp0" ]; then shd1_t0=$(<ramdisk/device1_temp0); else shd1_t0=0; fi
	if [ -s "ramdisk/device1_temp1" ]; then shd1_t1=$(<ramdisk/device1_temp1); else shd1_t1=0; fi
	if [ -s "ramdisk/device1_temp2" ]; then shd1_t2=$(<ramdisk/device1_temp2); else shd1_t2=0; fi
	if [ -s "ramdisk/verbraucher1_watt" ]; then verb1_w=$(<ramdisk/verbraucher1_watt); else verb1_w=0; fi
	verb1_w=$(printf "%.0f\n" $verb1_w)
	if [ -s "ramdisk/verbraucher2_watt" ]; then verb2_w=$(<ramdisk/verbraucher2_watt); else verb2_w=0; fi
	verb2_w=$(printf "%.0f\n" $verb2_w)
#	if [ -s "ramdisk/verbraucher3_watt" ]; then verb3_w=$(<ramdisk/verbraucher3_watt); else verb3_w=0; fi
#	verb3_w=$(printf "%.0f\n" $verb3_w)
	verb3_w=0	# NC

   #hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shd1_w - shd2_w - shd3_w - shd4_w - shd5_w - shd6_w - shd7_w - shd8_w - shd9_w - verb1_w - verb2_w - verb3_w))
	hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shdall_w - verb1_w - verb2_w - verb3_w))

   #hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shd1_w - shd2_w - shd3_w - shd4_w - shd5_w - shd6_w - shd7_w - shd8_w - shd9_w - verb1_w - verb2_w - verb3_w))
	hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shdall_w - verb1_w - verb2_w))
	if (( hausverbrauch < 0 )); then
		if [ -f ramdisk/hausverbrauch.invalid ]; then
			hausverbrauchinvalid=$(<ramdisk/hausverbrauch.invalid)
			let hausverbrauchinvalid+=1
		else
			hausverbrauchinvalid=1
		fi
		echo "$hausverbrauchinvalid" > ramdisk/hausverbrauch.invalid
		if (( hausverbrauchinvalid < 3 )); then
			hausverbrauch=$(<ramdisk/hausverbrauch)
		else
			hausverbrauch=0
		fi
	else
		echo "0" > ramdisk/hausverbrauch.invalid
	fi
	echo $hausverbrauch > ramdisk/hausverbrauch
	#fronius_sm_bezug_meterlocation=$(<ramdisk/fronius_sm_bezug_meterlocation)


	usesimbezug=$( (test ! -r modules/$wattbezugmodul/usesim && echo "0") || cat  modules/$wattbezugmodul/usesim   )
	if [[ $usesimbezug == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimbezug counter simulation"
		ra='^-?[0-9]+$'
		watt2=$(<ramdisk/wattbezug)
		if [[ -e ramdisk/bezugwatt0pos ]]; then
			importtemp=$(<ramdisk/bezugwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/evu/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/evu/WHImported_temp from mosquito $importtemp"
			echo $importtemp > ramdisk/bezugwatt0pos
		fi
		if [[ -e ramdisk/bezugwatt0neg ]]; then
			exporttemp=$(<ramdisk/bezugwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/evu/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/evu/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > ramdisk/bezugwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python3 runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh"
		sudo python3 runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh
#########################################################################						
		importtemp1=$(<ramdisk/bezugwatt0pos)
		exporttemp1=$(<ramdisk/bezugwatt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/evu/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/evu/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim bezug end
	fi

	usesimpv=$( (test ! -r modules/$pvwattmodul/usesim && echo "0") || cat  modules/$pvwattmodul/usesim   )
	if [[ $usesimpv == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimPV counter simulation"
		ra='^-?[0-9]+$'
		#rechnen nur auf wr1
		watt3=$(<ramdisk/pv1watt)
		if [[ -e ramdisk/pvwatt0pos ]]; then
			importtemp=$(<ramdisk/pvwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/pv/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WHImported_temp from mosquito $importtemp"
			echo $importtemp > ramdisk/pvwatt0pos
		fi
		if [[ -e ramdisk/pvwatt0neg ]]; then
			exporttemp=$(<ramdisk/pvwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/pv/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > ramdisk/pvwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python3 runs/simcount.py $watt3 pv pvposkwh pvkwh"
		sudo python3 runs/simcount.py $watt3 pv pvposkwh pvkwh
#########################################################################						
		importtemp1=$(<ramdisk/pvwatt0pos)
		exporttemp1=$(<ramdisk/pvwatt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/pv/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/pv/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim pv end
	fi
	#simcount für wr2
	usesimpv2=$( (test ! -r modules/$pv2wattmodul/usesim && echo "0") || cat  modules/$pv2wattmodul/usesim   )
	if [[ $usesimpv2 == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimPV2 counter simulation"
		ra='^-?[0-9]+$'
		#rechnen auf wr2
		watt4=$(<ramdisk/pv2watt)
		if [[ -e ramdisk/pv2watt0pos ]]; then
			importtemp=$(<ramdisk/pv2watt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/pv/WH2Imported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WH2Imported_temp from mosquito $importtemp"
			echo $importtemp > ramdisk/pv2watt0pos
		fi
		if [[ -e ramdisk/pv2watt0neg ]]; then
			exporttemp=$(<ramdisk/pv2watt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/pv/WH2Export_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WH2Export_temp from mosquito $exporttemp"
			echo $exporttemp > ramdisk/pv2watt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 2 "EXEC: sudo python3 runs/simcount.py $watt4 pv2 pv2poskwh pv2kwh"
		sudo python3 runs/simcount.py $watt4 pv2 pv2poskwh pv2kwh
#########################################################################						
		importtemp1=$(<ramdisk/pv2watt0pos)
		exporttemp1=$(<ramdisk/pv2watt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/pv/WH2Imported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/pv/WH2Export_temp -r -m "$exporttemp1"
		fi
		# sim pv2 end
	fi
	#addition Zaehler pv1 und pv2 nach Simcount
	if [[ $pv2vorhanden == "1" ]]; then
		pvkwh=$(<ramdisk/pvkwh)
		pv2kwh=$(<ramdisk/pv2kwh)
		pvallwh=$(echo "$pvkwh + $pv2kwh" |bc)
		echo $pvallwh > ramdisk/pvallwh
	fi

	usesimbat=$( (test ! -r modules/$speichermodul/usesim && echo "0") || cat  modules/$speichermodul/usesim   )
	if [[ $usesimbat == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### Use Sim Speicher counter simulation"
		ra='^-?[0-9]+$'
		watt2=$(<ramdisk/speicherleistung)
		if [[ -e ramdisk/speicherwatt0pos ]]; then
			importtemp=$(<ramdisk/speicherwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/housebattery/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/housebattery/WHImported_temp from mosquito $importtemp"
			echo $importtemp > ramdisk/speicherwatt0pos
		fi
		if [[ -e ramdisk/speicherwatt0neg ]]; then
			exporttemp=$(<ramdisk/speicherwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/housebattery/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/housebattery/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > ramdisk/speicherwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python3 runs/simcount.py $watt2 speicher speicherikwh speicherekwh"
		sudo python3 runs/simcount.py $watt2 speicher speicherikwh speicherekwh
#########################################################################						
		importtemp1=$(<ramdisk/speicherwatt0pos)
		exporttemp1=$(<ramdisk/speicherwatt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/housebattery/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/housebattery/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim speicher end
	fi

    xpt1=$ptx            
    ptstart
	if ((verbraucher1_aktiv == 1)) && [[ $verbraucher1_typ == "shelly" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimVerbraucher counter simulation"
		ra='^-?[0-9]+$'
		watt3=$(<ramdisk/verbraucher1_watt)
		if [[ -e ramdisk/verbraucher1watt0pos ]]; then
			importtemp=$(<ramdisk/verbraucher1watt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/Verbraucher/1/WH1Imported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/Verbraucher/1/WHImported_temp from mosquito $importtemp"
			echo $importtemp > ramdisk/verbraucher1watt0pos
		fi
		if [[ -e ramdisk/verbraucher1watt0neg ]]; then
			exporttemp=$(<ramdisk/verbraucher1watt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/verbraucher/1/WH1Export_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/verbraucher/1/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > ramdisk/verbraucher1watt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python3 runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe"
		sudo python3 runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe
#########################################################################						
		importtemp1=$(<ramdisk/verbraucher1watt0pos)
		exporttemp1=$(<ramdisk/verbraucher1watt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/verbraucher/1/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/verbraucher/1/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim verbraucher end
	fi
    if ((verbraucher2_aktiv == 1)) && [[ $verbraucher2_typ == "shelly" ]]; then
        openwbDebugLog "MAIN" 0 "verb  UseSimVerbraucher counter simulation"
        ra='^-?[0-9]+$'
        watt3=$(<ramdisk/verbraucher2_watt)
        if [[ -e ramdisk/verbraucher2watt0pos ]]; then
            importtemp=$(<ramdisk/verbraucher2watt0pos)
        else
            importtemp=$(timeout 4 mosquitto_sub -t openWB/Verbraucher/2/WH1Imported_temp)
            if ! [[ $importtemp =~ $ra ]] ; then
                importtemp="0"
            fi
            openwbDebugLog "MAIN" 0 "loadvars verb read openWB/Verbraucher/2/WHImported_temp from mosquito $importtemp"
            echo $importtemp > ramdisk/verbraucher2watt0pos
        fi
        if [[ -e ramdisk/verbraucher2watt0neg ]]; then
            exporttemp=$(<ramdisk/verbraucher2watt0neg)
        else
            exporttemp=$(timeout 4 mosquitto_sub -t openWB/verbraucher/2/WH1Export_temp)
            if ! [[ $exporttemp =~ $ra ]] ; then
                exporttemp="0"
            fi
            openwbDebugLog "MAIN" 0 "loadvars verb read openWB/verbraucher/2/WHExport_temp from mosquito $exporttemp"
            echo $exporttemp > ramdisk/verbraucher2watt0neg
        fi
#########################################################################                        
        openwbDebugLog "MAIN" 0 "EXEC: sudo python3 runs/simcount.py $watt3 verbraucher2 verbraucher2_wh verbraucher2_whe"
        sudo python3 runs/simcount.py $watt3 verbraucher2 verbraucher2_wh verbraucher2_whe
#########################################################################                        
        importtemp2=$(<ramdisk/verbraucher2watt0pos)
        exporttemp2=$(<ramdisk/verbraucher2watt0neg)
        if [[ $importtemp !=  $importtemp2 ]]; then
            mosquitto_pub -t openWB/verbraucher/2/WHImported_temp -r -m "$importtemp2"
        fi
        if [[ $exporttemp !=  $exporttemp2 ]]; then
            mosquitto_pub -t openWB/verbraucher/2/WHExport_temp -r -m "$exporttemp2"
        fi
        # sim verbraucher end
    fi
    ptend "verb simcount" 20
    ptx=$xpt1            


	#Uhrzeit
	date=$(date)
	H=$(date +%H)
#	if ((debug == 1)); then
#		echo "$(tail -1500 ramdisk/openWB.log)" > ramdisk/openWB.log
#	fi
	if [[ $speichermodul != "none" ]] ; then
		openwbDebugLog "MAIN" 1 "speicherleistung $speicherleistung speichersoc $speichersoc"
	fi
	if (( $etprovideraktiv == 1 )) ; then
		openwbDebugLog "MAIN" 1 "etproviderprice $etproviderprice etprovidermaxprice $etprovidermaxprice"
	fi

printf -v p1 "LL [%4sA %5sV] [%4sA] [%4sA]" $lla1 $llv1 $llas11 $llas21
printf -v p2 "LL [%4sA %5sV] [%4sA] [%4sA]" $lla2 $llv2 $llas12 $llas22
printf -v p3 "LL [%4sA %5sV] [%4sA] [%4sA]" $lla3 $llv3 $llas13 $llas23
printf -v pv "PV [%5sW|%5sW]=%5sW ladeleistung=%s llalt=%s nachladen [%d/%d] MinMax=[%dA %dA]" $pv1watt $pv2watt $pvwatt $ladeleistung $llalt $nachtladen $nachtladens1 $minimalstromstaerke $maximalstromstaerke

	openwbDebugLog "MAIN" 2 "$pv"
	openwbDebugLog "MAIN" 2 "$p1 $(echo -e  mindestuberschuss "$mindestuberschuss" abschaltuberschuss "$abschaltuberschuss" lademodus "$lademodus")"
	openwbDebugLog "MAIN" 2 "$p2 $(echo -e  sofortll "$sofortll" hausverbrauch "$hausverbrauch"  wattbezug "$wattbezug" uberschuss "$uberschuss")"
	openwbDebugLog "MAIN" 2 "$p3 $(echo -e  soclp1 $soc soclp2 $soc1)"
	openwbDebugLog "MAIN" 2 "EVU 1:${evuv1}V/${evua1}A 2: ${evuv2}V/${evua2}A 3: ${evuv3}V/${evua3}A"
	openwbDebugLog "MAIN" 2 "$(echo -e lp1enabled "$lp1enabled"'\t'lp2enabled "$lp2enabled"'\t'lp3enabled "$lp3enabled")"
	openwbDebugLog "MAIN" 2 "$(echo -e plugstatlp1 "$plugstat"'\t'plugstatlp2 "$plugstatlp2"'\t'plugstatlp3 "$plugstatlp3")"
	openwbDebugLog "MAIN" 2 "$(echo -e chargestatlp1 "$chargestat"'\t'chargestatlp2 "$chargestatlp2"'\t'chargestatlp3 "$chargestatlp3")"
#	if [[ $standardSocketInstalled == "1" ]]; then
#		openwbDebugLog "MAIN" 1 "socketa $socketa socketp $socketp socketkwh $socketkwh socketv $socketv"
#	fi



	
	# date&timestamp now in pubmqtt.sh
	tempPubList="openWB/system/Uptime=$(uptime)"

    opvwatt=$(<ramdisk/mqttpvwatt)
	if [[ "$opvwatt" != "$pvwatt" ]]; then
		tempPubList="${tempPubList}\nopenWB/pv/W=${pvwatt}"
		echo $pvwatt > ramdisk/mqttpvwatt
	fi
    owattbezug=$(<ramdisk/mqttwattbezug)
	if [[ "$owattbezug" != "$wattbezug" ]]; then
		tempPubList="${tempPubList}\nopenWB/evu/W=${wattbezug}"
		echo $wattbezug > ramdisk/mqttwattbezug
	fi
    oladestatus=$(<ramdisk/mqttlastladestatus)
	if [[ "$oladestatus" != "$ladestatus" ]]; then
		tempPubList="${tempPubList}\nopenWB/ChargeStatus=${ladestatus}"
		echo $ladestatus > ramdisk/mqttlastladestatus
	fi
	# TODO: wann wird der Lademodus geändert?
    olademodus=$(<ramdisk/mqttlastlademodus)
	if [[ "$olademodus" != "$lademodus" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/ChargeMode=${lademodus}"
		echo $lademodus > ramdisk/mqttlastlademodus
	fi


	if { (( lademodus == 0 )) && (( nlakt_sofort  == 1 )); } \
	|| { (( lademodus == 1 )) && (( nlakt_minpv   == 1 )); } \
	|| { (( lademodus == 2 )) && (( nlakt_nurpv   == 1 )); } \
	|| { (( lademodus == 4 )) && (( nlakt_standby == 1 )); } then
		if (( nachtladen > 0 )) ; then     #  Config value  
			openwbDebugLog "MAIN" 2 "################# lademodes:$lademodus set openWB/lp/1/boolChargeAtNight=1"
			tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=1"
		else	 
			openwbDebugLog "MAIN" 2 "################## lademodes:$lademodus set openWB/lp/1/boolChargeAtNight=0"
			tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=0"
		fi
	else
		 openwbDebugLog "MAIN" 2 "################ lademodes:$lademodus set openWB/lp/1/boolChargeAtNight=0"
		 tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=0"
	fi

    ohausverbrauch=$(<ramdisk/mqtthausverbrauch)
	if [[ "$ohausverbrauch" != "$hausverbrauch" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/WHouseConsumption=${hausverbrauch}"
		echo $hausverbrauch > ramdisk/mqtthausverbrauch
	fi
    
    oladeleistunglp1=$(<ramdisk/mqttladeleistunglp1)
    if [[ "$oladeleistunglp1" != "$ladeleistunglp1" ]]; then
        tempPubList="${tempPubList}\nopenWB/lp/1/W=${ladeleistunglp1}"
        echo $ladeleistunglp1 > ramdisk/mqttladeleistunglp1
    fi
    
    oladeleistungs1=$(<ramdisk/mqttladeleistungs1)
	if [[ "$oladeleistungs1" != "$ladeleistungs1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/W=${ladeleistungs1}"
		echo $ladeleistungs1 > ramdisk/mqttladeleistungs1
	fi
    
    oladeleistungs2=$(<ramdisk/mqttladeleistungs2)
	if [[ "$oladeleistungs2" != "$ladeleistungs2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/W=${ladeleistungs2}"
		echo $ladeleistungs2 > ramdisk/mqttladeleistungs2
	fi
 
# statt ramdisk hier mqttt lesen   
    ollkombiniert=$(<ramdisk/mqttladeleistung)
	if [[ "$ollkombiniert" != "$ladeleistung" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/WAllChargePoints=${ladeleistung}"
		echo $ladeleistung > ramdisk/mqttladeleistung
	fi
    ospeicherleistung=$(<ramdisk/mqttspeicherleistung)
	if [[ "$ospeicherleistung" != "$speicherleistung" ]]; then
		tempPubList="${tempPubList}\nopenWB/housebattery/W=${speicherleistung}"
		echo $speicherleistung > ramdisk/mqttspeicherleistung
	fi
    ospeichersoc=$(<ramdisk/mqttspeichersoc)
	if [[ "$ospeichersoc" != "$speichersoc" ]]; then
		tempPubList="${tempPubList}\nopenWB/housebattery/%Soc=${speichersoc}"
		echo $speichersoc > ramdisk/mqttspeichersoc
	fi
    osoc=$(<ramdisk/mqttsoc)
	if [[ "$osoc" != "$soc" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/%Soc=${soc}"
		echo $soc > ramdisk/mqttsoc
	fi
    osoc1=$(<ramdisk/mqttsoc1)
	if [[ "$osoc1" != "$soc1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/%Soc=${soc1}"
		echo $soc1 > ramdisk/mqttsoc1
	fi
    ostopchargeafterdisclp1=$(<ramdisk/mqttstopchargeafterdisclp1)
	if [[ "$ostopchargeafterdisclp1" != "$stopchargeafterdisclp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/1/stopchargeafterdisc=${stopchargeafterdisclp1}"
		echo $stopchargeafterdisclp1 > ramdisk/mqttstopchargeafterdisclp1
	fi
    ostopchargeafterdisclp2=$(<ramdisk/mqttstopchargeafterdisclp2)
	if [[ "$ostopchargeafterdisclp2" != "$stopchargeafterdisclp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/2/stopchargeafterdisc=${stopchargeafterdisclp2}"
		echo $stopchargeafterdisclp2 > ramdisk/mqttstopchargeafterdisclp2
	fi
    ostopchargeafterdisclp3=$(<ramdisk/mqttstopchargeafterdisclp3)
	if [[ "$ostopchargeafterdisclp3" != "$stopchargeafterdisclp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/3/stopchargeafterdisc=${stopchargeafterdisclp3}"
		echo $stopchargeafterdisclp3 > ramdisk/mqttstopchargeafterdisclp3
	fi

	# lp4-lp8

	if [[ $rfidakt == "1" ]]; then # function call
		rfid
	fi

	csvfile="web/logging/data/daily/$(date +%Y%m%d).csv"
	if [ -r $csvfile ]  ; then
		first=$(head -n 1 "$csvfile")
		last=$(tail -n 1 "$csvfile")
		dailychargelp1=$(echo "$(echo "$first" | cut -d , -f 5) $(echo "$last" | cut -d , -f 5)" | awk '{printf "%0.2f", ($2 - $1)/1000}')
		dailychargelp2=$(echo "$(echo "$first" | cut -d , -f 6) $(echo "$last" | cut -d , -f 6)" | awk '{printf "%0.2f", ($2 - $1)/1000}')
		dailychargelp3=$(echo "$(echo "$first" | cut -d , -f 7) $(echo "$last" | cut -d , -f 7)" | awk '{printf "%0.2f", ($2 - $1)/1000}')
	else	
		dailychargelp1=0
		dailychargelp2=0
		dailychargelp3=0
	fi		

	restzeitlp1=$(<ramdisk/restzeitlp1)
	restzeitlp2=$(<ramdisk/restzeitlp2)
	restzeitlp3=$(<ramdisk/restzeitlp3)
	gelrlp1=$(<ramdisk/gelrlp1)
	gelrlp2=$(<ramdisk/gelrlp2)
	gelrlp3=$(<ramdisk/gelrlp3)

	lastregelungaktiv=$(<ramdisk/lastregelungaktiv) # reload , maybee cleared
	hook1akt=$(<ramdisk/hook1akt)
	hook2akt=$(<ramdisk/hook2akt)
	hook3akt=$(<ramdisk/hook3akt)
    odailychargelp1=$(<ramdisk/mqttdailychargelp1)
	if [[ "$odailychargelp1" != "$dailychargelp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/kWhDailyCharged=${dailychargelp1}"
		echo $dailychargelp1 > ramdisk/mqttdailychargelp1
	fi
    odailychargelp2=$(<ramdisk/mqttdailychargelp2)
	if [[ "$odailychargelp2" != "$dailychargelp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/kWhDailyCharged=${dailychargelp2}"
		echo $dailychargelp2 > ramdisk/mqttdailychargelp2
	fi
    odailychargelp3=$(<ramdisk/mqttdailychargelp3)
	if [[ "$odailychargelp3" != "$dailychargelp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/kWhDailyCharged=${dailychargelp3}"
		echo $dailychargelp3 > ramdisk/mqttdailychargelp3
	fi
    orestzeitlp1=$(<ramdisk/mqttrestzeitlp1)
	if [[ "$orestzeitlp1" != "$restzeitlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/TimeRemaining=${restzeitlp1}"
		echo $restzeitlp1 > ramdisk/mqttrestzeitlp1
	fi
    orestzeitlp2=$(<ramdisk/mqttrestzeitlp2)
	if [[ "$orestzeitlp2" != "$restzeitlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/TimeRemaining=${restzeitlp2}"
		echo $restzeitlp2 > ramdisk/mqttrestzeitlp2
	fi
    orestzeitlp3=$(<ramdisk/mqttrestzeitlp3)
	if [[ "$orestzeitlp3" != "$restzeitlp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/TimeRemaining=${restzeitlp3}"
		echo $restzeitlp3 > ramdisk/mqttrestzeitlp3
	fi
    ogelrlp1=$(<ramdisk/mqttgelrlp1)
	if [[ "$ogelrlp1" != "$gelrlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/kmCharged=${gelrlp1}"
		echo $gelrlp1 > ramdisk/mqttgelrlp1
	fi
    ogelrlp2=$(<ramdisk/mqttgelrlp2)
	if [[ "$ogelrlp2" != "$gelrlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/kmCharged=${gelrlp2}"
		echo $gelrlp2 > ramdisk/mqttgelrlp2
	fi
    ogelrlp3=$(<ramdisk/mqttgelrlp3)
	if [[ "$ogelrlp3" != "$gelrlp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/kmCharged=${gelrlp3}"
		echo $gelrlp3 > ramdisk/mqttgelrlp3
	fi
    
    
     
# > openwbcong.sh/mqttconfvar.sh

	if (( ohook1akt != hook1akt )); then
		tempPubList="${tempPubList}\nopenWB/boolHook1Active=${hook1akt}"
		echo $hook1akt > ramdisk/mqtthook1aktiv
	fi
	if (( ohook2akt != hook2akt )); then
		tempPubList="${tempPubList}\nopenWB/boolHook2Active=${hook2akt}"
		echo $hook2akt > ramdisk/mqtthook2aktiv
	fi
	if (( ohook3akt != hook3akt )); then
		tempPubList="${tempPubList}\nopenWB/boolHook3Active=${hook3akt}"
		echo $hook3akt > ramdisk/mqtthook3aktiv
	fi
	oversion=$(<ramdisk/mqttversion)
	if [[ $oversion != $version ]]; then
		tempPubList="${tempPubList}\nopenWB/system/Version=${version}"
		echo -n "$version" > ramdisk/mqttversion
	fi

# > openwbcong.sh/mqttconfvar.sh

    osocvorhanden=$(<ramdisk/mqttsocvorhanden)
    if [[ "$osocvorhanden" != "$socvorhanden" ]]; then
        tempPubList="${tempPubList}\nopenWB/lp/1/boolSocConfigured=${socvorhanden}"
        echo $socvorhanden > ramdisk/mqttsocvorhanden
	fi
	osoc1vorhanden=$(<ramdisk/mqttsoc1vorhanden)
	if [[ "$osoc1vorhanden" != "$soc1vorhanden" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolSocConfigured=${soc1vorhanden}"
		echo $soc1vorhanden > ramdisk/mqttsoc1vorhanden
	fi


	# lp4-lp8

# > openwbcong.sh/mqttconfvar.sh

	# lp4-lp8

# > openwbcong.sh/mqttconfvar.sh

	ospeichervorhanden=$(<ramdisk/mqttspeichervorhanden)
	if (( ospeichervorhanden != speichervorhanden )); then
		tempPubList="${tempPubList}\nopenWB/housebattery/boolHouseBatteryConfigured=${speichervorhanden}"
		echo $speichervorhanden > ramdisk/mqttspeichervorhanden
	fi
	opv1vorhanden=$(<ramdisk/mqttpv1vorhanden)
	if (( opv1vorhanden != pv1vorhanden )); then
		tempPubList="${tempPubList}\nopenWB/pv/1/boolPVConfigured=${pv1vorhanden}"
		echo $pv1vorhanden > ramdisk/mqttpv1vorhanden
	fi
	opv2vorhanden=$(<ramdisk/mqttpv2vorhanden)
	if (( opv2vorhanden != pv2vorhanden )); then
		tempPubList="${tempPubList}\nopenWB/pv/2/boolPVConfigured=${pv2vorhanden}"
		echo $pv2vorhanden > ramdisk/mqttpv2vorhanden
	fi
    
# > openwbcong.sh/mqttconfvar.sh

	# lp4-lp8

# > openwbcong.sh/mqttconfvar.sh

	oetprovideraktiv=$(<ramdisk/mqttetprovideraktiv)
    if [[ "$oetprovideraktiv" != "$etprovideraktiv" ]]; then ## openwb.conf->mqtt
		tempPubList="${tempPubList}\nopenWB/global/awattar/boolAwattarEnabled=${etprovideraktiv}"
		echo $etprovideraktiv > ramdisk/mqttetprovideraktiv
	fi
	oetprovider=$(<ramdisk/mqttetprovider)
	if [[ "$oetprovider" != "$etprovider" ]]; then  ## openwb.conf->mqtt
		tempPubList="${tempPubList}\nopenWB/global/ETProvider/modulePath=${etprovider}"
		echo $etprovider > ramdisk/mqttetprovider
	fi
	oetproviderprice=$(<ramdisk/mqttetproviderprice)
#	etproviderprice=$(<ramdisk/etproviderprice) weiter vorne
	if [[ "$oetproviderprice" != "$etproviderprice" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/awattar/ActualPriceForCharging=${etproviderprice}"
		echo $etproviderprice > ramdisk/mqttetproviderprice
	fi
	oetprovidermaxprice=$(<ramdisk/mqttetprovidermaxprice)
#	etprovidermaxprice=$(<ramdisk/etprovidermaxprice) weiter vorne
	if [[ "$oetprovidermaxprice" != "$etprovidermaxprice" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/awattar/MaxPriceForCharging=${etprovidermaxprice}"
		echo $etprovidermaxprice > ramdisk/mqttetprovidermaxprice
	fi

# > openwbcong.sh/mqttconfvar.sh

	# publish last RFID scans as CSV with timestamp
	timestamp="$(date +%s)"

	orfidlp1=$(<ramdisk/mqttrfidlp1)
	arfidlp1=$(<ramdisk/rfidlp1)
	if [[ "$orfidlp1" != "$arfidlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/lastRfId=${arfidlp1}"
		echo $arfidlp1 > ramdisk/mqttrfidlp1
	fi

	orfidlp2=$(<ramdisk/mqttrfidlp2)
	arfidlp2=$(<ramdisk/rfidlp2)
	if [[ "$orfidlp2" != "$arfidlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/lastRfId=${arfidlp2}"
		echo $arfidlp2 > ramdisk/mqttrfidlp2
	fi

	orfidlast=$(<ramdisk/mqttrfidlasttag)
	arfidlast=$(<ramdisk/rfidlasttag)
	if [[ "$orfidlast" != "$arfidlast" ]]; then
		tempPubList="${tempPubList}\nopenWB/system/lastRfId=${arfidlast}"
		echo $arfidlast > ramdisk/mqttrfidlasttag
	fi

	ouiplast=$(<ramdisk/mqttupdateinprogress)
	auiplast=$(<ramdisk/updateinprogress)
	if [[ "$ouiplast" != "$auiplast" ]]; then
		tempPubList="${tempPubList}\nopenWB/system/updateInProgress=${auiplast}"
		echo $auiplast > ramdisk/mqttupdateinprogress
	fi

# YourCharge
#	arandomSleep=$(<ramdisk/randomSleepValue)
#	orandomSleepValue=$(<ramdisk/mqttRandomSleepValue)
#	if [[ "$orandomSleepValue" != "$arandomSleep" ]]; then
#		tempPubList="${tempPubList}\nopenWB/system/randomSleep=${arandomSleep}"
#		echo $arandomSleep > ramdisk/mqttRandomSleepValue
#	fi

# call main funtion from openwbconf.sh 
    xpt1=$ptx            
    ptstart
    doopenWBconfsyncorinit
    ptend "MQTTcvc syncopenwbconf" 20
    ptx=$xpt1            

	
if (( debug > 1 )); then
	echo "loadvars.Publist:"
	echo -e $tempPubList
	#echo "Running Python: runs/mqttpub.py -q 0 -r &"
fi
#########################################################################						
echo -e $tempPubList | python3 runs/mqttpub.py -q 0 -r &
#########################################################################						

#########################################################################						
runs/pubmqtt.sh &
#########################################################################						
if (( debug > 1 )); then
  loadv=$(cat /proc/loadavg)
  openwbDebugLog "MAIN" 2 "Load $loadv"
fi


}
