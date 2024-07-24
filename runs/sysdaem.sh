#!/bin/bash

########## Re-Run as PI if not
USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" "$@"

OPENWBBASEDIR=$(cd `dirname $0`/../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "$0: Seems like openwb.conf is not loaded. Reading file."
	source $OPENWBBASEDIR/loadconfig.sh
	source $OPENWBBASEDIR/helperFunctions.sh
fi

export LC_ALL='C'
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
    openwbDebugLog "MAIN" 0 "SYSD: Previous sysdaemon active, exit now"
    openwbDebugLog "DEB" 0 "SYSD: Previous sysdaemon active, exit now"
	exit
fi


function cleanup()
{
  openwbDebugLog "DEB" 0 "SYSD: **** Stop"
  openwbDebugLog "MAIN" 0 "SYSD: **** Stop"
}
trap cleanup EXIT
openwbDebugLog "DEB" 0 "SYSD: **** Start as $USER."
openwbDebugLog "MAIN" 0 "SYSD: **** Start as $USER."



declare	-A cache

putter()
{
  local val="$1"
  local name=$2
  local topic=${3:-""}
  if [[ "$val" == "" ]] ; then
    val=" "
  fi 
  if [[ "$val" != "${cache[$name]}" ]] ; then
    openwbDebugLog "DEB" 1 "SYSD: $topic [${cache[$name]:0:30}] => [${val:0:30}] "
    cache[$name]="$val"
    if [[ "$topic" != "" ]] ; then
       mosquitto_pub -r -t "$topic" -m "$val"
    fi
   # else
   #   openwbDebugLog "DEB" 1 "SYSD: $topic [${cache[$name]:0:20}] SAME [${val:0:20}] "
  fi
}

arch=$(uname -m)

function do5min()
{
  putter "$arch" "arch" "openWB/global/cpuArch"

  val=$(cat /proc/cpuinfo | grep -m 1 "model name" |  sed "s/^.*: //"  )
  putter "$val" "cpumodel" "openWB/global/cpuModel"

  val=$(cat /proc/stat | grep btime | awk '{print $2}' )
  putter "$val" "lastreboot" "openWB/system/lastReboot"
  putter "$(date --date="@${val}" "+%d.%m.%Y %H:%M" )" "lastrebootstr" "openWB/system/lastRebootStr"

  if [[ "$arch" == "x86_64" ]] ; then
    val=""
  else
    val=$(cat /sys/firmware/devicetree/base/model | sed 's/\x00//g' )
  fi
  putter "$val" "board" "openWB/global/board"

  val=$(lsblk -r | egrep 'part /$'  | cut -d ' ' -f 1 )
  putter "$val" "rootdev" "openWB/global/rootDev"

  val=$(free -m | grep 'Mem' | awk '{print $2}' )
  putter "$val" "memtot" "openWB/global/memTot"
            
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
}

loop=30     # trigger sofort den 5-Minutenmode
dstart=$(date +"%s")
dlopp=0     # secunden 
while true 
do
    ptstart
    ds=$(date +"%s")
    ((  dloop= (ds - dstart) ))
    let loop=($loop + 1)    # darf ruhig modulo gehen
   
     
    openwbDebugLog "DEB" 1 "SYSD: ---- ausgeschlafen, $loop on $arch dl:$dloop"
    
    if (( loop >= 30 )) ; then  # 30 x 10 = 300 = 5 Minuten
        loop=0
        dstart=$(date +"%s")
        openwbDebugLog "DEB" 1 "SYSD: **** MOD 30 alle 300 sekunden ***"
        #for key in "${!cache[@]}"; do echo "$key => [${cache[$key]}]"; done
        unset cache
        declare    -A cache
        openwbDebugLog "DEB" 1 "SYSD: clear cache"
        
        do5min
    fi
    
    #if (( (loop % 3 ) == 0 )) ; then    
    #    openwbDebugLog "DEB" 1 "SYSD: **** MOD 3 alle 30 sekunden ***"
    #fi
    
    #if (( (loop % 6 ) == 0 )) ; then    
    #    openwbDebugLog "DEB" 1 "SYSD: **** MOD 6 alle 60 sekunden ***"
    #fi

# Do every 10 seconds

# macht weiterhin pubmqtt.sh  als ticker
#	val=$( date '+%s' )
#	putter "$val" "systime" "openWB/system/Timestamp"

	val=$(/usr/bin/uptime )
	putter "$val" "uptime" "openWB/system/Uptime"

	
	val=$(ps aux | awk 'NR > 0 { s +=$3 }; END {print s}' )
	putter "$val" "cpuuse" "openWB/global/cpuUse"


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


    df=$(df -h | grep  ramdisk )
    val=$(echo $df | awk '{print $2}')
	putter "$val" "tmptot" "openWB/global/tmpTot"
	val=$(echo $df | awk '{print $3}')
	putter "$val" "tmpuse" "openWB/global/tmpUse"
	val=$(echo $df | awk '{print $4}')
	putter "$val" "tmpfree" "openWB/global/tmpFree"
	val=$(echo $df | awk '{print $5}')
	val=${val//%}
	putter "$val" "tmpusedprz" "openWB/global/tmpUsedPrz"

    df=$(df -h | grep  "/$" )
    val=$(echo $df | awk '{print $2}')
    putter "$val" "disktot" "openWB/global/diskTot"
	val=$(echo $df | awk '{print $3}')
	putter "$val" "diskuse" "openWB/global/diskUse"
	val=$(echo $df | awk '{print $4}')
	putter "$val" "diskfree" "openWB/global/diskFree"
	val=$(echo $df | awk '{print $5}')
	val=${val//%}
	putter "$val" "diskusedprz" "openWB/global/diskUsedPrz"
    
    
    mem=$(free -m | grep 'Mem' )
    val=$(echo $mem | awk '{print $3}' )
	putter "$val" "memuse" "openWB/global/memUse"
	val=$(echo $mem | awk '{print $7}' )
	putter "$val" "memfree" "openWB/global/memFree"

    ptend "SYSD: sysdaem.loop" 200
    sleep 10
	
done

openwbDebugLog "DEB" 0 "SYSD: **** End."
exit 0

