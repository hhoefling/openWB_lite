#!/bin/bash

# must be called  as pi from /var/www/html/openWB
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)

declare -F openwbDebugLog &> /dev/null || {
	. "$OPENWBBASEDIR/helperFunctions.sh"
    . "$OPENWBBASEDIR/loadconfig.sh"
}

openwbModulePublishState "LP" 0 "Kein Fehler" 1
