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

for f in $OPENWBBASEDIR/runs/tasker/chargeoff/*.sh
do
  tid=$(tsp $f $*)
  openwbDebugLog "EVENT" 0 "fire event $f  fid:$tid"
  
done

exit 0