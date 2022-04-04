#!/bin/bash
SELF=$(cd `dirname $0`   &&  pwd)
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
stamp="$OPENWBBASEDIR/ramdisk/rct2.last"

# check if config file is already in env
if [[ -z "$debug" ]]; then
	. $OPENWBBASEDIR/loadconfig.sh
	. $OPENWBBASEDIR/helperFunctions.sh
fi
debug=${1:-$debug}
secs=${2:-"300"}


function Log()
{
 level=$1;
 shift;
 openwbDebugLog "MAIN" $level "rct2: $*"
}


now=`date +%s`
# check Lastrun
if [ -f "$stamp" ] ; then
	lastrun=$(<$stamp)
else	
	lastrun=0
	echo "0" >$stamp
	chmod a+rw $stamp
fi
diff="$((now-lastrun))"
if (( diff >= secs )) ; then  # alle 5 Minuten 
   echo $now  >$stamp
   m5="--m5"
   Log  1 "##### fire --m5 event ##### ($debug $secs)"
   (( debug > 2 )) && echo "##### fire --m5 event ##### ($debug $secs)"
else
   m5=""
   Log 2 "Last --m5  $diff sec ago, skip for now ($debug)"
   (( debug > 2 )) && echo "Last --m5  $diff sec ago, skip for now ($debug $secs)"
fi

if (( debug > 2 )) ; then
  python3 $SELF/rct2.py --verbose --ip=$bezug1_ip  -b=$wattbezugmodul -w=$pvwattmodul -s=$speichermodul $m5 
else
  python3 $SELF/rct2.py --ip=$bezug1_ip  -b=$wattbezugmodul -w=$pvwattmodul -s=$speichermodul $m5  >>/var/log/openWB.log 2>&1
fi 

# Nehme wattbezug als ergbenis mit zurueck da beim Bezug-Module ein Returnwert erwartet wird.
cat  /var/www/html/openWB/ramdisk/wattbezug

