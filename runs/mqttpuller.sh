#!/bin/bash

cd /var/www/html/openWB
# must be called  as pi from /var/www/html/openWB
OPENWBBASEDIR=$(cd `dirname $0`/../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

. $OPENWBBASEDIR/loadconfig.sh
. $OPENWBBASEDIR/helperFunctions.sh


# if useid=="" stop server if running ,
# else start if not running
function control_subserver()  # $1=startcmd $2=useit $3=logfile
{
  local modulecmd=$1
  local useit=$2
  local logfile=$3
  local pid=$(pgrep -f "$modulecmd" )
  
  openwbDebugLog "MAIN" 1 "modcmd:[$modulecmd]:[$pid] useit:[$useit]"

  if [[  "$useit" != "" ]] ; then
  	if [[ "" !=  "$pid" ]]; then
	   	openwbDebugLog "MAIN" 1 "$modulecmd is already running"
	else
		openwbDebugLog "MAIN" 0 "$modulecmd not running! restarting process"
		$modulecmd >> "$logfile" 2>&1  &
		pid=$(pgrep -f "$modulecmd" )
		openwbDebugLog "MAIN" 0 "pid $pid"
	fi	
 else		
	if [[ "" !=  "$pid" ]]; then
		openwbDebugLog "MAIN" 1 "$modulecmd $pid stopped, no more needed"
  		sudo kill -9 $pid
	else	
		openwbDebugLog "MAIN" 1 "$modulecmd not runnung and not needed"
	fi
 fi
}

################ 
useit=""
[ "$evsecon" == "mqtt_puller" ] 	   && useit="${useit} ev1"
[ "$ladeleistungmodul" == "mqtt_puller" ]  && useit="${useit} ll1"
[ "$socmodul" == "soc_mqttpuller" ]          && useit="${useit} soc1"
if [ "$lastmanagment" == "1" ] ; then
    [ "$evsecons1" == "mqtt_puller" ] 	        && useit="${useit} ev2"
    [ "$ladeleistungs1modul" == "mqtt_puller" ] && useit="${useit} ll2"
    [ "$socmodul1"=="soc_mqttpuller" ]          && useit="${useit} soc2"
fi
[ "$wattbezugmodul" == "bezug_mqttpuller" ] && useit="${useit} evu"
[ "$pvwattmodul" == "wr_mqttpuller" ]       && useit="${useit} pv1"
[ "$speichermodul" == "speicher_mqttpuller" ] && useit="${useit} bat1"
 
modulecmd="python3 $OPENWBBASEDIR/runs/mqttpuller.py"

control_subserver "$modulecmd" "$useit" "$RAMDISKDIR/mqttpuller.log"
 

