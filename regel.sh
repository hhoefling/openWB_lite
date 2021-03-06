#!/bin/bash
# shellcheck disable=SC2116,SC2086,SC2163,SC2181,SC2155,SC2004,SC2017,SC2009,SC2046,SC2034,SC2053

#set -e

#####
#
# File: regel.sh
#
# Copyright 2018 Kevin Wieland, David Meder-Marouelli
#
#  This file is part of openWB.
#
#     openWB is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     openWB is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with openWB.  If not, see <https://www.gnu.org/licenses/>.
#
#####

set -o pipefail
set -o nounset


cd /var/www/html/openWB/ || exit 1
# use kostant ramdisk  , no var RAMDISK with 

source helperFunctions.sh

if [ -e ramdisk/updateinprogress ] && [ -e ramdisk/bootinprogress ]; then
	updateinprogress=$(<ramdisk/updateinprogress)
	bootinprogress=$(<ramdisk/bootinprogress)
	if (( updateinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Update in progress EXIT"
		exit 0
	elif (( bootinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Boot in progress EXIT"
		exit 0
	fi
else
	openwbDebugLog "MAIN" 0 "Ramdisk not set up. Maybe we are still booting. EXIT"
	exit 0
fi

########### Laufzeit protokolieren
startregel=$(date +%s)
function cleanup()
{
	local endregel=$(date +%s)
	local t=$((endregel-startregel))
	openwbDebugLog "DEB" 0 "**** Regulation loop needs $t Sekunden"
	if [ "$t" -le "8" ] ; then   # 1..8 Ok
		openwbDebugLog "MAIN" 0 "**** Regulation loop needs $t Sekunden"
	elif [ "$t" -le "9" ] ; then # 8,9 Warning 
		openwbDebugLog "MAIN" 0 "**** WARNING **** Regulation loop needs $t Sekunden"
	else                         # 10,... Fatal
		openwbDebugLog "MAIN" 0 "**** FATAL *********************************"
		openwbDebugLog "MAIN" 0 "**** FATAL Regulation loop needs $t Sekunden"
		openwbDebugLog "MAIN" 0 "**** FATAL *********************************"
	fi
}
trap cleanup EXIT
########### End Laufzeit protokolieren


#config file einlesen
. /var/www/html/openWB/loadconfig.sh

#######################
openwbDebugLog "MAIN" 0 "**** Regulation loop start ****"
openwbDebugLog "DEB" 0 "**** Regulation loop start ****"
#######################


#######################
# only for shellcheck to know the global names loadconfig.sh  loads,  
# here sourced not read as file
#######################
if [ -z $debug ] ; then
# shellcheck source=/var/www/html/openWB/openwb.conf
   source ./openwb.conf
   openwbDebugLog "MAIN" 0 "**** WARNING **** Oh no shit happens"
fi

if pidof -x -o $$ "${BASH_SOURCE[0]}"
then
	openwbDebugLog "MAIN" 0 "Previous regulation loop still running. EXIT"
	#exit
fi

#
# YourCharge, 
#
#declare -r IsFloatingNumberRegex='^-?[0-9.]+$'
#if (( slavemode == 1)); then
#	randomSleep=$(<ramdisk/randomSleepValue)
#	if [[ -z $randomSleep ]] || [[ "${randomSleep}" == "0" ]] || ! [[ "${randomSleep}" =~ $IsFloatingNumberRegex ]]; then
#		randomSleep=$(shuf --random-source=/dev/urandom -i 0-8 -n 1).$(shuf --random-source=/dev/urandom -i 0-9 -n 1)
#		openwbDebugLog "MAIN" 0 "slavemode=$slavemode: ramdisk/randomSleepValue missing or 0 - creating new one containing $randomSleep"
#		echo "$randomSleep" > ramdisk/randomSleepValue
#	fi
#	openwbDebugLog "MAIN" 1 "Slave mode regulation spread: Waiting ${randomSleep}s"
#	sleep "$randomSleep"
#	openwbDebugLog "MAIN" 1 "Slave mode regulation spread: Wait end"
#fi

source minundpv.sh
source nurpv.sh
source auslademodus.sh
source sofortlademodus.sh
source goecheck.sh
source loadvars.sh
source graphing.sh
source nachtladen.sh
source zielladen.sh
if [[ -r evsedintest.sh ]]; then
	source evsedintest.sh
fi	
source hook.sh
if (( u1p3paktiv == 1 )); then
	source u1p3p.sh
fi	
source nrgkickcheck.sh
source rfidtag.sh
source leds.sh
# source slavemode.sh

date=$(date)
re='^-?[0-9]+$'
if [[ $isss == "1" ]]; then
	heartbeat=$(<ramdisk/heartbeat)
	heartbeat=$((heartbeat+10))
	echo $heartbeat > ramdisk/heartbeat
	mosquitto_pub -r -t "openWB/system/Uptime" -m "$(uptime)"
	mosquitto_pub -r -t "openWB/system/Timestamp" -m "$(date +%s)"
	mosquitto_pub -r -t "openWB/system/Date" -m "$(date)"
	openwbDebugLog "MAIN" 1 "ISSS mode Exit"
	exit 0
fi

#doppelte Ausfuehrungsgeschwindigkeit
if [[ $dspeed == "1" ]]; then
	if [ -e ramdisk/5sec ]; then
		sleep 5 && ./regel.sh >> /var/log/openWB.log 2>&1 &
		rm ramdisk/5sec
	else
		echo 0 > ramdisk/5sec
	fi
fi
# halbe (20Sec)
if [[ $dspeed == "2" ]]; then

	if [ -e ramdisk/5sec ]; then
		rm ramdisk/5sec
		openwbDebugLog "MAIN" 1 "**** Regulation speed2-loop exits (exit 0)"
		exit 0
	else
		echo 0 > ramdisk/5sec
	fi
fi
# dspeed=3 weiter unten

# process autolock
./processautolock.sh &


ts=$(date +%s)

#ladelog ausfuehren
 [ -e ./ladelog.sh ]  &&  ( ./ladelog.sh &  )
 [ -e ./ladelog2.sh ] &&  ( ./ladelog2.sh & )
# ./ladelog.sh &

t=$(( $(date +%s) - ts))
if (( t > 1))  ; then
  openwbDebugLog "DEB" 0 " ************* $t for ladelog"
fi

incvar graphtimer 5 
#graphtimer=$(<ramdisk/graphtimer)
#if (( graphtimer < 5 )); then
#	graphtimer=$((graphtimer+1))
#	echo $graphtimer > ramdisk/graphtimer
#else
#	graphtimer=0
#	echo $graphtimer > ramdisk/graphtimer
#fi
#######################################

if (( displayaktiv == 1 )); then
	execdisplay=$(<ramdisk/execdisplay)
	if (( execdisplay == 1 )); then
		export DISPLAY=:0 && xset s "$displaysleep" && xset dpms "$displaysleep" "$displaysleep" "$displaysleep"
		echo 0 > ramdisk/execdisplay
		openwbDebugLog "MAIN" 1 "exec  runs/displaybacklight.sh $displayLight"
		sudo runs/displaybacklight.sh $displayLight
	fi
fi


#######################################
# check rfid
#moved in loadvars

#goe mobility check
goecheck

# nrgkick mobility check
nrgkickcheck


LadereglerTxt=""
BatSupportTxt=""
function endladeregler()
{
 openwbDebugLog "MAIN" 0 "LadereglerTxt: $LadereglerTxt $BatSupportTxt"
 mosquitto_pub -r -t "openWB/global/strLaderegler" -m "${LadereglerTxt:-None} "
 mosquitto_pub -r -t "openWB/global/strBatSupport" -m "${BatSupportTxt:-None} "
}
trap_befor endladeregler EXIT 

ts=$(date +%s)

#load charging vars
startloadvars=$(date +%s)
loadvars
endloadvars=$(date +%s)
timeloadvars=$((endloadvars-startloadvars))
openwbDebugLog "MAIN" 1 "Zeit zum abfragen aller Werte $timeloadvars Sekunden"

t=$(( $(date +%s) - ts))
if (( t > 6))  ; then
  openwbDebugLog "DEB" 0 " ************* $t for loadvars"
  openwbDebugLog "MAIN" 0 " ************* $t for loadvars"
fi


#hooks - externe geraete
hook

#Graphing, vorgezogen damit auch bei blockall die daten weitergef??hrt werden
graphing


if (( u1p3paktiv == 1 )); then
	blockall=$(<ramdisk/blockall)
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "----- Phasen Umschaltung noch aktiv... beende (exit 0) -----"
		exit 0
	fi
fi
if (( lp1enabled == 0)); then
	if (( ladeleistunglp1 > 100 )) || (( llalt > 0 )); then
		runs/set-current.sh 0 m
	fi
fi
if (( lp2enabled == 0)); then
	if (( ladeleistunglp2 > 100 )) || (( llalts1 > 0 )); then
		runs/set-current.sh 0 s1
	fi
fi
if (( lp3enabled == 0)); then
	if (( ladeleistunglp3 > 100 )) || (( llalts2 > 0 )); then
		runs/set-current.sh 0 s2
	fi
fi
# LP4-LP8


if [[ -r evsedintest.sh ]]; then
    # EVSE DIN Modbus test, wenn "Ausstehend" eingertragen ist (evsedinttest.php)
    #source evsedintest.sh
    evsedintest
else
	openwbDebugLog "MAIN" 2 "evsedintest skiped, no script found"
fi

#u1p3p switch
if (( u1p3paktiv == 1 )); then
	openwbDebugLog "MAIN" 0 "Start u1p3switsch"
	u1p3pswitch
	openwbDebugLog "MAIN" 0 "End u1p3switsch"
	blockall=$(<ramdisk/blockall)
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "Phasen Umschaltung wurde aktiv... beende (exit 0)"
		exit 0
	fi
fi


if (( cpunterbrechunglp1 == 1 )); then
	if (( plugstat == 1 )) && (( lp1enabled == 1 )); then
		if (( llalt > 5 )); then
			if (( ladeleistung < 100 )); then
				cpulp1waraktiv=$(<ramdisk/cpulp1waraktiv)
				cpulp1counter=$(<ramdisk/cpulp1counter)
				if (( cpulp1counter > 5 )); then
					if (( cpulp1waraktiv == 0 )); then
						openwbDebugLog "MAIN" 0 "CP Unterbrechung an LP1 wird durchgef??hrt"
						openwbDebugLog "CHARGESTAT" 0 "CP Unterbrechung an LP1 wird durchgef??hrt"
						if [[ $evsecon == "simpleevsewifi" ]]; then
							curl --silent --connect-timeout "$evsewifitimeoutlp1" -s "http://$evsewifiiplp1/interruptCp" > /dev/null
						elif [[ $evsecon == "ipevse" ]]; then
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp1}s"
							python runs/cpuremote.py -a "$evseiplp1" -i 4 -d "$cpunterbrechungdauerlp1"
						elif [[ $evsecon == "extopenwb" ]]; then
							mosquitto_pub -r -t openWB/set/isss/Cpulp1 -h $chargep1ip -m "1"
						else
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp1}s"
							sudo python runs/cpulp1.py -d "$cpunterbrechungdauerlp1"
						fi
						echo 1 > ramdisk/cpulp1waraktiv
						date +%s > ramdisk/cpulp1timestamp # Timestamp in epoch der CP Unterbrechung
					fi
				else
					cpulp1counter=$((cpulp1counter+1))
					echo $cpulp1counter > ramdisk/cpulp1counter
				fi
			else
				echo 0 > ramdisk/cpulp1waraktiv
				echo 0 > ramdisk/cpulp1counter
			fi
		fi
	else
		echo 0 > ramdisk/cpulp1waraktiv
		echo 0 > ramdisk/cpulp1counter
	fi
fi

if (( cpunterbrechunglp2 == 1 )); then
	if (( plugstatlp2 == 1 )) && (( lp2enabled == 1 )); then
		if (( llalts1 > 5 )); then
			if (( ladeleistunglp2 < 100 )); then
				cpulp2waraktiv=$(<ramdisk/cpulp2waraktiv)
				cpulp2counter=$(<ramdisk/cpulp2counter)
				if (( cpulp2counter > 5 )); then
					if (( cpulp2waraktiv == 0 )); then
						openwbDebugLog "MAIN" 0 "CP Unterbrechung an LP2 wird durchgef??hrt"
						if [[ $evsecons1 == "simpleevsewifi" ]]; then
							curl --silent --connect-timeout "$evsewifitimeoutlp2" -s "http://$evsewifiiplp2/interruptCp" > /dev/null
						elif [[ $evsecons1 == "ipevse" ]]; then ## Alter Satellit ohne Pi3
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp2}s"
							python runs/cpuremote.py -a "$evseiplp2" -i 7 -d "$cpunterbrechungdauerlp2"
						elif [[ $evsecons1 == "extopenwb" ]]; then
							mosquitto_pub -r -t openWB/set/isss/Cpulp1 -h $chargep2ip -m "1"
						else
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp2}s"
							sudo python runs/cpulp2.py -d "$cpunterbrechungdauerlp2"
						fi
						echo 1 > ramdisk/cpulp2waraktiv
						date +%s > ramdisk/cpulp2timestamp # Timestamp in epoch der CP Unterbrechung
					fi
				else
					cpulp2counter=$((cpulp2counter+1))
					echo $cpulp2counter > ramdisk/cpulp2counter
				fi
			else
				echo 0 > ramdisk/cpulp2waraktiv
				echo 0 > ramdisk/cpulp2counter
			fi
		fi
	else
		echo 0 > ramdisk/cpulp2waraktiv
		echo 0 > ramdisk/cpulp2counter
	fi
