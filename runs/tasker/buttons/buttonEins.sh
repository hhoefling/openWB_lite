#!/bin/bash

do=${1:-name}
if [[  $do == "name"  ]] ; then
  echo "button1"
  exit 0
fi

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

