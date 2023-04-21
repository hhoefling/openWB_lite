#!/bin/bash


# Import ladeleistung
# Export None, set new Current to Hardware

 
# If Modue=STOP 
auslademodus(){
	local ladeleistung=${ladeleistung:-0}
	openwbDebugLog "MAIN" 2 "auslademodus: Ladeleistung $ladeleistung"
	if grep -q 1 ramdisk/ladestatus; then
		meld "force stop m"
		runs/set-current.sh 0 m
		openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Stop. Stoppe Ladung"
	fi
	if grep -q 1 "ramdisk/ladestatuss1"; then
		meld "force stop s1"
		runs/set-current.sh 0 s1
		openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Stop. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss2; then
		meld "force stop s2"
		runs/set-current.sh 0 s2
		openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Stop. Stoppe Ladung"
	fi
	if (( ladeleistung > 300 )); then
		meld "force stop m,s1,s2"
		runs/set-current.sh 0 m
		runs/set-current.sh 0 s1
		runs/set-current.sh 0 s2

		openwbDebugLog "CHARGESTAT" 0 "Alle Ladepunkte, Lademodus Stop. Stoppe Ladung"
	fi
	openwbDebugLog "MAIN" 0 "*** EXIT 0 (auslademodus)"
	exit 0
}

# If Mode=STANDBY and no Nacht/Morgen
# Inport - None
# export - None

semiauslademodus(){
	if grep -q 1 ramdisk/ladestatus; then
		meld "stop m"
		runs/set-current.sh 0 m
		openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss1; then
		meld "stop s1"
		runs/set-current.sh 0 s1
		openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss2; then
		meld "stop s2"
		runs/set-current.sh 0 s2
		openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi

	openwbDebugLog "MAIN" 0 "*** EXIT 0 (semiauslademodus)"
	exit 0
}
