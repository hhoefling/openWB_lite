#!/bin/bash

# must be called  as pi from /var/www/html/openWB
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)

. $OPENWBBASEDIR/loadconfig.sh
. $OPENWBBASEDIR/helperFunctions.sh

srcip=${mqtt_pullerip:-""}
if [[ "$srcip" == "none" ]] ; then
  srcip=""
fi
if [[ ! -z "$srcip" ]] ; then
   openwbDebugLog "MAIN" 0 "mqtt_pullerip[${srcip}] [${MODULEDIR}] "
   $MODULEDIR/mqttpuller.sh
fi   

# openwbModulePublishState "LP" 0 "Kein Fehler" 1
