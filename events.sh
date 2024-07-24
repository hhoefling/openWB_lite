#!/bin/bash
function webhooks()
{
# WebHooks  / Events
#2022-06-20 16:35:32: 22994 LP1, Ladung gestoppt (LV0) at 149 main ./ladelog.sh
#2022-06-20 16:35:44: 22983 U1P3 für nurPV auf 1 Phasen geändert (LV0) at 90 u1p3pswitch u1p3p.sh
#2022-06-20 16:35:44: 22983 Abgesteckt-WebHook LP1 ausgeführt (LV0) at 282 hook hook.sh
#2022-06-20 16:35:44: 22983 Ladestopp-WebHook LP1 ausgeführt (LV0) at 312 hook hook.sh
#2022-06-20 16:35:58: 25538 Angesteckt-WebHook LP1 ausgeführt (LV0) at 267 hook hook.sh

	read plugstat <ramdisk/plugstat
	#openwbDebugLog "CHARGESTAT" 0 "Ab/angesteckt-WebHook LP1 $plugstat"
	if (( angesteckthooklp1 == 1 )); then
		read plugstat <ramdisk/plugstat
		if (( plugstat == 1 )); then
			if [ ! -e ramdisk/angesteckthooklp1aktiv ]; then
				touch ramdisk/angesteckthooklp1aktiv
				curl -s --connect-timeout 5 $angesteckthooklp1_url > /dev/null
				openwbDebugLog "CHARGESTAT" 0 "Angesteckt-WebHook LP1 ausgeführt"
				openwbDebugLog "MAIN" 1 "Angesteckt-WebHook LP1 ausgeführt"
			fi
		else
			if [  -e ramdisk/angesteckthooklp1aktiv ]; then
				rm ramdisk/angesteckthooklp1aktiv
			fi
		fi
	fi
	if (( abgesteckthooklp1 == 1 )); then
		read plugstat <ramdisk/plugstat
		if (( plugstat == 0 )); then
			if [ ! -e ramdisk/abgesteckthooklp1aktiv ]; then
				touch ramdisk/abgesteckthooklp1aktiv
				curl -s --connect-timeout 5 $abgesteckthooklp1_url > /dev/null
				openwbDebugLog "CHARGESTAT" 0 "Abgesteckt-WebHook LP1 ausgeführt"
				openwbDebugLog "MAIN" 1 "Abgesteckt-WebHook LP1 ausgeführt"
			fi
		else
			if [  -e ramdisk/abgesteckthooklp1aktiv ]; then
				rm ramdisk/abgesteckthooklp1aktiv
			fi
		fi
	fi
    
	# RCT-Add start
    # RCT Hausakku-Entladeschutz verwenden ?
	# Wenn aktive Hilfsscript bei Lade-Start/Stop aufrufen (alle Modi)
    if [[ -e ramdisk/HB_enable_discharge_max ]] ; then
        read HB_enable_discharge_max <ramdisk/HB_enable_discharge_max
        if (( HB_enable_discharge_max == 1 )) ; then
            read ladungaktivlp1 <ramdisk/ladungaktivlp1
	        if (( ladungaktivlp1 == 1 )); then
		  	       if [ ! -e ramdisk/ladestarthooklp1aktiv2 ]; then
			 	        touch ramdisk/ladestarthooklp1aktiv2
						# "nackig" starten lassen, kein stdout, nur sciript-errors
                        # env -i ./modules/bezug_rct2/rct_setter.sh hookstart >>/var/log/rct.log &
                        mosquitto_pub -q 2 -r -t openWB/set/houseBattery/hooker -m "hookstart"
				        openwbDebugLog "CHARGESTAT" 0 "Ladestart RCT hookstart sended "
				        openwbDebugLog "MAIN" 1 "Ladestart-RCTHook2 LP1 ausgeführt"
			     fi
	        else
			     if [  -e ramdisk/ladestarthooklp1aktiv2 ]; then
			 	       rm ramdisk/ladestarthooklp1aktiv2
                fi
           fi
	       if (( ladungaktivlp1 == 0 )); then
			     if [ ! -e ramdisk/ladestophooklp1aktiv2 ]; then
				        touch ramdisk/ladestophooklp1aktiv2
						# "nackig" starten lassen, kein stdout, nur sciript-errors
                        # env -i ./modules/bezug_rct2/rct_setter.sh hookstop >>/var/log/rct.log &
                        mosquitto_pub -q 2 -r -t openWB/set/houseBattery/hooker -m "hookstop"
				        openwbDebugLog "CHARGESTAT" 0 "Ladestopp-RCT hookstop sended"
				        openwbDebugLog "MAIN" 1 "Ladestopp-RCTHook2 LP1 ausgeführt "
			     fi
	       else
			     if [  -e ramdisk/ladestophooklp1aktiv2 ]; then
				        rm ramdisk/ladestophooklp1aktiv2
		         fi
          fi
      fi # Disharge_max=1
    fi # Disharge_max vorhanden
	# RCT-Add end
    
	if (( ladestarthooklp1 == 1 )); then
		read ladungaktivlp1 <ramdisk/ladungaktivlp1
		if (( ladungaktivlp1 == 1 )); then
			if [ ! -e ramdisk/ladestarthooklp1aktiv ]; then
				touch ramdisk/ladestarthooklp1aktiv
				if [[ $ladestarthooklp1_url  =~ ^http.*:// ]] ; then
					#openwbDebugLog "CHARGESTAT" 0 "Ladestart-curl [$ladestarthooklp1_url]"
					curl -s --connect-timeout 5 $ladestarthooklp1_url > /dev/null
				else
					#openwbDebugLog "CHARGESTAT" 0 "Ladestart-tsp [$ladestarthooklp1_url] "
					tsp  bash -c "$ladestarthooklp1_url >>/var/www/html/openWB/ramdisk/event.log"
				fi	
				openwbDebugLog "CHARGESTAT" 0 "Ladestart-WebHook LP1 ausgeführt "
				openwbDebugLog "MAIN" 1 "Ladestart-WebHook LP1 ausgeführt"
			fi
		else
			if [  -e ramdisk/ladestarthooklp1aktiv ]; then
				rm ramdisk/ladestarthooklp1aktiv
			fi
		fi
	fi
	if (( ladestophooklp1 == 1 )); then
		read ladungaktivlp1 <ramdisk/ladungaktivlp1
		if (( ladungaktivlp1 == 0 )); then
			if [ ! -e ramdisk/ladestophooklp1aktiv ]; then
				touch ramdisk/ladestophooklp1aktiv
				if [[ $ladestophooklp1_url =~ ^http.*:// ]] ; then
					#openwbDebugLog "CHARGESTAT" 0 "Ladestopp-curl [$ladestophooklp1_url]"
					curl -s --connect-timeout 5 $ladestophooklp1_url > /dev/null
				else
					#openwbDebugLog "CHARGESTAT" 0 "Ladestopp-tsp [$ladestophooklp1_url] "
					tsp  bash -c "$ladestophooklp1_url >>/var/www/html/openWB/ramdisk/event.log"
				fi	
				openwbDebugLog "CHARGESTAT" 0 "Ladestopp-WebHook LP1 ausgeführt"
				openwbDebugLog "MAIN" 1 "Ladestopp-WebHook LP1 ausgeführt "
			fi
		else
			if [  -e ramdisk/ladestophooklp1aktiv ]; then
				rm ramdisk/ladestophooklp1aktiv
			fi
		fi
	fi

}
