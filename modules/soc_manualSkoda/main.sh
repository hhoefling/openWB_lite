#!/bin/bash

OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
MODULEDIR=$(cd `dirname $0` && pwd)
DMOD="EVSOC"
CHARGEPOINT=$1

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "soc_manualSkoda: Seems like openwb.conf is not loaded. Reading file."
	# try to load config
	. $OPENWBBASEDIR/loadconfig.sh
	# load helperFunctions
	. $OPENWBBASEDIR/helperFunctions.sh
fi

function socLog()
{
 level=$1;
 shift;
 openwbDebugLog ${DMOD} $level "LP${CHARGEPOINT}: $*"
}

function getrvar()
{  # ramdisk-fileName, defaultwert
  if [ -f $RAMDISKDIR/$1 ] ; then 
	  val=$(<$RAMDISKDIR/$1)
  else 
	  val=$2
  fi
 	socLog 1 "get $1 -> [$val]"
  echo $val
}

function putrvar()
{ # ramdisk-fileName, wert
	echo "$2" > $RAMDISKDIR/$1
 	socLog 1 "set [$2] -> $1"
}



case $CHARGEPOINT in
	2)
		# second charge point
		manualSocvn="manual_soc_lp2"
		manualMetervn="manual_soc_meter_lp2"
		socvn="soc1"
		soctimervn="soctimer1"
		metervn="llkwhs1"
		ladungaktivvn="ladungaktivlp2"
		akkug=$akkuglp2
		efficiency=$wirkungsgradlp2
		url=$skodaurl2

		#chargestat=$(getrvar chargestats1 0)
		intervall=$(getrvar soc_Skoda_intervall2 60)
		intervallladen=$(getrvar soc_Skoda_intervallladen2  10)
		ladungaktiv=$(getrvar ladungaktivlp2 0)
		;;
	*)
		# defaults to first charge point for backward compatibility
		# set CHARGEPOINT in case it is empty (needed for logging)
		CHARGEPOINT=1
		manualSocvn="manual_soc_lp1"
		manualMetervn="manual_soc_meter_lp1"
		socvn="soc"
		soctimervn="soctimer"
		metervn="llkwh"
		ladungaktivvn="ladungaktivlp1"
		akkug=$akkuglp1
		efficiency=$wirkungsgradlp1
		url=$skodaurl

		#chargestat=$( getrvar chargestat 0)
		intervall=$(getrvar soc_Skoda_intervall 60)
		intervallladen=$(getrvar soc_Skoda_intervallladen  10 )
		intervall=3
		intervallladen=1
		ladungaktiv=1
		ladungaktiv=$(getrvar ladungaktivlp1 0)
		
		;;
esac
intervall=$(( intervall * 6 ))
intervallladen=$(( intervallladen * 6 ))
		
env >./env.txt
incrementTimer(){
	case $dspeed in
		1)
			# Regelgeschwindigkeit 10 Sekunden
			ticksize=1
			;;
		2)
			# Regelgeschwindigkeit 20 Sekunden
			ticksize=2
			;;
		3)
			# Regelgeschwindigkeit 60 Sekunden
			ticksize=1
			;;
		*)
			# Regelgeschwindigkeit unbekannt
			ticksize=1
			;;
	esac
	soctimer=$((soctimer+$ticksize))
	putrvar $soctimervn $soctimer 
}

getAndWriteSoc(){
	re='^-?[0-9]+$'
	socLog 0 " ########### Requesting SoC"
	putrvar $soctimervn 0
	soc=$(curl --connect-timeout 15 -s $url | cut -f1 -d".")
		
	if  [[ $soc =~ $re ]] ; then
		if (( $soc != 0 )) ; then
			putrvar $socvn $soc
			socLog 0 "From Skoda: SoC: $soc%"
		else
		# we have a problem
		socLog 0 "Error from http call"
		fi
	else
		# we have a problem
		soclog 0 "Error from http call"
	fi
}

