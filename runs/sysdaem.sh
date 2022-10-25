#!/bin/bash

########## Re-Run as PI if not 
[ "$USER" != "pi" ] && exec su pi "$0" -- "$@"

OPENWBBASEDIR=$(cd `dirname $0`/../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "$0: Seems like openwb.conf is not loaded. Reading file."
	source $OPENWBBASEDIR/loadconfig.sh
	source $OPENWBBASEDIR/helperFunctions.sh
fi

# at first call,  script ist starts up normaly
# ar next call, new call terminate (allready running)
# with "restart" as param, New instance is runnung with new Vars from  openWB.conf
#

if [[ "$1" == "restart" ]] ; then
   pgrep -f "runs/sysdaem.sh" | grep -v "^$$$"  | xargs kill >/dev/null 2>&1
   sleep 1
   openwbDebugLog "MAIN" 0 "restart requested, killed old Instance killed."
fi
if pidof -x -o $$ "${BASH_SOURCE[0]}" >/dev/null
then
	openwbDebugLog "MAIN" 0 "Previous sysdaemon active, exit now"
	exit
fi


function cleanup()
{
  openwbDebugLog "DEB" 0 "**** Stop"
  openwbDebugLog "MAIN" 0 "**** Stop"
}
trap cleanup EXIT
openwbDebugLog "DEB" 0 "**** Start as $USER."
openwbDebugLog "MAIN" 0 "**** Start as $USER."


loop=0

declare	-A cache

putter()
{
  local val="$1"
  local name=$2
  local topic=${3:-""}
  if [[ "$val" != "${cache[$name]}" ]] ; then
    cache[$name]="$val"
	#openwbDebugLog "DEB" 1 "$name now [${cache[$name]}] topic:$topic"
	openwbDebugLog "DEB" 1 "$name now [${cache[$name]}]"
    if [[ "$topic" != "" ]] ; then
       mosquitto_pub -r -t "$topic" -m "$val"
    fi
  fi
}


while true 
do
	let loop=($loop + 1)	# darf ruhig modulo gehen
	sleep 5
	openwbDebugLog "DEB" 1 "---- ausgeschlafen, $loop"
	if (( loop >= 10 )) ; then
		#for key in "${!cache[@]}"; do echo "$key => [${cache[$key]}]"; done
		unset cache
		declare	-A cache
		openwbDebugLog "DEB" 1 "clear cache"
		loop=0
	fi

	val=$( date '+%s' )
	putter "$val" "systime" "openWB/system/Timestamp"

	val=$(/usr/bin/uptime )
	putter "$val" "uptime" "openWB/system/Uptime"


	val=$(cat /proc/stat | grep btime | awk '{print $2}' )
	putter "$val" "lastreboot" "openWB/system/lastReboot"
	putter "$(date --date="@${val}" "+%d.%m.%Y %H:%M" )" "lastrebootstr" "openWB/system/lastRebootStr"


	val=$(uname -m)
	putter "$val" "arch" "openWB/global/cpuArch"
	arch="$val"
	
	val=$(ps aux | awk 'NR > 0 { s +=$3 }; END {print s}' )
	putter "$val" "cpuuse" "openWB/global/cpuUse"

	if (( loop == 0 )) ; then
	   if [[ "$arch" == "x86_64" ]] ; then
	   	val=""
	   else
		val=$(cat /sys/firmware/devicetree/base/model | sed 's/\x00//g' )
	   fi
	   putter "$val" "board" "openWB/global/board"
	fi
	
	if [[ "$arch" == "x86_64" ]] ; then
		val=""
	else 		
		val=$(cat /sys/class/thermal/thermal_zone0/temp)
		val=$(echo "scale=2; $(echo $val) / 1000" | bc)
	fi
	putter "$val" "cputemp" "openWB/global/cpuTemp"


	if [[ "$arch" == "x86_64" ]] ; then
		val=""
	else 		
		val=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
		val=$(echo "scale=0; $(echo $val) / 1000" | bc)
	fi
	putter "$val" "cpufreq" "openWB/global/cpuFreq"

    
	if (( loop == 0 )) ; then

	   val=$(cat /proc/cpuinfo | grep -m 1 "model name" |  sed "s/^.*: //"  )
	   putter "$val" "cpumodel" "openWB/global/cpuModel"

    	if [[ "$arch" == "x86_64" ]] ; then
	       	val=""
	   else 		
		  val=$( sudo ifconfig wlan0 |grep 'inet ' |awk '{print $2}' )
	   fi
	   putter "$val" "wlanip1" "openWB/global/wlanaddr"

	   if [[ "$arch" == "x86_64" ]] ; then
		  val=""
	   else 		
	   	   val=$(sudo ifconfig wlan0:0 |grep 'inet ' |awk '{print $2}' )
	   fi
	   putter "$val" "wlanip2" "openWB/global/wlanaddr2"

	   if [[ "$arch" == "x86_64" ]] ; then
	   	   val=""
	   else 		
		  val=$(sudo ifconfig eth0 |grep 'inet ' |awk '{print $2}' )
	   fi
	   putter "$val" "ethip1" "openWB/global/ethaddr"

	   if [[ "$arch" == "x86_64" ]] ; then
		  val=""
	   else 		
		  val=$(sudo ifconfig eth0:0 |grep 'inet ' |awk '{print $2}' )
	   fi
	   putter "$val" "ethip2" "openWB/global/ethaddr2"

	   val=$(free -m | grep 'Mem' | awk '{print $2}' )
	   putter "$val" "memtot" "openWB/global/memTot"

	   val=$(lsblk -r | egrep 'part /$'  | cut -d ' ' -f 1 )
	   putter "$val" "rootdev" "openWB/global/rootDev"
       
    fi


	val=$(df -h | grep  ramdisk | awk '{print $2}')
	putter "$val" "tmptot" "openWB/global/tmpTot"

	val=$(df -h | grep  ramdisk | awk '{print $3}')
	putter "$val" "tmpuse" "openWB/global/tmpUse"

	val=$(df -h | grep  ramdisk | awk '{print $4}')
	putter "$val" "tmpfree" "openWB/global/tmpFree"

	val=$(df -h | grep  ramdisk | awk '{print $5}')
	putter "$val" "tmpusedprz" "openWB/global/tmpUsedPrz"

	val=$(df -h | grep  "/$" | awk '{print $2}')
	putter "$val" "disktot" "openWB/global/diskTot"

	val=$(df -h | grep  "/$" | awk '{print $3}')
	putter "$val" "diskuse" "openWB/global/diskUse"

	val=$(df -h | grep  "/$" | awk '{print $4}')
	putter "$val" "diskfree" "openWB/global/diskFree"

	val=$(df -h | grep  "/$" | awk '{print $5}')
	putter "$val" "diskusedprz" "openWB/global/diskUsedPrz"
    
    
	val=$(free -m | grep 'Mem' | awk '{print $3}' )
	putter "$val" "memuse" "openWB/global/memUse"

	val=$(free -m | grep 'Mem' | awk '{print $7}' )
	putter "$val" "memfree" "openWB/global/memFree"

	
done

openwbDebugLog "DEB" 0 "**** End."
exit 0

