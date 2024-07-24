#!/bin/bash

########## Re-Run as PI if not
USER=${USER:-`id -un`}
[ "$USER" != "pi" ] && exec sudo -u pi "$0" "$@"

if [[ -z "$OPENWBBASEDIR" ]]; then
	OPENWBBASEDIR=$(cd "$(dirname "$0")/../../" && pwd)
	OPENWBBASEDIR=/var/www/html/openWB
	RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
fi

declare -F openwbDebugLog &> /dev/null || {
	. "$OPENWBBASEDIR/helperFunctions.sh"
    . "$OPENWBBASEDIR/loadconfig.sh"
    openwbDebugLog "MAIN" 0 "Directstart"
    
}

openwbDebugLog "MAIN" 0 "start tsp"
openwbDebugLog "EVENT" 0 "start tsp"



export TS_MAXFINISHED=10
export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
# export  TS_ENV='pwd;set;mount'.
tsp -K
tsp
openwbDebugLog "EVENT" 0 "tsp: $( ps -ef | grep tsp  | grep -v grep) "