soctimer=$(getrvar $soctimervn 0)
socLog 1 "----- timer = $soctimer ---- ($intervall ,$intervallladen )"

if (( ladungaktiv  ==  1 )); then
	if (( soctimer < intervallladen )); then
		socLog 1 "Charging, but nothing to do yet. Incrementing timer."
		incrementTimer
	else
		getAndWriteSoc
	fi
else
	if (( soctimer < intervall )); then
		socLog 1 "Nothing to do yet. Incrementing timer."
		incrementTimer
	else
		getAndWriteSoc
	fi
fi


 # manual calculation enabled, combining PSA module with manual calc method
 
# if charging started this round fetch once from myOpel out of order
	
if (( ladungaktiv == 1 )) && [[ "$RAMDISKDIR/$ladungaktivvn" -nt "$RAMDISKDIR/$manualSocvn" ]]; then
		socLog   0 "Ladestatus changed to laden. trigger Fetching SoC."
		soctimer=0
		putrvar $soctimervn 0
		getAndWriteSoc
		putrvar $manualSocvn $soc
		socLog 0 "Fetched from Skoda: $soc%"
fi

if (( ladungaktiv ==  1 )) ; then
# Laden aktive, summieren

	# read current meter
	currentMeter=$(getrvar $metervn "")
	socLog 1 "currentMeter: $currentMeter"
	
	if [[ "$currentMeter" != "" ]] ; then
	
		# read manual Soc
		if [[ -f "$RAMDISKDIR/$manualSocvn" ]]; then
			manualSoc=$(getrvar $manualSocvn 0)
		else
			# set manualSoc to 0 as a starting point
			manualSoc=0
			putrvar $manualSocvn $manualSoc  
		fi
	    socLog 1 " manual SoC: $manualSoc"

		# read manualMeterFile if file exists and manualMeterFile is newer than manualSocFile
		if  [[ -f "$RAMDISKDIR/$manualMetervn" ]] && [[ "$RAMDISKDIR/$manualMetervn" -nt "$RAMDISKDIR/$manualSocvn" ]]; then
			manualMeter=$(getrvar $manualMetervn 0)
		else
			# manualMeterFile does not exist or is outdated
			# update manualMeter with currentMeter
			manualMeter=$currentMeter
			putrvar $manualMetervn $manualMeter
		fi
		socLog 1 "manualMeter: $manualMeter"

		# read current soc
		currentSoc=$(getrvar $socvn $manualSoc)
		putrvar $socvn $currentSoc
		socLog 1 "currentSoc: $currentSoc"

		# calculate newSoc
		currMeterDiff=$(echo "scale=5;$currentMeter - $manualMeter" | bc)
		currEffectiveMeterDiff=$(echo "scale=5;$currMeterDiff * $efficiency / 100" | bc)
		currSocDiff=$(echo "scale=5;100 / $akkug * $currEffectiveMeterDiff" | bc | sed 's/\..*$//')
		if [[ "$currSocDiff" == "" ]] ; then
		  currSocDiff=0
		fi
		socLog 1 " currMeterDiff: $currMeterDiff"
		socLog 1 " currEffectiveMeterDiff: $currEffectiveMeterDiff (Eff:$efficiency % Akku:$akkug KW)"
		socLog 1 " currSocDiff: $currSocDiff"
				
		newSoc=$(echo "$manualSoc + $currSocDiff" | bc)
		if (( newSoc > 100 )); then
			socLog "newSoC above 100, setting to 100."
			newSoc=100
		fi
		if (( newSoc < 0 )); then
			socLog "newSoC below 100, setting to 0."
			newSoc=0
		fi
		socLog 1 "newSoc: $newSoc"
		putrvar $socvn $newSoc
	else
		# no current meter value for calculation -> Exit
		socLog 0 "ERROR: no meter value for calculation! ($metervn)"
	fi
fi
