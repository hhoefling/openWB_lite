#!/bin/bash
verbraucher()
{

# verbrauchwr 1,2
	if (( verbraucher1_aktiv == "1")); then	# is configured?
		echo "1" > ramdisk/verbraucher1vorhanden
		openwbDebugLog "MAIN" 2 "verbraucher1 [$verbraucher1_typ] "
		# werte holen
		verbraucher1_watt=0
		verbraucher1_wh=0
		if [[ $verbraucher1_typ == "http" ]]; then
			verbraucher1_watt=$(curl --connect-timeout 3 -s "$verbraucher1_urlw" )
			if ! [[ "$verbraucher1_watt" =~ ^[+-]?[0-9]+([\.][0-9]+)?$ ]]; then
				penwbDebugLog "MAIN" 1 "verbraucher1 W[$verbraucher1_watt] Bad"
				read verbraucher1_watt<ramdisk/verbraucher1_watt
			fi
			if [[ "$verbraucher1_urlh" == "simcount" ]] ; then
				openwbDebugLog "MAIN" 1 "verbraucher1 use simcount for verbraucher1_wh"
				read verbraucher1_wh <ramdisk/verbraucher1_wh
			elif [[ "$verbraucher1_urlh" != "none" ]] ; then
				verbraucher1_wh=$(curl --connect-timeout 3 -s $verbraucher1_urlh &)
				if ! [[ "$verbraucher1_wh" =~ ^[+-]?[0-9]+([\.][0-9]+)?$ ]]; then
					openwbDebugLog "MAIN" 1 "verbraucher1 wh[$verbraucher1_wh] Bad"
					read verbraucher1_wh <ramdisk/verbraucher1_wh
				fi
			fi
		fi
		if [[ $verbraucher1_typ == "bash" ]]; then
			#  verbraucher1_scriptw="modules/verbraucher/sdm120pusher.sh 1 /dev/ttyUSB0 9 192.168.208.3 2 "
			# openwbDebugLog "MAIN" 2 "EXEC: timeout 3 ${verbraucher1_scriptw}"
			if
				timeout 3 bash -c "${verbraucher1_scriptw}" # >/dev/null
			then
				read verbraucher2_watt <ramdisk/verbraucher1_watt
			else
				openwbDebugLog "DEB" 0 "TIMEOUT V1 > 3 !!! "
				read verbraucher2_watt <ramdisk/verbraucher1_watt
			fi
		fi
		if [[ $verbraucher1_typ == "mpm3pm" ]]; then
			if [[ $verbraucher1_source == *"dev"* ]]; then
				sudo python modules/verbraucher/mpm3pmlocal.py 1 $verbraucher1_source $verbraucher1_id &
			else
				sudo python modules/verbraucher/mpm3pmremote.py 1 $verbraucher1_source $verbraucher1_id &
			fi
			read verbraucher1_watt<ramdisk/verbraucher1_watt
		fi
		if [[ $verbraucher1_typ == "sdm630" ]]; then
			if [[ $verbraucher1_source == *"dev"* ]]; then
				sudo python modules/verbraucher/sdm630local.py 1 $verbraucher1_source $verbraucher1_id &
			else
				sudo python modules/verbraucher/sdm630remote.py 1 $verbraucher1_source $verbraucher1_id &
			fi
			read verbraucher1_watt<ramdisk/verbraucher1_watt
		fi
		if [[ $verbraucher1_typ == "sdm120" ]]; then
			if [[ $verbraucher1_source == *"dev"* ]]; then
				sudo python modules/verbraucher/sdm120local.py 1 $verbraucher1_source $verbraucher1_id &
			else
				sudo python modules/verbraucher/sdm120remote.py 1 $verbraucher1_source $verbraucher1_id &
			fi
			read verbraucher1_watt<ramdisk/verbraucher1_watt
		fi
		if [[ $verbraucher1_typ == "abb-b23" ]]; then
			python modules/verbraucher/abb-b23remote.py 1 $verbraucher1_source $verbraucher1_id &
			read verbraucher1_watt <ramdisk/verbraucher1_watt
			sleep .3
		fi
		if [[ $verbraucher1_typ == "tasmota" ]]; then
			verbraucher1_out=$(curl --connect-timeout 3 -s $verbraucher1_ip/cm?cmnd=Status%208 )
			verbraucher1_watt=$(echo $verbraucher1_out | jq '.StatusSNS.ENERGY.Power')
			verbraucher1_whxx=$(echo $verbraucher1_out | jq '.StatusSNS.ENERGY.Total')
			verbraucher1_wh=$(echo "scale=0;(($verbraucher1_whxx * 1000) + $verbraucher1_tempwh)  / 1" | bc)
		fi
		if [[ $verbraucher1_typ == "shelly" ]]; then
			verbraucher1_out=$(curl --connect-timeout 3 -s $verbraucher1_ip/status )
			verbraucher1_watt=$(echo $verbraucher1_out |jq '.meters[0].power' | sed 's/\..*$//')
			verbraucher1_wh=$(echo $verbraucher1_out | jq '.meters[0].total' | sed 's/\..*$//')
		fi
		# werte abspeichern
		openwbDebugLog "MAIN" 2 "verbraucher1_watt:[$verbraucher1_watt] verbraucher1_wh:[$verbraucher1_wh]"
		echo $verbraucher1_watt > ramdisk/verbraucher1_watt
		echo $verbraucher1_wh > ramdisk/verbraucher1_wh
	else
		if grep -q 1 ramdisk/verbraucher1vorhanden 2>/dev/null ; then
			openwbDebugLog "MAIN" 1 "verbraucher1vorhanden verschwunden, reset values"
			verbraucher1_watt=0
			echo "0" >ramdisk/verbraucher1vorhanden
			echo "0" >ramdisk/verbraucher1_watt
			echo "0" >ramdisk/verbraucher1_wh
			echo "0" >ramdisk/verbraucher1_out
			echo "0" >ramdisk/verbraucher1_totalwh
		fi
	fi

	if (( verbraucher2_aktiv == "1")); then	# is configured?
		echo "1" > ramdisk/verbraucher2vorhanden
		openwbDebugLog "MAIN" 2 "verbraucher2 [$verbraucher2_typ] "
		# werte holen
		verbraucher2_watt=0
		verbraucher2_wh=0
        
		if [[ $verbraucher2_typ == "http" ]]; then
			verbraucher2_watt=$(curl --connect-timeout 3 -s $verbraucher2_urlw )
			if ! [[ "$verbraucher2_watt" =~ ^[+-]?[0-9]+([\.][0-9]+)?$ ]]; then
				openwbDebugLog "MAIN" 1 "verbraucher2 W[$verbraucher2_watt] Bad"
				read verbraucher2_watt <ramdisk/verbraucher2_watt
			fi
			
			if [[ "$verbraucher2_urlh" == "simcount" ]] ; then
				openwbDebugLog "MAIN" 1 "verbraucher2 use simcount for verbraucher2_wh"
				read verbraucher2_wh <ramdisk/verbraucher2_wh
			elif [[ "$verbraucher2_urlh" != "none" ]] ; then
				verbraucher2_wh=$(curl --connect-timeout 3 -s $verbraucher2_urlh &)
    			if ! [[ "$verbraucher2_wh" =~ ^[+-]?[0-9]+([\.][0-9]+)?$ ]]; then
					openwbDebugLog "MAIN" 1 "verbraucher2 wh[$verbraucher2_wh] Bad"
					read verbraucher2_wh <ramdisk/verbraucher2_wh
				fi
			fi
		fi
		if [[ $verbraucher2_typ == "bash" ]]; then
			#  verbraucher1_scriptw="modules/verbraucher/sdm120pusher.sh 2 /dev/ttyUSB0 9 192.168.208.3 2 "
			# openwbDebugLog "MAIN" 2 "EXEC: timeout 3 ${verbraucher2_scriptw}"
			if
				timeout 3 bash -c "${verbraucher2_scriptw}" # >/dev/null
			then
				read verbraucher2_watt <ramdisk/verbraucher2_watt
			else
				openwbDebugLog "DEB" 0 "TIMEOUT V1 > 3 !!! "
				read verbraucher2_watt <ramdisk/verbraucher2_watt
			fi
		fi
		if [[ $verbraucher2_typ == "mpm3pm" ]]; then
			if [[ $verbraucher2_source == *"dev"* ]]; then
				sudo python modules/verbraucher/mpm3pmlocal.py 2 $verbraucher2_source $verbraucher2_id &
			else
				sudo python modules/verbraucher/mpm3pmremote.py 2 $verbraucher2_source $verbraucher2_id &
			fi
			read verbraucher2_watt <ramdisk/verbraucher2_watt
		fi
		if [[ $verbraucher2_typ == "sdm630" ]]; then
			if [[ $verbraucher2_source == *"dev"* ]]; then
				sudo python modules/verbraucher/sdm630local.py 2 $verbraucher2_source $verbraucher2_id &
			else
				sudo python modules/verbraucher/sdm630remote.py 2 $verbraucher2_source $verbraucher2_id &
			fi
			read verbraucher2_watt <ramdisk/verbraucher2_watt
		fi
		if [[ $verbraucher2_typ == "sdm120" ]]; then
			if [[ $verbraucher2_source == *"dev"* ]]; then
				sudo python modules/verbraucher/sdm120local.py 2 $verbraucher2_source $verbraucher2_id &
			else
				sudo python modules/verbraucher/sdm120remote.py 2 $verbraucher2_source $verbraucher2_id &
			fi
			read verbraucher2_watt <ramdisk/verbraucher2_watt
		fi
		if [[ $verbraucher2_typ == "abb-b23" ]]; then
				python modules/verbraucher/abb-b23remote.py 2 $verbraucher2_source $verbraucher2_id &
				read verbraucher2_watt <ramdisk/verbraucher2_watt
				sleep .3
		fi
		if [[ $verbraucher2_typ == "tasmota" ]]; then
			verbraucher2_out=$(curl --connect-timeout 3 -s $verbraucher2_ip/cm?cmnd=Status%208 )
			verbraucher2_watt=$(echo $verbraucher2_out | jq '.StatusSNS.ENERGY.Power')
			verbraucher2_whxx=$(echo $verbraucher2_out | jq '.StatusSNS.ENERGY.Total')
			verbraucher2_wh=$(echo "scale=0;(($verbraucher2_whxx * 1000) + $verbraucher2_tempwh)  / 1" | bc)
		fi
		if [[ $verbraucher2_typ == "shelly" ]]; then
			verbraucher2_out=$(curl --connect-timeout 3 -s $verbraucher2_ip/status )
			verbraucher2_watt=$(echo $verbraucher2_out |jq '.meters[0].power' | sed 's/\..*$//')
			verbraucher2_wh=$(echo $verbraucher2_out | jq '.meters[0].total' | sed 's/\..*$//')
		fi
		# werte abspeichern
		openwbDebugLog "MAIN" 2 "verbraucher2_watt:[$verbraucher2_watt] verbraucher2_wh:[$verbraucher2_wh]"
		echo $verbraucher2_watt > /var/www/html/openWB/ramdisk/verbraucher2_watt
		echo $verbraucher2_wh > /var/www/html/openWB/ramdisk/verbraucher2_wh

	else
		if grep -q 1 ramdisk/verbraucher2vorhanden 2>/dev/null ; then
			openwbDebugLog "MAIN" 1 "verbraucher2vorhanden verschwunden, reset values"
			verbraucher2_watt=0
			echo "0" >ramdisk/verbraucher2vorhanden
			echo "0" >ramdisk/verbraucher2_watt
			echo "0" >ramdisk/verbraucher2_wh
			echo "0" >ramdisk/verbraucher2_out
			echo "0" >ramdisk/verbraucher2_totalwh
		fi
	fi
}
