#!/bin/bash

u1p3_setter()			# phasen , sec before, sec after
{
	p=${1:-1}
	secbefore=${2:-0}
	secafter=${3:-0}

	meld "->$p"

	mosquitto_pub -r -t openWB/global/u1p3p_inwork -m "1"
	(( secbefore>0)) && sleep $secbefore
	if (( $1 == 3 )); then
		runs/u1p3pcheck.sh 3
	else
		runs/u1p3pcheck.sh 1 
	fi
	(( secafter>0)) && sleep $secafter
	mosquitto_pub -r -t openWB/global/u1p3p_inwork -m "0"
}

blockon()
{
 exit
}
Sheedblockoff()
{
 exit
}


u1p3pswitch(){

	if (( u1p3paktiv == 0 )); then
		return 0
	fi

	read u1p3pstat <ramdisk/u1p3pstat
	meld "U$u1p3pstat"
	read nachtladenstate <ramdisk/nachtladenstate
	read nachtladen2state <ramdisk/nachtladen2state
	read nachtladenstates1 <ramdisk/nachtladenstates1   # "Nachtladen" LP2
	read nachtladen2states1 <ramdisk/nachtladen2states1 # "Morgensladen" LP2		

	if [ -z "$u1p3schaltparam" ]; then
		u1p3schaltparam = 8         		# default 8 von 16 also 8+8
	fi
	uhwaittime=$(( $u1p3schaltparam * 60 ))			#  8 Minuten
	urwaittime=$(( (16 - $u1p3schaltparam) * 60 ))  # 16-8 Minuten
	openwbDebugLog "MAIN" 1 "U1P3 automatische Umschaltung aktiv Timing: $uhwaittime / $urwaittime"

		if (( ladestatus == 0)); then
			meld "UPM=$lademodus"
			# wir laden gerade nicht, also vorbereitende Umschaltung checken
			if ((nachtladenstate == 1)) || ((nachtladen2state == 1)) || ((nachtladenstates1 == 1)) || ((nachtladen2states1 == 1)); then			
			# if (( nachtladenstate == 1 )) || (( nachtladen2state == 1 )); then
				if (( u1p3pstat != u1p3pnl )); then
				    u1p3_setter $u1p3pnl
					openwbDebugLog "MAIN" 1 "U1P3 Nachtladen derzeit $u1p3pstat Phasen, auf $u1p3pnl konfiguriert, aendere..."
					openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pnl Phasen geaendert"
					openwbDebugLog "CHARGESTAT" 0 "U1P3 fuer Nachtladung auf $u1p3pnl Phasen geändert"
				fi
			else
				if (( lademodus == 0 )); then			#### SOFORTT
					if (( u1p3pstat != u1p3psofort )); then
						openwbDebugLog "MAIN" 1 "U1P3 Sofortladen derzeit $u1p3pstat Phasen, auf $u1p3psofort konfiguriert, aendere..."
						u1p3_setter $u1p3psofort
						openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3psofort Phasen geaendert"
						openwbDebugLog "CHARGESTAT" 0 "U1P3 für sofortladung auf $u1p3psofort Phasen geändert"
					fi
				fi
				if (( lademodus == 1 )); then		##### MINUNDPV
					if (( u1p3pstat != u1p3pminundpv )); then
						if (( u1p3pminundpv == 4 )); then
							if (( u1p3pstat == 0 )); then
								u1p3_setter 1
							fi
							if (( u1p3pstat == 3 )); then
								read urcounter <ramdisk/urcounter
								if (( urcounter < urwaittime )); then
									if (( urcounter < urwaittime - 60 )); then
										urcounter=$((urwaittime - 60))
									fi
									urcounter=$((urcounter + 10))
									echo $urcounter > /var/www/html/openWB/ramdisk/urcounter
									meld "4ur($urcounter)"
								else
									openwbDebugLog "MAIN" 1 "U1P3 Min PV Laden derzeit $u1p3pstat Phasen, auf 1 Nur PV konfiguriert, aendere..."
								    u1p3_setter 1
									echo 0 > /var/www/html/openWB/ramdisk/urcounter
								fi
							fi
						else
							openwbDebugLog "MAIN" 1 "U1P3 Min PV Laden derzeit $u1p3pstat Phasen, auf $u1p3pminundpv konfiguriert, aendere..."
							u1p3_setter $u1p3pnurpv
							openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pminundpv Phasen geaendert"
							openwbDebugLog "CHARGESTAT" 0 "U1P3 für MinundPV auf $u1p3pnurpv Phasen geändert"
						fi
					fi
				fi
				if (( lademodus == 2 )); then		# NURPV
					if (( u1p3pstat != u1p3pnurpv )); then
						if (( u1p3pnurpv == 4 )); then
							if (( u1p3pstat == 0 )); then
								u1p3_setter 1
							fi
							if (( u1p3pstat == 3 )); then
								read urcounter <ramdisk/urcounter
								if (( urcounter < urwaittime )); then
									if (( urcounter < urwaittime - 60 )); then
										urcounter=$((urwaittime - 60))
									fi
									urcounter=$((urcounter + 10))
									echo $urcounter > /var/www/html/openWB/ramdisk/urcounter
									meld "4(ur:$urcounter)"
								else
								    u1p3_setter 1
									openwbDebugLog "MAIN" 1 "U1P3 Nur PV Laden derzeit $u1p3pstat Phasen, auf 1 Nur PV konfiguriert, aendere..."
									openwbDebugLog "CHARGESTAT" 0 "U1P3 für nurPV auf 1 Phasen geändert"									
									echo 0 > /var/www/html/openWB/ramdisk/urcounter
								fi
							fi
						else
							openwbDebugLog "MAIN" 1 "U1P3 Nur PV Laden derzeit $u1p3pstat Phasen, auf $u1p3pnurpv konfiguriert, aendere..."
							u1p3_setter $u1p3pnurpv
							openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pnurpv Phasen geaendert"
							openwbDebugLog "CHARGESTAT" 0 "U1P3 für nurPV auf $u1p3pnurpv Phasen geändert"									
						fi
					fi
				fi
				if (( lademodus == 4 )); then  # standby (also Nacht,Morgen oder Zielladen )
					if (( u1p3pstat != u1p3pstandby )); then
						openwbDebugLog "MAIN" 1 "U1P3 Standby Laden derzeit $u1p3pstat Phasen, auf $u1p3pstandby konfiguriert, aendere..."
						u1p3_setter $u1p3pstandby
						openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pstandby Phasen geaendert"
						openwbDebugLog "CHARGESTAT" 0 "U1P3 für standby auf $u1p3pstandby Phasen geändert"						
					fi
				fi
				if (( lademodus == 3 )); then	# STOP
					if (( u1p3pstat != u1p3pstandby )); then
						openwbDebugLog "MAIN" 1 "U1P3 Stop Laden derzeit $u1p3pstat Phasen, auf $u1p3pstandby konfiguriert, aendere..."
						u1p3_setter $u1p3pstandby
						openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pstandby Phasen geaendert"
						openwbDebugLog "CHARGESTAT" 0 "U1P3 für stop mode auf $u1p3pstandby Phasen geändert, same as Standby"						
					fi
				fi
			fi
		else
		    # keine umschlatung in arbeit 
			meld "Uprep"
			if ((nachtladenstate == 1)) || ((nachtladen2state == 1)) || ((nachtladenstates1 == 1)) || ((nachtladen2states1 == 1)); then			
			# if (( nachtladenstate == 1 )) || (( nachtladen2state == 1 )); then
				if (( u1p3pstat != u1p3pnl )); then
					openwbDebugLog "MAIN" 1 "U1P3 Nachtladen derzeit $u1p3pstat Phasen, auf $u1p3pnl konfiguriert, unterbreche Ladung und aendere. Anf(Sleep 5+1)"
					openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:$u1p3pnl"
					echo 1 > ramdisk/blockall
					runs/u1p3pcheck.sh stop
					u1p3_setter $u1p3pnl  5  1  
					runs/u1p3pcheck.sh start
					openwbDebugLog "MAIN" 0 "U1P3 END BLOCKALL"
					echo 0 > ramdisk/blockall
					openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pnl Phasen geaendert End(Sleep 5+1)"
				    openwbDebugLog "CHARGESTAT" 0 "U1P3 trotz ladung für Nachtlande auf $u1p3pnl Phasen geändert"					
				fi
			else
				if (( lademodus == 0 )); then		# Sofort
					if (( u1p3pstat != u1p3psofort )); then
						openwbDebugLog "MAIN" 1 "U1P3 Sofortladen derzeit $u1p3pstat Phasen, auf $u1p3psofort konfiguriert, unterbreche Ladung und aendere..Anf(Sleep 5+1)."
						openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:$u1p3psofort"
						echo 1 > ramdisk/blockall
						runs/u1p3pcheck.sh stop
						u1p3_setter $u1p3psofort  5  1
						runs/u1p3pcheck.sh start
						echo 0 > ramdisk/blockall
						openwbDebugLog "MAIN" 0 "U1P3 END BLOCKALL"
						openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3psofort Phasen geaendert End(Sleep 5+1)"
						openwbDebugLog "CHARGESTAT" 0 "U1P3 trotz ladung für Sofortladen auf $u1p3psofort Phasen geändert"						
					fi
				fi
				if (( lademodus == 1 )); then   # MinUPV
					if (( u1p3pstat != u1p3pminundpv )); then
						if (( u1p3pminundpv == 4 )); then
							read oldll <ramdisk/llsoll
							if (( u1p3pstat == 1 )); then
							    # wir stehen auf 1 phasen
								if [[ $schieflastaktiv == "1" ]]; then
									maximalstromstaerke=$schieflastmaxa
								fi
								if (( ladeleistung < 100 )); then
									if (( uberschuss > ((3 * mindestuberschuss) + 1000) )); then
										openwbDebugLog "MAIN" 1 "U1P3 Min PV Laden derzeit $u1p3pstat Phasen, auf MinPV Automatik konfiguriert, aendere auf 3 Phasen da viel Überschuss vorhanden..Anf(Sleep 8+20)."
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:3"
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 3 8 20 
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 3 Phasen MinPV Automatik geaendert Anf(Sleep 8+20)"
									    openwbDebugLog "CHARGESTAT" 0 "U1P3 trotz ladung für MinundPV auf 3 Phasen geändert"						
									fi
								fi
								if (( oldll == maximalstromstaerke )); then
									read uhcounter <ramdisk/uhcounter
									if (( uhcounter < uhwaittime )); then
										if (( maximalstromstaerke == 16 )); then
											if (( uberschuss > 500 )); then
												uhcounter=$((uhcounter + 10))
												echo $uhcounter > /var/www/html/openWB/ramdisk/uhcounter
												meld "uh($uhcounter)"
												openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter Erhoehung auf $uhcounter erhoeht fuer Min PV Automatik Phasenumschaltung, genug uberschuss fuer 3 Phasen Ladung"
											else
												openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter nicht erhöht fuer Min PV Automatik Phasenumschaltung, fehlender uberschuss fuer 3 Phasen Ladung"
											fi
										else
											uhcounter=$((uhcounter + 10))
											echo $uhcounter > /var/www/html/openWB/ramdisk/uhcounter
											meld "uh($uhcounter)"
											openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter Erhoehung auf $uhcounter erhoeht fuer Min PV Automatik Phasenumschaltung"
										fi
									else
										openwbDebugLog "MAIN" 1 "U1P3 Min PV Laden derzeit $u1p3pstat Phasen, auf MinPV Automatik konfiguriert, unterbreche Ladung und  aendere auf 3 Phasen...Anf(Sleep 8+20) "
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:3"
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 3 8 20
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 3 Phasen MinPV Automatik geaendert End(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 trotz ladung für MinundPV auf 3 Phasen geändert"										
										echo 0 > /var/www/html/openWB/ramdisk/uhcounter
									fi
								else
									echo 0 > /var/www/html/openWB/ramdisk/uhcounter
								fi
							else
							    # wir stehen auf 3 phasen
								if (( ladeleistung < 100 )); then
									if (( uberschuss < (3 * mindestuberschuss) )); then
										openwbDebugLog "MAIN" 1 "U1P3 xxxx1 .Anf(Sleep 8+20) "
										echo 0 > /var/www/html/openWB/ramdisk/urcounter
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:1"
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 1 8 20
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 1 Phasen MinPV Automatik geaendert da geringerer Überschuss end(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 fallback back MinPV to 1 Phasen geändert"										
									fi
								fi
								if (( oldll == minimalampv ))  && (( ladeleistung > 100 )) ; then # fix toggling 1/3 on no car
									read urcounter <ramdisk/urcounter
									if (( urcounter < urwaittime )); then
										urcounter=$((urcounter + 10))
										echo $urcounter > /var/www/html/openWB/ramdisk/urcounter
										meld "ur($urcounter)"
										openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter Reduzierung auf $urcounter erhoeht fuer Min PV Automatik Phasenumschaltung"
									else
										openwbDebugLog "MAIN" 1 "U1P3 xxxx2 .Anf(Sleep 8+20) "
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:1"
										echo 0 > /var/www/html/openWB/ramdisk/urcounter
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 1 8 20
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 1 Phasen MinPV Automatik geaendert  end(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 auf 1 Phasen MinPV Automatik geaendert"										
									fi
								else
									echo 0 > /var/www/html/openWB/ramdisk/urcounter
								fi
							fi
						else
							openwbDebugLog "MAIN" 1 "U1P3 Min PV Laden derzeit $u1p3pstat Phasen, auf $u1p3pminundpv konfiguriert, unterbreche Ladung und  aendere...Anf(Sleep 5+1)"
							openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:$u1p3pminundpv"
							echo 1 > ramdisk/blockall
							runs/u1p3pcheck.sh stop
							u1p3_setter $u1p3pminundpv 5 1 
							runs/u1p3pcheck.sh start
							openwbDebugLog "MAIN" 0 "U1P3 END BLOCKALL"
							echo 0 > ramdisk/blockall
							openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pminundpv Phasen geaendert End(Sleep 5+1)"
							openwbDebugLog "CHARGESTAT" 0 "U1P3 MinPV trotz ladung auf $u1p3pminundpv Phasen geaendert"										
						fi
					fi
				fi
				if (( lademodus == 2 )); then		# NurPv
					if (( u1p3pstat != u1p3pnurpv )); then
						if (( u1p3pnurpv == 4 )); then
							read oldll <ramdisk/llsoll
							if (( u1p3pstat == 1 )); then
								if [[ $schieflastaktiv == "1" ]]; then
									maximalstromstaerke=$schieflastmaxa
								fi
								if (( ladeleistung < 100 )); then
									if (( uberschuss > ((3 * mindestuberschuss) + 1000) )); then
										openwbDebugLog "MAIN" 1 "U1P3 Nur PV Laden derzeit $u1p3pstat Phasen, auf NurPV Automatik konfiguriert, aendere auf 3 Phasen da viel Überschuss vorhanden...Anf(Sleep 8+20)"
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL Switchto:3"
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 3 8 20 
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 3 Phasen NurPV Automatik geaendert End(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 NurPV trotz ladung auf 3 Phasen geaendert"
									fi
								fi
								if (( oldll == maximalstromstaerke )); then
									read uhcounter <ramdisk/uhcounter
									if (( uhcounter < uhwaittime )); then
										uhcounter=$((uhcounter + 10))
										echo $uhcounter > /var/www/html/openWB/ramdisk/uhcounter
										meld "uh($uhcounter)"
										openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter Erhoehung auf $uhcounter erhoeht fuer PV Automatik Phasenumschaltung"
									else
										openwbDebugLog "MAIN" 1 "U1P3 Nur PV Laden derzeit $u1p3pstat Phasen, auf NurPV Automatik konfiguriert, unterbreche Ladung und  aendere auf 3 Phasen...Anf(Sleep 8+20)"
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:3"
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 3 8 20
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 3 Phasen NurPV Automatik geaendert End(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 NurPV trotz ladung auf 3 Phasen geaendert"
										echo 0 > /var/www/html/openWB/ramdisk/uhcounter
									fi
								else
									echo 0 > /var/www/html/openWB/ramdisk/uhcounter
								fi
							else
								if (( ladeleistung < 100 )); then
									if (( uberschuss < (3 * mindestuberschuss) )); then
										openwbDebugLog "MAIN" 1 "U1P3 xxxx3 .Anf(Sleep 8+20) "
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:1"
										echo 0 > /var/www/html/openWB/ramdisk/urcounter
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 1 8 20 
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 1 Phasen NurPV Automatik geaendert da geringerer Überschuss End(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 NurPV trotz ladung auf 1 Phasen geaendert"										
									fi
								fi
								if (( oldll == minimalapv )) && (( ladeleistung > 100 )); then   # fix toggling 1/3 on no car
									read urcounter <ramdisk/urcounter
									if (( urcounter  < urwaittime )); then
										urcounter=$((urcounter + 10))
										echo $urcounter > /var/www/html/openWB/ramdisk/urcounter
										meld "ur($urcounter)"
										openwbDebugLog "MAIN" 1 "U1P3 Umschaltcounter Reduzierung auf $urcounter erhoeht fuer PV Automatik Phasenumschaltung"
									else
										openwbDebugLog "MAIN" 1 "U1P3 xxxx4 .Anf(Sleep 8+20) "
										openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:1"
										echo 0 > /var/www/html/openWB/ramdisk/urcounter
										echo 1 > ramdisk/blockall
										runs/u1p3pcheck.sh stop
										u1p3_setter 1 8 20
										runs/u1p3pcheck.sh startslow
										openwbDebugLog "MAIN" 0 "U1P3 Sleep 25, then END BLOCKALL"
										(sleep 25 && echo 0 > ramdisk/blockall)&
										openwbDebugLog "MAIN" 1 "U1P3 auf 1 Phasen NurPV Automatik geaendert End(Sleep 8+20)"
										openwbDebugLog "CHARGESTAT" 0 "U1P3 NurPV trotz ladung auf 1 Phasen geaendert"
									fi
								else
									echo 0 > /var/www/html/openWB/ramdisk/urcounter
								fi
							fi
						else 
							openwbDebugLog "MAIN" 1 "U1P3 Nur PV Laden derzeit $u1p3pstat Phasen, auf $u1p3pnurpv konfiguriert, unterbreche Ladung und  aendere..Anf(Sleep 5+1)."
							openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:$u1p3pnurpv"
							echo 1 > ramdisk/blockall
							runs/u1p3pcheck.sh stop
							u1p3_setter $u1p3pnurpv 8 20 
							runs/u1p3pcheck.sh start
							openwbDebugLog "MAIN" 0 "U1P3 END BLOCKALL"
							echo 0 > ramdisk/blockall
							openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pnurpv Phasen geaendert End(Sleep 5+1)"
							openwbDebugLog "CHARGESTAT" 0 "U1P3 NurPV trotz ladung auf $u1p3pnurpv Phasen geaendert (Automode)"
						fi
					fi
				fi
				if (( lademodus == 4 )); then	# Standby
					if (( u1p3pstat != u1p3pstandby )); then
						openwbDebugLog "MAIN" 1 "U1P3 Standby Laden derzeit $u1p3pstat Phasen, auf $u1p3pstandby konfiguriert, unterbreche Ladung und aendere..Anf(Sleep 5+1)."
						openwbDebugLog "MAIN" 0 "U1P3 BLOCKALL  Switchto:$u1p3pstandby"
						echo 1 > ramdisk/blockall
						runs/u1p3pcheck.sh stop
						u1p3_setter $u1p3pstandby 5 1 
						runs/u1p3pcheck.sh start
						openwbDebugLog "MAIN" 0 "U1P3 END BLOCKALL"
						echo 0 > ramdisk/blockall
						openwbDebugLog "MAIN" 1 "U1P3 auf $u1p3pstandby Phasen geaendert End(Sleep 5+1)"
						openwbDebugLog "CHARGESTAT" 0 "U1P3 Standby trotz ladung auf $u1p3pstandby Phasen geaendert (Automode)"
					fi
				fi
			fi
		fi


}
