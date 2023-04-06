#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)

# check if config file is already in env
if [[ -z "$debug" ]]; then
	. $OPENWBBASEDIR/loadconfig.sh
	. $OPENWBBASEDIR/helperFunctions.sh
fi

DMOD="PV"
Debug=$debug

pvkwh=$(<${RAMDISKDIR}/pvkwh)
pvwatt=$(<${RAMDISKDIR}/pvwatt)
openwbDebugLog ${DMOD} 1 "PVWatt: ${pvwatt}  PVkWh: ${pvkwh}"
openwbModulePublishState "PV" 0 "Kein Fehler" 1
echo $pvwatt

