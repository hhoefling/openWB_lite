#!/bin/bash


# Import ladeleistung
# Export None, set new Current to Hardware

 

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

	openwbDebugLog "MAIN" 0 "*** EXIT 0 "
	exit 0
}

