#!/bin/bash

# Allow 3 minutes between RFID scan and plugin - else the CP gets disabled again
declare -r MaximumSecondsAfterRfidScanToAssignCp=180
#declare -r SocketActivationFile="ramdisk/socketActivationRequested"

# lastmanagement == 1 means that it's on openWB duo
if (( lastmanagement > 0 )); then
	declare -r InstalledChargePoints=2
else
	declare -r InstalledChargePoints=1
fi

declare -r StartScanDataLocation="web/logging/data/startRfidScanData"

#
# the main script that is called from outside world
rfid() {

	NowItIs=$(date +%s)

	setLpPlugChangeState

	lasttag=$(<"ramdisk/readtag")

	if [[ $lasttag != "0" ]]; then
		if [ "$lasttag" == "$rfidlp1c1" ] || [ "$lasttag" == "$rfidlp1c2" ]  || [ "$lasttag" == "$rfidlp1c3" ] ; then
			echo "${lasttag},${NowItIs}" > ramdisk/rfidlp1
		fi
		if [ "$lasttag" == "$rfidlp2c1" ] || [ "$lasttag" == "$rfidlp2c2" ]  || [ "$lasttag" == "$rfidlp2c3" ] ; then
			echo "${lasttag},${NowItIs}" > ramdisk/rfidlp2
		fi
		if [ "$lasttag" == "$rfidstop" ] || [ "$lasttag" == "$rfidstop2" ] || [ "$lasttag" == "$rfidstop3" ] ; then
			echo $STOP3 > ramdisk/lademodus
		fi

		if [ "$lasttag" == "$rfidsofort" ] || [ "$lasttag" == "$rfidsofort2" ] || [ "$lasttag" == "$rfidsofort3" ]  ; then
			echo $SOFORT0 > ramdisk/lademodus
		fi

		if [ "$lasttag" == "$rfidminpv" ] || [ "$lasttag" == "$rfidminpv2" ] || [ "$lasttag" == "$rfidminpv3" ]  ; then
			echo $MINPV1 > ramdisk/lademodus
		fi

		if [ "$lasttag" == "$rfidnurpv" ] || [ "$lasttag" == "$rfidnurpv2" ] || [ "$lasttag" == "$rfidnurpv3" ]   ; then
			echo $NURPV2 > ramdisk/lademodus
		fi

		if [ "$lasttag" == "$rfidstandby" ] || [ "$lasttag" == "$rfidstandby2" ] || [ "$lasttag" == "$rfidstandby3" ] ; then
			echo $STANDBY4 > ramdisk/lademodus
		fi
		if [ "$lasttag" == "$rfidlp1start1" ] || [ "$lasttag" == "$rfidlp1start2" ] || [ "$lasttag" == "$rfidlp1start3" ] || [ "$lasttag" == "$rfidlp1start4" ] || [ "$lasttag" == "$rfidlp1start5" ]; then
			mosquitto_pub -r -t openWB/set/lp/1/ChargePointEnabled -m "1"
			lp1enabled=1
			tagScanInfo="$NowItIs,$lasttag,1"
			echo "$tagScanInfo" > "ramdisk/tagScanInfoLp1"
			mosquitto_pub -r -q 2 -t "openWB/lp/1/tagScanInfo" -m "$tagScanInfo"
		fi
		if [ "$lasttag" == "$rfidlp2start1" ] || [ "$lasttag" == "$rfidlp2start2" ] || [ "$lasttag" == "$rfidlp2start3" ] || [ "$lasttag" == "$rfidlp2start4" ] || [ "$lasttag" == "$rfidlp2start5" ]; then
			mosquitto_pub -r -t openWB/set/lp/2/ChargePointEnabled -m "1"
			lp2enabled=1
			tagScanInfo="$NowItIs,$lasttag,1"
			echo "$tagScanInfo" > "ramdisk/tagScanInfoLp2"
			mosquitto_pub -r -q 2 -t "openWB/lp/2/tagScanInfo" -m "$tagScanInfo"
		fi

		# check all CPs that we support for whether the tag is valid for that CP
		for ((currentCp=1; currentCp<=InstalledChargePoints; currentCp++)); do
			checkTagValidAndSetStartScanData "$currentCp"
		done

		echo "${lasttag},${NowItIs}" > "ramdisk/rfidlasttag"
		openwbDebugLog "RFID" 0 "${lasttag},${NowItIs}"
		echo 0 > "ramdisk/readtag"
	fi

	#
	# handle special behaviour for slave mode, yourCharge deletet
	#
}




