#!/bin/bash
# dies ist utf8 äöüäöü
loadvars(){
	#reload mqtt vars
	renewmqtt=$(</var/www/html/openWB/ramdisk/renewmqtt)
	if (( renewmqtt == 1 )); then
		echo 0 > /var/www/html/openWB/ramdisk/renewmqtt
		echo 01 | tee ramdisk/mqtt*
		openwbDebugLog "MAIN" 1 "RenewMQTT copy 01 to all ramdiskvalues"
		openwbDebugLog "MAIN" 1 "RenewMQTT so all mqtt var are set new at end of loadvar."
	fi

	#get temp vars
	sofortll=$(<ramdisk/lp1sofortll)
	sofortlls1=$(<ramdisk/lp2sofortll)
	sofortlls2=$(<ramdisk/lp3sofortll)

	#get oldvars for mqtt
	opvwatt=$(<ramdisk/mqttpvwatt)
	owattbezug=$(<ramdisk/mqttwattbezug)
	ollaktuell=$(<ramdisk/mqttladeleistunglp1)
	ohausverbrauch=$(<ramdisk/mqtthausverbrauch)
	ollkombiniert=$(<ramdisk/llkombiniert)
	ollaktuells1=$(<ramdisk/mqttladeleistungs1)
	ollaktuells2=$(<ramdisk/mqttladeleistungs2)
	ospeicherleistung=$(<ramdisk/mqttspeicherleistung)
	oladestatus=$(<ramdisk/mqttlastladestatus)
	olademodus=$(<ramdisk/mqttlastlademodus)
	osoc=$(<ramdisk/mqttsoc)
	osoc1=$(<ramdisk/mqttsoc1)
	ostopchargeafterdisclp1=$(<ramdisk/mqttstopchargeafterdisclp1)
	ostopchargeafterdisclp2=$(<ramdisk/mqttstopchargeafterdisclp2)
	ostopchargeafterdisclp3=$(<ramdisk/mqttstopchargeafterdisclp3)
	ospeichersoc=$(<ramdisk/mqttspeichersoc)
	ladestatus=$(</var/www/html/openWB/ramdisk/ladestatus)
	odailychargelp1=$(<ramdisk/mqttdailychargelp1)
	odailychargelp2=$(<ramdisk/mqttdailychargelp2)
	odailychargelp3=$(<ramdisk/mqttdailychargelp3)
	oaktgeladens1=$(<ramdisk/mqttaktgeladens1)
	oaktgeladens2=$(<ramdisk/mqttaktgeladens2)
	oaktgeladen=$(<ramdisk/mqttaktgeladen)
	orestzeitlp1=$(<ramdisk/mqttrestzeitlp1)
	orestzeitlp2=$(<ramdisk/mqttrestzeitlp2)
	orestzeitlp3=$(<ramdisk/mqttrestzeitlp3)
	ogelrlp1=$(<ramdisk/mqttgelrlp1)
	ogelrlp2=$(<ramdisk/mqttgelrlp2)
	ogelrlp3=$(<ramdisk/mqttgelrlp3)
	olastregelungaktiv=$(<ramdisk/lastregelungaktiv)
	ohook1aktiv=$(<ramdisk/hook1akt)
	ohook2aktiv=$(<ramdisk/hook2akt)
	ohook3aktiv=$(<ramdisk/hook3akt)
	lp1enabled=$(<ramdisk/lp1enabled)
	lp2enabled=$(<ramdisk/lp2enabled)
	lp3enabled=$(<ramdisk/lp3enabled)

	version=$(<web/version)
	# EVSE DIN Plug State
	declare -r IsNumberRegex='^[0-9]+$'
	if [[ $evsecon == "modbusevse" ]]; then
		if [[ "$modbusevseid" == "0" ]]; then
			if [ -f /var/www/html/openWB/ramdisk/evsemodulconfig ]; then
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
		openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readmodbus.py $modbusevsesource $modbusevseid 1002 1"
		evseplugstate=$(sudo python runs/readmodbus.py $modbusevsesource $modbusevseid 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			# EVSE read returned empty or non-numeric value --> use last state for this loop
			evseplugstate=$(</var/www/html/openWB/ramdisk/evseplugstate)
			openwbDebugLog "MAIN" 0 "Modbus EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > /var/www/html/openWB/ramdisk/evseplugstate
		fi
		ladestatuslp1=$(</var/www/html/openWB/ramdisk/ladestatus)
		if [ "$evseplugstate" -ge "0" ] && [ "$evseplugstate" -le "10" ] ; then
			if [[ $evseplugstate > "1" ]]; then
				plugstat=$(</var/www/html/openWB/ramdisk/plugstat)
				if [[ $plugstat == "0" ]] ; then
					if [[ $pushbplug == "1" ]] && [[ $ladestatuslp1 == "0" ]] && [[ $pushbenachrichtigung == "1" ]] ; then
						message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
					    openwbDebugLog "MAIN" 0 "EXEC: /var/www/html/openWB/runs/pushover.sh"
						/var/www/html/openWB/runs/pushover.sh "$message"
#########################################################################						
					fi
					if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
						export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
					fi
					echo 20000 > /var/www/html/openWB/ramdisk/soctimer
				fi
				echo 1 > /var/www/html/openWB/ramdisk/plugstat
				plugstat=1
			else
				echo 0 > /var/www/html/openWB/ramdisk/plugstat
				plugstat=0
			fi
			if [[ $evseplugstate > "2" ]] && [[ $ladestatuslp1 == "1" ]] && [[ $lp1enabled == "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/chargestat
				chargestat=1
			else
				echo 0 > /var/www/html/openWB/ramdisk/chargestat
				chargestat=0
			fi
		fi
	else
		pluggedin=$(</var/www/html/openWB/ramdisk/pluggedin)    # nur vonn isss.py auf 1 gesetzt
		if [ "$pluggedin" -gt "0" ]; then
			if [[ $pushbplug == "1" ]] && [[ $ladestatuslp1 == "0" ]] && [[ $pushbenachrichtigung == "1" ]] ; then
				message="Fahrzeug eingesteckt. Ladung startet bei erfüllter Ladebedingung automatisch."
#########################################################################						
				openwbDebugLog "MAIN" 0 "EXEC: /var/www/html/openWB/runs/pushover.sh"
				/var/www/html/openWB/runs/pushover.sh "$message"
#########################################################################						
			fi
			if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
				export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
			fi
			echo 20000 > /var/www/html/openWB/ramdisk/soctimer
			echo 0 > /var/www/html/openWB/ramdisk/pluggedin
		fi

		plugstat=$(<ramdisk/plugstat)
		chargestat=$(<ramdisk/chargestat)
	fi
	if [[ $evsecon == "ipevse" ]]; then   ## Alter Satellit ohne Pi3
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1"
		evseplugstatelp1=$(sudo python runs/readipmodbus.py $evseiplp1 $evseidlp1 1002 1)
#########################################################################						
		if [ -z "${evseplugstate}" ] || ! [[ "${evseplugstate}" =~ $IsNumberRegex ]]; then
			evseplugstate=$(</var/www/html/openWB/ramdisk/evseplugstate)
			openwbDebugLog "MAIN" 0 "IP EVSE read CP1 issue - using previous state '${evseplugstate}'"
		else
			echo $evseplugstate > /var/www/html/openWB/ramdisk/evseplugstate
		fi
		ladestatuslp1=$(</var/www/html/openWB/ramdisk/ladestatus)
		if [[ $evseplugstatelp1 > "1" ]]; then
			echo 1 > /var/www/html/openWB/ramdisk/plugstat
		else
			echo 0 > /var/www/html/openWB/ramdisk/plugstat
		fi
		if [[ $evseplugstatelp1 > "2" ]] && [[ $ladestatuslp1 == "1" ]] && [[ $lp1enabled == "1" ]]; then
			echo 1 > /var/www/html/openWB/ramdisk/chargestat
		else
			echo 0 > /var/www/html/openWB/ramdisk/chargestat
		fi
	fi

	if [[ $lastmanagement == "1" ]]; then
		ConfiguredChargePoints=2
		if [[ $evsecons1 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readmodbus.py $evsesources1 $evseids1 1002 1"
			evseplugstatelp2=$(sudo python runs/readmodbus.py $evsesources1 $evseids1 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				evseplugstatelp2=$(</var/www/html/openWB/ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > /var/www/html/openWB/ramdisk/evseplugstatelp2
			fi
			ladestatuss1=$(</var/www/html/openWB/ramdisk/ladestatuss1)
			if [[ $evseplugstatelp2 > "0" ]] && [[ $evseplugstatelp2 < "7" ]] ; then
				if [[ $evseplugstatelp2 > "1" ]]; then
					plugstat2=$(</var/www/html/openWB/ramdisk/plugstats1)

					if [[ $plugstat2 == "0" ]] ; then
						if [[ $displayconfigured == "1" ]] && [[ $displayEinBeimAnstecken == "1" ]] ; then
							export DISPLAY=:0 && xset dpms force on && xset dpms $displaysleep $displaysleep $displaysleep
						fi
						echo 20000 > /var/www/html/openWB/ramdisk/soctimer1
					fi
					echo 1 > /var/www/html/openWB/ramdisk/plugstats1
					plugstat2=1
					plugstats1=$plugstat2
				else
					echo 0 > /var/www/html/openWB/ramdisk/plugstats1
					plugstat2=0
					plugstats1=$plugstat2
				fi
				if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuss1 == "1" ]] ; then
					echo 1 > /var/www/html/openWB/ramdisk/chargestats1
				else
					echo 0 > /var/www/html/openWB/ramdisk/chargestats1
				fi

			fi
		fi
		if [[ $evsecons1 == "slaveeth" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readslave.py 1002 1"
			evseplugstatelp2=$(sudo python runs/readslave.py 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				evseplugstatelp2=$(</var/www/html/openWB/ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "Slaveeth EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > /var/www/html/openWB/ramdisk/evseplugstatelp2
			fi
			ladestatuss1=$(</var/www/html/openWB/ramdisk/ladestatuss1)

			if [[ $evseplugstatelp2 > "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/plugstats1
			else
				echo 0 > /var/www/html/openWB/ramdisk/plugstats1
			fi
			if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuss1 == "1" ]] ; then
				echo 1 > /var/www/html/openWB/ramdisk/chargestats1
			else
				echo 0 > /var/www/html/openWB/ramdisk/chargestats1
			fi
		fi
		if [[ $evsecons1 == "ipevse" ]]; then ## Alter Satellit ohne Pi3
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readipmodbus.py $evseiplp2 $evseidlp2 1002 1"
			evseplugstatelp2=$(sudo python runs/readipmodbus.py $evseiplp2 $evseidlp2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp2}" ] || ! [[ "${evseplugstatelp2}" =~ $IsNumberRegex ]]; then
				evseplugstatelp2=$(</var/www/html/openWB/ramdisk/evseplugstatelp2)
				openwbDebugLog "MAIN" 0 "IP EVSE read CP2 issue - using previous state '${evseplugstatelp2}'"
			else
				echo $evseplugstatelp2 > /var/www/html/openWB/ramdisk/evseplugstatelp2
			fi
			ladestatuslp2=$(</var/www/html/openWB/ramdisk/ladestatuss1)

			if [[ $evseplugstatelp2 > "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/plugstats1
			else
				echo 0 > /var/www/html/openWB/ramdisk/plugstats1
			fi
			if [[ $evseplugstatelp2 > "2" ]] && [[ $ladestatuslp2 == "1" ]] && [[ $lp2enabled == "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/chargestats1
			else
				echo 0 > /var/www/html/openWB/ramdisk/chargestats1
			fi
		fi
		plugstatlp2=$(<ramdisk/plugstats1)
		chargestatlp2=$(<ramdisk/chargestats1)
	else
		plugstatlp2=$(<ramdisk/plugstats1)
		chargestatlp2=$(<ramdisk/chargestats1)
		ConfiguredChargePoints=1
	fi

	if [[ $lastmanagements2 == "1" ]]; then
		ConfiguredChargePoints=3
		if [[ $evsecons2 == "ipevse" ]]; then ## Alter Satellit ohne Pi3
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readipmodbus.py $evseiplp3 $evseidlp3 1002 1"
			evseplugstatelp3=$(sudo python runs/readipmodbus.py $evseiplp3 $evseidlp3 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				evseplugstatelp3=$(</var/www/html/openWB/ramdisk/evseplugstatelp3)
				openwbDebugLog "MAIN" 0 "IP EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > /var/www/html/openWB/ramdisk/evseplugstatelp3
			fi
			ladestatuslp3=$(</var/www/html/openWB/ramdisk/ladestatuss2)

			if [[ $evseplugstatelp3 > "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/plugstatlp3
			else
				echo 0 > /var/www/html/openWB/ramdisk/plugstatlp3
			fi
			if [[ $evseplugstatelp3 > "2" ]] && [[ $ladestatuslp3 == "1" ]] && [[ $lp3enabled == "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/chargestatlp3
			else
				echo 0 > /var/www/html/openWB/ramdisk/chargestatlp3
			fi
		fi


		if [[ $evsecons2 == "modbusevse" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: sudo python runs/readmodbus.py $evsesources2 $evseids2 1002 1"
			evseplugstatelp3=$(sudo python runs/readmodbus.py $evsesources2 $evseids2 1002 1)
#########################################################################						
			if [ -z "${evseplugstatelp3}" ] || ! [[ "${evseplugstatelp3}" =~ $IsNumberRegex ]]; then
				evseplugstatelp3=$(</var/www/html/openWB/ramdisk/evseplugstatelp3)
				openwbDebugLog "MAIN" 0 "Modbus EVSE read CP3 issue - using previous state '${evseplugstatelp3}'"
			else
				echo $evseplugstatelp3 > /var/www/html/openWB/ramdisk/evseplugstatelp3
			fi
			ladestatuss2=$(</var/www/html/openWB/ramdisk/ladestatuss2)
			if [[ $evseplugstatelp3 > "1" ]]; then
				echo 1 > /var/www/html/openWB/ramdisk/plugstatlp3
			else
				echo 0 > /var/www/html/openWB/ramdisk/plugstatlp3
			fi
			if [[ $evseplugstatelp3 > "2" ]] && [[ $ladestatuss2 == "1" ]] ; then
				echo 1 > /var/www/html/openWB/ramdisk/chargestatlp3
			else
					echo 0 > /var/www/html/openWB/ramdisk/chargestatlp3
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
		echo "" > ramdisk/lastregelungaktiv
	fi

	# Werte für die Berechnung ermitteln
	lademodus=$(</var/www/html/openWB/ramdisk/lademodus)
	if [ -z "$lademodus" ] ; then
		mosquitto_pub -r -t "openWB/set/ChargeMode" -m "$bootmodus"
		lademodus=$bootmodus
	fi
	llalt=$(cat /var/www/html/openWB/ramdisk/llsoll)
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
		echo 1 > /var/www/html/openWB/ramdisk/pv1vorhanden
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: modules/$pvwattmodul/main.sh"
		pvwatt=$(modules/$pvwattmodul/main.sh || true)
#########################################################################						
		if ! [[ $pvwatt =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für pvwatt: $pvwatt"
			pvwatt="0"
		fi
		pv1watt=$pvwatt
		echo $pv1watt > ramdisk/pv1watt
	else
		pv1vorhanden="0"
		echo 0 > /var/www/html/openWB/ramdisk/pv1vorhanden
		pvwatt=$(</var/www/html/openWB/ramdisk/pvwatt)
	fi
	if [[ $pv2wattmodul != "none" ]]; then
		pv2vorhanden="1"
		echo 1 > /var/www/html/openWB/ramdisk/pv2vorhanden
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: modules/$pv2wattmodul/main.sh"
		pv2watt=$(modules/$pv2wattmodul/main.sh || true)
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
		echo $pvwatt > /var/www/html/openWB/ramdisk/pvallwatt
		pvkwh=$(</var/www/html/openWB/ramdisk/pvkwh)
		pv2kwh=$(</var/www/html/openWB/ramdisk/pv2kwh)
		pvallwh=$(echo "$pvkwh + $pv2kwh" |bc)
		echo $pvallwh > /var/www/html/openWB/ramdisk/pvallwh
	else
		pvkwh=$(</var/www/html/openWB/ramdisk/pvkwh)
		pv2vorhanden="0"
		echo 0 > /var/www/html/openWB/ramdisk/pv2vorhanden
		echo $pvkwh > /var/www/html/openWB/ramdisk/pvallwh
		echo $pvwatt > /var/www/html/openWB/ramdisk/pvallwatt
	fi

	#Speicher werte
	if [[ $speichermodul != "none" ]] ; then
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: timeout 5 modules/$speichermodul/main.sh"
		timeout 5 modules/$speichermodul/main.sh
#########################################################################						
		if [[ $? -eq 124 ]] ; then
			openwbModulePublishState "BAT" 2 "Die Werte konnten nicht innerhalb des Timeouts abgefragt werden. Bitte Konfiguration und Gerätestatus prüfen."
		fi
		speicherleistung=$(</var/www/html/openWB/ramdisk/speicherleistung)
		speicherleistung=$(echo $speicherleistung | sed 's/\..*$//')
		speichersoc=$(</var/www/html/openWB/ramdisk/speichersoc)
		speichersoc=$(echo $speichersoc | sed 's/\..*$//')
		speichervorhanden="1"
		echo 1 > /var/www/html/openWB/ramdisk/speichervorhanden
		
#		if [[ $speichermodul == "speicher_alphaess" ]] ; then
#			pvwatt=$(</var/www/html/openWB/ramdisk/pvwatt)
#			echo 1 > /var/www/html/openWB/ramdisk/pv1vorhanden
#			pv1vorhanden="1"
#		fi
		if [[ $speichermodul == "speicher_e3dc" ]] ; then
			pvwatt=$(</var/www/html/openWB/ramdisk/pvwatt)
			echo 1 > /var/www/html/openWB/ramdisk/pv1vorhanden
			pv1vorhanden="1"

		fi
		if [[ $speichermodul == "speicher_sonneneco" ]] ; then
			pvwatt=$(</var/www/html/openWB/ramdisk/pvwatt)
			echo 1 > /var/www/html/openWB/ramdisk/pv1vorhanden
			pv1vorhanden="1"
		fi
	else
		speichervorhanden="0"
		echo 0 > /var/www/html/openWB/ramdisk/speichervorhanden
	fi
	#addition pv nach Speicherauslesung
	if [[ $pv2vorhanden == "1" ]]; then
		pv1watt=$(</var/www/html/openWB/ramdisk/pv1watt)
		pv2watt=$(</var/www/html/openWB/ramdisk/pv2watt)
		pvwatt=$(( pv1watt + pv2watt ))
		echo $pvwatt > /var/www/html/openWB/ramdisk/pvallwatt
		echo $pvwatt > /var/www/html/openWB/ramdisk/pvwatt
	else
		if [[ $pv1vorhanden == "1" ]]; then
			pv1watt=$(</var/www/html/openWB/ramdisk/pv1watt)
			pvwatt=$pv1watt
			echo $pvwatt > /var/www/html/openWB/ramdisk/pvallwatt
			echo $pvwatt > /var/www/html/openWB/ramdisk/pvwatt
		fi
	fi

	llphaset=3

	#Ladeleistung ermitteln
	if [[ $ladeleistungmodul != "none" ]]; then
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: timeout 10 modules/$ladeleistungmodul/main.sh"
		timeout 10 modules/$ladeleistungmodul/main.sh || true
#########################################################################						
		llkwh=$(</var/www/html/openWB/ramdisk/llkwh)
		llkwhges=$llkwh
		lla1=$(cat /var/www/html/openWB/ramdisk/lla1)
		lla2=$(cat /var/www/html/openWB/ramdisk/lla2)
		lla3=$(cat /var/www/html/openWB/ramdisk/lla3)
		lla1=$(echo $lla1 | sed 's/\..*$//')
		lla2=$(echo $lla2 | sed 's/\..*$//')
		lla3=$(echo $lla3 | sed 's/\..*$//')
		llv1=$(cat /var/www/html/openWB/ramdisk/llv1)
		llv2=$(cat /var/www/html/openWB/ramdisk/llv2)
		llv3=$(cat /var/www/html/openWB/ramdisk/llv3)
		ladeleistung=$(cat /var/www/html/openWB/ramdisk/llaktuell)
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
			openwbDebugLog "MAIN" 0 "ungültiger Wert für ladeleistung: $ladeleistung"
			ladeleistung="0"
		fi
		ladestatus=$(</var/www/html/openWB/ramdisk/ladestatus)

	else
		lla1=0
		lla2=0
		lla3=0
		ladeleistung=0
		llkwh=0
		llkwhges=$llkwh
	fi

	#zweiter ladepunkt
	if [[ $lastmanagement == "1" ]]; then
		if [[ $socmodul1 != "none" ]]; then
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: modules/$socmodul1/main.sh &"
			modules/$socmodul1/main.sh &
#########################################################################						
			soc1=$(</var/www/html/openWB/ramdisk/soc1)
			tmpsoc1=$(</var/www/html/openWB/ramdisk/tmpsoc1)
			if ! [[ $soc1 =~ $re ]] ; then
				openwbDebugLog "MAIN" 0 "ungültiger Wert für soc1: $soc1"
				soc1=$tmpsoc1
			else
				echo $soc1 > /var/www/html/openWB/ramdisk/tmpsoc1
			fi
			soc1vorhanden=1
			echo 1 > /var/www/html/openWB/ramdisk/soc1vorhanden
		else
			echo 0 > /var/www/html/openWB/ramdisk/soc1vorhanden
			soc1=0
			soc1vorhanden=0
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: timeout 10 modules/$ladeleistungs1modul/main.sh"
		timeout 10 modules/$ladeleistungs1modul/main.sh || true
#########################################################################						
		llkwhs1=$(</var/www/html/openWB/ramdisk/llkwhs1)
		llkwhges=$(echo "$llkwhges + $llkwhs1" |bc)
		llalts1=$(cat /var/www/html/openWB/ramdisk/llsolls1)
		ladeleistungs1=$(cat /var/www/html/openWB/ramdisk/llaktuells1)
		ladeleistunglp2=$ladeleistungs1
		llas11=$(cat /var/www/html/openWB/ramdisk/llas11)
		llas12=$(cat /var/www/html/openWB/ramdisk/llas12)
		llas13=$(cat /var/www/html/openWB/ramdisk/llas13)
		llas11=$(echo $llas11 | sed 's/\..*$//')
		llas12=$(echo $llas12 | sed 's/\..*$//')
		llas13=$(echo $llas13 | sed 's/\..*$//')
		ladestatuss1=$(</var/www/html/openWB/ramdisk/ladestatuss1)
		if ! [[ $ladeleistungs1 =~ $re ]] ; then
		ladeleistungs1="0"
		fi
		ladeleistung=$(( ladeleistung + ladeleistungs1 ))
		echo "$ladeleistung" > /var/www/html/openWB/ramdisk/llkombiniert
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
		echo $lp2phasen > /var/www/html/openWB/ramdisk/lp2phasen
	else
		echo "$ladeleistung" > /var/www/html/openWB/ramdisk/llkombiniert
		ladeleistunglp2=0
		soc1vorhanden=0
	fi

	#dritter ladepunkt
	if [[ $lastmanagements2 == "1" ]]; then
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: timeout 10 modules/$ladeleistungs2modul/main.sh"
		timeout 10 modules/$ladeleistungs2modul/main.sh || true
#########################################################################						
		llkwhs2=$(</var/www/html/openWB/ramdisk/llkwhs2)
		llkwhges=$(echo "$llkwhges + $llkwhs2" |bc)
		llalts2=$(cat /var/www/html/openWB/ramdisk/llsolls2)
		ladeleistungs2=$(cat /var/www/html/openWB/ramdisk/llaktuells2)
		ladeleistunglp3=$ladeleistungs2
		llas21=$(cat /var/www/html/openWB/ramdisk/llas21)
		llas22=$(cat /var/www/html/openWB/ramdisk/llas22)
		llas23=$(cat /var/www/html/openWB/ramdisk/llas23)
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
		ladestatuss2=$(</var/www/html/openWB/ramdisk/ladestatuss2)
		if ! [[ $ladeleistungs2 =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für ladeleistungs2: $ladeleistungs2"
		ladeleistungs2="0"
		fi
		ladeleistung=$(( ladeleistung + ladeleistungs2 ))
		echo "$ladeleistung" > /var/www/html/openWB/ramdisk/llkombiniert
	else
		echo "$ladeleistung" > /var/www/html/openWB/ramdisk/llkombiniert
		ladeleistungs2="0"
		ladeleistunglp3=0
	fi

  	#  lp3-lp8


	echo "$ladeleistung" > /var/www/html/openWB/ramdisk/llkombiniert
	echo $llkwhges > ramdisk/llkwhges

	#Schuko-Steckdose an openWB
	if [[ $standardSocketInstalled == "1" ]]; then

#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: timeout 10 modules/sdm120modbusSocket/main.sh"
		timeout 10 modules/sdm120modbusSocket/main.sh || true
#########################################################################						
		socketkwh=$(</var/www/html/openWB/ramdisk/socketkwh)
		socketp=$(cat /var/www/html/openWB/ramdisk/socketp)
		socketa=$(cat /var/www/html/openWB/ramdisk/socketa)
		socketa=$(echo $socketa | sed 's/\..*$//')
		socketv=$(cat /var/www/html/openWB/ramdisk/socketv)
		if ! [[ $socketa =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für socketa: $socketa"
			socketa="0"
		fi
	fi

	#Wattbezug
	if [[ $wattbezugmodul != "none" ]]; then
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: modules/$wattbezugmodul/main.sh"
		wattbezug=$(modules/$wattbezugmodul/main.sh || true)
#########################################################################						
		if ! [[ $wattbezug =~ $re ]] ; then
			openwbDebugLog "MAIN" 0 "ungültiger Wert für wattbezug: $wattbezug"
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
					glaettung=$(<ramdisk/glaettung$i)
					glaettungw=$(( glaettung + glaettungw))
				done
				glaettungfinal=$((glaettungw / ganzahl))
				echo $glaettungfinal > ramdisk/glattwattbezug
				wattbezug=$glaettungfinal
			fi
		fi
		#uberschuss zur berechnung
		uberschuss=$(printf "%.0f\n" $((-wattbezug)))
		if (( uberschuss > 0  )) ; then
		    openwbDebugLog "PV" 0 "1 :UEBERSCHUSS $uberschuss Watt EXPORT aus wattbezug "				
		else
		    openwbDebugLog "PV" 0 "1 :UEBERSCHUSS $uberschuss Watt IMPORT aus wattbezug "
        fi			 				
		if [[ $speichervorhanden == "1" ]]; then
			if [[ $speicherpveinbeziehen == "1" ]]; then
  			    openwbDebugLog "PV" 1 "Speicher vorhanden und speicherpveinbeziehen:$speicherpveinbeziehen"				
				if (( speicherleistung > 0 )); then    # es wird gerade der hausakku geladen
					if (( speichersoc > speichersocnurpv )); then  # der hausakku ist voll genug
						speicherww=$((speicherleistung + speicherwattnurpv))
						uberschuss=$((uberschuss + speicherww))          # stelle ladeleistung und erlaubte entladeleistung zur verfügung 
					    openwbDebugLog "PV" 0 "3a:UEBERSCHUSS $uberschuss  +  ($speicherleistung + $speicherwattnurpv) Hausspeicher voll Genug, stelle ladeleistung und erlaubte Entladeleistung zur verfügung "		
					else
						speicherww=$((speicherleistung - speichermaxwatt))
						uberschuss=$((uberschuss + speicherww))
					    openwbDebugLog "PV" 0 "3b:UEBERSCHUSS $uberschuss  +  ($speicherleistung - $speicherwattnurpv) Hausspeicher nicht voll Genug, reduziere nur auf min ladeleistung"		
					fi
				fi
			fi
		fi
		openwbDebugLog "PV" 0 "4 :UEBERSCHUSS $uberschuss now"		
		evua1=$(cat /var/www/html/openWB/ramdisk/bezuga1)
		evua2=$(cat /var/www/html/openWB/ramdisk/bezuga2)
		evua3=$(cat /var/www/html/openWB/ramdisk/bezuga3)
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
		echo $schieflast > /var/www/html/openWB/ramdisk/schieflast
	else
	    #  wattbezugmodul=none
		uberschuss=$((-pvwatt - hausbezugnone - ladeleistung))
		echo $((-uberschuss)) > /var/www/html/openWB/ramdisk/wattbezug
		wattbezugint=$((-uberschuss))
		wattbezug=$wattbezugint
	fi

	# Abschaltbare Smartdevices zum Ueberschuss rechnen
	## NC echo $uberschuss > /var/www/html/openWB/ramdisk/ueberschuss_org
	wattabs=$(cat /var/www/html/openWB/ramdisk/devicetotal_watt)
	if (( wattabs>0 )) ; then
	   uberschuss=$((uberschuss + wattabs))
	   ## NC echo $uberschuss > /var/www/html/openWB/ramdisk/ueberschuss_mitsmart
	   openwbDebugLog "PV" 0 "5 :UEBERSCHUSS $uberschuss  nach addierung der abschaltbaren smartdev"		
    fi
	
	#Soc ermitteln
	if [[ "$socmodul" != "none" ]]; then
		socvorhanden=1
		echo 1 > /var/www/html/openWB/ramdisk/socvorhanden
		if (( stopsocnotpluggedlp1 == 1 )); then
			soctimer=$(</var/www/html/openWB/ramdisk/soctimer)
			# if (( plugstat == 1 )); then
			if [[ "$plugstat" == "1" || "$soctimer" == "20005" ]]; then # force soc update button sends 20005
#########################################################################						
				openwbD	ebugLog "MAIN" 0 "EXEC: modules/$socmodul/main.sh &"
				"modules/$socmodul/main.sh" &
#########################################################################					
				soc=$(</var/www/html/openWB/ramdisk/soc)
				tmpsoc=$(</var/www/html/openWB/ramdisk/tmpsoc)
				if ! [[ $soc =~ $re ]] ; then
					openwbDebugLog "MAIN" 0 "ungültiger Wert für soc: $soc"
					soc=$tmpsoc
				else
					echo "$soc" > /var/www/html/openWB/ramdisk/tmpsoc
				fi
			else
				echo 600 > /var/www/html/openWB/ramdisk/soctimer
				soc=$(</var/www/html/openWB/ramdisk/soc)
			fi
		else
#########################################################################						
			openwbDebugLog "MAIN" 0 "EXEC: modules/$socmodul/main.sh &"
			"modules/$socmodul/main.sh" &
#########################################################################						
			soc=$(</var/www/html/openWB/ramdisk/soc)
			tmpsoc=$(</var/www/html/openWB/ramdisk/tmpsoc)
			if ! [[ $soc =~ $re ]] ; then
				openwbDebugLog "MAIN" 0 "ungültiger Wert für soc: $soc"
				soc=$tmpsoc
			else
				echo "$soc" > /var/www/html/openWB/ramdisk/tmpsoc
			fi
		fi
	else
		socvorhanden=0
		echo 0 > /var/www/html/openWB/ramdisk/socvorhanden
		soc=0
	fi

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
	if [ -s "ramdisk/verbraucher3_watt" ]; then verb3_w=$(<ramdisk/verbraucher3_watt); else verb3_w=0; fi
	verb3_w=$(printf "%.0f\n" $verb3_w)

	#hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shd1_w - shd2_w - shd3_w - shd4_w - shd5_w - shd6_w - shd7_w - shd8_w - shd9_w - verb1_w - verb2_w - verb3_w))
	hausverbrauch=$((wattbezugint - pvwatt - ladeleistung - speicherleistung - shdall_w - verb1_w - verb2_w - verb3_w))

#	echo "$hausverbrauch = $wattbezugint - $pvwatt - $ladeleistung - $speicherleistung - $shd1_w - $shd2_w - $shd3_w - $shd4_w - $shd5_w - $shd6_w - $shd7_w - $shd8_w - $shd9_w - $verb1_w - $verb2_w - $verb3_w" >>/var/www/html/openWB/ramdisk/openWB.log
	if (( hausverbrauch < 0 )); then
		if [ -f /var/www/html/openWB/ramdisk/hausverbrauch.invalid ]; then
			hausverbrauchinvalid=$(</var/www/html/openWB/ramdisk/hausverbrauch.invalid)
			let hausverbrauchinvalid+=1
		else
			hausverbrauchinvalid=1
		fi
		echo "$hausverbrauchinvalid" > /var/www/html/openWB/ramdisk/hausverbrauch.invalid
		if (( hausverbrauchinvalid < 3 )); then
			hausverbrauch=$(</var/www/html/openWB/ramdisk/hausverbrauch)
		else
			hausverbrauch=0
		fi
	else
		echo "0" > /var/www/html/openWB/ramdisk/hausverbrauch.invalid
	fi
	echo $hausverbrauch > /var/www/html/openWB/ramdisk/hausverbrauch
	fronius_sm_bezug_meterlocation=$(</var/www/html/openWB/ramdisk/fronius_sm_bezug_meterlocation)


	usesimbezug=$( (test ! -r modules/$wattbezugmodul/usesim && echo "0") || cat  modules/$wattbezugmodul/usesim   )
	if [[ $usesimbezug == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimbezug counter simulation"
		ra='^-?[0-9]+$'
		watt2=$(</var/www/html/openWB/ramdisk/wattbezug)
		if [[ -e /var/www/html/openWB/ramdisk/bezugwatt0pos ]]; then
			importtemp=$(</var/www/html/openWB/ramdisk/bezugwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/evu/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/evu/WHImported_temp from mosquito $importtemp"
			echo $importtemp > /var/www/html/openWB/ramdisk/bezugwatt0pos
		fi
		if [[ -e /var/www/html/openWB/ramdisk/bezugwatt0neg ]]; then
			exporttemp=$(</var/www/html/openWB/ramdisk/bezugwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/evu/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/evu/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > /var/www/html/openWB/ramdisk/bezugwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt2 bezug bezugkwh einspeisungkwh
#########################################################################						
		importtemp1=$(</var/www/html/openWB/ramdisk/bezugwatt0pos)
		exporttemp1=$(</var/www/html/openWB/ramdisk/bezugwatt0neg)
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
		watt3=$(</var/www/html/openWB/ramdisk/pv1watt)
		if [[ -e /var/www/html/openWB/ramdisk/pvwatt0pos ]]; then
			importtemp=$(</var/www/html/openWB/ramdisk/pvwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/pv/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WHImported_temp from mosquito $importtemp"
			echo $importtemp > /var/www/html/openWB/ramdisk/pvwatt0pos
		fi
		if [[ -e /var/www/html/openWB/ramdisk/pvwatt0neg ]]; then
			exporttemp=$(</var/www/html/openWB/ramdisk/pvwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/pv/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > /var/www/html/openWB/ramdisk/pvwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt3 pv pvposkwh pvkwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt3 pv pvposkwh pvkwh
#########################################################################						
		importtemp1=$(</var/www/html/openWB/ramdisk/pvwatt0pos)
		exporttemp1=$(</var/www/html/openWB/ramdisk/pvwatt0neg)
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
		watt4=$(</var/www/html/openWB/ramdisk/pv2watt)
		if [[ -e /var/www/html/openWB/ramdisk/pv2watt0pos ]]; then
			importtemp=$(</var/www/html/openWB/ramdisk/pv2watt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/pv/WH2Imported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WH2Imported_temp from mosquito $importtemp"
			echo $importtemp > /var/www/html/openWB/ramdisk/pv2watt0pos
		fi
		if [[ -e /var/www/html/openWB/ramdisk/pv2watt0neg ]]; then
			exporttemp=$(</var/www/html/openWB/ramdisk/pv2watt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/pv/WH2Export_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/pv/WH2Export_temp from mosquito $exporttemp"
			echo $exporttemp > /var/www/html/openWB/ramdisk/pv2watt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt4 pv2 pv2poskwh pv2kwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt4 pv2 pv2poskwh pv2kwh
#########################################################################						
		importtemp1=$(</var/www/html/openWB/ramdisk/pv2watt0pos)
		exporttemp1=$(</var/www/html/openWB/ramdisk/pv2watt0neg)
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
		pvkwh=$(</var/www/html/openWB/ramdisk/pvkwh)
		pv2kwh=$(</var/www/html/openWB/ramdisk/pv2kwh)
		pvallwh=$(echo "$pvkwh + $pv2kwh" |bc)
		echo $pvallwh > /var/www/html/openWB/ramdisk/pvallwh
	fi

	usesimbat=$( (test ! -r modules/$speichermodul/usesim && echo "0") || cat  modules/$speichermodul/usesim   )
	if [[ $usesimbat == "1" ]]; then
		openwbDebugLog "MAIN" 0 "#### Use Sim Speicher counter simulation"
		ra='^-?[0-9]+$'
		watt2=$(</var/www/html/openWB/ramdisk/speicherleistung)
		if [[ -e /var/www/html/openWB/ramdisk/speicherwatt0pos ]]; then
			importtemp=$(</var/www/html/openWB/ramdisk/speicherwatt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/housebattery/WHImported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/housebattery/WHImported_temp from mosquito $importtemp"
			echo $importtemp > /var/www/html/openWB/ramdisk/speicherwatt0pos
		fi
		if [[ -e /var/www/html/openWB/ramdisk/speicherwatt0neg ]]; then
			exporttemp=$(</var/www/html/openWB/ramdisk/speicherwatt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/housebattery/WHExport_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/housebattery/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > /var/www/html/openWB/ramdisk/speicherwatt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt2 speicher speicherikwh speicherekwh"
		sudo python /var/www/html/openWB/runs/simcount.py $watt2 speicher speicherikwh speicherekwh
#########################################################################						
		importtemp1=$(</var/www/html/openWB/ramdisk/speicherwatt0pos)
		exporttemp1=$(</var/www/html/openWB/ramdisk/speicherwatt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/housebattery/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/housebattery/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim speicher end
	fi

	if [[ $verbraucher1_aktiv == "1" ]] && [[ $verbraucher1_typ == "shelly" ]]; then
		openwbDebugLog "MAIN" 0 "#### UseSimVerbraucher counter simulation"
		ra='^-?[0-9]+$'
		watt3=$(</var/www/html/openWB/ramdisk/verbraucher1_watt)
		if [[ -e /var/www/html/openWB/ramdisk/verbraucher1watt0pos ]]; then
			importtemp=$(</var/www/html/openWB/ramdisk/verbraucher1watt0pos)
		else
			importtemp=$(timeout 4 mosquitto_sub -t openWB/Verbraucher/1/WH1Imported_temp)
			if ! [[ $importtemp =~ $ra ]] ; then
				importtemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/Verbraucher/1/WHImported_temp from mosquito $importtemp"
			echo $importtemp > /var/www/html/openWB/ramdisk/verbraucher1watt0pos
		fi
		if [[ -e /var/www/html/openWB/ramdisk/verbraucher1watt0neg ]]; then
			exporttemp=$(</var/www/html/openWB/ramdisk/verbraucher1watt0neg)
		else
			exporttemp=$(timeout 4 mosquitto_sub -t openWB/verbraucher/1/WH1Export_temp)
			if ! [[ $exporttemp =~ $ra ]] ; then
				exporttemp="0"
			fi
			openwbDebugLog "MAIN" 0 "loadvars read openWB/verbraucher/1/WHExport_temp from mosquito $exporttemp"
			echo $exporttemp > /var/www/html/openWB/ramdisk/verbraucher1watt0neg
		fi
#########################################################################						
		openwbDebugLog "MAIN" 0 "EXEC: sudo python /var/www/html/openWB/runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe"
		sudo python /var/www/html/openWB/runs/simcount.py $watt3 verbraucher1 verbraucher1_wh verbraucher1_whe
#########################################################################						
		importtemp1=$(</var/www/html/openWB/ramdisk/verbraucher1watt0pos)
		exporttemp1=$(</var/www/html/openWB/ramdisk/verbraucher1watt0neg)
		if [[ $importtemp !=  $importtemp1 ]]; then
			mosquitto_pub -t openWB/verbraucher/1/WHImported_temp -r -m "$importtemp1"
		fi
		if [[ $exporttemp !=  $exporttemp1 ]]; then
			mosquitto_pub -t openWB/verbraucher/1/WHExport_temp -r -m "$exporttemp1"
		fi
		# sim verbraucher end
	fi

	#Uhrzeit
	date=$(date)
	H=$(date +%H)
	if [[ $debug == "1" ]]; then
		echo "$(tail -1500 /var/www/html/openWB/ramdisk/openWB.log)" > /var/www/html/openWB/ramdisk/openWB.log
	fi
	if [[ $speichermodul != "none" ]] ; then
		openwbDebugLog "MAIN" 1 "speicherleistung $speicherleistung speichersoc $speichersoc"
	fi
	if (( $etprovideraktiv == 1 )) ; then
		openwbDebugLog "MAIN" 1 "etproviderprice $etproviderprice etprovidermaxprice $etprovidermaxprice"
	fi
	openwbDebugLog "MAIN" 1 "pv1watt $pv1watt pv2watt $pv2watt pvwatt $pvwatt ladeleistung $ladeleistung llalt $llalt nachtladen $nachtladen nachtladen $nachtladens1 minimalA $minimalstromstaerke maximalA $maximalstromstaerke"
	openwbDebugLog "MAIN" 1 "$(echo -e lla1 "$lla1"'\t'llv1 "$llv1"'\t'llas11 "$llas11" llas21 "$llas21" mindestuberschuss "$mindestuberschuss" abschaltuberschuss "$abschaltuberschuss" lademodus "$lademodus")"
	openwbDebugLog "MAIN" 1 "$(echo -e lla2 "$lla2"'\t'llv2 "$llv2"'\t'llas12 "$llas12" llas22 "$llas22" sofortll "$sofortll" hausverbrauch "$hausverbrauch"  wattbezug "$wattbezug" uberschuss "$uberschuss")"
	openwbDebugLog "MAIN" 1 "$(echo -e lla3 "$lla3"'\t'llv3 "$llv3"'\t'llas13 "$llas13" llas23 "$llas23" soclp1 $soc soclp2 $soc1)"
	openwbDebugLog "MAIN" 1 "EVU 1:${evuv1}V/${evua1}A 2: ${evuv2}V/${evua2}A 3: ${evuv3}V/${evua3}A"
	openwbDebugLog "MAIN" 1 "$(echo -e lp1enabled "$lp1enabled"'\t'lp2enabled "$lp2enabled"'\t'lp3enabled "$lp3enabled")"
	openwbDebugLog "MAIN" 1 "$(echo -e plugstatlp1 "$plugstat"'\t'plugstatlp2 "$plugstatlp2"'\t'plugstatlp3 "$plugstatlp3")"
	openwbDebugLog "MAIN" 1 "$(echo -e chargestatlp1 "$chargestat"'\t'chargestatlp2 "$chargestatlp2"'\t'chargestatlp3 "$chargestatlp3")"
	if [[ $standardSocketInstalled == "1" ]]; then
		openwbDebugLog "MAIN" 1 "socketa $socketa socketp $socketp socketkwh $socketkwh socketv $socketv"
	fi

	tempPubList="openWB/system/Uptime=$(uptime)"

	if [[ "$opvwatt" != "$pvwatt" ]]; then
		tempPubList="${tempPubList}\nopenWB/pv/W=${pvwatt}"
		echo $pvwatt > ramdisk/mqttpvwatt
	fi
	if [[ "$owattbezug" != "$wattbezug" ]]; then
		tempPubList="${tempPubList}\nopenWB/evu/W=${wattbezug}"
		echo $wattbezug > ramdisk/mqttwattbezug
	fi
	if [[ "$ollaktuell" != "$ladeleistunglp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/W=${ladeleistunglp1}"
		echo $ladeleistunglp1 > ramdisk/mqttladeleistunglp1
	fi
	if [[ "$oladestatus" != "$ladestatus" ]]; then
		tempPubList="${tempPubList}\nopenWB/ChargeStatus=${ladelestatus}"
		echo $ladestatus > ramdisk/mqttlastladestatus
	fi
	# TODO: wann wird der Lademodus geändert?
	if [[ "$olademodus" != "$lademodus" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/ChargeMode=${lademodus}"
		echo $lademodus > ramdisk/mqttlastlademodus
		
	fi

	
		if { (( lademodus == 0 )) && (( nlakt_sofort  == 1 )); } \
		|| { (( lademodus == 1 )) && (( nlakt_minpv   == 1 )); } \
 		|| { (( lademodus == 2 )) && (( nlakt_nurpv   == 1 )); } \
 		|| { (( lademodus == 4 )) && (( nlakt_standby == 1 )); } then
			if (( nachtladen > 0 )) ; then 
			     openwbDebugLog "MAIN" 0 "################# lademodes:$lademodus openWB/lp/1/boolChargeAtNight=1 1"
		         tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=1"
			else	 
				 openwbDebugLog "MAIN" 0 "################## lademodes:$lademodus openWB/lp/1/boolChargeAtNight=0 1"
		         tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=0"
			fi
		else
				 openwbDebugLog "MAIN" 0 "################ lademodes:$lademodus openWB/lp/1/boolChargeAtNight=0 2"
		         tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=0"
	fi
	if [[ "$ohausverbrauch" != "$hausverbrauch" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/WHouseConsumption=${hausverbrauch}"
		echo $hausverbrauch > ramdisk/mqtthausverbrauch
	fi
	if [[ "$ollaktuells1" != "$ladeleistungs1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/W=${ladeleistungs1}"
		echo $ladeleistungs1 > ramdisk/mqttladeleistungs1
	fi
	if [[ "$ollaktuells2" != "$ladeleistungs2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/W=${ladeleistungs2}"
		echo $ladeleistungs2 > ramdisk/mqttladeleistungs2
	fi
	if [[ "$ollkombiniert" != "$ladeleistung" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/WAllChargePoints=${ladeleistung}"
		echo $ladeleistung > ramdisk/mqttladeleistung
	fi
	if [[ "$ospeicherleistung" != "$speicherleistung" ]]; then
		tempPubList="${tempPubList}\nopenWB/housebattery/W=${speicherleistung}"
		echo $speicherleistung > ramdisk/mqttspeicherleistung
	fi
	if [[ "$ospeichersoc" != "$speichersoc" ]]; then
		tempPubList="${tempPubList}\nopenWB/housebattery/%Soc=${speichersoc}"
		echo $speichersoc > ramdisk/mqttspeichersoc
	fi
	if [[ "$osoc" != "$soc" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/%Soc=${soc}"
		echo $soc > ramdisk/mqttsoc
	fi
	if [[ "$osoc1" != "$soc1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/%Soc=${soc1}"
		echo $soc1 > ramdisk/mqttsoc1
	fi
	if [[ "$ostopchargeafterdisclp1" != "$stopchargeafterdisclp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/1/stopchargeafterdisc=${stopchargeafterdisclp1}"
		echo $stopchargeafterdisclp1 > ramdisk/mqttstopchargeafterdisclp1
	fi
	if [[ "$ostopchargeafterdisclp2" != "$stopchargeafterdisclp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/2/stopchargeafterdisc=${stopchargeafterdisclp2}"
		echo $stopchargeafterdisclp2 > ramdisk/mqttstopchargeafterdisclp2
	fi
	if [[ "$ostopchargeafterdisclp3" != "$stopchargeafterdisclp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/lp/3/stopchargeafterdisc=${stopchargeafterdisclp3}"
		echo $stopchargeafterdisclp3 > ramdisk/mqttstopchargeafterdisclp3
	fi

	# lp4-lp8

	if [[ $rfidakt == "1" ]]; then
		rfid
	fi

	csvfile="/var/www/html/openWB/web/logging/data/daily/$(date +%Y%m%d).csv"
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

	lastregelungaktiv=$(<ramdisk/lastregelungaktiv)
	hook1aktiv=$(<ramdisk/hook1akt)
	hook2aktiv=$(<ramdisk/hook2akt)
	hook3aktiv=$(<ramdisk/hook3akt)
	if [[ "$odailychargelp1" != "$dailychargelp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/kWhDailyCharged=${dailychargelp1}"
		echo $dailychargelp1 > ramdisk/mqttdailychargelp1
	fi
	if [[ "$odailychargelp2" != "$dailychargelp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/kWhDailyCharged=${dailychargelp2}"
		echo $dailychargelp2 > ramdisk/mqttdailychargelp2
	fi
	if [[ "$odailychargelp3" != "$dailychargelp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/kWhDailyCharged=${dailychargelp3}"
		echo $dailychargelp3 > ramdisk/mqttdailychargelp3
	fi
	if [[ "$orestzeitlp1" != "$restzeitlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/TimeRemaining=${restzeitlp1}"
		echo $restzeitlp1 > ramdisk/mqttrestzeitlp1
	fi
	if [[ "$orestzeitlp2" != "$restzeitlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/TimeRemaining=${restzeitlp2}"
		echo $restzeitlp2 > ramdisk/mqttrestzeitlp2
	fi
	if [[ "$orestzeitlp3" != "$restzeitlp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/TimeRemaining=${restzeitlp3}"
		echo $restzeitlp3 > ramdisk/mqttrestzeitlp3
	fi
	if [[ "$ogelrlp1" != "$gelrlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/kmCharged=${gelrlp1}"
		echo $gelrlp1 > ramdisk/mqttgelrlp1
	fi
	if [[ "$ogelrlp2" != "$gelrlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/kmCharged=${gelrlp2}"
		echo $gelrlp2 > ramdisk/mqttgelrlp2
	fi
	if [[ "$ogelrlp3" != "$gelrlp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/kmCharged=${gelrlp3}"
		echo $gelrlp3 > ramdisk/mqttgelrlp3
	fi
	ohook1_aktiv=$(<ramdisk/mqtthook1_aktiv)
	if [[ "$ohook1_aktiv" != "$hook1_aktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/hook/1/boolHookConfigured=${hook1_aktiv}"
		echo $hook1_aktiv > ramdisk/mqtthook1_aktiv
	fi
	ohook2_aktiv=$(<ramdisk/mqtthook2_aktiv)
	if [[ "$ohook2_aktiv" != "$hook2_aktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/hook/2/boolHookConfigured=${hook2_aktiv}"
		echo $hook2_aktiv > ramdisk/mqtthook2_aktiv
	fi
	ohook3_aktiv=$(<ramdisk/mqtthook3_aktiv)
	if [[ "$ohook3_aktiv" != "$hook3_aktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/hook/3/boolHookConfigured=${hook3_aktiv}"
		echo $hook3_aktiv > ramdisk/mqtthook3_aktiv
	fi

	if (( ohook1aktiv != hook1aktiv )); then
		tempPubList="${tempPubList}\nopenWB/boolHook1Active=${hook1aktiv}"
		echo $hook1aktiv > ramdisk/mqtthook1aktiv
	fi
	if (( ohook2aktiv != hook2aktiv )); then
		tempPubList="${tempPubList}\nopenWB/boolHook2Active=${hook2aktiv}"
		echo $hook2aktiv > ramdisk/mqtthook2aktiv
	fi
	if (( ohook3aktiv != hook3aktiv )); then
		tempPubList="${tempPubList}\nopenWB/boolHook3Active=${hook3aktiv}"
		echo $hook3aktiv > ramdisk/mqtthook3aktiv
	fi
	oversion=$(<ramdisk/mqttversion)
	if [[ $oversion != $version ]]; then
		tempPubList="${tempPubList}\nopenWB/system/Version=${version}"
		echo -n "$version" > ramdisk/mqttversion
	fi

	ocp1config=$(<ramdisk/mqttCp1Configured)
	if [[ "$ocp1config" != "1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolChargePointConfigured=1"
		echo 1 > ramdisk/mqttCp1Configured
	fi

	olastmanagement=$(<ramdisk/mqttlastmanagement)
	if [[ "$olastmanagement" != "$lastmanagement" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolChargePointConfigured=${lastmanagement}"
		echo $lastmanagement > ramdisk/mqttlastmanagement
	fi
	osoc1vorhanden=$(<ramdisk/mqttsoc1vorhanden)
	if [[ "$osoc1vorhanden" != "$soc1vorhanden" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolSocConfigured=${soc1vorhanden}"
		echo $soc1vorhanden > ramdisk/mqttsoc1vorhanden
	fi
	osocvorhanden=$(<ramdisk/mqttsocvorhanden)
	if [[ "$osocvorhanden" != "$socvorhanden" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolSocConfigured=${socvorhanden}"
		echo $socvorhanden > ramdisk/mqttsocvorhanden
	fi

	olastmanagements2=$(<ramdisk/mqttlastmanagements2)
	if [[ "$olastmanagements2" != "$lastmanagements2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/boolChargePointConfigured=${lastmanagements2}"
		echo $lastmanagements2 > ramdisk/mqttlastmanagements2
	fi

	# lp4-lp8

	olademstat=$(<ramdisk/mqttlademstat)
	if [[ "$olademstat" != "$lademstat" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolDirectModeChargekWh=${lademstat}"
		echo $lademstat > ramdisk/mqttlademstat
	fi
	olademstats1=$(<ramdisk/mqttlademstats1)
	if [[ "$olademstats1" != "$lademstats1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolDirectModeChargekWh=${lademstats1}"
		echo $lademstats1 > ramdisk/mqttlademstats1
	fi
	olademstats2=$(<ramdisk/mqttlademstats2)
	if [[ "$olademstats2" != "$lademstats2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/boolDirectModeChargekWh=${lademstats2}"
		echo $lademstats2 > ramdisk/mqttlademstats2
	fi

	# lp4-lp8

	osofortsocstatlp1=$(<ramdisk/mqttsofortsocstatlp1)
	if [[ "$osofortsocstatlp1" != "$sofortsocstatlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolDirectChargeModeSoc=${sofortsocstatlp1}"
		echo $sofortsocstatlp1 > ramdisk/mqttsofortsocstatlp1
	fi

	osofortsocstatlp2=$(<ramdisk/mqttsofortsocstatlp2)
	if [[ "$osofortsocstatlp2" != "$sofortsocstatlp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolDirectChargeModeSoc=${sofortsocstatlp2}"
		echo $sofortsocstatlp2 > ramdisk/mqttsofortsocstatlp2
	fi
	osofortsocstatlp3=$(<ramdisk/mqttsofortsocstatlp3)
	if (( osofortsocstatlp3 != sofortsocstatlp3 )); then
		tempPubList="${tempPubList}\nopenWB/boolsofortlademodussoclp3=${sofortsocstatlp3}"
		echo $sofortsocstatlp3 > ramdisk/mqttsofortsocstatlp3
	fi
	osofortsoclp3=$(<ramdisk/mqttsofortsoclp3)
	if (( osofortsoclp3 != sofortsoclp3 )); then
		tempPubList="${tempPubList}\nopenWB/percentsofortlademodussoclp3=${sofortsoclp3}"
		echo $sofortsoclp3 > ramdisk/mqttsofortsoclp3
	fi
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
	olp1name=$(<ramdisk/mqttlp1name)
	if [[ "$olp1name" != "$lp1name" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/strChargePointName=${lp1name}"
		echo $lp1name > ramdisk/mqttlp1name
	fi
	olp2name=$(<ramdisk/mqttlp2name)
	if [[ "$olp2name" != "$lp2name" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/strChargePointName=${lp2name}"
		echo $lp2name > ramdisk/mqttlp2name
	fi
	olp3name=$(<ramdisk/mqttlp3name)
	if [[ "$olp3name" != "$lp3name" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/strChargePointName=${lp3name}"
		echo $lp3name > ramdisk/mqttlp3name
	fi
	
	# lp4-lp8
	
	ozielladenaktivlp1=$(<ramdisk/mqttzielladenaktivlp1)
	if [[ "$ozielladenaktivlp1" != "$zielladenaktivlp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolFinishAtTimeChargeActive=${zielladenaktivlp1}"
		echo $zielladenaktivlp1 > ramdisk/mqttzielladenaktivlp1
	fi
	onachtladen=$(<ramdisk/mqttnachtladen)
	if [[ "$onachtladen" != "$nachtladen" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/boolChargeAtNight=${nachtladen}"
		echo $nachtladen > ramdisk/mqttnachtladen
	fi
	onachtladens1=$(<ramdisk/mqttnachtladens1)
	if [[ "$onachtladens1" != "$nachtladens1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/boolChargeAtNight=${nachtladens1}"
		echo $nachtladens1 > ramdisk/mqttnachtladens1
	fi
	onlakt_sofort=$(<ramdisk/mqttnlakt_sofort)
	if [[ "$onlakt_sofort" != "$nlakt_sofort" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolChargeAtNight_direct=${nlakt_sofort}"
		echo $nlakt_sofort > ramdisk/mqttnlakt_sofort
	fi
	onlakt_nurpv=$(<ramdisk/mqttnlakt_nurpv)
	if [[ "$onlakt_nurpv" != "$nlakt_nurpv" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolChargeAtNight_nurpv=${nlakt_nurpv}"
		echo $nlakt_nurpv > ramdisk/mqttnlakt_nurpv
	fi
	onlakt_minpv=$(<ramdisk/mqttnlakt_minpv)
	if [[ "$onlakt_minpv" != "$nlakt_minpv" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolChargeAtNight_minpv=${nlakt_minpv}"
		echo $nlakt_minpv > ramdisk/mqttnlakt_minpv
	fi

	onlakt_standby=$(<ramdisk/mqttnlakt_standby)
	if [[ "$onlakt_standby" != "$nlakt_standby" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolChargeAtNight_standby=${nlakt_standby}"
		echo $nlakt_standby > ramdisk/mqttnlakt_standby
	fi
	ohausverbrauchstat=$(<ramdisk/mqtthausverbrauchstat)
	if [[ "$ohausverbrauchstat" != "$hausverbrauchstat" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolDisplayHouseConsumption=${hausverbrauchstat}"
		echo $hausverbrauchstat > ramdisk/mqtthausverbrauchstat
	fi
	oheutegeladen=$(<ramdisk/mqttheutegeladen)
	if [[ "$oheutegeladen" != "$heutegeladen" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolDisplayDailyCharged=${heutegeladen}"
		echo $heutegeladen > ramdisk/mqttheutegeladen
	fi
	oevuglaettungakt=$(<ramdisk/mqttevuglaettungakt)
	if [[ "$oevuglaettungakt" != "$evuglaettungakt" ]]; then
		tempPubList="${tempPubList}\nopenWB/boolEvuSmoothedActive=${evuglaettungakt}"
		echo $evuglaettungakt > ramdisk/mqttevuglaettungakt
	fi
	onurpv70dynact=$(<ramdisk/mqttnurpv70dynact)
	if [[ "$onurpv70dynact" != "$nurpv70dynact" ]]; then
		tempPubList="${tempPubList}\nopenWB/pv/bool70PVDynActive=${nurpv70dynact}"
		tempPubList="${tempPubList}\nopenWB/config/get/pv/nurpv70dynact=${nurpv70dynact}"
		echo $nurpv70dynact > ramdisk/mqttnurpv70dynact
	fi
	onurpv70dynw=$(<ramdisk/mqttnurpv70dynw)
	if [[ "$onurpv70dynw" != "$nurpv70dynw" ]]; then
		tempPubList="${tempPubList}\nopenWB/pv/W70PVDyn=${nurpv70dynw}"
		tempPubList="${tempPubList}\nopenWB/config/get/pv/nurpv70dynw=${nurpv70dynw}"
		echo $nurpv70dynw > ramdisk/mqttnurpv70dynw
	fi

	overbraucher1_name=$(<ramdisk/mqttverbraucher1_name)
	if [[ "$overbraucher1_name" != "$verbraucher1_name" ]]; then
		tempPubList="${tempPubList}\nopenWB/Verbraucher/1/Name=${verbraucher1_name}"
		echo $verbraucher1_name > ramdisk/mqttverbraucher1_name
	fi
	overbraucher1_aktiv=$(<ramdisk/mqttverbraucher1_aktiv)
	if [[ "$overbraucher1_aktiv" != "$verbraucher1_aktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/Verbraucher/1/Configured=${verbraucher1_aktiv}"
		echo $verbraucher1_aktiv > ramdisk/mqttverbraucher1_aktiv
	fi
	overbraucher2_aktiv=$(<ramdisk/mqttverbraucher2_aktiv)
	if [[ "$overbraucher2_aktiv" != "$verbraucher2_aktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/Verbraucher/2/Configured=${verbraucher2_aktiv}"
		echo $verbraucher2_aktiv > ramdisk/mqttverbraucher2_aktiv
	fi

	overbraucher2_name=$(<ramdisk/mqttverbraucher2_name)
	if [[ "$overbraucher2_name" != "$verbraucher2_name" ]]; then
		tempPubList="${tempPubList}\nopenWB/Verbraucher/2/Name=${verbraucher2_name}"
		echo $verbraucher2_name > ramdisk/mqttverbraucher2_name
	fi

	ospeicherpveinbeziehen=$(<ramdisk/mqttspeicherpveinbeziehen)
	if [[ "$ospeicherpveinbeziehen" != "$speicherpveinbeziehen" ]]; then
		tempPubList="${tempPubList}\nopenWB/config/get/pv/priorityModeEVBattery=${speicherpveinbeziehen}"
		echo $speicherpveinbeziehen > ramdisk/mqttspeicherpveinbeziehen
	fi
	oetprovideraktiv=$(<ramdisk/mqttetprovideraktiv)
	if [[ "$oetprovideraktiv" != "$etprovideraktiv" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/awattar/boolAwattarEnabled=${etprovideraktiv}"
		echo $etprovideraktiv > ramdisk/mqttetprovideraktiv
	fi
	oetprovider=$(<ramdisk/mqttetprovider)
	if [[ "$oetprovider" != "$etprovider" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/ETProvider/modulePath=${etprovider}"
		echo $etprovider > ramdisk/mqttetprovider
	fi
	oetproviderprice=$(<ramdisk/mqttetproviderprice)
	etproviderprice=$(<ramdisk/etproviderprice)
	if [[ "$oetproviderprice" != "$etproviderprice" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/awattar/ActualPriceForCharging=${etproviderprice}"
		echo $etproviderprice > ramdisk/mqttetproviderprice
	fi
	oetprovidermaxprice=$(<ramdisk/mqttetprovidermaxprice)
	etprovidermaxprice=$(<ramdisk/etprovidermaxprice)
	if [[ "$oetprovidermaxprice" != "$etprovidermaxprice" ]]; then
		tempPubList="${tempPubList}\nopenWB/global/awattar/MaxPriceForCharging=${etprovidermaxprice}"
		echo $etprovidermaxprice > ramdisk/mqttetprovidermaxprice
	fi
	odurchslp1=$(<ramdisk/mqttdurchslp1)
	if [[ "$odurchslp1" != "$durchslp1" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/1/energyConsumptionPer100km=${durchslp1}"
		echo $durchslp1 > ramdisk/mqttdurchslp1
	fi
	odurchslp2=$(<ramdisk/mqttdurchslp2)
	if [[ "$odurchslp2" != "$durchslp2" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/2/energyConsumptionPer100km=${durchslp2}"
		echo $durchslp2 > ramdisk/mqttdurchslp2
	fi
	odurchslp3=$(<ramdisk/mqttdurchslp3)
	if [[ "$odurchslp3" != "$durchslp3" ]]; then
		tempPubList="${tempPubList}\nopenWB/lp/3/energyConsumptionPer100km=${durchslp3}"
		echo $durchslp3 > ramdisk/mqttdurchslp3
	fi
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

	arandomSleep=$(<ramdisk/randomSleepValue)
	orandomSleepValue=$(<ramdisk/mqttRandomSleepValue)
	if [[ "$orandomSleepValue" != "$arandomSleep" ]]; then
		tempPubList="${tempPubList}\nopenWB/system/randomSleep=${arandomSleep}"
		echo $arandomSleep > ramdisk/mqttRandomSleepValue
	fi

	declare -A mqttconfvar
	mqttconfvar["config/get/pv/minFeedinPowerBeforeStart"]=mindestuberschuss
	mqttconfvar["config/get/pv/maxPowerConsumptionBeforeStop"]=abschaltuberschuss
	mqttconfvar["config/get/pv/stopDelay"]=abschaltverzoegerung
	mqttconfvar["config/get/pv/startDelay"]=einschaltverzoegerung
	mqttconfvar["config/get/pv/minCurrentMinPv"]=minimalampv
	mqttconfvar["config/get/pv/lp/1/minCurrent"]=minimalapv
	mqttconfvar["config/get/pv/lp/2/minCurrent"]=minimalalp2pv
	mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeTo"]=minnurpvsoclp1
	mqttconfvar["config/get/pv/lp/1/maxSocToChargeTo"]=maxnurpvsoclp1
	mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeToCurrent"]=minnurpvsocll
	mqttconfvar["config/get/pv/chargeSubmode"]=pvbezugeinspeisung
	mqttconfvar["config/get/pv/regulationPoint"]=offsetpv
	mqttconfvar["config/get/pv/boolShowPriorityIconInTheme"]=speicherpvui
	mqttconfvar["config/get/pv/minBatteryChargePowerAtEvPriority"]=speichermaxwatt
	mqttconfvar["config/get/pv/minBatteryDischargeSocAtBattPriority"]=speichersocnurpv
	mqttconfvar["config/get/pv/batteryDischargePowerAtBattPriority"]=speicherwattnurpv
	mqttconfvar["config/get/pv/socStartChargeAtMinPv"]=speichersocminpv
	mqttconfvar["config/get/pv/socStopChargeAtMinPv"]=speichersochystminpv
	mqttconfvar["config/get/pv/boolAdaptiveCharging"]=adaptpv
	mqttconfvar["config/get/pv/adaptiveChargingFactor"]=adaptfaktor
	mqttconfvar["config/get/pv/nurpv70dynact"]=nurpv70dynact
	mqttconfvar["config/get/pv/nurpv70dynw"]=nurpv70dynw
	mqttconfvar["config/get/global/maxEVSECurrentAllowed"]=maximalstromstaerke
	mqttconfvar["config/get/global/minEVSECurrentAllowed"]=minimalstromstaerke
	mqttconfvar["config/get/global/dataProtectionAcknoledged"]=datenschutzack
	mqttconfvar["config/get/u1p3p/sofortPhases"]=u1p3psofort
	mqttconfvar["config/get/u1p3p/standbyPhases"]=u1p3pstandby
	mqttconfvar["config/get/u1p3p/nurpvPhases"]=u1p3pnurpv
	mqttconfvar["config/get/u1p3p/minundpvPhases"]=u1p3pminundpv
	mqttconfvar["config/get/u1p3p/nachtPhases"]=u1p3pnl
	mqttconfvar["config/get/u1p3p/isConfigured"]=u1p3paktiv
	mqttconfvar["config/get/sofort/lp/1/energyToCharge"]=lademkwh
	mqttconfvar["config/get/sofort/lp/2/energyToCharge"]=lademkwhs1
	mqttconfvar["config/get/sofort/lp/3/energyToCharge"]=lademkwhs2
	mqttconfvar["config/get/sofort/lp/1/socToChargeTo"]=sofortsoclp1
	mqttconfvar["config/get/sofort/lp/2/socToChargeTo"]=sofortsoclp2
	mqttconfvar["config/get/sofort/lp/1/chargeLimitation"]=msmoduslp1
	mqttconfvar["config/get/sofort/lp/2/chargeLimitation"]=msmoduslp2
	mqttconfvar["config/get/sofort/lp/3/chargeLimitation"]=msmoduslp3
	mqttconfvar["config/get/pv/lp/1/socLimitation"]=stopchargepvatpercentlp1
	mqttconfvar["config/get/pv/lp/2/socLimitation"]=stopchargepvatpercentlp2
	mqttconfvar["config/get/pv/lp/1/maxSoc"]=stopchargepvpercentagelp1
	mqttconfvar["config/get/pv/lp/2/maxSoc"]=stopchargepvpercentagelp2
	mqttconfvar["global/rfidConfigured"]=rfidakt
	mqttconfvar["system/priceForKWh"]=preisjekwh
	mqttconfvar["system/wizzardDone"]=wizzarddone
	mqttconfvar["config/get/display/chartEvuMinMax"]=displayevumax
	mqttconfvar["config/get/display/chartBatteryMinMax"]=displayspeichermax
	mqttconfvar["config/get/display/chartPvMax"]=displaypvmax
	mqttconfvar["config/get/display/showHouseConsumption"]=displayhausanzeigen
	mqttconfvar["config/get/display/chartHouseConsumptionMax"]=displayhausmax
	mqttconfvar["config/get/display/chartLp/1/max"]=displaylp1max
	mqttconfvar["config/get/display/chartLp/2/max"]=displaylp2max
	mqttconfvar["config/get/display/chartLp/3/max"]=displaylp3max
	mqttconfvar["config/get/global/slaveMode"]=slavemode

	for mq in "${!mqttconfvar[@]}"; do
		theval=${!mqttconfvar[$mq]}
		declare o${mqttconfvar[$mq]}
		declare ${mqttconfvar[$mq]}

		#tempnewname=${mqttconfvar[$mq]}

		tempoldname=o${mqttconfvar[$mq]}
		tempoldname=$(<ramdisk/mqtt"${mqttconfvar[$mq]}")
		#tempnewname="${mqttconfvar[$mq]}"
		if [[ "$tempoldname" != "$theval" ]]; then
			tempPubList="${tempPubList}\nopenWB/${mq}=${theval}"
			echo $theval > ramdisk/mqtt${mqttconfvar[$mq]}
		fi
	done

	#declare -a pvarray=("speichersocminpv" "speichersochystminpv" "mindestuberschuss" "abschaltuberschuss" "abschaltverzoegerung" "einschaltverzoegerung" "minimalampv" "minimalampv" "minimalalp2pv" "minnurpvsoclp1" "minnurpvsocll" "pvbezugeinspeisung" "offsetpv" "speicherpvui" "speichermaxwatt" "speichersocnurpv" "speicherwattnurpv" "adaptpv" "adaptfaktor")
	#for val in ${pvarray[@]}; do
	#	declare o$val
	#	ramdiskvar=$(<ramdisk/mqtt"$val")
	#	actualvar=${!val}
	#	tempname=$val
	#	if [[ "$ramdiskvar" != "$actualvar" ]]; then
	#		tempPubList="${tempPubList}\nopenWB/config/get/pv/${val}=${actualvar}"
	#		echo $actualvar > ramdisk/mqtt$val
	#	fi
	#done
	
echo "loadvars.Publist:"
echo -e $tempPubList
#echo "Running Python: runs/mqttpub.py -q 0 -r &"
#########################################################################						
echo -e $tempPubList | python3 runs/mqttpub.py -q 0 -r &
#########################################################################						

#########################################################################						
runs/pubmqtt.sh &
#########################################################################						

}
