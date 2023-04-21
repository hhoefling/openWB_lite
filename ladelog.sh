#!/bin/bash


# check if config file is already in env
if [[ -z "$debug" ]]; then
	cd /var/www/html/openWB
	./loadconfig.sh
	# ./helperFunctions.sh
	openwbDebugLog()
	{
	  shift; shift;
	  echo $*
	}
	openwbDebugLog "MAIN" 0 "Ladelog start"
fi

############### profiling Anf
ptx=0
pt=0

declare -F ptstart &>/dev/null || {
 ptstart()
 {
   ptx=$(( ${EPOCHREALTIME/[\,\.]/} / 1000 )) 
 }
 ptend()
 {
 local txt=${1:-}
 local max=${2:-200}
 local te
 te=$(( ${EPOCHREALTIME/[\,\.]/} / 1000 )) 
 pt=$(( te - ptx))
 if (( pt > max ))  ; then
   openwbDebugLog "DEB" 1 "TIME **** ${txt} needs $pt ms. (max:$max)"
   openwbDebugLog "MAIN" 2 "TIME **** ${txt} needs $pt ms. (max:$max)"
 fi
 }
} 
############### profiling End

ptstart 



monthlyfile="web/logging/data/ladelog/$(date +%Y%m).csv"
if [ ! -f $monthlyfile ]; then
	echo $monthlyfile
fi

readonly SOFORT0=0
readonly MINPV1=1
readonly NURPV2=2
readonly STOP3=3
readonly STANDBY4=4
readonly SUBMODE_NACHLADEN7=7


ladeleistung=$(<ramdisk/llaktuell)
llkwh=$(<ramdisk/llkwh)
soc=$(<ramdisk/soc)
soc1=$(<ramdisk/soc1)
nachtladenstate=$(<ramdisk/nachtladenstate)
nachtladen2state=$(<ramdisk/nachtladen2state)
rfidlp1=$(<ramdisk/rfidlp1)
rfidlp1=$( cut -d ',' -f 1 <<< "$rfidlp1" )     # Zeit vom Tag abtennen
rfidlp2=$(<ramdisk/rfidlp2)
rfidlp2=$( cut -d ',' -f 1 <<< "$rfidlp2" )		# Zeit vom Tag abtennen
rfidlp3=$(<ramdisk/rfidlp3)
rfidlp4="0" # $(<ramdisk/rfidlp4)
rfidlp5="0" # $(<ramdisk/rfidlp5)
rfidlp6="0" # $(<ramdisk/rfidlp6)
rfidlp7="0" # $(<ramdisk/rfidlp7)
soc1KM=$(<ramdisk/soc1KM)
soc2KM=$(<ramdisk/soc2KM)
soc3KM=$(<ramdisk/soc3KM)
soc1Range=$(<ramdisk/soc1Range)
soc2Range=$(<ramdisk/soc2Range)


if (( nachtladenstate == 0 )) && (( nachtladen2state == 0 )); then # Weder Nachtladen (nachtladestate) noch  Morgens laden (nachtladen2state) aktiv? nutze lademodus.
	lmodus=$(<ramdisk/lademodus)
else # Nachtladen oder Morgens laden ist aktiv, lademodus 7 setzen
	lmodus=$SUBMODE_NACHLADEN7
fi
if [ -e ramdisk/loglademodus ]; then
	lademodus=$(<ramdisk/loglademodus)
	loglademodus=$lademodus
fi
if (( soc > 0 )); then
	soctext=$(echo ", bei $soc %SoC")
else
	soctext=$(echo ".")
fi
if (( soc1 > 0 )); then
	soctext1=$(echo ", bei $soc1 %SoC")
else
	soctext1=$(echo ".")
fi


