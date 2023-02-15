#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)
DMOD="MAIN"

wattbezug=$(<$RAMDISKDIR/wattbezug)
# openwbDebugLog ${DMOD} 1 "wattbezug: ${wattbezug}"
openwbModulePublishState "EVU" 0 "Kein Fehler"

echo $wattbezug