fi


# 0,2,3  Norm=10S,Langsam=20S,sehr langsam=1Min
if [[ $dspeed == "3" ]]; then
    regeltimer=0 
	incvar regeltimer 5
	if (( regeltimer!=0 )) ; then 
		openwbDebugLog "MAIN" 0 "DSpeed=3, EXIT 0  Now ($regeltimer) "
		exit 0
 	else 		
		openwbDebugLog "MAIN" 0 "DSpeed=3, run at ($regeltimer) "
	fi
fi


#if [[ $dspeed == "3" ]]; then
#	if [ -e ramdisk/5sec ]; then
#		regeltimer=$(<ramdisk/5sec)
#		if (( regeltimer < 5 )); then
#			regeltimer=$((regeltimer+1))
#			echo $regeltimer > ramdisk/5sec
#			exit 0
#		else
#			regeltimer=0
#			echo $regeltimer > ramdisk/5sec
#		fi
#	else
#		echo 0 > ramdisk/5sec
#	fi
#fi

if (( ledsakt == 1 )); then
	ledsteuerung
fi

#Pr??ft ob der RSE (Rundsteuerempf??ngerkontakt) geschlossen ist, wenn ja wird die Ladung pausiert.
if (( rseenabled == 1 )); then
	rsestatus=$(<ramdisk/rsestatus)
	rseaktiv=$(<ramdisk/rseaktiv)
	if (( rsestatus == 1 )); then
		echo "RSE Kontakt aktiv, pausiere Ladung" > ramdisk/lastregelungaktiv
		if (( rseaktiv == 0 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt aktiviert, ??ndere Lademodus auf Stop"
			echo "$lademodus" > ramdisk/rseoldlademodus
			echo "$STOP3" > ramdisk/lademodus
			mosquitto_pub -r -t openWB/set/ChargeMode -m "$STOP3"
			echo 1 > ramdisk/rseaktiv
		fi
	else
		if (( rseaktiv == 1 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt deaktiviert, setze auf alten Lademodus zur??ck"
			rselademodus=$(<ramdisk/rseoldlademodus)
			echo "$rselademodus" > ramdisk/lademodus
			mosquitto_pub -r -t openWB/set/ChargeMode -m "$rselademodus"
			echo 0 > ramdisk/rseaktiv
		fi
	fi
fi



evsemodbustimer=0
incvar evsemodbustimer 30
if (( evsemodbustimer == 0 )) ; then
   openwbDebugLog "MAIN" 1 "call evse modbus check, every 5 minutes"

	if [[ -r evsedintest.sh ]]; then
    	#source evsedintest.sh
    	evsemodbuscheck
	else
		openwbDebugLog "MAIN" 2 "evsemodbuscheck skiped, no script found"
	fi
fi


# YourCharge, Slave Mode, openWB als Ladepunkt nutzen
#if (( slavemode == 1 )); then
#	openwbisslave
#    # Exit 0
#fi

#Lademodus STOP3 == Aus
if (( lademodus == $STOP3 )); then
	auslademodus
fi

#loadsharing check
if [[ $loadsharinglp12 == "1" ]]; then
	if (( loadsharingalp12 == 16 )); then
		agrenze=8
		aagrenze=16
		if (( current > 16 )); then
			current=16
		fi
	else
		agrenze=16
		aagrenze=32
	fi
	tcurrent=$(( llalt + llalts1 ))
	if (( tcurrent > aagrenze )); then
		#detect charging cars
		if (( lla1 > 1 )); then
			lp1c=1
			if (( lla2 > 1 )); then
				lp1c=2
			fi
		else
			lp1c=0
		fi
		if (( llas11 > 1 )); then
			lp2c=1
			if (( llas12 > 1 )); then
				lp2c=2
			fi
		else
			lp2c=0
		fi
		chargingphases=$(( lp1c + lp2c ))
		if (( chargingphases > 2 )); then
			runs/set-current.sh "$agrenze" all
			openwbDebugLog "CHARGESTAT" 0 "Alle Ladepunkte, Loadsharing LP1-LP2 aktiv. Setze Ladestromst??rke auf $agrenze"
			exit 0
		fi
	fi
fi


#########################################
#Regelautomatiken

if (( zielladenaktivlp1 == 1 )); then
	ziellademodus
	# Exit 0 if Laden aktive 		
fi

####################
# Nachtladung bzw. Ladung bis SOC x% nachts von x bis x Uhr
prenachtlademodus
# Exit 0 if laden aktive

#######################
#Ladestromstarke berechnen
anzahlphasen=$(<ramdisk/anzahlphasen)
if (( anzahlphasen > 9 )); then
	anzahlphasen=1
fi
# mehr als 3A gelten als "Laden"
declare -ri LLPHASENTEST=3

openwbDebugLog "PV" 0 "Alte Anzahl genutzter Phasen= $anzahlphasen"


#Anzahl genutzter Phasen ermitteln, wenn ladestrom kleiner 3 (nicht vorhanden) nutze den letzten bekannten wert
if (( llalt > LLPHASENTEST )); then
	anzahlphasen=0
	if (( lla1 > LLPHASENTEST )); then
		anzahlphasen=$((anzahlphasen + 1 ))
	fi
	if (( lla2 > LLPHASENTEST )); then
		anzahlphasen=$((anzahlphasen + 1 ))
	fi
	if (( lla3 > LLPHASENTEST )); then
		anzahlphasen=$((anzahlphasen + 1 ))
	fi
	echo $anzahlphasen > ramdisk/anzahlphasen
	echo $anzahlphasen > ramdisk/lp1anzahlphasen
	openwbDebugLog "PV" 0 "LP1 aktive Phasen w??hrend Ladung= $anzahlphasen"
	openwbDebugLog "MAIN" 0 "--NurPV LP1 aktive Phasen w??hrend Ladung= $anzahlphasen"
else
	# wir laden nicht, k??nten aber daher future-phasen bestimmen 
	if (( plugstat == 1 )) && (( lp1enabled == 1 )); then
		if [ ! -f ramdisk/anzahlphasen ]; then
			echo 1 > ramdisk/anzahlphasen
		fi
		if (( u1p3paktiv == 1 )); then
			anzahlphasen=$(cat ramdisk/u1p3pstat)	# letzer stand von u1P3, statt mit 1 zu beginnen
			openwbDebugLog "PV" 0 "LP1 u1p3aktiv, nehme u1p3pstat:$u1p3pstat als mogliche phasenanzahl"
		else
		    openwbDebugLog "PV" 0 "LP1 nehme letzte phasenanzzahl als mogliche phasenanzahl"
			if [ -f ramdisk/lp1anzahlphasen ]; then
				anzahlphasen=$(cat ramdisk/lp1anzahlphasen)
			else
				anzahlphasen=$(cat ramdisk/anzahlphasen)
			fi
		fi
#		if (( lademodus == $NURPV2 )); then
#				anzahlphasen=1; ## starte immer mit 1
#				openwbDebugLog "MAIN" 0 " -- NurPV Setze Anzahl Phasen fix = 1 bei NurPV bei keiner Ladung"
#		fi
	else # nicht angesteckt oder disabled
		anzahlphasen=0
	fi
	openwbDebugLog "PV" 0 "LP1 Anzahl Phasen w??hrend keiner Ladung= $anzahlphasen"
	openwbDebugLog "MAIN" 0 "--NurPV LP1 Anzahl Phasen w??hrend keiner Ladung= $anzahlphasen"
fi



lp2anzahlphasen=0
if (( lastmanagement == 1 )); then		# lastmanagement == 1 means that it's on openWB duo
	if (( llas11 > LLPHASENTEST )); then
		if (( llas11 > LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
			lp2anzahlphasen=1
		fi
		if (( llas12 > LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
			lp2anzahlphasen=$((lp2anzahlphasen + 1 ))
		fi
		if (( llas13 > LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
			lp2anzahlphasen=$((lp2anzahlphasen + 1 ))
		fi
		echo $anzahlphasen > ramdisk/anzahlphasen
		echo $lp2anzahlphasen > ramdisk/lp2anzahlphasen
		openwbDebugLog "PV" 0 "LP2 Anzahl Phasen w??hrend Ladung= $lp2anzahlphasen"
	else
		if (( plugstatlp2 == 1 )) && (( lp2enabled == 1 )); then
			if [ ! -f ramdisk/anzahlphasen ]; then
				echo 1 > ramdisk/anzahlphasen
			fi
#			if (( u1p3plp2aktiv == 1 )); then   ## immmer false da variable unbekannt
#				lp2anzahlphasen=$(cat ramdisk/u1p3pstat)
#				anzahlphasen=$((lp2anzahlphasen + anzahlphasen))
#			else
				if [ ! -f ramdisk/lp2anzahlphasen ]; then
					echo 1 > ramdisk/lp2anzahlphasen
					anzahlphasen=$((anzahlphasen + 1 ))
				else
					lp2anzahlphasen=$(cat ramdisk/lp2anzahlphasen)
					anzahlphasen=$((lp2anzahlphasen + anzahlphasen))
				fi
#			fi
		fi
		openwbDebugLog "PV" 0 "LP2 Anzahl Phasen w??hrend keiner Ladung= $lp2anzahlphasen"
	fi
fi
if (( lastmanagements2 == 1 )); then
	if (( llas21 > LLPHASENTEST )); then
		if (( llas21 >  LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
		fi
		if (( llas22 > LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
		fi
		if (( llas23 > LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
		fi
		echo $anzahlphasen > ramdisk/anzahlphasen
	fi
fi
if [ $anzahlphasen -eq 0 ]; then
	anzahlphasen=1
fi
if [ "$anzahlphasen" -ge "24" ]; then
	anzahlphasen=1
	echo $anzahlphasen > ramdisk/anzahlphasen
fi
openwbDebugLog "PV" 0 "Gesamt Anzahl Phasen= $anzahlphasen (0..24 korrigiert)"
openwbDebugLog "MAIN" 0 "-- NurPV regel.sh Gesamt Anzahl Phasen= $anzahlphasen (0..24 korrigiert)"

########################
# Sofort Laden
if (( lademodus == $SOFORT0 )); then
	sofortlademodus
	# Exit 0 if aktiv
fi

########################
# Berechnung f??r PV Regelung
if [[ $nurpv70dynact == "1" ]]; then
	nurpv70status=$(<ramdisk/nurpv70dynstatus)
	if [[ $nurpv70status == "1" ]]; then
		uberschuss=$((uberschuss - nurpv70dynw))
		# Schwelle zum Beginn der Ladung
		mindestuberschuss=0
		# Schwelle zum Beenden der Ladung
		abschaltuberschuss=-1500
		#abschaltuberschuss=$((minimalapv * 230 * anzahlphasen))
		openwbDebugLog "MAIN" 1 "PV 70% aktiv! derzeit genutzter ??berschuss $uberschuss"
		openwbDebugLog "PV" 0 "70% Grenze aktiv. Alter ??berschuss: $((uberschuss + nurpv70dynw)), Neuer verf??gbarer Uberschuss: $uberschuss"
		openwbDebugLog "MAIN" 0 "--NurPV 70% Grenze aktiv. Alter ??berschuss: $((uberschuss + nurpv70dynw)), Neuer verf??gbarer Uberschuss: $uberschuss"
	fi
fi

mindestuberschussphasen=$((mindestuberschuss * anzahlphasen))
wattkombiniert=$((ladeleistung + uberschuss))
#PV Regelmodus
if [[ $pvbezugeinspeisung == "0" ]]; then
	pvregelungm="0"
	schaltschwelle=$(echo "(230*$anzahlphasen)" | bc)
fi
if [[ $pvbezugeinspeisung == "1" ]]; then
	pvregelungm=$(echo "(230*$anzahlphasen*-1)" | bc)
	schaltschwelle="0"
fi
if [[ $pvbezugeinspeisung == "2" ]]; then
	pvregelungm=$offsetpv
	schaltschwelle=$((schaltschwelle + offsetpv))
fi
openwbDebugLog "PV" 0 "Schaltschwelle: $schaltschwelle, zum runterregeln: $pvregelungm"
# Debug Ausgaben
openwbDebugLog "MAIN" 1 "anzahlphasen $anzahlphasen"
openwbDebugLog "MAIN" 2 "uberschuss $uberschuss wattbezug $wattbezug ladestatus $ladestatus llsoll $llalt pvwatt $pvwatt mindestuberschussphasen $mindestuberschussphasen wattkombiniert $wattkombiniert schaltschwelle $schaltschwelle"
########################
#Min Ladung + PV Uberschussregelung lademodus 1
if (( lademodus == $MINPV1 )); then
	minundpvlademodus
fi
########################
#NUR PV Uberschussregelung lademodus 2
# wenn evse aus und $mindestuberschuss vorhanden, starte evse mit 6A Ladestromstaerke (1320 - 3960 Watt je nach Anzahl Phasen)
if (( lademodus == $NURPV2 )); then
	nurpvlademodus
fi

########################
#Lademodus 4 == SemiAus
if (( lademodus == $STANDBY4 )); then
	semiauslademodus
fi



openwbDebugLog "MAIN" 1 "Regulation normal end (exit 0)"