# determine if any of LP1 or LP2 has just been plugged in
# if it has, pluggedLp will be set to the CP number (1 or 2).
# if it has NOT, pluggedLp will be set to 0
setLpPlugChangeState() {

  set +u

	if [ ! -f "ramdisk/accPlugstatChangeDetectLp1" ]; then
		echo "$plugstat" > "ramdisk/accPlugstatChangeDetectLp1"
	fi
	local oplugstat
	oplugstat=$(<"ramdisk/accPlugstatChangeDetectLp1")

	if [ ! -f "ramdisk/accPlugstatChangeDetectLp2" ]; then
		echo "$plugstats1" > "ramdisk/accPlugstatChangeDetectLp2"
	fi
	local oplugstats1
	oplugstats1=$(<"ramdisk/accPlugstatChangeDetectLp2")

	pluggedLp=0

	getCpPlugstat 1
	local plugstatToUse1=$?
	getCpPlugstat 2
	local plugstatToUse2=$?

	lpsPlugStat=(0 "$plugstatToUse1" "$plugstatToUse2")
	unpluggedLps=(0 0 0)
	pluggedLps=(0 0 0)

	# first check LP2 as the last one will win for plugin and it seems more logical to let LP1 win
	if [ -n "$plugstats1" ]; then
		if (( lpsPlugStat[2] == oplugstats1 )); then
			:
		elif (( lpsPlugStat[2] == 1 )) && (( oplugstats1 == 0 )); then
			openwbDebugLog "MAIN" 0 "LP 2 plugged in"
			pluggedLp=2
			pluggedLps[2]=1
		elif (( lpsPlugStat[2] == 0 )) && (( oplugstats1 == 1 )); then
			openwbDebugLog "MAIN" 0 "LP 2 un-plugged"
			unpluggedLps[2]=1
		else
			openwbDebugLog "MAIN" 0 "LP 2 unkown plug state '${lpsPlugStat[2]}'"
		fi

		echo "${lpsPlugStat[2]}" > "ramdisk/accPlugstatChangeDetectLp2"
	fi

	# finally check LP1 so it wins
	if [ -n "$plugstat" ]; then
		if (( lpsPlugStat[1] == oplugstat )); then
			:
		elif (( lpsPlugStat[1] == 1 )) && (( oplugstat == 0 )); then
			openwbDebugLog "MAIN" 0 "LP 1 plugged in"
			pluggedLp=1
			pluggedLps[1]=1
		elif (( lpsPlugStat[1] == 0 )) && (( oplugstat == 1 )); then
			openwbDebugLog "MAIN" 0 "LP 1 un-plugged"
			unpluggedLps[1]=1
		else
			openwbDebugLog "MAIN" 0 "LP 1 unkown plug state '${lpsPlugStat[1]}'"
		fi

		echo "${lpsPlugStat[1]}" > "ramdisk/accPlugstatChangeDetectLp1"
	fi

  set -u
}


# checks if the tag stored in $lasttag is valid for the charge point passed in $1
checkTagValidAndSetStartScanData() {

	local chargePoint=$1

	# if we're in slave mode on an openWB dual and the LP has not just been plugged in (in same control interval as the RFID scan)
	# we completely ignore the scan as we cannot associate it with a plugin operation

# YourCharge delete

	local ramdiskFileForCp="ramdisk/AllowedRfidsForLp${chargePoint}"
	if [ ! -f "$ramdiskFileForCp" ]; then
		return 1
	fi

	local rfidlist
	rfidlist=$(<"$ramdiskFileForCp")
	openwbDebugLog "MAIN" 2 "rfidlist(LP${chargePoint})='${rfidlist}'"

	# leave right away if we have no list of valid RFID tags for the charge point
	if [ -z "$rfidlist" ]; then
		openwbDebugLog "MAIN" 0 "Empty 'allowed tags list' for CP #${chargePoint} after scan of tag '${lasttag}'"
		return 1
	fi

	for i in ${rfidlist//,/ }
	do
		if [ "$lasttag" == "$i" ] ; then

			# found valid RFID tag for the charge point
			# write at-scan accounting info
			echo "$NowItIs,$lasttag,$llkwh" > "${StartScanDataLocation}"

			# and the ramdisk file for legacy ladelog
			echo "$lasttag" > "ramdisk/rfidlp${chargePoint}"
			local tagScanInfo="$NowItIs,$lasttag,1"
			echo "$tagScanInfo" > "ramdisk/tagScanInfoLp${chargePoint}"
			mosquitto_pub -r -q 2 -t "openWB/lp/${chargePoint}/tagScanInfo" -m "$tagScanInfo"
			mosquitto_pub -r -q 2 -t "openWB/set/lp/${chargePoint}/ChargePointEnabled" -m "1"

			eval lp${chargePoint}enabled=1
			openwbDebugLog "MAIN" 0 "Start waiting for ${MaximumSecondsAfterRfidScanToAssignCp} seconds for CP #${chargePoint} to get plugged in after RFID scan of '$lasttag' @ meter value $llkwh (justPlugged == ${pluggedLps[$chargePoint]})"

			# explicitly and immediately disable the socket
            # YourCharge
			# echo 2 > $SocketActivationFile

			return 0
		fi
	done

	openwbDebugLog "MAIN" 0 "RFID tag '${lasttag}' is not authorized to enable this CP"

	local tagScanInfo="$NowItIs,$lasttag,0"
	echo "$tagScanInfo" > "ramdisk/tagScanInfoLp${chargePoint}"
	mosquitto_pub -r -q 2 -t "openWB/lp/${chargePoint}/tagScanInfo" -m "$tagScanInfo"

	return 1
}

# returns the plugstat value for the given CP as exit code
getCpPlugstat() {

	local chargePoint=$1
	local returnstat=255

	if (( chargePoint == 1 )); then
		returnstat=$plugstat
	elif (( chargePoint == 2 )); then
		returnstat=$plugstats1
	else
		openwbDebugLog "MAIN" 0 "Don't know how to get plugged status of CP #${chargePoint}. Returning 255"
		returnstat=255
	fi

	# heal cases where $plugstat contains garbage
	if [ -z "${returnstat}" ]; then
		returnstat=255
	fi

	return $returnstat
}


# returns the chargestat value for the given CP as exit code
getCpChargestat() {

	local chargePoint=$1
	local returnstat=255

	if (( chargePoint == 1 )); then
		returnstat=$chargestat
	elif (( chargePoint == 2 )); then
		returnstat=$chargestats1
	else
		openwbDebugLog "MAIN" 0 "Don't know how to get chage status of CP #${chargePoint}. Returning 255"
		returnstat=255
	fi

	# heal cases where $chargestat contains garbage
	if [ -z "${returnstat}" ]; then
		returnstat=255
	fi

	return $returnstat
}
