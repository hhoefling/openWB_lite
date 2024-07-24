#!/bin/bash
goecheck3(){
	#######################################
	# goe mobility check
	if [[ $lastmanagements2 == "1" ]]; then
		if [[ $evsecons2 == "goe" ]]; then
			output=$(curl --connect-timeout 1 -s http://$goeiplp3/status)
			rc=$?
			if [[ "$rc" == "0" ]] ; then
				state=$(echo $output | jq -r '.alw')
				if grep -q 1 ramdisk/ladestatuss2; then
					lp3enabled=$(<ramdisk/lp3enabled)
					if ((state == "0"))  && (( lp3enabled == "1" ))  ; then
						curl --silent --connect-timeout $goetimeoutlp3 -s http://$goeiplp3/mqtt?payload=alw=1 > /dev/null
					fi
				fi
				if grep -q 0 ramdisk/ladestatuss2; then
					if ((state == "1")) ; then
						curl --silent --connect-timeout $goetimeoutlp3 -s http://$goeiplp3/mqtt?payload=alw=0 > /dev/null
					fi
				fi
				fwv=$(echo $output | jq -r '.fwv' | grep -Po "[1-9]\d{1,2}")
				oldcurrent=$(echo $output | jq -r '.amp')
				current=$(<ramdisk/llsolls2)
				if (( oldcurrent != $current )) ; then
					if (($fwv >= 40)) ; then
						curl --silent --connect-timeout $goetimeoutlp3 -s http://$goeiplp3/mqtt?payload=amx=$current > /dev/null
					else
						curl --silent --connect-timeout $goetimeoutlp3 -s http://$goeiplp3/mqtt?payload=amp=$current > /dev/null
					fi
				fi
			else
				openwbDebugLog "MAIN" 1 "curl-rc $rc [$output]"
			fi
		fi
	fi
}

goecheck3

