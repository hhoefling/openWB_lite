#!/bin/bash

if [[ -z "$OPENWBBASEDIR" ]]; then
	OPENWBBASEDIR=$(cd "$(dirname "$0")/../../" && pwd)
	OPENWBBASEDIR=/var/www/html/openWB
	RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
fi

declare -F openwbDebugLog &> /dev/null || {
	. "$OPENWBBASEDIR/helperFunctions.sh"
    . "$OPENWBBASEDIR/loadconfig.sh"
}


if ! pgrep tsp >/dev/null ; then
  openwbDebugLog "MAIN" 0 "tsp not running, no Event send"
  openwbDebugLog "EVENT" 0 "tsp not running, no Event send"
  exit
fi


evt=${1:-plugoff}
shift

openwbDebugLog "EVENT" 0 "fire $evt $*" 

for f in $OPENWBBASEDIR/runs/tasker/${evt}/*.sh
do
  echo "[$f]"
  tid=$(tsp $f $*)
  f=$(basename $f)
  openwbDebugLog "EVENT" 0 "shedule $f fid:$tid"
  
done

exit 0
