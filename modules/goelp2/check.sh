#!/bin/bash
goecheck(){
	#######################################
	# goe mobility check
	if [[ $lastmanagement == "1" ]]; then
		if [[ $evsecons1 == "goe" ]]; then
			output=$(curl --connect-timeout 1 -s http://$goeiplp2/status)
			rc=$?
			if [[ "$rc" == "0" ]] ; then
				state=$(echo $output | jq -r '.alw')
				if grep -q 1 ramdisk/ladestatuss1; then
					lp2enabled=$(<ramdisk/lp2enabled)
					if ((state == "0"))  && (( lp2enabled == "1" )) ; then
						curl --silent --connect-timeout $goetimeoutlp2 -s http://$goeiplp2/mqtt?payload=alw=1 > /dev/null
					fi
				fi
				if grep -q 0 ramdisk/ladestatuss1; then
					if ((state == "1")) ; then
						curl --silent --connect-timeout $goetimeoutlp2 -s http://$goeiplp2/mqtt?payload=alw=0 > /dev/null
					fi
				fi
				fwv=$(echo $output | jq -r '.fwv' | grep -Po "[1-9]\d{1,2}")
				oldcurrent=$(echo $output | jq -r '.amp')
				current=$(<ramdisk/llsolls1)
				if (( oldcurrent != $current )) && (( $current != 0 )); then
					if (($fwv >= 40)) ; then
						curl --silent --connect-timeout $goetimeoutlp2 -s http://$goeiplp2/mqtt?payload=amx=$current > /dev/null
					else
						curl --silent --connect-timeout $goetimeoutlp2 -s http://$goeiplp2/mqtt?payload=amp=$current > /dev/null
					fi
				fi
			else
				openwbDebugLog "MAIN" 1 "curl-rc $rc [$output]"
			fi
		fi
	fi
}

goecheck
