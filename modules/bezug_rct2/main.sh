#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
## RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
## MODULEDIR=$(cd `dirname $0` && pwd)
## CONFIGFILE="$OPENWBBASEDIR/openwb.conf"

stamp="$OPENWBBASEDIR/ramdisk/rct2.last"

# check if config file is already in env
if [[ -z "$debug" ]]; then
	. $OPENWBBASEDIR/loadconfig.sh
	. $OPENWBBASEDIR/helperFunctions.sh
fi
debug=${1:-$debug}


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
if (( $diff >= 30 )) ; then
   echo $now  >$stamp
   m5="--m5"
   Log  1 "##### set --m5 #####"
else
   m5=""
   Log 2 "Last --m5  $diff sec ago"
fi

if (( debug > 1 )) ; then
  python3 /var/www/html/openWB/modules/bezug_rct2/rct2.py --verbose --ip=$bezug1_ip  -b=$wattbezugmodul -w=$pvwattmodul -s=$speichermodul $m5 >>/var/log/openWB.log 2>&1 
else
  python3 /var/www/html/openWB/modules/bezug_rct2/rct2.py --ip=$bezug1_ip  -b=$wattbezugmodul -w=$pvwattmodul -s=$speichermodul $m5
fi 

# Nehme wattbezug als ergbenis mit zurueck da beim Bezug-Module ein Returnwert erwartet wird.
cat  /var/www/html/openWB/ramdisk/wattbezug

