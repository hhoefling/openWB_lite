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

OPENWBBASEDIR=/var/www/html/openWB
set -o pipefail
set -o nounset
cd /var/www/html/openWB/ || exit 1
# use kostant ramdisk  , no var RAMDISK

source helperFunctions.sh
if pidof -x -o $$ "${BASH_SOURCE[0]}"
then
	openwbDebugLog "MAIN" 0 "Previous regulation loop still running. EXIT 1"
	exit 1
fi

if [ -e ramdisk/updateinprogress ] && [ -e ramdisk/bootinprogress ]; then
	read updateinprogress <ramdisk/updateinprogress
	read bootinprogress <ramdisk/bootinprogress
	if (( updateinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Update in progress EXIT 0"
		exit 0
	elif (( bootinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Boot in progress EXIT 0"
		exit 0
	fi
else
	openwbDebugLog "MAIN" 0 "Ramdisk not set up. Maybe we are still booting. EXIT 0"
	exit 0
fi

########### Laufzeit protokolieren
startregel=$(date +%s)
function cleanup()
{
	local endregel=$(date +%s)
	local t=$((endregel-startregel))
	openwbDebugLog "DEB" 0 "**** Regulation loop needs $t Sekunden TIME"
	echo $t >ramdisk/regelneeds
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

#######################
openwbDebugLog "MAIN" 0 "**** Regulation loop start ****"
#######################

#config file einlesen, auch debug mode, vorher defaults=2
ptstart
 source loadconfig.sh
ptend loadconfig 50




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
	openwbDebugLog "MAIN" 0 "Previous regulation loop still running. EXIT "
	#exit
fi

#
# YourCharge, deletet 
#

date=$(date)
re='^-?[0-9]+$'
if [[ $isss == "1" ]]; then
	read heartbeat <ramdisk/heartbeat
	heartbeat=$((heartbeat+10))
	echo $heartbeat > ramdisk/heartbeat
	mosquitto_pub -r -t "openWB/system/Uptime" -m "$(uptime)"
	mosquitto_pub -r -t "openWB/system/Timestamp" -m "$(date +%s)"
	mosquitto_pub -r -t "openWB/system/Date" -m "$(date)"
	openwbDebugLog "MAIN" 1 "##### ISSS #####  EXIT 0"
	exit 0
fi
ptstart

# Must be first
source loadvars.sh
source minundpv.sh
source nurpv.sh
source auslademodus.sh
source sofortlademodus.sh
source graphing.sh
source nachtladen.sh
source zielladen.sh
source evsedintest.sh
source verbraucher.sh
source hook.sh
(( u1p3paktiv == 1 ))  && source u1p3p.sh
# NC source goecheck.sh
# NC source nrgkickcheck.sh
(( rfidakt == 1 )) && source rfidtag.sh
source leds.sh
ptend "sourceing" 50

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
		openwbDebugLog "MAIN" 1 "**** Regulation speed2-loop EXIT 0"
		exit 0
	else
		echo 0 > ramdisk/5sec
	fi
fi
# dspeed=3 weiter unten

### NC # process autolock
### NC ./processautolock.sh &   # Asncron , keine rückwirkung auf Variablen


ptstart

#ladelog ausfuehren # Asncron , keine rückwirkung auf Variablen                           
 [ -e ./ladelog.sh ]  &&  ( ./ladelog.sh &  )
 [ -e ./ladelog2.sh ] &&  ( ./ladelog2.sh & )
# ./ladelog.sh &
ptend "ladelog" 100

IncVar graphtimer 6 

#######################################
if (( displayaktiv == 1 )); then
   if ! flagIsClear execdisplay ; then
        openwbDebugLog "MAIN" 1 "EXEC runs/displaybacklight.sh $displayLight and reloadDisplay.sh"
	# export DISPLAY=:0 && xset s "$displaysleep" && xset dpms "$displaysleep" "$displaysleep" "$displaysleep"
	sudo bash -c "export DISPLAY=:0 && xset s $displaysleep && xset dpms $displaysleep $displaysleep $displaysleep"
        runs/displaybacklight.sh $displayLight
        sudo runs/reloadDisplay.sh 
	fi
fi

#if (( displayaktiv == 1 )); then
#	execdisplay=$(<ramdisk/execdisplay)
#	if (( execdisplay == 1 )); then
#        echo 0 > ramdisk/execdisplay
#        openwbDebugLog "MAIN" 1 "EXEC runs/displaybacklight.sh $displayLight and reloadDisplay.sh"
#        export DISPLAY=:0 && xset s "$displaysleep" && xset dpms "$displaysleep" "$displaysleep" "$displaysleep"
#        runs/displaybacklight.sh $displayLight
#        runs/reloadDisplay.sh 
#	fi
#fi

#######################################
# check rfid
#moved in loadvars


function domod(){
 local mod=$1
 if [[ -x $mod ]] ; then
	openwbDebugLog "MAIN" 2 "EXEC $mod"
	$mod
 else	 
  	openwbDebugLog "MAIN" 1 "NO $mod found"
 fi
}

ptstart
# Statt goecheck und nrgcheck immer zu laden, 
# nur dann wenn verwendet subscript aufrufen (ausgelagert )
#########################################################################
		domod  "modules/${evsecon}lp1/check.sh"
#########################################################################
	if (( lastmanagement  == 1 )) ; then
		domod "modules/${evsecons1}lp2/check.sh"
	fi	
#########################################################################
 	if (( lastmanagements2 == 1 )); then
		domod "modules/${evsecons2}lp3/check.sh"
	fi	
#########################################################################
ptend checksh 100

LadereglerTxt=""
BatSupportTxt=""
function endladeregler()
{
 openwbDebugLog "MAIN" 1 "LadereglerTxt: $LadereglerTxt $BatSupportTxt"
 mosquitto_pub -r -t "openWB/global/strLaderegler" -m "${LadereglerTxt:-None} "
 mosquitto_pub -r -t "openWB/global/strBatSupport" -m "${BatSupportTxt:-None} "
}
trap_befor endladeregler EXIT 

ptstart
loadvars
ptend loadvars 2000
openwbDebugLog "MAIN" 1 "loadvars Zeit zum abfragen aller Werte $pt Millisekunden"



#hooks - externe geraete
hook

#hooks - externe verbaucher  (simcount schon vorher in loadvars)
ptstart
doverbraucher
ptend verbraucher 20




#Graphing, vorgezogen damit auch bei blockall die daten weitergeführt werden
ptstart
graphing
ptend graphing 600 



if (( u1p3paktiv == 1 )); then
	read blockall <ramdisk/blockall
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "----- Phasen Umschaltung noch aktiv... beende (EXIT 0) -----"
		exit 0
	fi
fi

# Double check, if lp is disabled and ladeleistung trotzdem noch da, dann Clear to 0
if (( lp1enabled == 0)); then
	if (( ladeleistunglp1 > 100 )) || (( llalt > 0 )); then
	    openwbDebugLog "MAIN" 2 "runs/set-current.sh 0 m"
		runs/set-current.sh 0 m
	fi
fi
if (( lp2enabled == 0)); then
	if (( ladeleistunglp2 > 100 )) || (( llalts1 > 0 )); then
	    openwbDebugLog "MAIN" 2 "runs/set-current.sh 0 s1"
		runs/set-current.sh 0 s1
	fi
fi
if (( lp3enabled == 0)); then
	if (( ladeleistunglp3 > 100 )) || (( llalts2 > 0 )); then
	    openwbDebugLog "MAIN" 2 "runs/set-current.sh 0 s2"
		runs/set-current.sh 0 s2
	fi
fi
# Delete LP4-8

# Maybee Exit 
ptstart 
evsedintest
ptend evsedintest 100 

#u1p3p switch
if (( u1p3paktiv == 1 )); then
	openwbDebugLog "MAIN" 1 "Start u1p3switsch"
	u1p3pswitch
	openwbDebugLog "MAIN" 1 "End u1p3switsch"
	read blockall <ramdisk/blockall
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "Phasen Umschaltung wurde aktiv... beende (EXIT 0)"
		exit 0
	fi
fi


if (( cpunterbrechunglp1 == 1 )); then
	if (( plugstat == 1 )) && (( lp1enabled == 1 )); then
		if (( llalt > 5 )); then
			if (( ladeleistung < 100 )); then
				read cpulp1waraktiv <ramdisk/cpulp1waraktiv
				read cpulp1counter <ramdisk/cpulp1counter
				if (( cpulp1counter > 5 )); then
					if (( cpulp1waraktiv == 0 )); then
						openwbDebugLog "MAIN" 0 "CP Unterbrechung an LP1 wird durchgeführt"
						openwbDebugLog "CHARGESTAT" 0 "CP Unterbrechung an LP1 wird durchgeführt"
						if [[ $evsecon == "simpleevsewifi" ]]; then
							curl --silent --connect-timeout "$evsewifitimeoutlp1" -s "http://$evsewifiiplp1/interruptCp" > /dev/null
						elif [[ $evsecon == "ipevse" ]]; then
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp1}s"
							python runs/cpuremote.py -a "$evseiplp1" -i 4 -d "$cpunterbrechungdauerlp1"
						elif [[ $evsecon == "extopenwb" ]]; then
							mosquitto_pub -r -t openWB/set/isss/Cpulp1 -h $chargep1ip -m "1"
						else
							openwbDebugLog "MAIN" 0 "Dauer der Unterbrechung: ${cpunterbrechungdauerlp1}s"
							# Alle Raspberry basierten OpenWB Variannten haben evt. diese Hardware, also versuche es
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
				read cpulp2waraktiv <ramdisk/cpulp2waraktiv
				read cpulp2counter <ramdisk/cpulp2counter
				if (( cpulp2counter > 5 )); then
					if (( cpulp2waraktiv == 0 )); then
						openwbDebugLog "MAIN" 0 "CP Unterbrechung an LP2 wird durchgeführt"
						openwbDebugLog "CHARGESTAT" 0 "CP Unterbrechung an LP2 wird durchgeführt"
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
	if ! IncVar regeltimer 6 ; then
		openwbDebugLog "MAIN" 0 "DSpeed=3, EXIT 0  Now IncVar: ($regeltimer) "
		exit 0
 	else 		
		openwbDebugLog "MAIN" 0 "DSpeed=3, run at IncVar: ($regeltimer) "
	fi
fi

if (( ledsakt == 1 )); then
	ledsteuerung
fi

#Prüft ob der RSE (Rundsteuerempfängerkontakt) geschlossen ist, wenn ja wird die Ladung pausiert.
if (( rseenabled == 1 )); then
	read rsestatus <ramdisk/rsestatus
	read rseaktiv <ramdisk/rseaktiv
	if (( rsestatus == 1 )); then
		echo "RSE Kontakt aktiv, pausiere Ladung" > ramdisk/lastregelungaktiv
		if (( rseaktiv == 0 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt aktiviert, ändere Lademodus auf Stop"
			echo "$lademodus" > ramdisk/rseoldlademodus
			echo "$STOP3" > ramdisk/lademodus
			mosquitto_pub -r -t openWB/set/ChargeMode -m "$STOP3"
			echo 1 > ramdisk/rseaktiv
		fi
	else
		if (( rseaktiv == 1 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt deaktiviert, setze auf alten Lademodus zurück"
			read rselademodus <ramdisk/rseoldlademodus
			echo "$rselademodus" > ramdisk/lademodus
			mosquitto_pub -r -t openWB/set/ChargeMode -m "$rselademodus"
			echo 0 > ramdisk/rseaktiv
		fi
	fi
fi



 
if IncVar evsemodbustimer 30 ; then
       openwbDebugLog "MAIN" 1 "call evse modbus check, every 5 minutes IncVar"
   	evsemodbuscheck5
fi


# YourCharge, Slave Mode, openWB als Ladepunkt nutzen

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
	if (( tcurrent > aagrenze )); then # handlungsbedarf, summe > grenze
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
			runs/set-current.sh "$agrenze" all   # alle auf 8 damit summe nicht>16
			openwbDebugLog "CHARGESTAT" 0 "Alle Ladepunkte, Loadsharing LP1-LP2 aktiv. Setze Ladestromstärke auf $agrenze (EXIT 0)"
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
read anzahlphasen <ramdisk/anzahlphasen
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
	openwbDebugLog "PV" 0 "LP1 aktive Phasen während Ladung= $anzahlphasen"
	openwbDebugLog "MAIN" 1 "--NurPV LP1 aktive Phasen während Ladung= $anzahlphasen"
else
	# wir laden nicht, könten aber daher future-phasen bestimmen 
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
#				openwbDebugLog "MAIN" 1 " -- NurPV Setze Anzahl Phasen fix = 1 bei NurPV bei keiner Ladung"
#		fi
	else # nicht angesteckt oder disabled
		anzahlphasen=0
	fi
	openwbDebugLog "PV" 0 "LP1 Anzahl Phasen während keiner Ladung= $anzahlphasen"
	openwbDebugLog "MAIN" 1 "--NurPV LP1 Anzahl Phasen während keiner Ladung= $anzahlphasen"
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
		openwbDebugLog "PV" 0 "LP2 Anzahl Phasen während Ladung= $lp2anzahlphasen"
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
		openwbDebugLog "PV" 0 "LP2 Anzahl Phasen während keiner Ladung= $lp2anzahlphasen"
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
openwbDebugLog "MAIN" 1 "-- NurPV regel.sh Gesamt Anzahl Phasen= $anzahlphasen (0..24 korrigiert)"

########################
# Sofort Laden
if (( lademodus == $SOFORT0 )); then
	sofortlademodus
	# Exit 0 if aktiv
fi

########################
# Berechnung für PV Regelung
if [[ $nurpv70dynact == "1" ]]; then
	read nurpv70status <ramdisk/nurpv70dynstatus
	if [[ $nurpv70status == "1" ]]; then
		uberschuss=$((uberschuss - nurpv70dynw))           # ue - 6000 = 
		# Schwelle zum Beginn der Ladung
		mindestuberschuss=0
		# Schwelle zum Beenden der Ladung
		abschaltuberschuss=-1500
		#abschaltuberschuss=$((minimalapv * 230 * anzahlphasen))
		openwbDebugLog "MAIN" 1 "PV 70% aktiv! derzeit genutzter Überschuss $uberschuss"
		openwbDebugLog "PV" 0 "70% Grenze aktiv. Alter Überschuss: $((uberschuss + nurpv70dynw)), Neuer verfügbarer Uberschuss: $uberschuss"
		openwbDebugLog "MAIN" 1 "--NurPV 70% Grenze aktiv. Alter Überschuss: $((uberschuss + nurpv70dynw)), Neuer verfügbarer Uberschuss: $uberschuss"
		bmeld "Bat70 aktiv => U:${uberschuss}W"
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

meld "Ü$uberschuss"

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



openwbDebugLog "MAIN" 1 "Regulation normal end (EXIT 0)"

