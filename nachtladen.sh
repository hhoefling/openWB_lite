#!/bin/bash
lastmnacht(){
	if [[ $schieflastaktiv == "1" ]]; then
		if [[ $u1p3paktiv == "1" ]]; then
			u1p3pstat=$(<ramdisk/u1p3pstat)
			if [[ $u1p3pstat == "1" ]]; then
				maximalstromstaerke=$schieflastmaxa
			fi
		fi
	fi
	if [ $# -eq 2 ]; then
		if (( evua1 < lastmaxap1 )) && (( evua2 < lastmaxap2 )) && (( evua3 < lastmaxap3 )); then
			evudiff1=$((lastmaxap1 - evua1 ))
			evudiff2=$((lastmaxap2 - evua2 ))
			evudiff3=$((lastmaxap3 - evua3 ))
			evudiffmax=($evudiff1 $evudiff2 $evudiff3)
			maxdiff=${evudiffmax[0]}
			for v in "${evudiffmax[@]}"; do
				if (( v < maxdiff )); then maxdiff=$v; fi;
			done
			if (( $1 == $2 )); then
				llnachtreturn=$2
			else
				if (( $2 == 0 )); then
					llnachtreturn=$2
				else
					if (( $1 > $2 )); then
						llnachtreturn=$(($1 - 1 ))
					else
						if (( maxdiff > 1 )); then
							llnachtreturn=$(($1 + 1 ))
						else
							llnachtreturn=$1
						fi
					fi
					if (( llnachtreturn > maximalstromstaerke )); then
						llnachtreturn=$2
					fi
					if (( llnachtreturn < minimalstromstaerke )); then
						llnachtreturn=$minimalstromstaerke
					fi
				fi
			fi
		else
			evudiff1=$((evua1 - lastmaxap1 ))
			evudiff2=$((evua2 - lastmaxap2 ))
			evudiff3=$((evua3 - lastmaxap3 ))
			evudiffmax=($evudiff1 $evudiff2 $evudiff3)
			maxdiff=0
			for vv in "${evudiffmax[@]}"; do
				if (( vv > maxdiff )); then maxdiff=$vv; fi;
			done
			maxdiff=$((maxdiff + 1 ))
			llnachtreturn=$(($1 - maxdiff))
			if (( llnachtreturn < minimalstromstaerke )); then
				llnachtreturn=$minimalstromstaerke
				openwbDebugLog "MAIN" 1 "Differenz groesser als minimalstromstaerke, setze Nachtladen auf minimal A $minimalstromstaerke"
			fi
			echo "Lastmanagement aktiv, Ladeleistung reduziert" > ramdisk/lastregelungaktiv
			openwbDebugLog "MAIN" 1 "Nachtladen um $maxdiff auf $llnachtreturn reduziert"
		fi
	fi
}


isnacht()  # $1 $2 $3
{
 local -i H=$1
 local -i abuhr=$2
 local -i bisuhr=$3
 
#                     17        0        9   
# Zeit #!-----------------------!----------------------!
# Nacht               xxxxxxxxxxxxxxxxxxxx       
# V B over 0          V--------------B		V>B && V>=17 && B<=9 
# V B before 0        V-------B             V<B && V>=17 
# V B after 0                    V----B     V<B && B<=9


# check if ab und bis ein gueltiges interwall sind
 local -i mode
 if (( abuhr > bisuhr && abuhr>=17 && bisuhr<=9 )) ; then
        mode=0      # mode over 0
  elif (( abuhr < bisuhr &&  abuhr>=17  )) ; then
        mode=1      # mode before 0
  elif (( abuhr < bisuhr &&  bisuhr<=9   )) ; then
        mode=2      # mode after 0
  else
        openwbDebugLog "MAIN" 0 "isnacht Interwall nicht gueltig  ($abuhr - $bisuhr) --> 2"
        return 2
  fi
  
  local -i ok=0
  case $mode in
   0)   # over 0
       if (( abuhr <= H && H <= 24 ))  || (( 0 <= H && H < bisuhr )); then
        ok=1
       fi ;;
   1 | 2) # before 0 or after 0
       if (( H >= abuhr  && H < bisuhr )); then
        ok=1
       fi ;;
  esac
  openwbDebugLog "MAIN" 1 "isnacht ($abuhr -- $bisuhr) m:$mode ---> $ok" 
  return $ok
}



