#!/bin/bash

if [[ $multifems == "0" ]]; then
	soc=$(curl -s "http://x:$femskacopw@$femsip:8084/rest/channel/ess0/Soc" | jq .value)
	speicheriwh=$(curl -s "http://x:$femskacopw@$femsip:8084/rest/channel/ess0/ActiveChargeEnergy" | jq .value)
	speicherewh=$(curl -s "http://x:$femskacopw@$femsip:8084/rest/channel/ess0/ActiveDischargeEnergy" | jq .value)
else
    MYLOGFILE="${RAMDISKDIR}/speicher.log"
fi

openwbDebugLog ${DMOD} 2 "Speicher IP: ${femsip}"
openwbDebugLog ${DMOD} 2 "Speicher Passwort: ${femskacopw}"
openwbDebugLog ${DMOD} 2 "Speicher Multi: ${multifems}"

python3 /var/www/html/openWB/modules/speicher_fems/fems.py "${multifems}" "${femskacopw}" "${femsip}" >>$MYLOGFILE 2>&1
ret=$?

openwbDebugLog ${DMOD} 2 "RET: ${ret}"

speicherleistung=$(<${RAMDISKDIR}/speicherleistung)

openwbDebugLog ${DMOD} 1 "BattLeistung: ${speicherleistung}"

