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
    read cached <$cf
 fi
 #openwbDebugLog "MAIN" 0 "checkcache [$checktxt] [$cf] [$cached] $t1 $t2"
 if [[ "$cached" != "$checktxt" ]] ; then
		echo $checktxt >$cf
		mosquitto_pub -t "openWB/set/${token}/$t1" -r -m "$sollstate"
		mosquitto_pub -t "openWB/set/${token}/$t2" -r -m "$solltxt"
		openwbDebugLog "MAIN" 2 "writeifchanged:  $token $sollstate $solltxt"
		openwbDebugLog "ERR" 0 "ERR: $token $sollstate $solltxt"
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


rlog()  # rlog TAG Messages
{
 if [[ -n "$debloggerip" ]] ; then
   d=$1
   shift;
   logger --id=$$ -t $d -n $debloggerip -- $*
 fi
}
export -f rlog

openwbDebugLog() {
	# $1: Channel (MAIN=default, EVSOC, PV, MQTT, RFID, SMARTHOME, CHARGESTAT, DEB, EVENT, ERR)
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
			"ERR")
				LOGFILE="/var/log/openwb.error.log"
				;;
			"DEB")
				LOGFILE="/var/www/html/openWB/ramdisk/dbg.log"
				;;
			"EVENT")
				LOGFILE="/var/www/html/openWB/ramdisk/event.log"
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
		
		
        if [ "$$" != "$BASHPID" ] ; then
           p="C$BASHPID"
        else
           p="$$"
        fi
		   
		u=$(caller 0)
		u=${u/\/var\/www\/html\/openWB\//}
		if (( DEBUGLEVEL > 0 )); then
			echo "$timestamp: $p $3 (LV$2) at $u" >> $LOGFILE
		else
			echo "$timestamp: $p $3 (LV$2)" >> $LOGFILE
		fi
	fi
	
	
	if ! realpath -e ramdisk >/dev/null 2>&1 ; then
	    echo "$timestamp: $$ Oh no!, wrong basedir: [$(pwd)] " >> $LOGFILE
        echo "$timestamp: $$ switch to /var/www/html/openWB " >> $LOGFILE        
        cd /var/www/html/openWB
	fi
	
}

export -f openwbDebugLog

openwbRunLoggingOutput() {
	$1 2>&1 | while read -r line
	do
		echo "$(date +"%Y-%m-%d %H:%M:%S"): $1: $line" >> "$OPENWBBASEDIR/ramdisk/openWB.log"
	done
}
export -f openwbRunLoggingOutput

#===================================================================

# Increment var with Name $1 to $2 (0..n) default 5
function IncVar()   
{
 local -n pvar=$1
 local -i toval=${2:-"5"}
 local fn="/var/www/html/openWB/ramdisk/${!pvar}"
 # openwbDebugLog "MAIN" 2 "IncVar:  increment file $fn  '${!pvar}'  to $toval"
 pvar=$(cat "$fn" 2>/dev/null); rc=$?
 if [ ! $rc -eq  0 ] ; then
   openwbDebugLog "MAIN" 2 "IncVar: file $fn not found, use 0"
   pvar=0
 fi
	 pvar=$((pvar + 1))
 if (( pvar >= toval )); then
	 pvar=0
         res=0
         openwbDebugLog "MAIN" 2 "IncVar: '$1 has $2 reached"
 else
         res=1
 fi
 echo $pvar >"$fn"
 return "$res"
}

export -f IncVar

# Sample
# if IncVar evsemodbustimer 30 ; then
#   openwbDebugLog "MAIN" 1 "call evse modbus check, every 5 minutes"
#   evsemodbuscheck5
# fi

#===================================================================

function flagIsClear() # $1=name
{
 local -n pvar=$1
 local fn="/var/www/html/openWB/ramdisk/${!pvar}"
 pvar=$(cat "$fn" 2>/dev/null); rc=$?
 if [ ! $rc -eq  0 ] ; then
   openwbDebugLog "MAIN" 2 "Warning flagIsClear: file $fn not found, created as 0"
   pvar=0
 fi
 if(( pvar != 0 )) ; then
     openwbDebugLog "MAIN" 2 "flagIsClear [$1] fired"
 fi
 echo "0" >"$fn"
 return "$pvar"
}

export -f  flagIsClear


# sample
#if ! flagIsClear testfliper2  ; then
#  echo "war auf <>0 gesetzt"
#else
#  echo "war clear"
#fi

#===================================================================
# FUNCTION trap_befor ()
#
# Purpose:  prepend a command to a trap
#
# - 1st arg:  code to prepend
# - remaining args:  names of traps to modify
#
# Example:  trap_befor 'echo "in trap DEBUG"' DEBUG
#
# See: http://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal
#===================================================================
trap_befor() 
{
    trap_add_cmd=$1; shift || fatal "${FUNCNAME} usage error"
    new_cmd=
    for trap_add_name in "$@"; do
        # Grab the currently defined trap commands for this trap
        existing_cmd=`trap -p "${trap_add_name}" |  awk -F"'" '{print $2}'`

        # Define default command
        [ -z "${existing_cmd}" ] && existing_cmd="echo exiting @ `date`"

        # Generate the new command
        new_cmd="${trap_add_cmd};${existing_cmd}"

        # Assign the test
         trap   "${new_cmd}" "${trap_add_name}" || \
                fatal "unable to prepend to trap ${trap_add_name}"
    done
}

#  Sample
# function cleanup()
# {
#  log "**** Regulation ends"
#  }

#  function cleanup2()
# {
# log "**** save values"
# }
 
#  trap cleanup EXIT
#  trap_befor cleanup2 EXIT

export -f trap_befor 

function meld()
{
  LadereglerTxt="$LadereglerTxt,$1"
}
export -f meld 

function bmeld()
{
  BatSupportTxt="$BatSupportTxt,$1"
}
export -f bmeld 
############### profiling Anf
ptx=0
pt=0

declare -F ptstart &>/dev/null || {
 ptstart()
 {
   # TODO EPOCHREALTIME erst ab bash 5.x verfügbar, fehlt in Debian9 , replace with `date +%s%N | cut -bl-13 `
   ptx=$(( ${EPOCHREALTIME/[\,\.]/} / 1000 )) 
 }
export -f ptstart
 ptend()
 {
 local txt=${1:-}
 local max=${2:-200}
 local te
 # TODO EPOCHREALTIME erst ab bash 5.x verfügbar, fehlt in Debian9 , replace with `date +%s%N | cut -bl-13 `
 te=$(( ${EPOCHREALTIME/[\,\.]/} / 1000 )) 
 pt=$(( te - ptx))
 if (( pt > max ))  ; then
   openwbDebugLog "DEB" 1 "TIME **** ${txt} needs $pt ms. (max:$max)"
   openwbDebugLog "MAIN" 2 "TIME **** ${txt} needs $pt ms. (max:$max)"
 fi
 }
} 
export -f ptend 

# Enable all python scripts to import from the "package"-directory without fiddling with sys.path individually
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
export PYTHONPATH="$SCRIPT_DIR/packages"