###################
####  LP1 ########
###################
plugstat=$(<ramdisk/plugstat)
if (( plugstat == 1 )); then
	pluggedladungaktlp1=$(<ramdisk/pluggedladungaktlp1)
	if (( pluggedladungaktlp1 == 0 )); then
		echo $llkwh > ramdisk/pluggedladunglp1startkwh
		echo 1 > ramdisk/pluggedladungaktlp1
	fi
	if (( stopchargeafterdisclp1 == 1 )); then
		boolstopchargeafterdisclp1=$(<ramdisk/boolstopchargeafterdisclp1)
		if (( boolstopchargeafterdisclp1 == 0 )); then
			echo 1 > ramdisk/boolstopchargeafterdisclp1
		fi
	fi
	pluggedladunglp1startkwh=$(<ramdisk/pluggedladunglp1startkwh)
	pluggedladungbishergeladen=$(echo "scale=2;($llkwh - $pluggedladunglp1startkwh)/1" |bc | sed 's/^\./0./')
	echo $pluggedladungbishergeladen > ramdisk/pluggedladungbishergeladen
	echo 0 > ramdisk/pluggedtimer1
else
	pluggedtimer1=$(<ramdisk/pluggedtimer1)
	if (( pluggedtimer1 < 3 )); then
		pluggedtimer1=$((pluggedtimer1 + 1))
		echo $pluggedtimer1 > ramdisk/pluggedtimer1
	else
		echo 0 > ramdisk/pluggedladungaktlp1
		if (( stopchargeafterdisclp1 == 1 )); then
			boolstopchargeafterdisclp1=$(<ramdisk/boolstopchargeafterdisclp1)
			if (( boolstopchargeafterdisclp1 == 1 )); then
				echo 0 > ramdisk/boolstopchargeafterdisclp1
				mosquitto_pub -r -t "openWB/set/lp/1/ChargePointEnabled" -m "0"
			fi
		fi
	fi
fi

if (( ladeleistung > 100 )); then
	if [ -e ramdisk/ladeustart ]; then
		ladelstart=$(<ramdisk/ladelstart)
		bishergeladen=$(echo "scale=2;($llkwh - $ladelstart)/1" |bc | sed 's/^\./0./')
		echo $bishergeladen > ramdisk/aktgeladen
		gelrlp1=$(echo "scale=2;$bishergeladen / $durchslp1 * 100" |bc)
		gelrlp1=${gelrlp1%.*}
		echo $gelrlp1 > ramdisk/gelrlp1
		restzeitlp1=$(echo "scale=6;($lademkwh - $bishergeladen)/ $ladeleistung * 1000 * 60" |bc)
		restzeitlp1=${restzeitlp1%.*}
		echo $restzeitlp1 > ramdisk/restzeitlp1m
		if (( restzeitlp1 > 60 )); then
			restzeitlp1h=$((restzeitlp1 / 60))
			restzeitlp1r=$((restzeitlp1 % 60))
			echo "$restzeitlp1h H $restzeitlp1r Min" > ramdisk/restzeitlp1
		else
			echo "$restzeitlp1 Min" > ramdisk/restzeitlp1
		fi
	else
		echo 1 > ramdisk/ladungaktivlp1
		touch ramdisk/ladeustart
		echo -e $(date +%d.%m.%y-%H:%M) > ramdisk/ladeustart
		echo -e $(date +%s) > ramdisk/ladeustarts
		echo $lmodus > ramdisk/loglademodus
		echo $llkwh > ramdisk/ladelstart
		if ((pushbenachrichtigung == "1")) ; then
			if ((pushbstartl == "1")) ; then
				./runs/pushover.sh "$lp1name Ladung gestartet$soctext"
			fi
		fi
		openwbDebugLog "CHARGESTAT" 0 "LP1, Ladung gestartet."
	fi
	echo 0 > ramdisk/llog1
