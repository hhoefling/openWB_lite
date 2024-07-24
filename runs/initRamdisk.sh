#!/bin/bash
# Ramdisk mit initialen Werten befüllen nach Neustart, UP atreboot.sh

initRamdisk(){
	RamdiskPath="/var/www/html/openWB/ramdisk"
	openwbDebugLog "MAIN" 2  "Initializing Ramdisk $RamdiskPath"

	# Logfiles erstellen
	if [[ ! -L $RamdiskPath/openWB.log ]]; then
		sudo rm -f $RamdiskPath/openWB.log
		ln -s /var/log/openWB.log $RamdiskPath/openWB.log
	fi
	# Errfiles erstellen
	if [[ ! -L $RamdiskPath/openwb.error.log ]]; then
		sudo rm -f $RamdiskPath/openwb.error.log
		ln -s /var/log/openwb.error.log $RamdiskPath/openwb.error.log
	fi
	echo "**** REBOOT ****" >> $RamdiskPath/mqtt.log
	echo "**** REBOOT ****" >> $RamdiskPath/ladestatus.log
	echo "**** REBOOT ****" >> $RamdiskPath/soc.log
	echo "**** REBOOT ****" >> $RamdiskPath/rfid.log
	echo "**** REBOOT ****" >> $RamdiskPath/nurpv.log
	echo "**** REBOOT ****" >> $RamdiskPath/cleanup.log
	echo "**** REBOOT ****" >> $RamdiskPath/smarthome.log
	echo "**** REBOOT ****" >> $RamdiskPath/isss.log
	echo "**** REBOOT ****" >> $RamdiskPath/event.log

	echo "$bootmodus" > $RamdiskPath/lademodus
	echo "" >$RamdiskPath/LadereglerTxt
	echo "" >$RamdiskPath/BatSupportTxt

	# Ladepunkte
	# Variablen noch nicht einheitlich benannt, daher individuelle Zeilen
	echo 0 > $RamdiskPath/errcounterextopenwb
	echo 0 > $RamdiskPath/pluggedin
	echo "nicht angefragt" > $RamdiskPath/evsedintestlp1
	echo "nicht angefragt" > $RamdiskPath/evsedintestlp2
	echo "nicht angefragt" > $RamdiskPath/evsedintestlp3
    echo 0 > $RamdiskPath/restzeitlp1
    echo 0 > $RamdiskPath/restzeitlp2
    echo 0 > $RamdiskPath/restzeitlp3
	echo 0 > $RamdiskPath/restzeitlp1m         # NC
	echo 0 > $RamdiskPath/restzeitlp2m         # NC
	echo 0 > $RamdiskPath/restzeitlp3m         # NC
	echo 0 > $RamdiskPath/aktgeladen
	echo 0 > $RamdiskPath/aktgeladens1
	echo 0 > $RamdiskPath/aktgeladens2
	echo 0 > $RamdiskPath/chargestat
	echo 0 > $RamdiskPath/chargestats1
	echo 0 > $RamdiskPath/chargestatlp3
	echo 0 > $RamdiskPath/ladestatus
	echo 0 > $RamdiskPath/ladestatuss1
	echo 0 > $RamdiskPath/ladestatuss2
	echo 0 > $RamdiskPath/ladestart
	echo 0 > $RamdiskPath/ladestarts1
	echo 0 > $RamdiskPath/ladestarts2
	echo 0 > $RamdiskPath/gelrlp1
	echo 0 > $RamdiskPath/gelrlp2
	echo 0 > $RamdiskPath/gelrlp3
	echo 0 > $RamdiskPath/ladungaktivlp1
	echo 0 > $RamdiskPath/ladungaktivlp2
	echo 0 > $RamdiskPath/ladungaktivlp3
	echo 0 > $RamdiskPath/lla1
	echo 0 > $RamdiskPath/llas11
	echo 0 > $RamdiskPath/llas21
	echo 0 > $RamdiskPath/lla2
	echo 0 > $RamdiskPath/llas12
	echo 0 > $RamdiskPath/llas22
	echo 0 > $RamdiskPath/lla3
	echo 0 > $RamdiskPath/llas13
	echo 0 > $RamdiskPath/llas23
	echo 0 > $RamdiskPath/llkwh
	echo 0 > $RamdiskPath/llkwhs1
	echo 0 > $RamdiskPath/llkwhs2
	echo 0 > $RamdiskPath/llsoll
	echo 0 > $RamdiskPath/llsolls1
	echo 0 > $RamdiskPath/llsolls2
	echo 0 > $RamdiskPath/llv1
	echo 0 > $RamdiskPath/llvs11
	echo 0 > $RamdiskPath/llvs21
	echo 0 > $RamdiskPath/llv2
	echo 0 > $RamdiskPath/llvs12
	echo 0 > $RamdiskPath/llvs22
	echo 0 > $RamdiskPath/llv3
	echo 0 > $RamdiskPath/llvs13
	echo 0 > $RamdiskPath/llvs23
	echo 0 > $RamdiskPath/pluggedtimer1
	echo 0 > $RamdiskPath/pluggedladungbishergeladen
	echo 0 > $RamdiskPath/pluggedladungbishergeladenlp2
	echo 0 > $RamdiskPath/pluggedladungbishergeladenlp3
	echo 0 > $RamdiskPath/plugstat
	echo 0 > $RamdiskPath/plugstats1
	echo 0 > $RamdiskPath/plugstatlp3
	echo 0 > $RamdiskPath/llaltnv
	echo 0 > $RamdiskPath/llhz
	echo 0 > $RamdiskPath/llkombiniert
	echo 0 > $RamdiskPath/llkwhges
	echo 0 > $RamdiskPath/llpf1
	echo 0 > $RamdiskPath/llpf2
	echo 0 > $RamdiskPath/llpf3
	echo 0 > $RamdiskPath/llaktuell
	echo 0 > $RamdiskPath/llaktuells1
	echo 0 > $RamdiskPath/llaktuells2
	echo 0 > $RamdiskPath/nachtladen2state
	echo 0 > $RamdiskPath/nachtladen2states1
	echo 0 > $RamdiskPath/nachtladenstate
	echo 0 > $RamdiskPath/nachtladenstates1
#	echo 0 > $RamdiskPath/pluggedtimer1
#	echo 0 > $RamdiskPath/pluggedtimer2
#	echo 0 > $RamdiskPath/pluggedtimerlp3
	echo 0 > $RamdiskPath/progevsedinlp1
	echo 0 > $RamdiskPath/progevsedinlp12000
	echo 0 > $RamdiskPath/progevsedinlp12007
	echo 0 > $RamdiskPath/progevsedinlp2
	echo 0 > $RamdiskPath/progevsedinlp22000
	echo 0 > $RamdiskPath/progevsedinlp22007
	echo 0 > $RamdiskPath/cpulp1counter
	echo 0 > $RamdiskPath/soc
	echo 0 > $RamdiskPath/soc1
	echo 0 > $RamdiskPath/soc1KM
	echo 0 > $RamdiskPath/soc2KM
	echo 0 > $RamdiskPath/soc3KM
	echo 0 > $RamdiskPath/soc1Range
    echo 0 > $RamdiskPath/soc2Range
    echo 0 > $RamdiskPath/socvorhanden
	echo 0 > $RamdiskPath/soc1vorhanden
	echo 0 > $RamdiskPath/tmpsoc
	echo 0 > $RamdiskPath/tmpsoc1
	echo 0 > $RamdiskPath/zielladenkorrektura
	echo 0 > $RamdiskPath/ladungdurchziel
	echo 20000 > $RamdiskPath/soctimer
	echo 20000 > $RamdiskPath/soctimer1
	echo 28 > $RamdiskPath/evsemodbustimer
	touch $RamdiskPath/llog1
	touch $RamdiskPath/llogs1
	touch $RamdiskPath/llogs2

	# rct
	echo 0 > $RamdiskPath/HB_discharge_max
	echo 0 > $RamdiskPath/HB_loadWatt
	echo 0 > $RamdiskPath/HB_load_minutes
	echo 0 > $RamdiskPath/HB_soctarget
	echo 0 > $RamdiskPath/HB_iskalib
	echo 1 > $RamdiskPath/HB_enable_discharge_max
	echo 0 > $RamdiskPath/HB_enable_priceloading

	
	# SmartHome 2.0
	echo 0 > $RamdiskPath/device1_temp0
	echo 0 > $RamdiskPath/device1_temp1
	echo 0 > $RamdiskPath/device1_temp2
	echo 0 > $RamdiskPath/device1_wh
	echo 0 > $RamdiskPath/device2_temp0
	echo 0 > $RamdiskPath/device2_temp1
	echo 0 > $RamdiskPath/device2_temp2
	echo 0 > $RamdiskPath/device2_wh
	echo 0 > $RamdiskPath/device3_wh
	echo 0 > $RamdiskPath/device4_wh
	echo 0 > $RamdiskPath/device5_wh
	echo 0 > $RamdiskPath/device6_wh
	echo 0 > $RamdiskPath/device7_wh
	echo 0 > $RamdiskPath/device8_wh
	echo 0 > $RamdiskPath/device9_wh
	echo 0 > $RamdiskPath/smarthome_device_minhaus_1
	echo 0 > $RamdiskPath/smarthome_device_minhaus_2
	echo 0 > $RamdiskPath/smarthome_device_minhaus_3
	echo 0 > $RamdiskPath/smarthome_device_minhaus_4
	echo 0 > $RamdiskPath/smarthome_device_minhaus_5
	echo 0 > $RamdiskPath/smarthome_device_minhaus_6
	echo 0 > $RamdiskPath/smarthome_device_minhaus_7
	echo 0 > $RamdiskPath/smarthome_device_minhaus_8
	echo 0 > $RamdiskPath/smarthome_device_minhaus_9
	echo 0 > $RamdiskPath/smarthome_device_manual_1
	echo 0 > $RamdiskPath/smarthome_device_manual_2
	echo 0 > $RamdiskPath/smarthome_device_manual_3
	echo 0 > $RamdiskPath/smarthome_device_manual_4
	echo 0 > $RamdiskPath/smarthome_device_manual_5
	echo 0 > $RamdiskPath/smarthome_device_manual_6
	echo 0 > $RamdiskPath/smarthome_device_manual_7
	echo 0 > $RamdiskPath/smarthome_device_manual_8
	echo 0 > $RamdiskPath/smarthome_device_manual_9
	echo 0 > $RamdiskPath/smarthomehandlermaxbatterypower
	echo 0 > $RamdiskPath/smarthomehandlerloglevel

	# evu
	echo 0 > $RamdiskPath/bezuga1
	echo 0 > $RamdiskPath/bezuga2
	echo 0 > $RamdiskPath/bezuga3
	echo 0 > $RamdiskPath/bezugkwh
	echo 0 > $RamdiskPath/bezugw1
	echo 0 > $RamdiskPath/bezugw2
	echo 0 > $RamdiskPath/bezugw3
	echo 0 > $RamdiskPath/einspeisungkwh
	echo 0 > $RamdiskPath/evuhz
	echo 0 > $RamdiskPath/evupf1
	echo 0 > $RamdiskPath/evupf2
	echo 0 > $RamdiskPath/evupf3
	echo 0 > $RamdiskPath/evuv1
	echo 0 > $RamdiskPath/evuv2
	echo 0 > $RamdiskPath/evuv3
	echo 0 > $RamdiskPath/wattbezug

	# pv
	echo 0 > $RamdiskPath/daily_pvkwhk
//NC	echo 0 > $RamdiskPath/daily_pvkwhk1
//NC	echo 0 > $RamdiskPath/daily_pvkwhk2
	echo 0 > $RamdiskPath/monthly_pvkwhk
//NC	echo 0 > $RamdiskPath/monthly_pvkwhk1
//NC	echo 0 > $RamdiskPath/monthly_pvkwhk2
	echo 0 > $RamdiskPath/nurpv70dynstatus
	echo 0 > $RamdiskPath/pv1watt
	echo 0 > $RamdiskPath/pv2a1
	echo 0 > $RamdiskPath/pv2a2
	echo 0 > $RamdiskPath/pv2a3
	echo 0 > $RamdiskPath/pv2kwh
	echo 0 > $RamdiskPath/pv2watt
	echo 0 > $RamdiskPath/pvcounter
	echo 0 > $RamdiskPath/pvecounter
	echo 0 > $RamdiskPath/pvkwh
	echo 0 > $RamdiskPath/pvkwhk
	echo 0 > $RamdiskPath/pvkwhk1
	echo 0 > $RamdiskPath/pvkwhk2
	echo 0 > $RamdiskPath/pv1vorhanden
	echo 0 > $RamdiskPath/pv2vorhanden
	echo 0 > $RamdiskPath/pvwatt
	echo 0 > $RamdiskPath/pvwatt1
	echo 0 > $RamdiskPath/pvwatt2
	echo 0 > $RamdiskPath/yearly_pvkwhk
//NC	echo 0 > $RamdiskPath/yearly_pvkwhk1
//NC	echo 0 > $RamdiskPath/yearly_pvkwhk2

	# bat
	echo 0 > $RamdiskPath/speicher
	echo 0 > $RamdiskPath/speicherekwh
	echo 0 > $RamdiskPath/speicherikwh
	echo 0 > $RamdiskPath/speicherleistung
	echo 0 > $RamdiskPath/speicherleistung1
	echo 0 > $RamdiskPath/speicherleistung2
	echo 0 > $RamdiskPath/speichersoc
	echo 0 > $RamdiskPath/speichersoc2
# HH
	echo 0 > $RamdiskPath/speichervorhanden


	# rfid
	echo "$rfidlist" > $RamdiskPath/rfidlist
	echo 0 > $RamdiskPath/rfidlasttag
	echo 0 > $RamdiskPath/rfidlp1
	echo 0 > $RamdiskPath/rfidlp2
	echo 0 > $RamdiskPath/rfidlp3
	echo 0 > $RamdiskPath/readtag
	echo 0 > $RamdiskPath/tagScanInfoLp1
	echo 0 > $RamdiskPath/tagScanInfoLp2
	echo 0 > $RamdiskPath/tagScanInfoLp3

	# SmartHome 1.0
	echo 0 > $RamdiskPath/hook1akt
	echo 0 > $RamdiskPath/hook1einschaltverzcounter
	echo 0 > $RamdiskPath/hook2akt
	echo 0 > $RamdiskPath/hook2einschaltverzcounter
	echo 0 > $RamdiskPath/hook3akt
	echo 0 > $RamdiskPath/hook3einschaltverzcounter      # fehlte
	echo "$verbraucher1_name" > $RamdiskPath/verbraucher1_name
	echo "$verbraucher2_name" > $RamdiskPath/verbraucher2_name


	echo 0 > $RamdiskPath/verbraucher1_watt
	echo 0 > $RamdiskPath/verbraucher1_wh
	echo 0 > $RamdiskPath/verbraucher1_whe
	echo 0 > $RamdiskPath/verbraucher1vorhanden
	echo 0 > $RamdiskPath/daily_verbraucher1ekwh
	echo 0 > $RamdiskPath/daily_verbraucher1ikwh

	echo 0 > $RamdiskPath/verbraucher2_watt
	echo 0 > $RamdiskPath/verbraucher2_wh
	echo 0 > $RamdiskPath/verbraucher2_whe
	echo 0 > $RamdiskPath/verbraucher2vorhanden
	echo 0 > $RamdiskPath/daily_verbraucher2ekwh
	echo 0 > $RamdiskPath/daily_verbraucher2ikwh
    
	touch $RamdiskPath/ladestophooklp1aktiv # benötigt damit der Ladestopp-WebHook nicht beim Neustart auslöst
	touch $RamdiskPath/abgesteckthooklp1aktiv # benötigt damit der Abgesteckt-WebHook nicht beim Neustart auslöst

	# standard socket
#	echo 0 > $RamdiskPath/socketa
#	echo 0 > $RamdiskPath/socketv
#	echo 0 > $RamdiskPath/socketp
#	echo 0 > $RamdiskPath/socketpf
#	echo 0 > $RamdiskPath/socketkwh
#	echo 0 > $RamdiskPath/socketApproved
#	echo 0 > $RamdiskPath/socketActivated
#	echo 0 > $RamdiskPath/socketActivationRequested

	# diverse Dateien
#	echo 0 > $RamdiskPath/autolocktimer  NC
	echo 0 > $RamdiskPath/blockall
	echo 0 > $RamdiskPath/devicetotal_watt
	echo 0 > $RamdiskPath/etprovidermaxprice
	echo 0 > $RamdiskPath/etproviderprice
	touch $RamdiskPath/etprovidergraphlist
	echo 0 > $RamdiskPath/evseausgelesen
	echo 0 > $RamdiskPath/glattwattbezug
	echo 0 > $RamdiskPath/hausverbrauch
	echo 0 > $RamdiskPath/ipaddress
	echo 0 > $RamdiskPath/ledstatus
	echo 0 > $RamdiskPath/netzschutz
# Yourcharge
#	echo 0 > $RamdiskPath/randomSleepValue
	echo 0 > $RamdiskPath/renewmqtt
	echo 0 > $RamdiskPath/rseaktiv
    echo 0 > $RamdiskPath/rsestatus
	echo 0 > $RamdiskPath/schieflast
	echo 0 > $RamdiskPath/u1p3pstat
	echo 0 > $RamdiskPath/uhcounter
	echo 0 > $RamdiskPath/urcounter
	echo 1 > $RamdiskPath/anzahlphasen
	echo 1 > $RamdiskPath/bootinprogress
	echo 1 > $RamdiskPath/execdisplay
	echo 4 > $RamdiskPath/graphtimer



#	# temporäre Zwischenspeicher für z. B. Kostal Plenticore, da
#	# bei Anschluss von Speicher und Energiemanager direkt am WR
#	# alle Werte im Modul des Wechselrichters aus den Registern
#	# gelesen werden, um einen zeitlich zusammenhängenden Datensatz
#	# zu bekommen. Im jeweiligen Modul Speicher/Bezug werden
#	# die Werte dann in die ramdisk für die weitere globale
#	# Verarbeitung geschrieben.
#	# Bezug/Einspeisung
#	echo 0 > $RamdiskPath/temp_wattbezug
#	# Gesamte AC-Leistung des Speichers am WR 1 + 2
#	echo 0 > $RamdiskPath/temp_peicherleistung
#	# AC-Leistung des Speichers am WR 1
#	echo 0 > $RamdiskPath/temp_peicherleistung1
#	# AC-Leistung des Speichers am WR 2
#	echo 0 > $RamdiskPath/temp_peicherleistung2
#	# SoC des Speichers am WR 1
#	echo 0 > $RamdiskPath/temp_speichersoc
#	# Strom auf den jeweiligen Phasen
#	echo 0 > $RamdiskPath/temp_bezuga1
#	echo 0 > $RamdiskPath/temp_bezuga2
#	echo 0 > $RamdiskPath/temp_bezuga3
#	# Netzfrequenz
#	echo 0 > $RamdiskPath/temp_evuhz
#	# Leistung auf den jeweiligen Phasen
#	echo 0 > $RamdiskPath/temp_bezugw1
#	echo 0 > $RamdiskPath/temp_bezugw2
#	echo 0 > $RamdiskPath/temp_bezugw3
#	# Spannung auf den jeweiligen Phasen
#	echo 0 > $RamdiskPath/temp_evuv1
#	echo 0 > $RamdiskPath/temp_evuv2
#	echo 0 > $RamdiskPath/temp_evuv3
#	# Wirkfaktor, wird aus historischen Gründen je Phase geschrieben
#	echo 0 > $RamdiskPath/temp_evupf1
#	echo 0 > $RamdiskPath/temp_evupf2
#	echo 0 > $RamdiskPath/temp_evupf3



#  "autolockstatuslp${i}::0" \
#  "autolockconfiguredlp${i}::0" \

	# init common files for lp1 to lp8
	# "<ramdiskFileName>:<MqttTopic>:<defaultValue>"
	# <Mqtt-Topic> is optional and request to broker will be skipped if empty
#	for i in $(seq 1 8);
	for i in $(seq 1 3);
	do
		for f in \
			"pluggedladunglp${i}startkwh:openWB/lp/${i}/plugStartkWh:0" \
			"manual_soc_lp${i}:openWB/lp/${i}/manualSoc:0" \
			"pluggedladungaktlp${i}:openWB/lp/${i}/pluggedladungakt:0" \
			"lp${i}phasen::0" \
			"lp${i}enabled::1" \
			"restzeitlp${i}::0" \
			"lp${i}sofortll:openWB/config/get/sofort/lp/${i}/current:10" \
			"rfidlp${i}::0" \
			"boolstopchargeafterdisclp${i}::0" 
		do
			IFS=':' read -r -a tuple <<< "$f"
			currentRamdiskFile="$RamdiskPath/${tuple[0]}"
			if ! [ -f "$currentRamdiskFile" ]; then
				if [[ ! -z ${tuple[1]} ]]; then # oder -n 
					mqttValue=$(timeout 1 mosquitto_sub -C 1 -t "${tuple[1]}")
					if [[ ! -z "$mqttValue" ]]; then	# oder -n
						openwbDebugLog "MAIN" 2 "'$currentRamdiskFile' missing: Setting from MQTT topic '${tuple[0]}' to value '$mqttValue'"
						echo "$mqttValue" > "$currentRamdiskFile"
					else
						openwbDebugLog "MAIN" 2 "'$currentRamdiskFile' missing: MQTT topic '${tuple[0]}' can also not provide any value: Setting to default of '${tuple[2]}'"
						echo "${tuple[2]}" > "$currentRamdiskFile"
					fi
				else
					openwbDebugLog "MAIN" 2  "'$currentRamdiskFile' missing: no MQTT topic set: Setting to default of '${tuple[2]}'"
					echo "${tuple[2]}" > "$currentRamdiskFile"
				fi
			fi
		done
	done

		
# init other files
##	for f in \
##			"mqttlastlademodus:-1" 
##		do
##			IFS=':' read -r -a tuple <<< "$f"
##			currentRamdiskFile="$RamdiskPath/${tuple[0]}"
##			if ! [ -f "$currentRamdiskFile" ]; then
##				if [[ ! -z "${tuple[1]}" ]]; then   -n
##					openwbDebugLog "MAIN" 2  "'${tuple[0]}' missing: Setting to provided default value '${tuple[1]}'"
##					echo "${tuple[1]}" > "$currentRamdiskFile"
##				else
##					openwbDebugLog "MAIN" 2  "'${tuple[0]}' missing: No default value provided. Setting to 0."
##					echo 0 > "$currentRamdiskFile"
##				fi
##			fi
##		done

	# read values from mosquitto and store them to ramdisk for smarthomehandler.py
	ra='^-?[0-9]+$'
	importtemp=$(timeout 1 mosquitto_sub -t openWB/config/get/SmartHome/maxBatteryPower)
	if ! [[ $importtemp =~ $ra ]] ; then
		importtemp="0"
	fi
	echo $importtemp > $RamdiskPath/smarthomehandlermaxbatterypower

	ra='^-?[0-9]+$'
	smartmqtemp=$(timeout 1 mosquitto_sub -t openWB/config/get/SmartHome/smartmq)
	if ! [[ $smartmqtemp =~ $ra ]] ; then
		smartmqtemp="1"
	fi
	echo $smartmqtemp > $RamdiskPath/smartmq
	
	sudo chmod 777 $RamdiskPath/*

	openwbDebugLog "MAIN" 2  "Trigger update of logfiles..."
	python3 /var/www/html/openWB/runs/csvcalc.py --input /var/www/html/openWB/web/logging/data/daily/ --output /var/www/html/openWB/web/logging/data/v001/ --partial /var/www/html/openWB/ramdisk/ --mode M >> /var/www/html/openWB/ramdisk/csvcalc.log 2>&1 &
	openwbDebugLog "MAIN" 2  "Ramdisk init done."
}