private_nachtlademodus(){
	if [[ $nachtladen == "1" ]]; then
        isnacht 10#$H 10#$nachtladenabuhr 10#$nachtladenbisuhr
        doit=$?
		if [ $doit -eq 1 ] ; then
#		if (( nachtladenabuhr <= 10#$H && 10#$H <= 24 )) || (( 0 <= 10#$H && 10#$H < nachtladenbisuhr )); then
      		openwbDebugLog "MAIN" 0 "nachtladen Year doit LP1" 
			nachtladenstate=1
			llnachtneu=""	# wird auf -Z getestet
			dayoftheweek=$(date +%w)
			currenthour=$(date +%k)
			if [[ $dayoftheweek -eq 0 && $currenthour -ge 14 ]] || [[ $dayoftheweek -ge 1 && $dayoftheweek -le 4 ]] || [[ $dayoftheweek -eq 5 && $currenthour -le 11 ]]  ; then
				diesersoc=$nachtsoc
			else
				diesersoc=$nachtsoc1
			fi
			if [[ $socmodul != "none" ]]; then
			  openwbDebugLog "MAIN" 1 "nachtladen LP1 mit socmodul $socmodul (soc:$soc ds:$disersoc ns:$nachtsoc ns2:$nachtsoc1)"
			  if (( soc < diesersoc ||  diesersoc == 100 )) ; then
					if grep -q 0 ramdisk/ladestatus; then
						llnachtneu=$nachtll
						#runs/set-current.sh "$nachtll" m
						openwbDebugLog "MAIN" 1 "soc $soc ladeleistung nachtladen bei $nachtll"
					fi
					if ! grep -q $nachtll ramdisk/llsoll; then
						llnachtneu=$nachtll
						#runs/set-current.sh "$nachtll" m
						openwbDebugLog "MAIN" 1 "aendere nacht Ladeleistung auf $nachtll"
					fi
				else
					if grep -q 1 ramdisk/ladestatus; then
						llnachtneu=0
						#runs/set-current.sh 0 m
					fi
				fi
			else
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$nachtll
					#runs/set-current.sh "$nachtll" m
					openwbDebugLog "MAIN" 1 "soc $soc ladeleistung nachtladen $nachtll A"
				else
					if ! grep -q $nachtll ramdisk/llsoll; then
						llnachtneu=$nachtll
						#runs/set-current.sh "$nachtll" m
						openwbDebugLog "MAIN" 1 "aendere nacht Ladeleistung auf $nachtll"
					fi
				fi
			fi
			if [ -z "$llnachtneu" ]; then
				llnachtneu=$llalt
			fi
		else
			nachtladenstate=0
		fi
		#Morgens Laden LP1
		dayoftheweek=$(date +%w)
		currenttime=$(date +%H:%M)
		#Sonntag
		if (( dayoftheweek == 0 )); then
			if [[ "$currenttime" > "$mollp1soab" ]] && [[ "$currenttime" < "$mollp1sobis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1soll
					openwbDebugLog "CHARGESTAT" 0 "Sonntag morgens Laden gestartet mit $mollp1soll A"
					openwbDebugLog "MAIN" 1 "ladeleistung Sonntag morgens Laden $mollp1soll A"
				else
					if ! grep -q $mollp1soll ramdisk/llsoll; then
						llnachtneu=$mollp1soll
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Sonntag morgens Laden $mollp1soll A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Montag
		if (( dayoftheweek == 1 )); then
			if [[ "$currenttime" > "$mollp1moab" ]] && [[ "$currenttime" < "$mollp1mobis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1moll
					openwbDebugLog "CHARGESTAT" 0 "Montag morgens Laden gestartet mit $mollp1moll A"
					openwbDebugLog "MAIN" 1 "ladeleistung Sonntag morgens Laden $mollp1moll A"
				else
					if ! grep -q $mollp1moll ramdisk/llsoll; then
						llnachtneu=$mollp1moll
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Montag morgens Laden $mollp1moll A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Dienstag
		if (( dayoftheweek == 2 )); then
			if [[ "$currenttime" > "$mollp1diab" ]] && [[ "$currenttime" < "$mollp1dibis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1dill
					openwbDebugLog "CHARGESTAT" 0 "Dienstag morgens Laden gestartet mit $mollp1dill A"
					openwbDebugLog "MAIN" 1 "ladeleistung Dienstag morgens Laden $mollp1dill A"
				else
					if ! grep -q $mollp1dill ramdisk/llsoll; then
						llnachtneu=$mollp1dill
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Dienstag morgens Laden $mollp1dill A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Mittwoch
		if (( dayoftheweek == 3 )); then
			if [[ "$currenttime" > "$mollp1miab" ]] && [[ "$currenttime" < "$mollp1mibis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1mill
					openwbDebugLog "CHARGESTAT" 0 "Mittwoch morgens Laden gestartet mit $mollp1mill A"
					openwbDebugLog "MAIN" 1 "ladeleistung Mittwoch morgens Laden $mollp1mill A"
				else
					if ! grep -q $mollp1mill ramdisk/llsoll; then
						llnachtneu=$mollp1mill
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Mittwoch morgens Laden $mollp1mill A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Donnerstag
		if (( dayoftheweek == 4 )); then
			if [[ "$currenttime" > "$mollp1doab" ]] && [[ "$currenttime" < "$mollp1dobis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1doll
					openwbDebugLog "CHARGESTAT" 0 "Donnerstag morgens Laden gestartet mit $mollp1doll A"
					openwbDebugLog "MAIN" 1 "ladeleistung Donnerstag morgens Laden $mollp1doll A"
				else
					if ! grep -q $mollp1doll ramdisk/llsoll; then
						llnachtneu=$mollp1doll
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Donnerstag morgens Laden $mollp1doll A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Freitag
		if (( dayoftheweek == 5 )); then
			if [[ "$currenttime" > "$mollp1frab" ]] && [[ "$currenttime" < "$mollp1frbis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1frll
					openwbDebugLog "CHARGESTAT" 0 "Freitag morgens Laden gestartet mit $mollp1frll A"
					openwbDebugLog "MAIN" 1 "ladeleistung Freitag morgens Laden $mollp1frll A"
				else
					if ! grep -q $mollp1frll ramdisk/llsoll; then
						llnachtneu=$mollp1frll
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Freitag morgens Laden $mollp1frll A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

		#Samstag
		if (( dayoftheweek == 6 )); then
			if [[ "$currenttime" > "$mollp1saab" ]] && [[ "$currenttime" < "$mollp1sabis" ]]; then
				nachtladen2state=1
				if grep -q 0 ramdisk/ladestatus; then
					llnachtneu=$mollp1sall
					openwbDebugLog "CHARGESTAT" 0 "Samstag morgens Laden gestartet mit $mollp1sall A"
					openwbDebugLog "MAIN" 1 "ladeleistung Samstag morgens Laden $mollp1sall A"
				else
					if ! grep -q $mollp1sall ramdisk/llsoll; then
						llnachtneu=$mollp1sall
						openwbDebugLog "MAIN" 1 "aendere ladeleistung Samstag morgens Laden $mollp1sall A"
					fi
				fi
				if [ -z "$llnachtneu" ]; then
					llnachtneu=$llalt
				fi	
			else
				nachtladen2state=0
			fi
		fi

	else
		nachtladenstate=0
		nachtladen2state=0
	fi

	#Nachtladen S1
	if [[ $nachtladens1 == "1" ]]; then
    
	    isnacht 10#$H 10#$nachtladenabuhrs1 10#$nachtladenbisuhrs1
        doit=$?
        if [ $doit -eq 1 ] ; then
    	# if (( nachtladenabuhrs1 <= 10#$H && 10#$H <= 24 )) || (( 0 <= 10#$H && 10#$H < nachtladenbisuhrs1 )); then
		    openwbDebugLog "MAIN" 0 "nachtladen Year doit LP2"
			nachtladenstates1=1
			dayoftheweek=$(date +%w)
			currenthour=$(date +%k)
			if [[ $dayoftheweek -eq 0 && $currenthour -ge 14 ]] || [[ $dayoftheweek -ge 1 && $dayoftheweek -le 4 ]] || [[ $dayoftheweek -eq 5 && $currenthour -le 11 ]]  ; then
				diesersocs1=$nachtsocs1
			else
				diesersocs1=$nachtsoc1s1
			fi
			if [[ $socmodul1 != "none" ]]; then
				openwbDebugLog "MAIN" 1 "nachtladen LP2 mit socmodul $socmodul1"
				if ((  soc1 < diesersocs1  ||  diesersocs1 == 100 )) ; then
					if grep -q 0 ramdisk/ladestatuss1; then
						llnachts1neu=$nachtlls1
						#runs/set-current.sh "$nachtlls1" s1
						openwbDebugLog "MAIN" 1 "soc $soc1 ladeleistung nachtladen bei $nachtlls1"
					fi
					if ! grep -q $nachtlls1 ramdisk/llsolls1; then
						llnachts1neu=$nachtlls1
						#runs/set-current.sh "$nachtlls1" s1
						openwbDebugLog "MAIN" 1 "aendere nacht Ladeleistung auf $nachtlls1"
					fi
				else
					if grep -q 1 ramdisk/ladestatuss1; then
						llnachts1neu=0
						#runs/set-current.sh 0 s1
					fi
				fi
			else
				if grep -q 0 ramdisk/ladestatuss1; then
					llnachts1neu=$nachtlls1
					#runs/set-current.sh "$nachtlls1" s1
					openwbDebugLog "MAIN" 1 "soc $soc1 ladeleistung nachtladen $nachtlls1 A"
					openwbDebugLog "CHARGESTAT" 0 "start Nachtladung mit $nachtlls1"
				else
					if ! grep -q $nachtlls1 ramdisk/llsolls1; then
						llnachts1neu=$nachtlls1
						#runs/set-current.sh "$nachtlls1" s1
						openwbDebugLog "MAIN" 1 "aendere nacht Ladeleistung auf $nachtlls1"
					fi
				fi
			fi
			if [ -z "$llnachts1neu" ]; then
				llnachts1neu=$llalts1
			fi
		else
			nachtladenstates1=0
		fi
		if (( nachtladen2abuhrs1 <= 10#$H )) && (( 10#$H < nachtladen2bisuhrs1 )); then
			nachtladen2states1=1
			dayoftheweek=$(date +%w)

			if grep -q 0 ramdisk/ladestatuss1; then
				llnachts1neu=$nacht2lls1
				#runs/set-current.sh "$nacht2lls1" s1
				openwbDebugLog "MAIN" 1 "soc $soc1 ladeleistung nachtladen $nacht2lls1 A"
			else
				if ! grep -q $nacht2lls1 ramdisk/llsolls1; then
					llnachts1neu=$nacht2lls1
					#runs/set-current.sh "$nacht2lls1" m
					openwbDebugLog "MAIN" 1 "aendere nacht Ladeleistung auf $nacht2lls1"
				fi
			fi
			if [ -z "$llnachts1neu" ]; then
				llnachts1neu=$llalts1
			fi
		else
			nachtladen2states1=0
		fi
	else
		nachtladenstates1=0
		nachtladen2states1=0
	fi
	echo $nachtladenstate > ramdisk/nachtladenstate
	echo $nachtladenstates1 > ramdisk/nachtladenstates1
	echo $nachtladen2state > ramdisk/nachtladen2state
	echo $nachtladen2states1 > ramdisk/nachtladen2states1
	if (( nachtladenstate == 1 )) || (( nachtladenstates1 == 1 )) || (( nachtladen2state == 1 )) || (( nachtladen2states1 == 1 )); then
		if (( nachtladenstate == 1 )) || (( nachtladen2state == 1 )); then
			lastmnacht $llalt $llnachtneu 
			if (( llnachtreturn != llalt )); then
				runs/set-current.sh $llnachtreturn m
				openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Nachtladen. Ladung mit $llnachtreturn Ampere, Zielsoc: $diesersoc % soc: $soc "
			fi
		fi
		if (( nachtladenstates1 == 1 )) || (( nachtladen2states1 == 1 )); then
			lastmnacht $llalts1 $llnachts1neu
			if (( llnachtreturn != llalts1 )); then
				runs/set-current.sh $llnachtreturn s1
				openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Nachtladen. Ladung mit $llnachtreturn Ampere, Zielsoc: $diesersocs1 % soc: $soc1 "
			fi
		fi
		openwbDebugLog "MAIN" 0 "*** exit 0"
		exit 0
	fi
}

prenachtlademodus()
{
	if { (( lademodus == $SOFORT0 ))  && (( nlakt_sofort  == 1 )); } \
	|| { (( lademodus == $MINPV1 ))   && (( nlakt_minpv   == 1 )); } \
	|| { (( lademodus == $NURPV2 ))   && (( nlakt_nurpv   == 1 )); } \
	|| { (( lademodus == $STANDBY4 )) && (( nlakt_standby == 1 )); } then
		private_nachtlademodus
	else
		echo 0 > ramdisk/nachtladenstate
		echo 0 > ramdisk/nachtladen2state
		echo 0 > ramdisk/nachtladenstates1
		echo 0 > ramdisk/nachtladen2states1
	fi
}