else
	llog1=$(<ramdisk/llog1)
	if (( llog1 < 5 )); then
		llog1=$((llog1 + 1))
		echo $llog1 > ramdisk/llog1
	else
		if [ -e ramdisk/ladeustart ]; then
			echo 0 > ramdisk/ladungaktivlp1
			echo "--" > ramdisk/restzeitlp1
			ladelstart=$(<ramdisk/ladelstart)
			ladeustarts=$(<ramdisk/ladeustarts)
			bishergeladen=$(echo "scale=2;($llkwh - $ladelstart)/1" |bc | sed 's/^\./0./')
			start=$(<ramdisk/ladeustart)
			jetzt=$(date +%d.%m.%y-%H:%M)
			jetzts=$(date +%s)
			ladedauer=$(((jetzts - ladeustarts) / 60 ))
			ladedauers=$((jetzts - ladeustarts))
			ladegeschw=$(echo "scale=2;$bishergeladen * 60 * 60 / $ladedauers" |bc)
			gelrlp1=$(echo "scale=2;$bishergeladen / $durchslp1 * 100" |bc)
			gelrlp1=${gelrlp1%.*}
			if (( ladedauer > 60 )); then
				ladedauerh=$((ladedauer / 60))
				laderest=$((ladedauer % 60))
				sed -i '1i'$start,$jetzt,$gelrlp1,$bishergeladen,$ladegeschw,$ladedauerh' H '$laderest' Min,1',$loglademodus,$rfidlp1,$soc1KM $monthlyfile
				if ((pushbenachrichtigung == "1")) ; then
					if ((pushbstopl == "1")) ; then
						./runs/pushover.sh "$lp1name Ladung gestoppt. $bishergeladen kWh in $ladedauerh H $laderest Min mit durchschnittlich $ladegeschw kW geladen$soctext"
					fi
				fi
			else
				sed -i '1i'$start,$jetzt,$gelrlp1,$bishergeladen,$ladegeschw,$ladedauer' Min,1',$loglademodus,$rfidlp1,$soc1KM $monthlyfile
				if ((pushbenachrichtigung == "1")) ; then
					if ((pushbstopl == "1")) ; then
						./runs/pushover.sh "$lp1name Ladung gestoppt. $bishergeladen kWh in $ladedauer Min mit durchschnittlich $ladegeschw kW geladen$soctext"
					fi
				fi
			fi
			openwbDebugLog "CHARGESTAT" 0 "LP1, Ladung gestoppt"
			rm ramdisk/ladeustart
		fi
	fi
fi


###################
####  LP2 ########
###################

