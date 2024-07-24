#!/bin/bash
startms=$(($(date +%s%N)/1000000))
SELF=$(cd `dirname $0`   &&  pwd)
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RCT=$(basename `dirname $0`)
RCT=${RCT/bezug_/}
# rct2 oder rct2h oder rct2x


function Log()
{
 level=$1;
 shift;
 openwbDebugLog "MAIN" $level "${RCT^^}: $*"
}
function Deb()
{
 level=$1;
 shift;
 openwbDebugLog "DEB" $level "${RCT^^}: $*"
}

# check if config file is already in env
if [[ -z "$debug" ]]; then
	source $OPENWBBASEDIR/loadconfig.sh
	source $OPENWBBASEDIR/helperFunctions.sh
	Deb 1 "$RCT read loadconf and helperfunction"
	bezug1_ip=192.168.208.63
	pvwattmodul=${2:-$pvwattmodul}	
fi

Log 2 "pvwattmodul :$pvwattmodul"

debug=${1:-$debug}
debug=3

if (( debug > 2 )) ; then
  python3 $SELF/rct2.py --verbose --ip=$bezug1_ip  -w=$pvwattmodul >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log 
else
  python3 $SELF/rct2.py --ip=$bezug1_ip  -w=$pvwattmodul >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log 
fi 


endms=$(($(date +%s%N)/1000000))
let "ms=( endms - startms )"
Log 1 "wr runs $ms Millisec"


cat /var/www/html/openWB/ramdisk/pvwatt
