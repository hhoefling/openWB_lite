#!/bin/bash
# openwbDebugLog "MAIN" 2 "source sofortlademodus.sh"


sofortlademodus(){

	openwbDebugLog "MAIN" 1 "sofortlademodus called"
	if [[ $schieflastaktiv == "1" ]]; then
		if [[ $u1p3paktiv == "1" ]]; then
			read u1p3pstat <ramdisk/u1p3pstat
			if [[ $u1p3pstat == "1" ]]; then
				maximalstromstaerke=$schieflastmaxa
			fi
		fi
	fi
	if (( etprovideraktiv == 1 )); then
		read actualprice <ramdisk/etproviderprice
        read etprovidermaxprice <ramdisk/etprovidermaxprice
        openwbDebugLog "DEB" 1 "etprovideraktiv == 1, price:[$actualprice] max:[$etprovidermaxprice]"
		if (( $(echo "$actualprice <= $etprovidermaxprice" |bc -l) )); then
			#price lower than max price, enable charging
			openwbDebugLog "MAIN" 1 "Aktiviere Ladung (preisbasiert), Preis $actualprice, Max $etprovidermaxprice"
			if (( lp1enabled == 0 )); then
				mosquitto_pub -r -t openWB/set/lp/1/ChargePointEnabled -m "1"
			fi
			if (( lp2enabled == 0 )); then
				mosquitto_pub -r -t openWB/set/lp/2/ChargePointEnabled -m "1"
			fi
			if (( lp3enabled == 0 )); then
				mosquitto_pub -r -t openWB/set/lp/3/ChargePointEnabled -m "1"
			fi
		else
			openwbDebugLog "MAIN" 1 "Deaktiviere Ladung (preisbasiert), Preis $actualprice, Max $etprovidermaxprice"
			#price higher than max price, disable charging
			if (( lp1enabled == 1 )); then
				mosquitto_pub -r -t openWB/set/lp/1/ChargePointEnabled -m "0"
			fi
			if (( lp2enabled == 1 )); then
				mosquitto_pub -r -t openWB/set/lp/2/ChargePointEnabled -m "0"
			fi
			if (( lp3enabled == 1 )); then
				mosquitto_pub -r -t openWB/set/lp/3/ChargePointEnabled -m "0"
			fi
			
		fi
	fi
	if (( lastmmaxw < 10 ));then
		lastmmaxw=40000
	fi
	read aktgeladen <ramdisk/aktgeladen
    # mit einem Ladepunkt
	if [[ $lastmanagement == "0" ]]; then
		if (( msmoduslp1 == "2" )); then
			openwbDebugLog "MAIN" 0 "sofortLP1  $soc $sofortsoclp1"
			if (( soc >= sofortsoclp1 )) && (( sofortsoclp1 < 100 )); then    ##  HH Ok, stop bei 80=80 stop nicht bei ziel=100
				if grep -q 1 "ramdisk/ladestatus"; then
					runs/set-current.sh 0 all
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gestoppt, $soc % SoC erreicht"
                    openwbDebugLog "MAIN" 1 "Beende Sofort Laden da $sofortsoclp1 % erreicht"
				fi
				meld "Sofort1, SOC erreicht"
				openwbDebugLog "MAIN" 0 "*** exit 0 (sofort1)"
				exit 0
			fi
		fi
		if grep -q 0 "ramdisk/ladestatus"; then
			if (( msmoduslp1 == "1" )); then
				if (( $(echo "$aktgeladen > $lademkwh" |bc -l) )); then
					meld "Sofort1a, Lademenge erreicht"
					openwbDebugLog "MAIN" 1 "Sofort ladung beendet da $lademkwh kWh lademenge erreicht"
				else
					runs/set-current.sh $minimalstromstaerke all
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gestartet mit $minimalstromstaerke Ampere"
					openwbDebugLog "MAIN" 1 "starte sofort Ladeleistung von $minimalstromstaerke aus"
					meld "Sofort2, Start mit $minimalstromstaerke" 
				    openwbDebugLog "MAIN" 0 "*** exit 0 (sofort2)"
					exit 0
				fi
			else
				runs/set-current.sh $minimalstromstaerke all
				openwbDebugLog "MAIN" 1 "starte sofort Ladeleistung von $minimalstromstaerke aus"
				meld "Sofort3, Start mit $minimalstromstaerke" 
			    openwbDebugLog "MAIN" 0 "*** exit 0 (sofort3)"
				exit 0
			fi
		fi
		if grep -q 1 "ramdisk/ladestatus"; then
			if (( msmoduslp1 == "1" )) && (( $(echo "$aktgeladen > $lademkwh" |bc -l) )); then
				runs/set-current.sh 0 m
				openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gestoppt da $lademkwh kWh Limit erreicht"
				openwbDebugLog "MAIN" 1 "Beende Sofort Laden da  $lademkwh kWh erreicht"
				meld "Sofort4a, Stop Lademnege erreicht" 
			else
				if (( evua1 < lastmaxap1 )) && (( evua2 < lastmaxap2 )) &&  (( evua3 < lastmaxap3 )) && (( wattbezug < lastmmaxw )); then
					if (( ladeleistunglp1 < 100 )); then
						if (( llalt > minimalstromstaerke )); then
							llneu=$((llalt - 1 ))
							runs/set-current.sh $llneu m
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung reduziert auf $llneu bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort4)"
							meld "Sofort4, Ladestrom reduziert" 
							exit 0
						fi
						if (( llalt == minimalstromstaerke )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort5)"
							meld "Sofort5, Ladestrom schon auf minimal reduziert" 
							exit 0
						fi
						if (( llalt < minimalstromstaerke )); then
							llneu=$minimalstromstaerke
							runs/set-current.sh $llneu m
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere (anschubsen)" "ladelog"
							openwbDebugLog "MAIN" 1 "Sofort ladung erhöht auf $llneu bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort6)"
							meld "Sofort6, Ladestrom ladung erhöht"  
							exit 0
						fi
					else
						if (( llalt < minimalstromstaerke )); then
							llneu=$minimalstromstaerke
							runs/set-current.sh $llneu m
							echo "Mindeststrom aktiv: $minimalstromstaerke A" > ramdisk/lastregelungaktiv
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung erhöht auf $llneu bei minimal A $minimalstromstaerke"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort7)"
							meld "Sofort7, Ladestrom ladung erhöht"  
							exit 0
						fi
						if (( llalt > maximalstromstaerke )); then
							llneu=$maximalstromstaerke
							runs/set-current.sh "$llneu" m
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung auf $llneu reduziert, über eingestellter max A $maximalstromstaerke"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort8)"
							meld "Sofort8, Ladestrom ladung redizier" 
							exit 0
						fi
						if (( llalt == sofortll )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung erreicht bei $sofortll A"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort9)"
							meld "Sofort9, Ladestrom  Ziel erreicht"  
							exit 0
						fi
						if (( llalt < sofortll)); then
							evudiff1=$((lastmaxap1 - evua1 ))
							evudiff2=$((lastmaxap2 - evua2 ))
							evudiff3=$((lastmaxap3 - evua3 ))
							evudiffmax=($evudiff1 $evudiff2 $evudiff3)
							maxdiff=${evudiffmax[0]}
							for v in "${evudiffmax[@]}"; do
								if (( v < maxdiff )); then maxdiff=$v; fi;
							done
							maxdiff=$((maxdiff - 1 ))
							maxdiffw=$(( lastmmaxw - wattbezug ))
							maxdiffwa=$(( maxdiffw / 230 ))
							maxdiffwa=$(( maxdiffwa - 2 ))
							if (( maxdiffwa > maxdiff )); then
								maxdiff=$maxdiff
							else
								maxdiff=$maxdiffwa
							fi
							if (( maxdiff < 0 )); then
								maxdiff=0
							fi

							llneu=$((llalt + maxdiff))
							if (( llneu > sofortll )); then
								llneu=$sofortll
							fi

							if (( llneu < sofortll )); then
								echo "Lastmanagement aktiv, Ladeleistung reduziert" > ramdisk/lastregelungaktiv
							fi
							if (( llneu > maximalstromstaerke )); then
								llneu=$maximalstromstaerke
								runs/set-current.sh "$llneu" m
								openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere" "ladelog"
								openwbDebugLog "MAIN" 1 "Sofort ladung auf $llneu reduziert, über eingestellter max A $maximalstromstaerke"
					            openwbDebugLog "MAIN" 0 "*** exit 0 (sofort10)"
								meld "Sofort10, Ladestrom  reduziert" 
								exit 0
							fi
							runs/set-current.sh "$llneu" m
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere, Lastmanagement aktiv"
							openwbDebugLog "MAIN" 1 "Sofort ladung um $maxdiff A Differenz auf $llneu A erhoeht, kleiner als sofortll $sofortll"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort11)"
							meld "Sofort11, Ladestrom  erhöht" 
							exit 0
						fi
						if (( llalt > sofortll)); then
							llneu=$sofortll
							if (( llneu > maximalstromstaerke )); then
								llneu=$maximalstromstaerke
								runs/set-current.sh "$llneu" m
								openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
								openwbDebugLog "MAIN" 1 "Sofort ladung auf $llneu reduziert, über eingestellter max A $maximalstromstaerke"
					            openwbDebugLog "MAIN" 0 "*** exit 0 (sofort12)"
								meld "Sofort12, Ladestrom  reduziert" 
								exit 0
							fi
							if (( llneu < minimalstromstaerke )); then
								llneu=$minimalstromstaerke
								runs/set-current.sh "$llneu" m
								echo "Mindeststrom aktiv: $minimalstromstaerke A" > ramdisk/lastregelungaktiv
								openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
								openwbDebugLog "MAIN" 1 "Sofort ladung auf $llneu erhöht, war unter eingestellter min A $minimalstromstaerke"
					            openwbDebugLog "MAIN" 0 "*** exit 0 (sofort13)"
								meld  "Sofort13, Ladestrom  erhöht" 								
								exit 0
							fi

							runs/set-current.sh "$llneu" m
							openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung von $llalt A llalt auf $llneu A reduziert, größer als sofortll $sofortll"
					        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort14)"
							meld "Sofort14, Ladestrom  geändert" 
							exit 0
						fi
					fi
				else
					if (( wattbezug < lastmmaxw )); then

						evudiff1=$((evua1 - lastmaxap1 ))
						evudiff2=$((evua2 - lastmaxap2 ))
						evudiff3=$((evua3 - lastmaxap3 ))
						evudiffmax=($evudiff1 $evudiff2 $evudiff3)
						maxdiff=${evudiffmax[0]}
						for v in "${evudiffmax[@]}"; do
							if (( v > maxdiff )); then maxdiff=$v; fi;
						done
						maxdiff=$((maxdiff + 1 ))
						echo "Lastmanagement aktiv (Ampere), Ladeleistung reduziert" > ramdisk/lastregelungaktiv

					else
						wattzuviel=$((wattbezug - lastmmaxw))
						amperezuviel=$(( wattzuviel / 230 ))
						maxdiff=$((amperezuviel + 2 ))
						if (( activechargepoints > 1 )); then
							maxdiff=$(echo "($maxdiff / $activechargepoints) / 1" |bc)
						fi
						echo "Lastmanagement aktiv (Leistung), Ladeleistung reduziert" > ramdisk/lastregelungaktiv
					fi

					llneu=$((llalt - maxdiff))
					if (( llneu < minimalstromstaerke )); then
						llneu=$minimalstromstaerke
						openwbDebugLog "MAIN" 1 "Differenz groesser als minimalstromstaerke, setze auf minimal A $minimalstromstaerke"
					fi
					runs/set-current.sh "$llneu" m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere, Lastmanagement aktiv"
					openwbDebugLog "MAIN" 1 "Sofort ladung um $maxdiff auf $llneu reduziert"
			        openwbDebugLog "MAIN" 0 "*** exit 0 (sofort15)"
					meld "Sofort15, Ladestrom  geändert" 
					exit 0
				fi
			fi
		fi
	else
		activechargepoints=0
		if (( ladeleistunglp1 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		if (( ladeleistunglp2 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		if (( ladeleistunglp3 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#if (( ladeleistunglp4 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#if (( ladeleistunglp5 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#if (( ladeleistunglp6 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#if (( ladeleistunglp7 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#if (( ladeleistunglp8 > 100)); then activechargepoints=$((activechargepoints + 1)); fi
		#mit mehr als einem ladepunkt
		read aktgeladens1 <ramdisk/aktgeladens1
		if (( evua1 < lastmaxap1 )) && (( evua2 < lastmaxap2 )) &&  (( evua3 < lastmaxap3 )) && (( wattbezug < lastmmaxw )); then
			evudiff1=$((lastmaxap1 - evua1 ))
			evudiff2=$((lastmaxap2 - evua2 ))
			evudiff3=$((lastmaxap3 - evua3 ))
			evudiffmax=($evudiff1 $evudiff2 $evudiff3)
			maxdiff=${evudiffmax[0]}
			for v in "${evudiffmax[@]}"; do
				if (( v < maxdiff )); then maxdiff=$v; fi;
			done
			maxdiff=$((maxdiff - 1 ))
			maxdiffw=$(( lastmmaxw - wattbezug ))
			maxdiffwa=$(( maxdiffw / 230 / anzahlphasen))
			maxdiffwa=$(( maxdiffwa - 2 ))

			if (( maxdiffwa > maxdiff )); then
				maxdiff=$maxdiff
			else
				maxdiff=$maxdiffwa
			fi
			if (( maxdiff < 0 )); then
				maxdiff=0
			fi

			if (( activechargepoints > 1 )); then
				maxdiff=$(echo "($maxdiff / $activechargepoints) / 1" |bc)
			fi

            openwbDebugLog "MAIN" 0 "Sofort maxdiff:$maxdiff   msmoduslp1:$msmoduslp1"
		
			#Ladepunkt 1
			if (( msmoduslp1 == "2" )) && (( soc >= sofortsoclp1 ))  &&  (( sofortsoclp1 < 100 )); then  # HH >= statt >
				# SoC-Limit gesetzt und erreicht
				if grep -q 1 "ramdisk/ladestatus"; then
					runs/set-current.sh 0 m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gestoppt, $sofortsoclp1 % SoC erreicht"
					openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 1 da $sofortsoclp1 % erreicht"
				fi
			elif (( msmoduslp1 == "1" )) && (( $(echo "$aktgeladen > $lademkwh" |bc -l) )); then
				# Ernergie-Limit gesetzt und erreicht
				if grep -q 1 "ramdisk/ladestatus"; then
					runs/set-current.sh 0 m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gestoppt da $lademkwh kWh Limit erreicht"
					openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 1 da  $lademkwh kWh erreicht"
				fi
			else
				# kein gesetztes Limit erreicht, normale Ladung
				if (( ladeleistunglp1 < 100 )); then
					if (( llalt > minimalstromstaerke )); then
						llneu=$((llalt - 1 ))
						runs/set-current.sh "$llneu" m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 reudziert auf $llneu bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					fi
					if (( llalt == minimalstromstaerke )); then
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					fi
					if (( llalt < minimalstromstaerke )); then
						llneu=$minimalstromstaerke
						runs/set-current.sh "$llneu" m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 erhöht auf $llneu bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					fi
				else
					if (( llalt == sofortll )); then
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 erreicht bei $sofortll A"
					fi
					if (( llalt > maximalstromstaerke )); then
						llneu=$((llalt - 1 ))
						runs/set-current.sh "$llneu" m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 auf $llneu reduziert, über eingestellter max A $maximalstromstaerke"
					else
						if (( llalt < sofortll)); then
							llneu=$((llalt + maxdiff))
							if (( llneu > sofortll )); then
								llneu=$sofortll
							fi
							if (( llneu < sofortll )); then
								echo "Lastmanagement aktiv, Ladeleistung reduziert" > ramdisk/lastregelungaktiv
							fi
							if (( llneu > maximalstromstaerke )); then
								llneu=$maximalstromstaerke
							fi
							if (( llneu < minimalstromstaerke )); then
								llneu=$minimalstromstaerke
							fi
							runs/set-current.sh "$llneu" m
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 um $maxdiff A Differenz auf $llneu A erhoeht, war kleiner als sofortll $sofortll"
						fi
						if (( llalt > sofortll)); then
							llneu=$sofortll
							if (( llneu < minimalstromstaerke )); then
								llneu=$minimalstromstaerke
								echo "Mindeststrom aktiv: $minimalstromstaerke A" > ramdisk/lastregelungaktiv
								openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneu Ampere"
								openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 erhöht auf $llneu bei minimal A $minimalstromstaerke"
							else
								openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
								openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 von $llalt A llalt auf $llneu A reduziert, war größer als sofortll $sofortll"
							fi
							runs/set-current.sh "$llneu" m
						fi
					fi
					if (( llalt < minimalstromstaerke )); then
						llneu=$minimalstromstaerke
						runs/set-current.sh "$llneu" m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneu Ampere"
						openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 1 erhöht auf $llneu bei minimal A $minimalstromstaerke Ladeleistung zu gering"
					fi
				fi
			fi

			#Ladepunkt 2
			if [[ $lastmanagement == "1" ]]; then
				openwbDebugLog "MAIN" 0 "Sofort msmod:$msmoduslp2 soc1:$soc1 sofortsoclp2:$sofortsoclp2" 
            
                if (( msmoduslp2 == "2" )) && (( soc1 >= sofortsoclp2 ))  &&  (( sofortsoclp2<100 )); then  # HH >= statt >                
					# SoC-Limit gesetzt und erreicht
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss1"; then
						runs/set-current.sh 0 s1
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung gestoppt, $sofortsoclp2 % SoC erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 2 da  $sofortsoclp2 % erreicht"
					fi
				elif (( msmoduslp2 == "1" )) && (( $(echo "$aktgeladens1 > $lademkwhs1" |bc -l) )); then
					# Ernergie-Limit gesetzt und erreicht
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss1"; then
						runs/set-current.sh 0 s1
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung gestoppt da $lademkwhs1 kWh Limit erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 2 da  $lademkwhs1 kWh erreicht"
					fi
				else
					# kein gesetztes Limit erreicht, normale Ladung
					if (( ladeleistungs1 < 100 )); then
						if (( llalts1 > minimalstromstaerke )); then
							llneus1=$((llalts1 - 1 ))
							runs/set-current.sh "$llneus1" s1
							openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 reudziert auf $llneus1 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
						if (( llalts1 == minimalstromstaerke )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
						if (( llalts1 < minimalstromstaerke )); then
							llneus1=$minimalstromstaerke
							runs/set-current.sh "$llneus1" s1
							openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 erhöht auf $llneus1 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
					else
						if (( llalts1 == sofortlls1 )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 erreicht bei $sofortlls1 A"
						fi
						if (( llalts1 > maximalstromstaerke )); then
							llneus1=$((llalts1 - 1 ))
							runs/set-current.sh "$llneus1" s1
							openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 auf $llneus1 reduziert, über eingestellter max A $maximalstromstaerke"
						else
							if (( llalts1 < sofortlls1)); then
								llneus1=$((llalts1 + maxdiff))
								if (( llneus1 > sofortlls1 )); then
									llneus1=$sofortlls1
								fi
								if (( llneus1 < sofortlls1 )); then
									echo "Lastmanagement aktiv, Ladeleistung reduziert" > ramdisk/lastregelungaktiv
								fi
								if (( llneus1 > maximalstromstaerke )); then
									llneus1=$maximalstromstaerke
								fi
								if (( llneus1 < minimalstromstaerke )); then
									llneus1=$minimalstromstaerke
								fi
								runs/set-current.sh "$llneus1" s1
								openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 um $maxdiff A Differenz auf $llneus1 A erhoeht, war kleiner als sofortll $sofortlls1"
							fi
							if (( llalts1 > sofortlls1)); then
								llneus1=$sofortlls1
								if (( llneus1 < minimalstromstaerke )); then
									llneus1=$minimalstromstaerke
									echo "Mindeststrom aktiv: $minimalstromstaerke A" > ramdisk/lastregelungaktiv
									openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneus1 Ampere"
									openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 erhöht auf $llneus1 bei minimal A $minimalstromstaerke"
								else
									openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
									openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 von $llalts1 A llalt auf $llneus1 A reduziert, war größer als sofortll $sofortlls1"
								fi
								runs/set-current.sh "$llneus1" s1
							fi
						fi
						if (( llalts1 < minimalstromstaerke )); then
							llneus1=$minimalstromstaerke
							runs/set-current.sh "$llneus1" s1
							openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneus1 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 2 erhöht auf $llneus1 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
					fi
				fi
			fi

			#Ladepunkt 3
			if [[ $lastmanagements2 == "1" ]]; then
				read aktgeladens2 <ramdisk/aktgeladens2
				if (( msmoduslp3 == "1" )) && (( $(echo "$aktgeladens2 > $lademkwhs2" |bc -l) )); then
					# Ernergie-Limit gesetzt und erreicht
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss2"; then
						runs/set-current.sh 0 s2
						openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung gestoppt da $lademkwhs2 kWh Limit erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 3 da  $lademkwhs2 kWh erreicht"
					fi
				else
					# kein gesetztes Limit erreicht, normale Ladung
					if (( ladeleistungs2 < 100 )); then
						if (( llalts2 > minimalstromstaerke )); then
							llneus2=$((llalts2 - 1 ))
							runs/set-current.sh "$llneus2" s2
							openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf $llneus2 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 reudziert auf $llneus2 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
						if (( llalts2 == minimalstromstaerke )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
						if (( llalts2 < minimalstromstaerke )); then
							llneus2=$minimalstromstaerke
							runs/set-current.sh "$llneus2" s2
							openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf $llneus2 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 erhöht auf $llneus2 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
					else
						if (( llalts2 == sofortlls2 )); then
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 erreicht bei $sofortlls2 A"
						fi
						if (( llalts2 > maximalstromstaerke )); then
							llneus2=$((llalts2 - 1 ))
							runs/set-current.sh "$llneus2" s2
							openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf $llneus2 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 auf $llneus2 reduziert, über eingestellter max A $maximalstromstaerke"
						else
							if (( llalts2 < sofortlls2)); then
								llneus2=$((llalts2 + maxdiff))
								if (( llneus2 > sofortlls2 )); then
									llneus2=$sofortlls2
								fi
								if (( llneus2 < sofortlls2 )); then
									echo "Lastmanagement aktiv, Ladeleistung reduziert" > ramdisk/lastregelungaktiv
								fi
								if (( llneus2 > maximalstromstaerke )); then
									llneus2=$maximalstromstaerke
								fi
								if (( llneus2 < minimalstromstaerke )); then
									llneus2=$minimalstromstaerke
								fi
								runs/set-current.sh "$llneus2" s2
								openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 um $maxdiff A Differenz auf $llneus2 A erhoeht, war kleiner als sofortll $sofortlls2"
							fi
							if (( llalts2 > sofortlls2)); then
								llneus2=$sofortlls2
								if (( llneus2 < minimalstromstaerke )); then
									llneus2=$minimalstromstaerke
									echo "Mindeststrom aktiv: $minimalstromstaerke A" > ramdisk/lastregelungaktiv
									openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneus2 Ampere"
									openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 erhöht auf $llneus2 bei minimal A $minimalstromstaerke"
								else
									openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf $llneus2 Ampere"
									openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 von $llalts2 A llalt auf $llneus2 A reduziert, war größer als sofortll $sofortlls2"
								fi
								runs/set-current.sh "$llneus2" s2
							fi
						fi
						if (( llalts2 < minimalstromstaerke )); then
							llneus2=$minimalstromstaerke
							runs/set-current.sh "$llneus2" m
							openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf Mindeststrom: $llneus2 Ampere"
							openwbDebugLog "MAIN" 1 "Sofort ladung Ladepunkt 3 erhöht auf $llneus2 bei minimal A $minimalstromstaerke Ladeleistung zu gering"
						fi
					fi
				fi
			fi


			# Lp4-LP8 deletet



			openwbDebugLog "MAIN" 0 "*** exit 0 (sofort16)"
			meld "Sofort16" 
			exit 0
		else
			if (( wattbezug < lastmmaxw )); then
				evudiff1=$((evua1 - lastmaxap1 ))
				evudiff2=$((evua2 - lastmaxap2 ))
				evudiff3=$((evua3 - lastmaxap3 ))
				evudiffmax=($evudiff1 $evudiff2 $evudiff3)
				maxdiff=0
				for v in "${evudiffmax[@]}"; do
					if (( v > maxdiff )); then maxdiff=$v; fi;
				done
				maxdiff=$((maxdiff + 1 ))
				if (( activechargepoints > 1 )); then
					maxdiff=$(echo "($maxdiff / $activechargepoints) / 1" |bc)
				fi
				echo "Lastmanagement aktiv (Ampere), Ladeleistung reduziert" > ramdisk/lastregelungaktiv
			else
				wattzuviel=$((wattbezug - lastmmaxw))
				amperezuviel=$(( wattzuviel / 230 ))
				maxdiff=$((amperezuviel + 2 ))
				if (( activechargepoints > 1 )); then
					maxdiff=$(echo "($maxdiff / $activechargepoints) / 1" |bc)
				fi
				echo "Lastmanagement aktiv (Leistung), Ladeleistung reduziert" > ramdisk/lastregelungaktiv

			fi
			llneu=$((llalt - maxdiff))
			llneus1=$((llalts1 - maxdiff))
			if [[ $lastmanagements2 == "1" ]]; then
				llneus2=$((llalts2 - maxdiff))
			fi
			if (( llneu < minimalstromstaerke )); then
				llneu=$minimalstromstaerke
				openwbDebugLog "MAIN" 1 "Ladepunkt 1 Differenz groesser als minimalstromstaerke, setze auf minimal A $minimalstromstaerke"
			fi
			if (( llneus1 < minimalstromstaerke )); then
				llneus1=$minimalstromstaerke
				openwbDebugLog "MAIN" 1 "Ladepunkt 2 Differenz groesser als minimalstromstaerke, setze auf minimal A $minimalstromstaerke"
			fi
			if [[ $lastmanagements2 == "1" ]]; then
				if (( llneus2 < minimalstromstaerke )); then
					llneus2=$minimalstromstaerke
					openwbDebugLog "MAIN" 1 "Ladepunkt 3 Differenz groesser als minimalstromstaerke, setze auf minimal A $minimalstromstaerke"
				fi
			fi

			if (( msmoduslp1 == 2 )); then
				if (( soc >= sofortsoclp1)); then       # HH >= war schon da
					if grep -q 1 "ramdisk/ladestatus"; then
						runs/set-current.sh 0 m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gstoppt da $socortsoclp1 % SoC erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden da $sofortsoclp1 % erreicht"
					fi
				else
					runs/set-current.sh "$llneu" m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
				fi
			fi
			if (( msmoduslp1 == 1 )); then
				if (( $(echo "$aktgeladen > $lademkwh" |bc -l) )); then
					if grep -q 1 "ramdisk/ladestatus"; then
						runs/set-current.sh 0 m
						openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung gstoppt da $lademkwh kWh erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 1 da  $lademkwh kWh erreicht"
					fi
				else
					runs/set-current.sh "$llneu" m
					openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
				fi
			fi
			if (( msmoduslp1 == 0));then
				runs/set-current.sh "$llneu" m
				openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
			fi
			if (( msmoduslp2 == 2 )); then
				if (( soc1 >= sofortsoclp2 )); then  # HH >= war schon da
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss1"; then
						runs/set-current.sh 0 s1
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung gstoppt da $sofortsoclp2 % SoC erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 2 da  $sofortsoclp2 % erreicht"
					fi
				else
					runs/set-current.sh "$llneu" s1
					openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneu Ampere"
				fi
			fi
			if (( msmoduslp2 == 1 )); then
				if (( $(echo "$aktgeladens1 > $lademkwhs1" |bc -l) )); then
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss1"; then
						runs/set-current.sh 0 s1
						openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung gstoppt da $lademkwhs1 kWh erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 2 da  $lademkwhs1 kWh erreicht"
					fi
				else
					runs/set-current.sh "$llneus1" s1
					openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
				fi
			fi
			if (( msmoduslp2 == 0)) ;then
				runs/set-current.sh "$llneus1" s1
				openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Sofort. Ladung geändert auf $llneus1 Ampere"
			fi
			if [[ $lastmanagements2 == "1" ]]; then
				read aktgeladens2 <ramdisk/aktgeladens2
				if (( msmoduslp2 == "1" )) && (( $(echo "$aktgeladens2 > $lademkwhs2" |bc -l) )); then
					if grep -q 1 "/var/www/html/openWB/ramdisk/ladestatuss2"; then
						runs/set-current.sh 0 s2
						openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung gestoppt da $lademkwhs2 kWh erreicht"
						openwbDebugLog "MAIN" 1 "Beende Sofort Laden an Ladepunkt 3 da  $lademkwhs2 kWh erreicht"
					fi
				else
					runs/set-current.sh "$llneus2" s2
					openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Sofort. Ladung geändert auf $llneus2 Ampere"

				fi
			fi
			# Lp4-LP8 deletet
			openwbDebugLog "MAIN" 1 "Sofort ladung um $maxdiff auf $llneu reduziert"
			openwbDebugLog "MAIN" 0 "*** exit 0 (sofort17)"
			meld "Sofort17, Ladestrom reduziert"
			exit 0
		fi
	fi
}
