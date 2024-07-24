#!/bin/bash
goecheck1(){
	#######################################
	#goe mobility check
	if [[ $evsecon == "goe" ]]; then
		output=$(curl --connect-timeout 1 -s http://$goeiplp1/status)
		rc=$?
		if [[ "$rc" == "0" ]] ; then
			state=$(echo $output | jq -r '.alw')
			if grep -q 1 ramdisk/ladestatus; then
				lp1enabled=$(<ramdisk/lp1enabled)
				if ((state == "0")) && (( lp1enabled == "1" )) ; then
					curl --silent --connect-timeout $goetimeoutlp1 -s http://$goeiplp1/mqtt?payload=alw=1 > /dev/null
				fi
			fi
			if grep -q 0 ramdisk/ladestatus; then
				if ((state == "1")) ; then
					curl --silent --connect-timeout $goetimeoutlp1 -s http://$goeiplp1/mqtt?payload=alw=0 > /dev/null
				fi
			fi
			fwv=$(echo $output | jq -r '.fwv' | grep -Po "[1-9]\d{1,2}")
			oldcurrent=$(echo $output | jq -r '.amp')
			current=$(<ramdisk/llsoll)
			if (( oldcurrent != $current )) && (( $current != 0 )); then
				if (($fwv >= 40)) ; then
					curl --silent --connect-timeout $goetimeoutlp1 -s http://$goeiplp1/mqtt?payload=amx=$current > /dev/null
				else
					curl --silent --connect-timeout $goetimeoutlp1 -s http://$goeiplp1/mqtt?payload=amp=$current > /dev/null
				fi
			fi
		else
			openwbDebugLog "MAIN" 1 "curl-rc $rc [$output]"
		fi		
	fi
}

goecheck1


