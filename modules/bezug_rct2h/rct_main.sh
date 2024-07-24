#!/bin/bash

startms=$(($(date +%s%N)/1000000))
SELF=$(cd `dirname $0`   &&  pwd)
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
stamp="$OPENWBBASEDIR/ramdisk/rct2.last"
RCT=$(basename `dirname $0`)
RCT=${RCT/bezug_/}
# rct2 oder rct2h oder rct2x

# check if config file is already in env
if [[ -z "$debug" ]]; then
	source $OPENWBBASEDIR/loadconfig.sh
	source $OPENWBBASEDIR/helperFunctions.sh
fi
debug=${1:-$debug}
secs=${2:-"300"}


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

if (( debug >= 2 )) ; then
    wattbezugmodul="bezug_${RCT,,}"
    speichermodul="speicher_${RCT,,}"
    pvwattmodul="wr_${RCT,,}"
    Log 2 "Debugmode -> uses rct all modules"
fi


Log 2 "wattbezugmodul:$wattbezugmodul speichermodul:$speichermodul pvwattmodul:$pvwattmodul"


now=`date +%s`
# check Lastrun
if [ -f "$stamp" ] ; then
	lastrun=$(<$stamp)
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
   (( debug > 2 )) && echo "$RCT ##### fire --m5 event ##### ($debug $secs)"
else
   m5=""
   Log 1 "Last --m5  $diff sec ago, skip for now (d:$debug secs:$secs)"
   (( debug > 2 )) && echo "$RCT Last --m5  was  $diff sec ago, skip for now ($debug $secs)"
fi

if (( debug >= 2 )) ; then
  python3 $SELF/rct2.py --verbose --info --ip=$bezug1_ip  -b=$wattbezugmodul   -w=$pvwattmodul -s=$speichermodul  $m5 >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log 
else
  python3 $SELF/rct2.py --ip=$bezug1_ip  -b=$wattbezugmodul   -w=$pvwattmodul -s=$speichermodul $m5  >>/var/log/openWB.log 2>>$OPENWBBASEDIR/ramdisk/dbg.log
fi 


endms=$(($(date +%s%N)/1000000))
let "ms=( endms - startms )"
Log 1 "TIME rct_main $ms Millisec (O)"
Deb 1 "TIME rct_main $ms Millisec (D)"

# Nehme wattbezug als ergbenis mit zurueck da beim Bezug-Module ein Returnwert erwartet wird.

cat  /var/www/html/openWB/ramdisk/wattbezug

