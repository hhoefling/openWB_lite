#!/bin/bash
# OPENWBBASEDIR=$(cd "$(dirname "$0")/../../" && pwd)
# Auch von web/settings/saveconifg.php aufgerufen. dann pwd falsch
OPENWBBASEDIR=/var/www/html/openWB
cd /var/www/html/openWB

RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
# try to load config
. "$OPENWBBASEDIR/loadconfig.sh"
# load helperFunctions
. "$OPENWBBASEDIR/helperFunctions.sh"
# load rfidHelper
. "$OPENWBBASEDIR/runs/rfid/rfidHelper.sh"

rfidSetup "$rfidakt" 0 "$rfidlist"


