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

cd /var/www/html/openWB/ || exit 1
# use kostant ramdisk  , no var RAMDISK 




source helperFunctions.sh


# NC mach regler.sh schon
# if pidof -x -o $$ "${BASH_SOURCE[0]}"
# then
#	openwbDebugLog "MAIN" 0 "Previous regulation loop still running. EXIT 1"
# 	exit 1
# fi

if [ -e ramdisk/updateinprogress ] && [ -e ramdisk/bootinprogress ]; then
	read -r updateinprogress <ramdisk/updateinprogress
	read -r bootinprogress  <ramdisk/bootinprogress
	if (( updateinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Update in progress (EXIT 0)"
		exit 0
	elif (( bootinprogress == "1" )); then
		openwbDebugLog "MAIN" 0 "Boot in progress (EXIT 0)"
		exit 0
	fi
else
	openwbDebugLog "MAIN" 0 "Ramdisk not set up. Maybe we are still booting. (EXIT 0)"
	exit 0
fi

########### Laufzeit protokolieren
startregel=$(date +%s)
function cleanup()
{
	local endregel=$(date +%s)
	local t=$((endregel-startregel))
	openwbDebugLog "DEB" 0 "**** Regulation loop needs $t Sekunden"
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


#config file einlesen, auch debug mode, vorher defaults=2
ptstart
 source loadconfig.sh
ptend loadconfig 200

#######################
openwbDebugLog "MAIN" 0 "TIME ** Regulation loop start ($HOME)****"



needgoe=$( [[ ( "$evsecon" == "goe" ) \
           || ( "$lastmanagement"   == "1" && "$evsecons1" == "goe" ) \
           || ( "$lastmanagements2" == "1" && "$evsecons2" == "goe" ) \
           ]] && echo 1 || echo 0 )
neednrgkick=$( [[ ( "$evsecon" == "nrgkick" ) \
               || ( "$lastmanagement"   == "1" && "$evsecons1" == "nrgkick" ) \
               ]] && echo 1 || echo 0 )
openwbDebugLog "MAIN" 1 "needgoe:[$needgoe] neednrgkick:[$neednrgkick] "



ptstart

# Must be first
source loadvars.sh

(( lademodus == 1 )) && source minundpv.sh
(( lademodus == 2 )) && source nurpv.sh
(( lademodus == 3 )) &&	source auslademodus.sh
(( lademodus == 4 )) &&	source semiauslademodus.sh
(( lademodus == 0 )) && source sofortlademodus.sh
(( needgoe == 1 )) && 	source goecheck.sh
						source graphing.sh
						source nachtladen.sh
(( zielladenaktivlp1 == 1 )) && source zielladen.sh
						source evsedintest.sh
						source geraete.sh
						source events.sh  
						source verbraucher.sh
(( u1p3paktiv == 1 )) && source u1p3p.sh
(( neednrgkick==1 )) && source nrgkickcheck.sh
(( rfidakt==1 )) && 	source rfidtag.sh
(( ledsakt == 1 )) && 	source leds.sh


ptend "sourceing" 50




date=$(date)
re='^-?[0-9]+$'
if [[ $isss == "1" ]]; then
	read -r heartbeat <ramdisk/heartbeat
	heartbeat=$((heartbeat+10))
	echo $heartbeat > ramdisk/heartbeat
	mosquitto_pub -r -t "openWB/system/Uptime" -m "$(uptime)"
	mosquitto_pub -r -t "openWB/system/Timestamp" -m "$(date +%s)"
	mosquitto_pub -r -t "openWB/system/Date" -m "$(date)"
	openwbDebugLog "MAIN" 1 "ISSS mode (EXIT 0)"
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
		openwbDebugLog "MAIN" 1 "**** Regulation speed2-loop exits (EXIT 0)"
		exit 0
	else
		echo 0 > ramdisk/5sec
	fi
fi

## NC
## ts=$(date +%s)
## # process autolock
## ./processautolock.sh &
## t=$(( $(date +%s) - ts))
## if (( t > 1))  ; then
##   openwbDebugLog "DEB" 0 " ************* $t for autolock"
## fi



ptstart
#ladelog ausfuehren   nun 24 Std HH
#ladelog ausfuehren # Asncron , keine rückwirkung auf Variablen                           
 [ -e ./ladelog.sh ]  &&  ( ./ladelog.sh &  )
 [ -e ./ladelog2.sh ] &&  ( ./ladelog2.sh & )
# ./ladelog.sh &
ptend "ladelog" 50


read graphtimer <ramdisk/graphtimer
if (( graphtimer < 5 )); then
	graphtimer=$((graphtimer+1))
	echo $graphtimer > ramdisk/graphtimer
else
	graphtimer=0
	echo $graphtimer > ramdisk/graphtimer
fi
#######################################

if (( displayaktiv == 1 )); then
	read -r execdisplay  <ramdisk/execdisplay
	if (( execdisplay == 1 )); then
		export DISPLAY=:0 && xset s $displaysleep && xset dpms $displaysleep $displaysleep $displaysleep
		echo 0 > ramdisk/execdisplay
		openwbDebugLog "MAIN" 1 "EXEC runs/displaybacklight.sh $displayLight"
		sudo runs/displaybacklight.sh $displayLight
	fi
fi


#######################################
# check rfid
#moved in loadvars

ptstart

#goe mobility check
(( $needgoe==1)) &&  goecheck

# nrgkick mobility check
(( $neednrgkick==1 )) && nrgkickcheck

ptend "gocheck and nkhickcheck" 20


LadereglerTxt=""
BatSupportTxt=""
function endladeregler()
{
 openwbDebugLog "MAIN" 0 "LadereglerTxt: $LadereglerTxt $BatSupportTxt"
 mosquitto_pub -r -t "openWB/global/strLaderegler" -m "${LadereglerTxt:-None} "
 mosquitto_pub -r -t "openWB/global/strBatSupport" -m "${BatSupportTxt:-None} "
}
trap_befor endladeregler EXIT 

ptstart
loadvars
ptend loadvars 2000
openwbDebugLog "MAIN" 1 "Zeit zum abfragen aller Werte $pt Millisekunden"

############### geratet ###############
ptstart
geraete
ptend geraete 10

############# verbraucher vorgezogen in loadvars ############# 
# ptstart
# verbraucher
# ptend verbraucher 30

############# events und webhooks ##############
ptstart
webhooks
ptend webhooks 10


################ Graphing immer auch bei blockall, daher vorgezogen
ptstart
graphing
ptend graphing 600 


###########################
if (( u1p3paktiv == 1 )); then
	read -r blockall <ramdisk/blockall
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "U1P3 ----- Phasenumschaltung aktiv... beende  (EXIT 0) -----"
		exit 0
	fi
fi

# Double check, if lp is disabled and ladeleistung trotzdem noch da, dann Clear to 0
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
# Delete LP4-8

#EVSE DIN Modbus test
ptstart 
evsedintest

#u1p3p switch
if (( u1p3paktiv == 1 )); then
	openwbDebugLog "MAIN" 0 "U1P3 Start u1p3switsch"
	u1p3pswitch
	openwbDebugLog "MAIN" 0 "U1P3 End u1p3switsch"
	read -r blockall <ramdisk/blockall
	if (( blockall == 1 )); then
		openwbDebugLog "MAIN" 1 "U1P3 Phasenumschaltung wurde aktiviert... beende (EXIT 0)"
		exit 0
	fi
fi

#Graphing
#graphing

if (( cpunterbrechunglp1 == 1 )); then
	if (( plugstat == 1 )) && (( lp1enabled == 1 )); then
		if (( llalt > 5 )); then
			if (( ladeleistung < 100 )); then
				read -r cpulp1waraktiv <ramdisk/cpulp1waraktiv
				read -r cpulp1counter <ramdisk/cpulp1counter
				if (( cpulp1counter > 5 )); then
					if (( cpulp1waraktiv == 0 )); then
						openwbDebugLog "MAIN" 0 "CP Unterbrechung an LP1 wird durchgeführt"
						openwbDebugLog "CHARGESTAT" 0 "CP Unterbrechung an LP1 wird durchgeführt"
						mosquitto_pub -r -t openWB/global/cplp1_inwork -m "1"
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
						mosquitto_pub -r -t openWB/global/cplp1_inwork -m "0"
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
				read -r cpulp2waraktiv <ramdisk/cpulp2waraktiv
				read -r cpulp2counter <ramdisk/cpulp2counter
				if (( cpulp2counter > 5 )); then
					if (( cpulp2waraktiv == 0 )); then
						mosquitto_pub -r -t openWB/global/cplp2_inwork -m "1"
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
						mosquitto_pub -r -t openWB/global/cplp2_inwork -m "0"
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

if [[ $dspeed == "3" ]]; then
	if [ -e ramdisk/5sec ]; then
		read -r regeltimer <ramdisk/5sec
		if (( regeltimer < 5 )); then
			regeltimer=$((regeltimer+1))
			echo $regeltimer > ramdisk/5sec
			openwbDebugLog "MAIN" 1 "**** Regulation speed3-loop exits (EXIT 0)"
			exit 0
		else
			regeltimer=0
			echo $regeltimer > ramdisk/5sec
		fi
	else
		echo 0 > ramdisk/5sec
	fi
fi

if (( ledsakt == 1 )); then
	ledsteuerung
fi

#Prüft ob der RSE (Rundsteuerempfängerkontakt) geschlossen ist, wenn ja wird die Ladung pausiert.
if (( rseenabled == 1 )); then
	read -r rsestatus <ramdisk/rsestatus
	read -r rseaktiv <ramdisk/rseaktiv
	if (( rsestatus == 1 )); then
		echo "RSE Kontakt aktiv, pausiere Ladung" > ramdisk/lastregelungaktiv
		if (( rseaktiv == 0 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt aktiviert, ändere Lademodus auf Stop"
			echo "$lademodus" > ramdisk/rseoldlademodus
			echo 3 > ramdisk/lademodus
			mosquitto_pub -r -t openWB/global/ChargeMode -m "3"
			echo 1 > ramdisk/rseaktiv
		fi
	else
		if (( rseaktiv == 1 )); then
			openwbDebugLog "CHARGESTAT" 0 "RSE Kontakt deaktiviert, setze auf alten Lademodus zurück"
			read -r rselademodus <ramdisk/rseoldlademodus
			echo "$rselademodus" > ramdisk/lademodus
			mosquitto_pub -r -t openWB/global/ChargeMode -m "$rselademodus"
			echo 0 > ramdisk/rseaktiv
		fi
	fi
fi

#evse modbus check alle 5 minuten
read evsemodbustimer <ramdisk/evsemodbustimer
if (( evsemodbustimer < 30 )); then
	evsemodbustimer=$((evsemodbustimer+1))
	echo $evsemodbustimer > ramdisk/evsemodbustimer
else
	evsemodbustimer=0
	echo $evsemodbustimer > ramdisk/evsemodbustimer
	evsemodbuscheck
fi




#Lademodus 3 == Stop
if (( lademodus == 3 )); then
	auslademodus	# Exit 0 !!!!
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
			openwbDebugLog "CHARGESTAT" 0 "Alle Ladepunkte, Loadsharing LP1-LP2 aktiv. Setze Ladestromstärke auf $agrenze (EXIT 0)"
			exit 0
		fi
	fi
fi


#########################################
#Regelautomatiken
#########################################
#
# Schritt 1 ,  Ist Zustand bewerten
#				wenn Laden -> ANzahl Phasen
#				Überschuss bestimmen
#
# Schirtt 2 	NICHT LADEN, sollen wir starten? 
#				cp testen wenn ladung nicht angenommen wird
#				phasen auf mode vorbereiten
#				ende
#
# Schirtt 3 	LADEN, sollen wir abschalten
#				Endzeiten prüfen , Zeitladen (standby)
#				preis-ende prüfen, Preisladen (sofort)
#				End-Soc Erreicht (alle)
#				if stop -> Ende
#
# Schritt 4 	Wird laden
#				lademengte nachführem	immer
#				manual soc nachführen	immer
#				Ladestrom an mindeststrom anpassen (minpv)
#				Ladestrom an überschuss anpassen (pv)
#				Ladestrom an vorgabe anpassen
#				u1p3 testen, timer
#				u1p3 schalten 			-> Ende
#				ladesrom setzen -> ende
#
#########################################


#########################################
#########################################
#         Zielladen 
# Exit 0 if Laden aktive         
(( zielladenaktivlp1 == 1 )) &&  ziellademodus
#########################################
#########################################

####################
# Nachtladung bzw. Ladung bis SOC x% nachts von x bis x Uhr
prenachtlademodus
# Exit 0 if laden aktive

#######################
#Ladestromstarke berechnen
read -r anzahlphasen <ramdisk/anzahlphasen
if (( anzahlphasen > 9 )); then
	anzahlphasen=1
fi

# mehr als 3A gelten als "Laden"
declare -ri LLPHASENTEST=3


llphasentest=3
openwbDebugLog "PV" 0 "Alte Anzahl genutzter Phasen= $anzahlphasen"
#Anzahl genutzter Phasen ermitteln, wenn ladestrom kleiner 3 (nicht vorhanden) nutze den letzten bekannten wert
if (( llalt > LLPHASENTEST )); then
	anzahlphasen=0
	if (( lla1 >= LLPHASENTEST )); then
		anzahlphasen=$((anzahlphasen + 1 ))
	fi
	if (( lla2 >= LLPHASENTEST )); then
		anzahlphasen=$((anzahlphasen + 1 ))
	fi
	if (( lla3 >= LLPHASENTEST )); then
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
			read -r anzahlphasen <ramdisk/u1p3pstat
			openwbDebugLog "PV" 0 "LP1 u1p3aktiv, nehme u1p3pstat:$u1p3pstat als mogliche phasenanzahl"
		else
		    openwbDebugLog "PV" 0 "LP1 nehme letzte phasenanzzahl als mogliche phasenanzahl"
			if [ -f ramdisk/lp1anzahlphasen ]; then
				read -r anzahlphasen <ramdisk/lp1anzahlphasen
			else
				read -r anzahlphasen <ramdisk/anzahlphasen
			fi
		fi
	else # nicht angesteckt oder disabled
		anzahlphasen=0
	fi
	openwbDebugLog "PV" 0 "LP1 Anzahl Phasen während keiner Ladung= $anzahlphasen"
	openwbDebugLog "MAIN" 1 "--NurPV LP1 Anzahl Phasen während keiner Ladung= $anzahlphasen"
fi


lp2anzahlphasen=0
if (( lastmanagement == 1 )); then		# lastmanagement == 1 means that it's on openWB duo
	if (( llas11 > LLPHASENTEST )); then
		if (( llas11 >= LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
			lp2anzahlphasen=1
		fi
		if (( llas12 >= LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
			lp2anzahlphasen=$((lp2anzahlphasen + 1 ))
		fi
		if (( llas13 >= LLPHASENTEST )); then
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
			if (( u1p3plp2aktiv == 1 )); then   ## immmer false da variable unbekannt
				read -r lp2anzahlphasen <ramdisk/u1p3pstat
				anzahlphasen=$((lp2anzahlphasen + anzahlphasen))
			else
				if [ ! -f ramdisk/lp2anzahlphasen ]; then
					echo 1 > ramdisk/lp2anzahlphasen
					anzahlphasen=$((anzahlphasen + 1 ))
				else
					read -r lp2anzahlphasen <ramdisk/lp2anzahlphasen
					anzahlphasen=$((lp2anzahlphasen + anzahlphasen))
				fi
			fi
		fi
		openwbDebugLog "PV" 0 "LP2 Anzahl Phasen während keiner Ladung= $lp2anzahlphasen"
	fi
fi
if (( lastmanagements2 == 1 )); then
	if (( llas21 > LLPHASENTEST )); then
		if (( llas21 >=  LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
		fi
		if (( llas22 >= LLPHASENTEST )); then
			anzahlphasen=$((anzahlphasen + 1 ))
		fi
		if (( llas23 >= LLPHASENTEST )); then
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
meld "P$anzahlphasen"


#########################################
# Nun aktionen RCT
#########################################
HB_enable_priceloading=-1
[ -e ramdisk/HB_enable_priceloading ]  &&  read HB_enable_priceloading <ramdisk/HB_enable_priceloading
# openwbDebugLog "MAIN" 1 "RCT: HB_enable_priceloading:[$HB_enable_priceloading]" 


if (( HB_enable_priceloading >= 0 )) ; then  # also definiert egaal ob an der aus, somit rct da
 if (( HB_enable_priceloading > 0 )) ; then
   # openwbDebugLog "MAIN" 1 "RCT: HB_enable_priceloading:[$HB_enable_priceloading] etprovideraktiv:[$etprovideraktiv]" 
   if (( etprovideraktiv )); then
      read -r actualprice <ramdisk/etproviderprice
      read -r etprovidermaxprice <ramdisk/etprovidermaxprice
      read -r loadWatt <ramdisk/HB_loadWatt

      openwbDebugLog "MAIN" 2 "RCT: aktiv check, price: [$actualprice] max:[$etprovidermaxprice] loadWatrr:[$loadWatt]"
      if (( $(echo "$actualprice <= $etprovidermaxprice" |bc -l) )); then
            #price lower than max price, enable charging
            if (( $(echo "$loadWatt <= 100.0" |bc -l) )); then
                openwbDebugLog "MAIN" 2 "RCT: aktiviere Batterie-Ladung (preisbasiert)"
                mosquitto_pub -q 2 -r -t openWB/set/houseBattery/priceload -m "1"
            else
                openwbDebugLog "MAIN" 2 "RCT allready loading"
            fi        
     else
            #price higher than max price, disable loadbat 
            if (( $(echo "$loadWatt > 100.0" |bc -l) )); then
                openwbDebugLog "MAIN" 1 "RCT: Deaktiviere Battery-Ladung (preisbasiert)"
                mosquitto_pub -q 2 -r -t openWB/set/houseBattery/priceload -m "0"
            else
                openwbDebugLog "MAIN" 2 "RCT: Battery not loading, no offswitch needed"
            fi        
     fi
  else   
     openwbDebugLog "MAIN" 1 "RCT no etprovider "
  fi
  else
     openwbDebugLog "MAIN" 1 "RCT Disabled priceloading:[$HB_enable_priceloading] "
  fi

# wenn loadbat aktive, dann per Timer soc-abschaltung testen
 if test $(find ramdisk/HB_load_minutes  -not -newermt '-30 seconds' 2>/dev/null) ; then
    read -r load_minutes <ramdisk/HB_load_minutes
    if (( (load_minutes > 0) )) ; then
        openwbDebugLog "MAIN" 1 "RCT Batladen aktiv, Send timer via mqtt"
        mosquitto_pub -q 2 -r -t openWB/set/houseBattery/hooker -m "timer"
    fi
  else
   openwbDebugLog "MAIN" 2 "RCT No timer, skip rct_setter "
 fi

fi  

# 



#########################################
#     Sofortladen
#########################################
# Exit 0 if aktiv,  most of time it exits
(( lademodus == 0 )) && sofortlademodus
#########################################

########################
# Berechnung für PV Regelung
if [[ $nurpv70dynact == "1" ]]; then
	read -r nurpv70status <ramdisk/nurpv70dynstatus
	if [[ $nurpv70status == "1" ]]; then
		openwbDebugLog "MAIN" 1 "PV 70% aktiv! derzeit genutzter Überschuss $uberschuss"
		# Setze Ladeleistung so das maximal 70% einspeisung übrig bleibt
		# nur sinvol wenn akteller überschuss > anregelgrenze ist 
		# also PKW soll die oberen 30% nutzen die abgeregelt (sind/werden)
		uberschuss=$((uberschuss - nurpv70dynw))           # ue - 6000 = 
		# Schwelle zum Beginn der Ladung
		mindestuberschuss=0
		# Schwelle zum Beenden der Ladung
		abschaltuberschuss=-1500
		#abschaltuberschuss=$((minimalapv * 230 * anzahlphasen))
		  openwbDebugLog "PV" 0 "--NurPV 70% Grenze aktiv. Alter Überschuss: $((uberschuss + nurpv70dynw)), Neuer verfügbarer Uberschuss: $uberschuss"
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
openwbDebugLog "MAIN" 2 "uberschuss $uberschuss wattbezug $wattbezug ladestatus $ladestatus llsoll $llalt pvwatt $pvwatt"
openwbDebugLog "MAIN" 2 "mindestuberschussphasen $mindestuberschussphasen wattkombiniert $wattkombiniert schaltschwelle $schaltschwelle"

meld "Ü$uberschuss"


(( lademodus == 1 )) && minundpvlademodus;   
(( lademodus == 2 )) && nurpvlademodus;    
(( lademodus == 4 )) && semiauslademodus;    


########################
#Min Ladung + PV Uberschussregelung lademodus 1
#if (( lademodus == 1 )); then
#	minundpvlademodus
#fi

########################
#NUR PV Uberschussregelung lademodus 2
# wenn evse aus und $mindestuberschuss vorhanden, starte evse mit 6A Ladestromstaerke (1320 - 3960 Watt je nach Anzahl Phasen)
# return 0 (no exit anymore)
#if (( lademodus == 2 )); then
#	nurpvlademodus
#fi

########################
#Lademodus 4 == Standby
#if (( lademodus == 4 )); then
#	semiauslademodus
#fi

########################
openwbDebugLog "MAIN" 1 "Regulation normal end (EXIT 0)"
exit 0

