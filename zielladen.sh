#!/bin/bash

openwbDebugLog "MAIN" 1 "source zielladen.sh"

    
#// Zielladen aktiv wunschawh:[4600], 
#// maximal mögliche:[5520], 
#// zu ladende Wh:[17280],  
#// mögliche ladbare Wh bis Zieluhrzeit:[59570]
 
#// aufruf bei zielladenaktivlp1>0
ziellademodus(){

    openwbDebugLog "MAIN" 1 "ziellademodus called"

	local zielladenkorrektura
	read zielladenkorrektura <ramdisk/zielladenkorrektur)

	read ladestatus <ramdisk/ladestatus

	#verbleibende Zeit berechnen
	local dateaktuell=$(date '+%Y-%m-%d %H:%M')
	local epochdateaktuell=$(date -d "$dateaktuell" +"%s")
	local epochdateziel=$(date -d "$zielladenuhrzeitlp1" +"%s")
	local zeitdiff=$(( epochdateziel - epochdateaktuell ))
	local minzeitdiff=$(( zeitdiff / 60 ))
	
	# zu ladende Menge ermitteln
	read soc <ramdisk/soc
	local zuladendersoc=$(( zielladensoclp1 - soc ))
	local akkuglp1wh=$(( akkuglp1 * 1000 ))
	local zuladendewh=$(( akkuglp1wh * zuladendersoc / 100 ))

	#ladeleistung ermitteln
	local lademaxwh=$(( zielladenmaxalp1 * zielladenphasenlp1 * 230 ))

	local wunschawh=$(( zielladenalp1 * zielladenphasenlp1 * 230 ))
	#ladezeit ermitteln
	if (( llalt > 5 )); then
		wunschawh=$(( llalt * zielladenphasenlp1 * 230 ))
	fi
	moeglichewh=$(( wunschawh * minzeitdiff / 60 ))

	openwbDebugLog "MAIN" 1 "Zielladen aktiv wunschawh:[$wunschawh], maximal mögliche:[$lademaxwh], zu ladende Wh:[$zuladendewh],  mögliche ladbare Wh bis Zieluhrzeit:[$moeglichewh]"
	diffwh=$(( zuladendewh - moeglichewh ))
	openwbDebugLog "MAIN" 1 "Zielladen diffwh:[$diffwh]"
	#vars
	local ladungdurchziel
	read ladungdurchziel <ramdisk/ladungdurchziel
    meld " ZL:[$ladungdurchziel $ladestatus]"
	
	if (( zuladendewh <= 0 )); then
        meld " ZL:nix zu laden, stop if charging"
		if (( ladestatus == 1 )); then
            meld " do Stop Zielladen"
			echo 0 > ramdisk/ladungdurchziel
			echo 0 > ramdisk/zielladenkorrektura
			# Store in openwb.conf 
			# schalte ziellande.sh komplett ab, 
			sed -e "s/zielladenaktivlp1=.*/zielladenaktivlp1=0/" openwb.conf > ramdisk/openwb.conf	&& mv ramdisk/openwb.conf openwb.conf && chmod 777 openwb.conf
			runs/set-current.sh 0 m
		fi
	else
        meld " ZL:$zuladendewh "
		if (( zuladendewh > moeglichewh )); then
			if (( ladestatus == 0  )); then
				if (( lp1enabled == 1 )) ; then
    		    	meld " ZL: es wird zeit, start set $zielladenalp1"
					runs/set-current.sh $zielladenalp1 m
					openwbDebugLog "MAIN" 1 "setzte Soctimer hoch zum Abfragen des aktuellen SoC"
					echo 20000 > /var/www/html/openWB/ramdisk/soctimer
					echo 1 > ramdisk/ladungdurchziel
				    openwbDebugLog "MAIN" 0 "*** EXIT 0"
					exit 0     # keine Weiter regelung"
				else
    		    	meld " ZL: kann nicht, will aber"
				fi			
			else
    		    meld " ZL:>,läuft"
				if (( diffwh > 1000 )); then
					if test $(find /var/www/html/openWB/ramdisk/zielladenkorrektura -mmin +10); then
						meld " wird knap, +1 alle 10 minuten "
						zielladenkorrektura=$(( zielladenkorrektura + 1 ))
						echo $zielladenkorrektura > ramdisk/zielladenkorrektura
						zielneu=$(( zielladenalp1 + zielladenkorrektura ))
						if (( zielneu > zielladenmaxalp1)); then
							zielneu=$zielladenmaxalp1
						fi
						runs/set-current.sh $zielneu m
					    openwbDebugLog "MAIN" 0 "*** EXIT 0"
						exit 0    # keine Weiter regelung"
					fi
				fi
			fi
		else
  		    meld " ZL:<,warten"
			if (( ladestatus == 1 )); then
				if (( diffwh < -1000 )); then
					if test $(find /var/www/html/openWB/ramdisk/zielladenkorrektura -mmin +10); then
  		    		    meld " korrigire-1, alle 10 Minuten"
						zielladenkorrektura=$(( zielladenkorrektura - 1 ))
						echo $zielladenkorrektura > ramdisk/zielladenkorrektura
						zielneu=$(( zielladenalp1 + zielladenkorrektura ))
						if (( zielneu < minimalstromstaerke )); then
							zielneu=$minimalstromstaerke
						fi
						runs/set-current.sh $zielneu m
					    openwbDebugLog "MAIN" 0 "*** EXIT 0"
						exit 0    # keine Weiter regelung"
					fi
				fi
			fi
		fi
	fi
	if (( ladungdurchziel == 1 )); then
	# breche regel.sh hier ab 
		openwbDebugLog "MAIN" 0 "*** EXIT 0,  Zielladen aktive, also abort regel in Zielladen"
		exit 0        # keine Weiter regelung"
	fi
}
