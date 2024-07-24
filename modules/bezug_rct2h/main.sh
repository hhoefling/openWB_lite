#!/bin/bash

startms=$(($(date +%s%N)/1000000))
SELF=$(cd `dirname $0`   &&  pwd)
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
stamp="$OPENWBBASEDIR/ramdisk/rct2_last.stamp"
RCT=$(basename `dirname $0`)
RCT=${RCT/bezug_/}
# rct2 oder rct2h oder rct2x

# sudo -u pi modules/bezug_rct2h/main.sh 3 10 bezug_rct2hx speicher_rct2hx wr_rct2h


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
	wattbezugmodul=${3:-$wattbezugmodul}
	speichermodul=${4:-$speichermodul}
	pvwattmodul=${5:-$pvwattmodul}
fi
debug=${1:-$debug}
debug=3
secs=${2:-"120"}


Log 2 "RCT EVU:[$wattbezugmodul] BAT:[$speichermodul] PV:[$pvwattmodul]"


now=`date +%s`
# check Lastrun
if [ -f "$stamp" ] ; then
	read lastrun <$stamp
else	
	let "lastrun= now - secs"
	echo "$lastrun" >$stamp
	chmod a+rw $stamp
fi
diff="$((now-lastrun))"
if (( diff >= secs )) ; then  # alle 5 Minuten 
   echo $now  >$stamp
   m5="--m5"
   Log  1 "##### fire --m5 event ##### ($debug $secs)"
else
   m5=""
   Log 1 "Last --m5  $diff sec ago, skip for now (d:$debug secs:$secs)"
fi

if (( debug >= 2 )) ; then
  python3 $SELF/rct2.py -d --ip=$bezug1_ip  -b=$wattbezugmodul  $m5 >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log 
else
 if (( debug >= 1 )) ; then
   python3 $SELF/rct2.py --ip=$bezug1_ip -v  -b=$wattbezugmodul  $m5  >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log
 else 
   python3 $SELF/rct2.py --ip=$bezug1_ip  -b=$wattbezugmodul  $m5  >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log
 fi
fi 


endms=$(($(date +%s%N)/1000000))
let "ms=( endms - startms )"
Log 1 "TIME bezug runs $ms Millisec (O)"
Deb 1 "TIME bezug runs $ms Millisec (D)"

# Nehme wattbezug als ergbenis mit zurueck da beim Bezug-Module ein Returnwert erwartet wird.
cat  /var/www/html/openWB/ramdisk/wattbezug