if (( lastmanagement == 1 )); then
	ladeleistungs1=$(<ramdisk/llaktuells1)
	llkwhs1=$(<ramdisk/llkwhs1)
	plugstatlp2=$(<ramdisk/plugstats1)
	if (( plugstatlp2 == 1 )); then
		pluggedladungaktlp2=$(<ramdisk/pluggedladungaktlp2)
		if (( pluggedladungaktlp2 == 0 )); then
			echo $llkwhs1 > ramdisk/pluggedladunglp2startkwh
			echo 1 > ramdisk/pluggedladungaktlp2
		fi
		pluggedladunglp2startkwh=$(<ramdisk/pluggedladunglp2startkwh)
		pluggedladungbishergeladenlp2=$(echo "scale=2;($llkwhs1 - $pluggedladunglp2startkwh)/1" |bc | sed 's/^\./0./')
		echo $pluggedladungbishergeladenlp2 > ramdisk/pluggedladungbishergeladenlp2
		echo 0 > ramdisk/pluggedtimer2
		if (( stopchargeafterdisclp2 == 1 )); then
			boolstopchargeafterdisclp2=$(<ramdisk/boolstopchargeafterdisclp2)
			if (( boolstopchargeafterdisclp2 == 0 )); then
				echo 1 > ramdisk/boolstopchargeafterdisclp2
			fi
		fi
	else
		pluggedtimer2=$(<ramdisk/pluggedtimer2)
		if (( pluggedtimer2 < 3 )); then
			pluggedtimer2=$((pluggedtimer2 + 1))
			echo $pluggedtimer2 > ramdisk/pluggedtimer2
		else
			echo 0 > ramdisk/pluggedladungaktlp2
			if (( stopchargeafterdisclp2 == 1 )); then
				boolstopchargeafterdisclp2=$(<ramdisk/boolstopchargeafterdisclp2)
				if (( boolstopchargeafterdisclp2 == 1 )); then
					echo 0 > ramdisk/boolstopchargeafterdisclp2
					mosquitto_pub -r -t "openWB/set/lp/2/ChargePointEnabled" -m "0"
				fi
			fi
		fi
	fi

	if (( ladeleistungs1 > 100 )); then
		if [ -e ramdisk/ladeustarts1 ]; then

			ladelstarts1=$(<ramdisk/ladelstarts1)
			bishergeladens1=$(echo "scale=2;($llkwhs1 - $ladelstarts1)/1" |bc | sed 's/^\./0./')
			echo $bishergeladens1 > ramdisk/aktgeladens1
			gelrlp2=$(echo "scale=2;$bishergeladens1 / $durchslp2 * 100" |bc)
			gelrlp2=${gelrlp2%.*}
			echo $gelrlp2 > ramdisk/gelrlp2
			restzeitlp2=$(echo "scale=6;($lademkwhs1 - $bishergeladens1)/ $ladeleistungs1 * 1000 * 60" |bc)
			restzeitlp2=${restzeitlp2%.*}
			echo $restzeitlp2 > ramdisk/restzeitlp2m

			if (( restzeitlp2 > 60 )); then
				restzeitlp2h=$((restzeitlp2 / 60))
				restzeitlp2r=$((restzeitlp2 % 60))
				echo "$restzeitlp2h H $restzeitlp2r Min" > ramdisk/restzeitlp2
			else
				echo "$restzeitlp2 Min" > ramdisk/restzeitlp2
			fi
		else
			if ((pushbenachrichtigung == "1")) ; then
				if ((pushbstartl == "1")) ; then
					./runs/pushover.sh "$lp2name Ladung gestartet$soctext1"
				fi
			fi
			openwbDebugLog "CHARGESTAT" 0 "LP2, Ladung gestartet"

			echo 1 > ramdisk/ladungaktivlp2
			touch ramdisk/ladeustarts1
			echo $lmodus > ramdisk/loglademodus
			echo -e $(date +%d.%m.%y-%H:%M) > ramdisk/ladeustarts1
			echo -e $(date +%s) > ramdisk/ladeustartss1
			echo $llkwhs1 > ramdisk/ladelstarts1
		fi
		echo 0 > ramdisk/llogs1
	else
		llogs1=$(<ramdisk/llogs1)
		if (( llogs1 < 5 )); then
			llogs1=$((llogs1 + 1))
			echo $llogs1 > ramdisk/llogs1
		else
			if [ -e ramdisk/ladeustarts1 ]; then
				echo 0 > ramdisk/ladungaktivlp2
				echo "--" > ramdisk/restzeitlp2
				ladelstarts1=$(<ramdisk/ladelstarts1)
				ladeustartss1=$(<ramdisk/ladeustartss1)
				bishergeladens1=$(echo "scale=2;($llkwhs1 - $ladelstarts1)/1" |bc | sed 's/^\./0./')
				starts1=$(<ramdisk/ladeustarts1)
				jetzts1=$(date +%d.%m.%y-%H:%M)
				jetztss1=$(date +%s)
				ladedauers1=$(((jetztss1 - ladeustartss1) / 60 ))
				ladedauerss1=$((jetztss1 - ladeustartss1))
				ladegeschws1=$(echo "scale=2;$bishergeladens1 * 60 * 60 / $ladedauerss1" |bc)
				gelrlp2=$(echo "scale=2;$bishergeladens1 / $durchslp2 * 100" |bc)
				gelrlp2=${gelrlp2%.*}
				if (( ladedauers1 > 60 )); then
					ladedauerhs1=$((ladedauers1 / 60))
					laderests1=$((ladedauers1 % 60))
					sed -i '1i'$starts1,$jetzts1,$gelrlp2,$bishergeladens1,$ladegeschws1,$ladedauerhs1' H '$laderests1' Min,2',$loglademodus,$rfidlp2,$soc2KM $monthlyfile
					if ((pushbenachrichtigung == "1")) ; then
						if ((pushbstopl == "1")) ; then
							./runs/pushover.sh "$lp2name Ladung gestoppt. $bishergeladens1 kWh in $ladedauerhs1 H $laderests1 Min mit durchschnittlich $ladegeschws1 kW geladen$soctext1"
						fi
					fi
				else
					sed -i '1i'$starts1,$jetzts1,$gelrlp2,$bishergeladens1,$ladegeschws1,$ladedauers1' Min,2',$loglademodus,$rfidlp2,$soc2KM $monthlyfile
					if ((pushbenachrichtigung == "1")) ; then
						if ((pushbstopl == "1")) ; then
							./runs/pushover.sh "$lp2name Ladung gestoppt. $bishergeladens1 kWh in $ladedauers1 Min mit durchschnittlich $ladegeschws1 kW geladen$soctext1"
						fi
					fi
				fi
				openwbDebugLog "CHARGESTAT" 0 "LP2, Ladung gestoppt"
				rm ramdisk/ladeustarts1
			fi
		fi
	fi
