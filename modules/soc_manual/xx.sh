#!/bin/bash

RAMDISKDIR="ramdisk"
DMOD="EVSOC"
CHARGEPOINT=$1
CB=${1:-}
CN=${1:-1}
if (( CB == 2 )) ; then
 CB="1"
 CS="s1"
else 
 CB=""
 CS=""
fi


declare -F openwbDebugLog &>/dev/null || {
    cd /var/www/html/openWB || exit 0
    source loadconfig.sh
    #source helperFunctions.sh
    openwbDebugLog()
    {
      d1=$1
      shift; shift;
      echo "$d1 $*"
    }
    openwbDebugLog "MAIN" 0 "$0 Directstart"
}


# Werte aus openwb.conf
if (( CN == 1 )) ; then 
  socIntervall=$socintervall;
  akkug=$akkuglp1
  efficiency=$wirkungsgradlp1
else 
  socIntervall=$soc2intervall;
  akkug=$akkuglp2
  efficiency=$wirkungsgradlp2
fi
# ramdisk
manualMeterFile="ramdisk/manual_soc_meter_lp${CN}"
meterFile="ramdisk/llkwh${CS}"
manualSocFile="ramdisk/manual_soc_lp${CN}"
socFile="ramdisk/soc${CB}"
soctimerFile="ramdisk/soctimer${CB}"

openwbDebugLog ${DMOD} 3 "CB:[$CB] -> xxx  or xxx1 "
openwbDebugLog ${DMOD} 3 "CS:[$CS] -> xxx  or xxxs1"
openwbDebugLog ${DMOD} 3 "CN:[$CN] -> xxx1 or xxx2"
openwbDebugLog ${DMOD} 3 "socTntervall     -> [$socTntervall]"
openwbDebugLog ${DMOD} 3 "manualMeterFile  -> [$manualMeterFile]"
openwbDebugLog ${DMOD} 3 "meterFile        -> [$meterFile]"
openwbDebugLog ${DMOD} 3 "manualSocFile    -> [$manualSocFile]"
openwbDebugLog ${DMOD} 3 "socFile          -> [$socFile]"
openwbDebugLog ${DMOD} 3 "soctimerFile     -> [$soctimerFile]"
openwbDebugLog ${DMOD} 3 "akkug            - > [$akkug]"
openwbDebugLog ${DMOD} 3 "efficiency       -> [$efficiency]"

function incrementTimer()
{
 case $dspeed in
	1)
		# Regelgeschwindigkeit 10 Sekunden
		ticksize=10
		;;
	2)
		# Regelgeschwindigkeit 20 Sekunden
		ticksize=20
		;;
	3)
		# Regelgeschwindigkeit 60 Sekunden
		ticksize=60
		;;
	*)
		# Regelgeschwindigkeit unbekannt
		ticksize=10
		;;
 esac
 soctimer=$(($soctimer+$ticksize))
 echo $soctimer >$soctimerFile
}

read soctimer < $soctimerFile
if (( soctimer < socIntervall )); then
	openwbDebugLog ${DMOD} 1 "Lp$CN: Nothing to do yet. Incrementing timer."
	incrementTimer
else
	openwbDebugLog ${DMOD} 1 "Lp$CN: Calculating manual SoC"
	# reset timer
	echo 0 > $soctimerFile		# Touch lastrun
	# read current meter
	if [[ -f "$meterFile" ]]; then
		read currentMeter <$meterFile
		openwbDebugLog ${DMOD} 1 "Lp$CN: currentMeter:[$currentMeter]"
		# read manual Soc
		if [[ -f "$manualSocFile" ]]; then
			read manualSoc <$manualSocFile
			openwbDebugLog ${DMOD} 1 "Lp$CN: IN manual SoC:[$manualSoc]"
		else
			# set manualSoc to 0 as a starting point
			manualSoc=0
			echo $manualSoc > $manualSocFile
			openwbDebugLog ${DMOD} 1 "Lp$CN: OUT init manualSoC:[$manualSoc]"
		fi

		# read manualMeterFile if file exists and manualMeterFile is newer than manualSocFile
		if [[ -f "$manualMeterFile" ]] && [ "$manualMeterFile" -nt "$manualSocFile" ]; then
			read manualMeter <$manualMeterFile
  		    openwbDebugLog ${DMOD} 1 "Lp$CN: IN manualMeter:[$manualMeter]"
		else
			# manualMeterFile does not exist or is outdated
			# update manualMeter with currentMeter
			manualMeter=$currentMeter
			echo $manualMeter > $manualMeterFile
  		    openwbDebugLog ${DMOD} 1 "Lp$CN: INIT manualMeter:[$manualMeter] from currentMeter"
		fi

		# read current soc
		if [[ -f "$socFile" ]]; then
			read currentSoc <$socFile
			openwbDebugLog ${DMOD} 1 "Lp$CN: IN currentSoc:[$currentSoc]"
		else
			currentSoc=$manualSoc
			echo $currentSoc > $socFile
			openwbDebugLog ${DMOD} 1 "Lp$CN: Init currentSoc:[$currentSoc] from ManualSoc"
		fi

		# calculate newSoc
		currentMeterDiff=$(echo "scale=5;$currentMeter - $manualMeter" | bc)
		currentEffectiveMeterDiff=$(echo "scale=5;$currentMeterDiff * $efficiency / 100" | bc)
		currentSocDiff=$(echo "scale=5;100 / $akkug * $currentEffectiveMeterDiff" | bc | awk '{printf"%d\n",$1}')

		openwbDebugLog ${DMOD} 1 "Lp$CHARGEPOINT: currentMeterDiff:[$currentMeterDiff]"
		openwbDebugLog ${DMOD} 1 "Lp$CHARGEPOINT: currentEffectiveMeterDiff:[$currentEffectiveMeterDiff] ($efficiency %)"
		openwbDebugLog ${DMOD} 1 "Lp$CHARGEPOINT: currentSocDiff:[$currentSocDiff]"
		newSoc=$(echo "$manualSoc + $currentSocDiff" | bc)
		if (( newSoc > 100 )); then
			newSoc=100
		fi
		if (( newSoc < 0 )); then
			newSoc=0
		fi
		openwbDebugLog ${DMOD} 1 "Lp$CN: OUT newSoc:[$newSoc]"
		echo $newSoc > $socFile
	else
		# no current meter value for calculation -> Exit
		openwbDebugLog ${DMOD} 0 "Lp$CN: ERROR: no meter value for calculation! ($meterFile)"
	fi
fi

openwbDebugLog ${DMOD} 1 "Lp$CN: --- Manual SoC end ---"
