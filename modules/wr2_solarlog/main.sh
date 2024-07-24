#!/bin/bash

#DMOD="MAIN"
DMOD="PV"
Debug=$debug

re='^-?[0-9]+$'


answer=$(curl -d {\"801\":{\"170\":null}} --connect-timeout 5 -s $bezug2_solarlog_ip/getjp)

openwbDebugLog ${DMOD} 2 "answer: $answer"
pv2watt=$(echo $answer | jq '."801"."170"."101"' )
openwbDebugLog ${DMOD} 2 "pvwatt: $pvwatt"
pv2kwh=$(echo $answer | jq '."801"."170"."109"' )
openwbDebugLog ${DMOD} 2 "pv2kwh: $pv2kwh"

if ! [[ $pv2watt =~ $re ]] ; then
	pv2watt="0"
	openwbDebugLog ${DMOD} 0 "pv2watt: NaN set 0"
fi

if (( $pv2watt > 5 )); then
	pv2watt=$(echo "$pv2watt*-1" |bc)
fi
if ! [[ $pv2kwh =~ $re ]] ; then
	openwbDebugLog ${DMOD} 2 "PV2kWh: NaN get prev. Value"
	pv2kwh=$(</var/www/html/openWB/ramdisk/pv2kwh)
fi

openwbDebugLog ${DMOD} 2 "pv2watt: $pv2watt"
openwbDebugLog ${DMOD} 2 "pv2kwh: $pv2kwh"
echo $pv2watt
echo $pv2watt > /var/www/html/openWB/ramdisk/pv2watt
echo $pv2kwh > /var/www/html/openWB/ramdisk/pv2kwh
