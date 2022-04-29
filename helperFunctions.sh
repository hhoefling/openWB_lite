#!/bin/bash


writeifchanged()
{
 sollstate=$1
 solltxt=$2
 token=$3
 cf="/var/www/html/openWB/ramdisk/${4}_scache"
 t1=${5:-faultState}
 t2=${6:-faultStr}
 checktxt="${sollstate}##${solltxt}"
 
 if ! [ -f $cf ]; then
	  cached=""
 else
    cached=$(<$cf)
 fi
 #openwbDebugLog "MAIN" 0 "checkcache [$checktxt] [$cf] [$cached] $t1 $t2"
 if [[ "$cached" != "$checktxt" ]] ; then
		echo $checktxt >$cf
		mosquitto_pub -t "openWB/set/${token}/$t1" -r -m "$sollstate"
		mosquitto_pub -t "openWB/set/${token}/$t2" -r -m "$solltxt"
 fi
}

export -f writeifchanged

openwbModulePublishState() {
	# $1: Modultyp (EVU, LP, EVSOC, PV, BAT)
	# $2: Status (0=Ok, 1=Warning, 2=Error)
	# $3: Meldung (String)
	# $4: Index (bei LP und PV und EVSOC)
	case $1 in
		"EVU")
			if (( $# != 3 )); then
				echo "openwbPublishStatus: Wrong number of arguments: EVU $#"
			else
		    writeifchanged "$2" "$3" "evu" "evu"
			fi
			;;
		"LP")
			if (( $# != 4 )); then
				echo "openwbPublishStatus: Wrong number of arguments: LP $#"
			else
		    writeifchanged "$2" "$3" "lp/${4}" "lp_${4}"
			fi
			;;
		"EVSOC")
			if (( $# != 4 )); then
				echo "openwbPublishStatus: Wrong number of arguments: EVSOC $#"
			else
		    writeifchanged "$2" "$3" "lp/${4}" "lp_${4}" "socFaultState" "socFaultStr"
			fi
			;;
		"PV")
			if (( $# != 4 )); then
				echo "openwbPublishStatus: Wrong number of arguments: PV $#"
			else
		    writeifchanged "$2" "$3" "pv/${4}" "pv_${4}"
			fi
			;;
		"BAT")
			if (( $# != 3 )); then
				echo "openwbPublishStatus: Wrong number of arguments: BAT $#"
			else
		    writeifchanged "$2" "$3" "houseBattery" "houseBattery"
			fi
			;;
		*)
			echo "openwbPublishStatus: Unknown module type: $1"
			;;
	esac
}


export -f openwbModulePublishState

openwbDebugLog() {
	# $1: Channel (MAIN=default, EVSOC, PV, MQTT, RFID, SMARTHOME, CHARGESTAT, DEB)
	# $2: Level (0=Info, 1=Regelwerte , 2=Berechnungsgrundlage)
	# $3: Meldung (String)
	LOGFILE="/var/log/openWB.log"
	timestamp=$(date +"%Y-%m-%d %H:%M:%S")

	if [[ -z "${debug:-}" ]]; then
		# enable all levels as global $debug is not set up yet
		DEBUGLEVEL=2
	else
		DEBUGLEVEL=$debug
	fi
	# echo "LVL: $2 DEBUG: $debug DEBUGLEVEL: $DEBUGLEVEL" >> $LOGFILE
	if (( $2 <= DEBUGLEVEL )); then
		case $1 in
			"DEB")
				LOGFILE="/var/www/html/openWB/ramdisk/dbg.log"
				;;
			"EVSOC")
				LOGFILE="/var/www/html/openWB/ramdisk/soc.log"
				;;
			"PV")
				LOGFILE="/var/www/html/openWB/ramdisk/nurpv.log"
				;;
			"MQTT")
				LOGFILE="/var/www/html/openWB/ramdisk/mqtt.log"
				;;
			"RFID")
				LOGFILE="/var/www/html/openWB/ramdisk/rfid.log"
				;;
			"SMARTHOME")
				LOGFILE="/var/www/html/openWB/ramdisk/smarthome.log"
				;;
			"CHARGESTAT")
				LOGFILE="/var/www/html/openWB/ramdisk/ladestatus.log"
				;;
			*)
				# MAIN
				LOGFILE="/var/log/openWB.log"
				;;
		esac
		if (( DEBUGLEVEL > 0 )); then
			echo "$timestamp: $$ $3 (LV$2) at $(caller 0)" >> $LOGFILE
		else
			echo "$timestamp: $$ $3 (LV$2)" >> $LOGFILE
		fi
	fi
}

export -f openwbDebugLog
