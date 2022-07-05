#!/bin/bash

auslademodus(){
	if grep -q 1 ramdisk/ladestatus; then
		runs/set-current.sh 0 m
		openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Stop. Stoppe Ladung"
	fi
	if grep -q 1 "ramdisk/ladestatuss1"; then
		runs/set-current.sh 0 s1
		openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Stop. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss2; then
		runs/set-current.sh 0 s2
		openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Stop. Stoppe Ladung"
	fi
	if (( ladeleistung > 300 )); then
		runs/set-current.sh 0 m
		runs/set-current.sh 0 s1
		runs/set-current.sh 0 s2

		openwbDebugLog "CHARGESTAT" 0 "Alle Ladepunkte, Lademodus Stop. Stoppe Ladung"
	fi
	openwbDebugLog "MAIN" 0 "*** exit 0 (auslademodus)"
	exit 0
}

semiauslademodus(){
	if grep -q 1 ramdisk/ladestatus; then
		runs/set-current.sh 0 m
		openwbDebugLog "CHARGESTAT" 0 "LP1, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss1; then
		runs/set-current.sh 0 s1
		openwbDebugLog "CHARGESTAT" 0 "LP2, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi
	if grep -q 1 ramdisk/ladestatuss2; then
		runs/set-current.sh 0 s2
		openwbDebugLog "CHARGESTAT" 0 "LP3, Lademodus Standby. Ladefreigabe noch aktiv. Stoppe Ladung"
	fi

	openwbDebugLog "MAIN" 0 "*** exit 0"
	exit 0
}
