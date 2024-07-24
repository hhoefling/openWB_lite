#!/bin/bash
# NUR PV Uberschussregelung Lademodus 2
openwbDebugLog "MAIN" 1 "source nurpv.sh"
     
#
# from config minimalapv 6-16
#
# return 0 (no exit anymore)
nurpvlademodus(){
    openwbDebugLog "MAIN" 1 "nurpvlademodus called"
	meld "NurPV"
    
    local llaltlp1
    llaltlp1=$llalt
		
	openwbDebugLog "PV" 0 "NurPV 1 uberschuss: $uberschuss  HausMinLade:$speichermaxwatt HausMaxEntnahme $speicherwattnurpv"
	maxll=($llalt $llalts1 $llalts2)  #  $llaltlp4 $llaltlp5 $llaltlp6 $llaltlp7 $llaltlp8)
	maxllvar=0
	for v in "${maxll[@]}"; do
		if (( v > maxllvar )); then maxllvar=$v; fi;
	done
	llalt=$maxllvar		# hoechstes altueller ladestrom aller LP
	if (( llalt > minimalapv )); then
		if (( llaltlp1 == minimalapv )); then
			llalt=$minimalapv
		fi
	fi

	if [[ $schieflastaktiv == "1" ]]; then
		if [[ $u1p3paktiv == "1" ]]; then                # config 0/1  u1p3 aktive
			read u1p3pstat <ramdisk/u1p3pstat
			if [[ $u1p3pstat == "1" ]]; then			# aktuell 1 phasig?
				if (( schieflastmaxa < maximalstromstaerke )); then
					maximalstromstaerke=$schieflastmaxa
					openwbDebugLog "PV" 0 "Maximalstromstärke begrenzt auf $schieflastmaxa da Schieflastbegrenzung konfiguriert"
				fi
			fi
		fi
	fi
	
	meld "$llalt"
	
	if [[ $lastmanagement == "0" ]]; then
		openwbDebugLog "PV" 0 "Nur LP1, keine automatischen Abschaltungen"
	else
		if (( stopchargeafterdisclp1 == 0 )); then
			if [[ $stopchargepvatpercentlp1 == "1" ]]; then
				if (( soc > stopchargepvpercentagelp1 )); then  
					if [[ $lp1enabled == "1" ]]; then
						mosquitto_pub -r -t "openWB/set/lp/1/ChargePointEnabled" -m "0"
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Schalte Ladepunkt auf gesperrt da $soc % SoC erreicht, Ziel $stopchargepvpercentagelp1 %"
						openwbDebugLog "PV" 0 "LP1, Lademodus NurPV. Schalte Ladepunkt auf gesperrt da $soc % SoC erreicht, Ziel $stopchargepvpercentagelp1 %"
						echo "SoC PV Begrenzung (Limit: $stopchargepvpercentagelp1%) LP1 aktiv, LP gesperrt" > ramdisk/lastregelungaktiv
			      	    meld "Soc Limit erreicht, sperre LP1"

					fi
				fi
				if (( soc < stopchargepvpercentagelp1 )); then
					if [[ $lp1enabled == "0" ]]; then
						mosquitto_pub -r -t "openWB/set/lp/1/ChargePointEnabled" -m "1"
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Schalte Ladepunkt frei da $soc % SoC noch nicht erreicht, Ziel $stopchargepvpercentagelp1 %"
						openwbDebugLog "PV" 0 "LP1, Lademodus NurPV. Schalte Ladepunkt frei da $soc % SoC noch nicht erreicht, Ziel $stopchargepvpercentagelp1 %"
						echo "SoC PV Begrenzung LP1 (Limit: $stopchargepvpercentagelp1%) unterschritten, LP entsperrt" > ramdisk/lastregelungaktiv
		      	    	meld "Soc Limit unterschritten, gebe LP1 frei"

					fi
				fi
			fi
		fi
		if (( stopchargeafterdisclp2 == 0 )); then
			if [[ $stopchargepvatpercentlp2 == "1" ]]; then
				if (( soc1 > stopchargepvpercentagelp2 )); then
					if [[ $lp2enabled == "1" ]]; then
						mosquitto_pub -r -t "openWB/set/lp/2/ChargePointEnabled" -m "0"
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Schalte Ladepunkt auf gesperrt da $soc1 % SoC erreicht, Ziel $stopchargepvpercentagelp2 %"
						openwbDebugLog "PV" 0 "LP2, Lademodus NurPV. Schalte Ladepunkt auf gesperrt da $soc1 % SoC erreicht, Ziel $stopchargepvpercentagelp2 %"
						echo "SoC PV Begrenzung LP2 (Limit: $stopchargepvpercentagelp2%) aktiv, LP gesperrt" > ramdisk/lastregelungaktiv
		    	  	    meld "Soc Limit erreicht, sperre LP2"

					fi
				fi
				if (( soc1 < stopchargepvpercentagelp2 )); then
					if [[ $lp2enabled == "0" ]]; then
						mosquitto_pub -r -t "openWB/set/lp/2/ChargePointEnabled" -m "1"
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Schalte Ladepunkt frei da $soc % SoC noch nicht erreicht, Ziel $stopchargepvpercentagelp2 %"
						openwbDebugLog "PV" 0 "LP2, Lademodus NurPV. Schalte Ladepunkt frei da $soc % SoC noch nicht erreicht, Ziel $stopchargepvpercentagelp2 %"
						echo "SoC PV Begrenzung LP2 (Limit: $stopchargepvpercentagelp2%) unterschritten, LP entsperrt" > ramdisk/lastregelungaktiv
		      	    	meld "Soc Limit unterschritten, gebe LP2 frei"
	
					fi
				fi
			fi
		fi
	fi # mehr als 1 lp


# Sofortladen bis min soc
 
	if [[ $lastmanagement == "0" ]]; then
		meld "1LP"

		openwbDebugLog "PV" 0 "NurPV 2 nur ein Ladepunkt"
		if [[ $socmodul != "none" ]]; then
			if (( soc < minnurpvsoclp1 )); then
			 	# Wir sollten ladem, soc nicht erreicht
				if grep -q 0 "ramdisk/ladestatus"; then
					runs/set-current.sh $minnurpvsocll all
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung mit $minnurpvsocll Ampere, $soc % SoC noch nicht erreicht"
					openwbDebugLog "MAIN" 1 "Starte PV Laden da $minnurpvsoclp1 % zu gering"
					openwbDebugLog "PV" 0 "NurPV 2a Starte PV Laden da $minnurpvsoclp1 % zu gering"
					meld "Soc<, Start $minnurpvsocll"
				else
					if (( llalt != minnurpvsocll )); then
						runs/set-current.sh $minnurpvsocll all
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung geändert auf $minnurpvsocll Ampere, $soc % SoC noch nicht erreicht"
						openwbDebugLog "PV" 0 "NurPV 2b LP1, Ladung geändert auf $minnurpvsocll Ampere, $soc % SoC noch nicht erreicht"
						meld "Soc<, Lade mit $minnurpvsocll"
					fi
				fi
			  echo "Ladung mit $minnurpvsocll Ampere, da $minnurpvsoclp1 % SoC noch nicht erreicht" > ramdisk/lastregelungaktiv
			  openwbDebugLog "PV" 0 "NurPV-1 return 0"
			  return 0
			fi
			if (( soc >= maxnurpvsoclp1 ))  && (( maxnurpvsoclp1<100 )); then
				if grep -q 1 "ramdisk/ladestatus"; then
					runs/set-current.sh 0 all
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung gestoppt, $soc % SoC erreicht"
					openwbDebugLog "MAIN" 1 "Beende PV Laden da $maxnurpvsoclp1 % erreicht"
					openwbDebugLog "PV" 0 "NurPV 2c Beende PV Laden da $maxnurpvsoclp1 % erreicht"
				fi
				meld "SOC erreicht, Stop"
				openwbDebugLog "PV" 0 "NurPV-2 return  0"
			    return 0
			fi
		fi
	fi

# Laden wir gerade?
	if grep -q 0 "ramdisk/ladestatus"; then
	    meld "try to start"
	    # nein, sicherheitslaber alles aus machen wenn noch was läd
		if (( ladestatuss1 == 1 )) || (( ladestatuss2 == 1 )); then
			runs/set-current.sh 0 all
			openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung gestoppt"
		fi
		openwbDebugLog "PV" 1 "NurPV 20, keine ladung aktiv, check ob start möglich ( $mindestuberschussphasen <= $uberschuss )"
		openwbDebugLog "MAIN" 1 "Überschuss $uberschuss; mindestens $mindestuberschussphasen"
		if (( mindestuberschussphasen <= uberschuss )); then
			openwbDebugLog "PV" 0 "NurPV 21 Überschuss $uberschuss ist größer als nötiger Überschuss, Wert: $mindestuberschussphasen"
			pvecounter=$(cat /var/www/html/openWB/ramdisk/pvecounter)
			if (( pvecounter < einschaltverzoegerung )); then
				openwbDebugLog "PV" 0 "NurPV 22 Einschaltverzögerung aktiv, Aktuell: $pvecounter, Ziel: $einschaltverzoegerung"
				pvecounter=$((pvecounter + 10))
				echo $pvecounter > /var/www/html/openWB/ramdisk/pvecounter
				openwbDebugLog "PV" 1 "NurPV 23 Einschaltverzögerung auf $pvecounter erhöht, Ziel $einschaltverzoegerung, return 0"
				return 0
			else
				openwbDebugLog "MAIN" 1 "nur pv ladung auf $minimalapv starten"
				openwbDebugLog "PV" 0 "Einschaltverzögerung erreicht, Aktuell: $pvecounter, Ziel: $einschaltverzoegerung"
				if (( minimalapv == minimalalp2pv )); then
					runs/set-current.sh $minimalapv all
					openwbDebugLog "PV" 0 "starte Ladung"
					openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung gestartet mit $minimalapv Ampere"
				else
					openwbDebugLog "PV" 0 "starte Ladung LP1 mit $minimalapv"
					runs/set-current.sh $minimalapv m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung gestartet mit $minimalapv Ampere"
					openwbDebugLog "PV" 0 "starte Ladung LP2 mit $minimalalp2pv"
					runs/set-current.sh $minimalalp2pv s1
					openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Ladung gestartet mit $minimalalp2pv Ampere"
				fi
				echo 0 > /var/www/html/openWB/ramdisk/pvcounter
				echo 0 > /var/www/html/openWB/ramdisk/pvecounter
				openwbDebugLog "PV" 0 "setzte Soctimer hoch zum Abfragen des aktuellen SoC, return 0"
				echo 20000 > /var/www/html/openWB/ramdisk/soctimer
				return 0
			fi
		else
			echo 0 > /var/www/html/openWB/ramdisk/pvecounter
			openwbDebugLog "PV" 0 "NurPV-5 set pvecounter=0 return 0"
			return 0
		fi
	fi

	# ladeleiszung ist die gesammte aktelle ladeleistung aller ladepunkte
	if (( ladeleistung < 300 )); then
	    meld "force"
		openwbDebugLog "PV" 0 "Keine Ladung aktiv (ladeleistung<300) llalt:$llalt  minimalApv:$minimalapv"
		if (( llalt > minimalapv )); then
			llneu=$minimalapv
			if (( minimalapv == minimalalp2pv )); then
				runs/set-current.sh $llneu all
				openwbDebugLog "PV" 0 "alle Ladepunkte, Lademodus NurPV. Ladung geändert auf $llneu Ampere"
				openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung geändert auf $llneu Ampere"
			else
				runs/set-current.sh $minimalapv m
				openwbDebugLog "PV" 0 "LP1, Lademodus NurPV. Ladung geändert auf $minimalapv Ampere"
				openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung geändert auf $minimalapv Ampere"

				runs/set-current.sh $minimalalp2pv s1
				openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Ladung geändert auf $minimalalp2pv Ampere"
				openwbDebugLog "PV" 0 "LP2, Lademodus NurPV. Ladung geändert auf $minimalalp2pv Ampere"
			fi
			echo 0 > /var/www/html/openWB/ramdisk/pvcounter
			openwbDebugLog "PV" 0 "NurPV-6 return 0"
			return 0
		fi
		if (( llalt < minimalapv )); then
			llneu=$minimalapv
			if (( minimalapv == minimalalp2pv )); then
				runs/set-current.sh $llneu all
				openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung geändert auf $llneu Ampere" "ladelog"
				openwbDebugLog "PV" 0 "alle Ladepunkte, Lademodus NurPV. Ladung geändert auf $llneu Ampere"
			else
				runs/set-current.sh $minimalapv m
				openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung geändert auf $minimalapv Ampere"
				openwbDebugLog "PV" 0 "LP1, Lademodus NurPV. Ladung geändert auf $minimalapv Ampere"

				runs/set-current.sh $minimalalp2pv s1
				openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Ladung geändert auf $minimalalp2pv Ampere"
				openwbDebugLog "PV" 0 "LP2, Lademodus NurPV. Ladung geändert auf $minimalalp2pv Ampere"
			fi
			echo 0 > /var/www/html/openWB/ramdisk/pvcounter
			openwbDebugLog "PV" 0 "NurPV-7 return 0"
			return 0
		fi
		if (( llalt == minimalapv )); then
			if (( uberschuss < mindestuberschussphasen )); then
				#pvcounter=$(cat /var/www/html/openWB/ramdisk/pvcounter)
				#if (( pvcounter < abschaltverzoegerung )); then
				#	pvcounter=$((pvcounter + 10))
				#	echo $pvcounter > /var/www/html/openWB/ramdisk/pvcounter
				#	openwbDebugLog "MAIN" 1 "Nur PV auf Minimalstromstaerke, PV Counter auf $pvcounter erhöht"
				#else
					if [ -e ramdisk/nurpvoff ]; then
						runs/set-current.sh 0 all
						openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladefreigabe aufgehoben, Überschuss unterschritten"
						openwbDebugLog "MAIN" 1 "NurPV Ladung beendet (all)"
						rm ramdisk/nurpvoff
					else # Keine aktive Ladung erkannt, Mindestüberschuss unterschritten
						if [ "$cpunterbrechungmindestlaufzeitaktiv" == "1" ]; then # Mindestwartezeit für Ladestopp nach CP Unterbrechung aktiviert	
							# Lade letzte Timestamps der letzten CP Unterbrechungen
							openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Prüfe minimale Wartezeit nach CP Unterbrechung"
							currentTimestamp=$(date +%s)
							if [ -e ramdisk/cpulp1timestamp ] ;
							then
								cpulp1timestamp=$(cat ramdisk/cpulp1timestamp) # Timestamp letzter CP Unterbrechung laden
								openwbDebugLog "CHARGESTAT" 1 "LP1, Lademodus NurPV. Timestamp letzter CP Unterbrechung: ($cpulp1timestamp)"						
							else
								cpulp1timestamp=$currentTimestamp # kein Timestamp gefunden, nutze aktuelle Zeit
								openwbDebugLog "CHARGESTAT" 1 "LP1, Lademodus NurPV. Kein Timestamp für LP1 gefunden, nutze aktuelle Zeit: ($cpulp1timestamp)"
							fi
							if [ -e ramdisk/cpulp2timestamp ] ;
							then
								cpulp2timestamp=$(cat ramdisk/cpulp2timestamp) # Timestamp letzter CP Unterbrechung laden
								openwbDebugLog "CHARGESTAT" 1 "LP2, Lademodus NurPV. Timestamp letzter CP Unterbrechung: ($cpulp2timestamp)"
							else
								cpulp2timestamp=$currentTimestamp # kein Timestamp gefunden, nutze aktuelle Zeit
								openwbDebugLog "CHARGESTAT" 1 "LP2, Lademodus NurPV. Kein Timestamp für LP2 gefunden, nutze aktuelle Zeit: ($cpulp2timestamp)"
							fi
							
							# Prüfe ob Mindestwartezeit nach CP Unterbrechung verstrichen ist
							if (( $cpulp1timestamp + $cpunterbrechungmindestlaufzeit < $currentTimestamp )) || (( $cpulp2timestamp + $cpunterbrechungmindestlaufzeit < $currentTimestamp )); #Mehr als x Sekunden nach letzter CP Unterbrechung vergangen?
							then
								openwbDebugLog "CHARGESTAT" 1 "alle Ladepunkte, Lademodus NurPV. Überschuss unterschritten, minimale Wartezeit nach CP Unterbrechung abgelaufen, setze nurpvoff."
								touch ramdisk/nurpvoff
							else
								openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Überschuss unterschritten, minimale Wartezeit nach CP Unterbrechung noch nicht abgelaufen."
							fi
						else
							touch ramdisk/nurpvoff
						fi
						
					fi
					openwbDebugLog "PV" 0 "Ladefreigabe aufgehoben da zu wenig Uberschuss vorhanden"
				#fi
			fi
		fi
	else
		if [[ $speichervorhanden == "1" ]]; then
			if (( speicherleistung < 10 )); then	# Speicher still oder wird entladen
				if (( speichersoc > speichersocnurpv )); then
					uberschuss=$((uberschuss + speicherleistung + speicherwattnurpv))
					openwbDebugLog "PV" 0 "NurPV 2 SpeicherSoc ($speichersoc) über konfiguriertem Wert ($speichersocnurpv), neuer Überschusswert: $uberschuss"
					meld "Bat+Ü:$uberschuss"
					bmeld "NPV1 Ü:$uberschuss"
				else
					uberschuss=$((uberschuss + speicherleistung))
					openwbDebugLog "PV" 0 "NurPV 2a SpeicherSoc ($speichersoc) unter konfiguriertem Wert ($speichersocnurpv), neuer Überschusswert: $uberschuss"
					meld "Bat-Ü:$uberschuss"
					bmeld "NPV2 Ü:$uberschuss"
				fi
			fi
		fi
		
    	meld "flow "
		openwbDebugLog "PV" 0 "NurPV uebeschuss: $uberschuss schaltschwelle:$schaltschwelle llalt:$llalt"
		if (( uberschuss > schaltschwelle )); then
    		meld "may++ "
		
			if (( llalt == maximalstromstaerke )); then
				openwbDebugLog "MAIN" 1 "llalt == maximalstromstaerke"
				#exit 0
			fi
			if [[ $pvbezugeinspeisung == "0" ]]; then
				if (( nurpvslowup == 1 )); then
					llneu=$(( llalt + 1 ))
		     		openwbDebugLog "PV" 0 "NurPV 4 erhoehe Ampere um 1 auf $llneu"
				else
					llneu=$(( llalt + ( uberschuss / 230 / anzahlphasen)))
		     		openwbDebugLog "PV" 0 "NurPV 4a erhoehe Ampere um ueberschuss  auf $llneu"
				fi
			else
				if (( llalt == minimalapv )); then
					llneu=$(( llalt + 1 ))
		     		openwbDebugLog "PV" 0 "NurPV 5 erhoehe Ampere um 1 auf $llneu"
				else
					if (( nurpvslowup == 1 )); then
						llneu=$(( llalt + 1 ))
		     		    openwbDebugLog "PV" 0 "NurPV 5a erhoehe Ampere um 1 auf $llneu"
					else
						llneu=$(( llalt + ( (uberschuss - schaltschwelle) / 230 / anzahlphasen)))
		     		    openwbDebugLog "PV" 0 "NurPV 5b erhoehe Ampere um ueberschuss  auf $llneu"
					fi
				fi
			fi
			if (( llneu > maximalstromstaerke )); then
				llneu=$maximalstromstaerke
			fi
			if (( llneu < minimalapv )); then
				llneu=$minimalapv
			fi
			meld "=$llneu"
			openwbDebugLog "PV" 0 "Überschuss ($uberschuss) ist größer als Schaltschwelle ($schaltschwelle), neuer Ladestromwert: $llneu"
			if (( adaptpv == 1 )) && (( soc > 0 )) && (( soc1 > 0 )) && (( (( anzahlphasen == 6 )) || (( anzahlphasen == 2 )) )); then
				# adaptive + beide soc's>0 und wir laden mit 2*1 oder 2*3 phasen
				if (( minimalalp2pv > minimalapv )); then
					minimalapv=$minimalalp2pv
				fi
				socdist=$(echo $((soc1 - soc)) | sed 's/-//')
				anzahl=$((socdist / adaptfaktor))
				if (( soc1 > soc )); then
					higherev=s1
					lowerev=m
				else
					higherev=m
					lowerev=s1
				fi
				llhigher=$llneu
				lllower=$llneu
				# statt 2* die hälfte , verschiebe zum vorhezogenen lp
				for ((i=1;i<=anzahl;i++)); do
					if (( llhigher > minimalapv )) && (( lllower < maximalstromstaerke )); then
						llhigher=$((llhigher - 1))
						lllower=$((lllower + 1))
					fi
				done
				runs/set-current.sh $llhigher $higherev
				openwbDebugLog "CHARGESTAT" 0 "LP$higherev, Lademodus NurPV. Adaptive PV Ladung geändert auf $llhigher Ampere"
				runs/set-current.sh $lllower $lowerev
				openwbDebugLog "CHARGESTAT" 0 "LP$lowerev, Lademodus NurPV. Adaptive PV Ladung geändert auf $lllower Ampere"
				sleep 1
				echo $llneu > ramdisk/llsoll
				echo $llneu > ramdisk/llsolls1
				openwbDebugLog "MAIN" 1 "$llneu erhöht, adaptiert auf $llhigher A für LP $higherev und $lllower A für LP $lowerev"
			else
				runs/set-current.sh $llneu all
				if (( llalt != llneu)) ; then  
					openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung++ geändert von $llalt auf $llneu Ampere"
				fi
				openwbDebugLog "MAIN" 1 "pv ladung auf $llneu erhoeht"
			fi
			echo 0 > /var/www/html/openWB/ramdisk/pvcounter
			openwbDebugLog "PV" 0 "NurPV-8 return 0"
			return 0
		fi
		if (( uberschuss < pvregelungm )); then
			if (( llalt > minimalapv )); then
				llneu=$(( llalt - 1 + ( (uberschuss - pvregelungm) / 230 / anzahlphasen)))
				if (( llneu < minimalapv )); then
					llneu=$minimalapv
				fi
				if (( adaptpv == 1 )) && (( soc > 0 )) && (( soc1 > 0 )) && (( (( anzahlphasen == 6 )) || (( anzahlphasen == 2 )) )); then
					socdist=$(echo $((soc1 - soc)) | sed 's/-//')
					anzahl=$((socdist / adaptfaktor))
					if (( soc1 > soc )); then
						higherev=s1
						lowerev=m
					else
						higherev=m
						lowerev=s1
					fi
					llhigher=$llneu
					lllower=$llneu
					for ((i=1;i<=anzahl;i++)); do
						if (( llhigher > minimalapv )) && (( lllower < maximalstromstaerke )); then
							llhigher=$((llhigher - 1))
							lllower=$((lllower + 1))
						fi
					done
					runs/set-current.sh $llhigher $higherev
					openwbDebugLog "CHARGESTAT" 0 "LP$higherev, Lademodus NurPV. Adaptive PV Ladung geändert auf $llhigher Ampere"
					runs/set-current.sh $lllower $lowerev
					openwbDebugLog "CHARGESTAT" 0 "LP$lowerev, Lademodus NurPV. Adaptive PV Ladung geändert auf $lllower Ampere"

					sleep 1
					echo $llneu > ramdisk/llsoll
					echo $llneu > ramdisk/llsolls1

					openwbDebugLog "MAIN" 1 "$llneu reduziert, adaptiert auf $llhigher A für LP $higherev und $lllower A für LP $lowerev"
				else
					if (( minimalapv == minimalalp2pv )); then
						runs/set-current.sh $llneu all
						if (( llalt != llneu)) ; then   
							openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung-- geändert von $llalt auf $llneu Ampere"
						fi	
						openwbDebugLog "MAIN" 1 "pv ladung auf $llneu reduziert"
					else
						runs/set-current.sh $llneu m

						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus NurPV. Ladung geändert auf $llneu Ampere"
						if (( llneu < minimalalp2pv )); then
							llneulp2=$minimalalp2pv
						else
							llneulp2=$llneu
						fi
						runs/set-current.sh $llneulp2 s1
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus NurPV. Ladung geändert auf $llneulp2 Ampere"
						openwbDebugLog "MAIN" 1 "pv ladung auf $llneu bzw. $llneulp2 reduziert"
					fi
				fi
				openwbDebugLog "PV" 0 "Uberschuss ($uberschuss) geringer als herunterschaltschwelle ($pvregelungm), neuer Ladestromwert: $llneu"
				echo 0 > /var/www/html/openWB/ramdisk/pvcounter
				openwbDebugLog "PV" 0 "NurPV-9 return 0"
				return 0
			else
				if [[ $nurpv70dynact == "1" ]]; then
					read nurpv70status <ramdisk/nurpv70dynstatus
					if [[ $nurpv70status == "1" ]]; then
						abschaltuberschuss=$(( 1500 * anzahlphasen ))
						openwbDebugLog "MAIN" 1 "Setze neue Abschwaltschwelle"
					fi
				fi
				openwbDebugLog "MAIN" 1 "Abschaltschwelle: $((-abschaltuberschuss)), Überschuss derzeit: $uberschuss"

				if (( uberschuss < -abschaltuberschuss )); then
					pvcounter=$(cat /var/www/html/openWB/ramdisk/pvcounter)
					if (( pvcounter < abschaltverzoegerung )); then
						pvcounter=$((pvcounter + 10))
						echo $pvcounter > /var/www/html/openWB/ramdisk/pvcounter
						openwbDebugLog "MAIN" 1 "Nur PV auf Minimalstromstaerke, PV Counter auf $pvcounter erhöht"
						openwbDebugLog "PV" 0 "Überschuss ($uberschuss) kleiner als Abschwaltschwelle ($abschaltuberschuss), Verzögerung ($pvcounter) kleiner als Ziel $abschaltverzoegerung Sec"
						meld "cnt($pvcounter)"
					else
						openwbDebugLog "PV" 0 "Abschaltverzögerung erreicht, stoppe Ladung"
						runs/set-current.sh 0 all
						openwbDebugLog "CHARGESTAT" 0 "alle Ladepunkte, Lademodus NurPV. Ladung gestoppt zu wenig PV Leistung: $uberschuss"
						openwbDebugLog "MAIN" 1 "pv ladung beendet"
						echo 0 > /var/www/html/openWB/ramdisk/pvcounter
					fi
					openwbDebugLog "PV" 0 "NurPV-10 return 0"
					return 0
				else
					openwbDebugLog "PV" 0 "Minimalstromstärke erreicht, Überschuss größer als Abschaltschwelle"
					echo 0 > /var/www/html/openWB/ramdisk/pvcounter
					openwbDebugLog "PV" 0 "NurPV-11 return 0"
					return 0
				fi
			fi
		fi
	fi

 openwbDebugLog "PV" 0 "*** NurPV-99 (never) return 0"
 return 0
}
