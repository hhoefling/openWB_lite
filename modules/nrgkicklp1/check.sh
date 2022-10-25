#!/bin/bash

nrgkickcheck(){
	#######################################
	#nrgkick mobility check
	if [[ $evsecon == "nrgkick" ]]; then
		output=$(curl --connect-timeout 3 -s http://$nrgkickiplp1/api/settings/$nrgkickmaclp1)
		rc=$?
		if [[ "$rc" == "0" ]] ; then
			state=$(echo $output | jq -r '.Values.ChargingStatus.Charging')
			if grep -q 1 ramdisk/ladestatus; then
				if [[ $state == "false" ]] ; then
					openwbDebugLog "MAIN" 2 "nachtrigger start ladung"
					curl --connect-timeout 2 -s -X PUT -H "Content-Type: application/json" --data "{ "Values": {"ChargingStatus": { "Charging": true }, "ChargingCurrent": { "Value": $current }, "DeviceMetadata":{"Password": $nrgkickpwlp1}}}" $nrgkickiplp1/api/settings/$nrgkickmaclp1 > /dev/null
				fi
			fi
			if grep -q 0 ramdisk/ladestatus; then
				if [[ $state == "true" ]] ; then
					openwbDebugLog "MAIN" 2 "nachtrigger stop ladung"
					curl --connect-timeout 2 -s -X PUT -H "Content-Type: application/json" --data "{ "Values": {"ChargingStatus": { "Charging": false }, "ChargingCurrent": { "Value": "6"}, "DeviceMetadata":{"Password": $nrgkickpwlp1}}}" $nrgkickiplp1/api/settings/$nrgkickmaclp1 > /dev/null
				fi
			fi
			oldcurrent=$(echo $output | jq -r '.Values.ChargingCurrent.Value')
			current=$(<ramdisk/llsoll)
			if (( oldcurrent != $current )) ; then
				openwbDebugLog "MAIN" 2 "nachtrigger ladestrom"
				curl --silent --connect-timeout $nrgkicktimeoutlp1 -s -X PUT -H "Content-Type: application/json" --data "{ "Values": {"ChargingStatus": { "Charging": true }, "ChargingCurrent": { "Value": $current}, "DeviceMetadata":{"Password": $nrgkickpwlp1}}}" $nrgkickiplp1/api/settings/$nrgkickmaclp1 > /dev/null
			fi
		else
			openwbDebugLog "MAIN" 1 "curl-rc $rc [$output]"
		fi		
	fi
}

nrgkickcheck