fi


###################
####  LP3  ########
###################

if (( lastmanagements2 == 1 )); then
	ladeleistungs2=$(<ramdisk/llaktuells2)
	llkwhs2=$(<ramdisk/llkwhs2)
	plugstatlp3=$(<ramdisk/plugstatlp3)
	if (( plugstatlp3 == 1 )); then
		pluggedladungaktlp3=$(<ramdisk/pluggedladungaktlp3)
		if (( pluggedladungaktlp3 == 0 )); then
			echo $llkwhs2 > ramdisk/pluggedladunglp3startkwh
			echo 1 > ramdisk/pluggedladungaktlp3
		fi
		pluggedladunglp3startkwh=$(<ramdisk/pluggedladunglp3startkwh)
		pluggedladungbishergeladenlp3=$(echo "scale=2;($llkwhs2 - $pluggedladunglp3startkwh)/1" |bc | sed 's/^\./0./')
		echo $pluggedladungbishergeladenlp3 > ramdisk/pluggedladungbishergeladenlp3
		echo 0 > ramdisk/pluggedtimer3
		if (( stopchargeafterdisclp3 == 1 )); then
			boolstopchargeafterdisclp3=$(<ramdisk/boolstopchargeafterdisclp3)
			if (( boolstopchargeafterdisclp3 == 0 )); then
				echo 1 > ramdisk/boolstopchargeafterdisclp3
			fi
		fi
	else
		pluggedtimer3=$(<ramdisk/pluggedtimer3)
		if (( pluggedtimer3 < 3 )); then
			pluggedtimer3=$((pluggedtimer3 + 1))
			echo $pluggedtimer3 > ramdisk/pluggedtimer3
		else
			echo 0 > ramdisk/pluggedladungaktlp3

			if (( stopchargeafterdisclp3 == 1 )); then
				boolstopchargeafterdisclp3=$(<ramdisk/boolstopchargeafterdisclp3)
				if (( boolstopchargeafterdisclp3 == 1 )); then
					echo 0 > ramdisk/boolstopchargeafterdisclp3
					mosquitto_pub -r -t "openWB/set/lp/3/ChargePointEnabled" -m "0"
				fi
			fi
		fi
	fi

	if (( ladeleistungs2 > 100 )); then
		if [ -e ramdisk/ladeustarts2 ]; then

			ladelstarts2=$(<ramdisk/ladelstarts2)
			bishergeladens2=$(echo "scale=2;($llkwhs2 - $ladelstarts2)/1" |bc | sed 's/^\./0./')
			echo $bishergeladens2 > ramdisk/aktgeladens2
			gelrlp3=$(echo "scale=2;$bishergeladens2 / $durchslp3 * 100" |bc)
			gelrlp3=${gelrlp3%.*}
			echo $gelrlp3 > ramdisk/gelrlp3
			restzeitlp3=$(echo "scale=6;($lademkwhs2 - $bishergeladens2)/ $ladeleistungs2 * 1000 * 60" |bc)
			restzeitlp3=${restzeitlp3%.*}
			echo $restzeitlp3 > ramdisk/restzeitlp3m
			if (( restzeitlp3 > 60 )); then
				restzeitlp3h=$((restzeitlp3 / 60))
				restzeitlp3r=$((restzeitlp3 % 60))
				echo "$restzeitlp3h H $restzeitlp3r Min" > ramdisk/restzeitlp3
			else
				echo "$restzeitlp3 Min" > ramdisk/restzeitlp3
			fi
		else
			if ((pushbenachrichtigung == "1")) ; then
				if ((pushbstartl == "1")) ; then
					./runs/pushover.sh "$lp3name Ladung gestartet"
				fi
			fi
			openwbDebugLog "CHARGESTAT" 0 "LP3, Ladung gestartet"

			echo 1 > ramdisk/ladungaktivlp3
			touch ramdisk/ladeustarts2
			echo $lmodus > ramdisk/loglademodus
			echo -e $(date +%d.%m.%y-%H:%M) > ramdisk/ladeustarts2
			echo -e $(date +%s) > ramdisk/ladeustartss2
			echo $llkwhs2 > ramdisk/ladelstarts2
		fi
		echo 0 > ramdisk/llogs2
	else
		llogs2=$(<ramdisk/llogs2)
		if (( llogs2 < 5 )); then
			llogs2=$((llogs2 + 1))
			echo $llogs2 > ramdisk/llogs2
		else
			if [ -e ramdisk/ladeustarts2 ]; then
				echo 0 > ramdisk/ladungaktivlp3
				echo "--" > ramdisk/restzeitlp3
				ladelstarts2=$(<ramdisk/ladelstarts2)
				ladeustartss2=$(<ramdisk/ladeustartss2)
				bishergeladens2=$(echo "scale=2;($llkwhs2 - $ladelstarts2)/1" |bc | sed 's/^\./0./')
				starts2=$(<ramdisk/ladeustarts2)
				jetzts2=$(date +%d.%m.%y-%H:%M)
				jetztss2=$(date +%s)
				ladedauers2=$(((jetztss2 - ladeustartss2) / 60 ))
				ladedauerss2=$((jetztss2 - ladeustartss2))
				ladegeschws2=$(echo "scale=2;$bishergeladens2 * 60 * 60 / $ladedauerss2" |bc)
				gelrlp3=$(echo "scale=2;$bishergeladens2 / $durchslp3 * 100" |bc)
				gelrlp3=${gelrlp3%.*}

				if (( ladedauers2 > 60 )); then
					ladedauerhs2=$((ladedauers2 / 60))
					laderests2=$((ladedauers2 % 60))
					sed -i '1i'$starts2,$jetzts2,$gelrlp3,$bishergeladens2,$ladegeschws2,$ladedauerhs2' H '$laderests2' Min,3',$lademodus,$rfidlp3,$soc3KM $monthlyfile
					if ((pushbenachrichtigung == "1")) ; then
						if ((pushbstopl == "1")) ; then
							./runs/pushover.sh "$lp3name Ladung gestoppt. $bishergeladens2 kWh in $ladedauerhs2 H $laderests2 Min mit durchschnittlich $ladegeschws2 kW geladen."
						fi
					fi
				else
					sed -i '1i'$starts2,$jetzts2,$gelrlp3,$bishergeladens2,$ladegeschws2,$ladedauers2' Min,3',$lademodus,$rfidlp3,$soc3KM $monthlyfile
					if ((pushbenachrichtigung == "1")) ; then
						if ((pushbstopl == "1")) ; then
							./runs/pushover.sh "$lp3name Ladung gestoppt. $bishergeladens2 kWh in $ladedauers2 Min mit durchschnittlich $ladegeschws2 kW geladen."
						fi
					fi

				fi
				openwbDebugLog "CHARGESTAT" 0 "LP3, Ladung gestoppt"

				rm ramdisk/ladeustarts2
			fi
		fi
	fi
fi


# LP4-LP8


ptend "ladelog " 10

