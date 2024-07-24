#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="${OPENWBBASEDIR}/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)
DMOD="PV"
Debug=$debug


pv2watt=$(<${RAMDISKDIR}/pv2watt)
echo $pv2watt
openwbDebugLog ${DMOD} 1 "PV2Watt: ${pv2watt}"

pv2kwh=$(<${RAMDISKDIR}/pv2kwh)
openwbDebugLog ${DMOD} 1 "PV2kWh: ${pv2kwh}"
openwbModulePublishState "PV" 0 "Kein Fehler" 1
