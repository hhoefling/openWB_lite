#!/bin/bash
# Low Level driver.
# update Haredware to new State
#
# called only from u1p3p.sh
#
# Para 1 | 3 | stop | start | startslow
# 
#
# change to 1 phases
if [[ "$1" == "1" ]]; then
	# chargepoint 1
	if [[ $evsecon == "modbusevse" ]]; then
		openwbDebugLog "MAIN" 0 "Pause nach Umschaltung: ${u1p3ppause}s"
		sudo python runs/trigopen.py -d $u1p3ppause -c 1
	fi
	if [[ $evsecon == "ipevse" ]]; then 	## Alter Satellit ohne Pi3
		sudo python runs/u1p3premote.py -a $evseiplp1 -i $u1p3plp2id -p 1 -d $u1p3ppause
	fi
	if [[ $evsecon == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep1ip -m "1"
	fi
	if [[ $evsecon == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=1" $owbpro1ip/connect.php
	fi
	# chargepoint 2
	if [[ $lastmanagement == 1 && $evsecons1 == "modbusevse" && $u1p3plp2aktiv == "1" ]]; then
		openwbDebugLog "MAIN" 0 "Pause nach Umschaltung: ${u1p3ppause}s"
		sudo python runs/trigopen.py -d $u1p3ppause -c 2
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "ipevse" && $u1p3plp2aktiv == "1" ]]; then
		sudo python runs/u1p3premote.py -a $evseiplp2 -i $u1p3plp2id -p 1 -d $u1p3ppause
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep2ip -m "1"
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=1" $owbpro2ip/connect.php
	fi

	# chargepoint 3
	if [[ $lastmanagements2 == 1 && $evsecons2 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep3ip -m "1"
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=1" $owbpro3ip/connect.php
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "ipevse" && $u1p3plp3aktiv == "1" ]]; then
		sudo python runs/u1p3premote.py -a $evseiplp3 -i $u1p3plp3id -p 1 -d $u1p3ppause
	fi

# lp4-lp8

#  done
	echo 1 > ramdisk/u1p3pstat
fi

# change to 3 phases
if [[ "$1" == "3" ]]; then
	if [[ $evsecon == "modbusevse" ]]; then
		openwbDebugLog "MAIN" 0 "Pause nach Umschaltung: ${u1p3ppause}s"
		sudo python runs/trigclose.py -d $u1p3ppause -c 1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "modbusevse" && $u1p3plp2aktiv == "1" ]]; then
		openwbDebugLog "MAIN" 0 "Pause nach Umschaltung: ${u1p3ppause}s"
		sudo python runs/trigclose.py -d $u1p3ppause -c 2
	fi
	if [[ $evsecon == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep1ip -m "3"
	fi
	if [[ $evsecon == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=3" $owbpro1ip/connect.php
	fi

	if [[ $lastmanagement == 1 && $evsecons1 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep2ip -m "3"
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=3" $owbpro2ip/connect.php
	fi

	if [[ $lastmanagements2 == 1 && $evsecons2 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/U1p3p -h $chargep3ip -m "3"
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "owbpro" ]]; then
		curl -s -X POST --data "phasetarget=3" $owbpro3ip/connect.php
	fi

# lp4-lp8

	if [[ $evsecon == "ipevse" ]]; then	## Alter Satellit ohne Pi3
		sudo python runs/u1p3premote.py -a $evseiplp1 -i $u1p3plp2id -p 3 -d $u1p3ppause
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "ipevse" && $u1p3plp2aktiv == "1" ]]; then
		sudo python runs/u1p3premote.py -a $evseiplp2 -i $u1p3plp2id -p 3 -d $u1p3ppause
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "ipevse" && $u1p3plp3aktiv == "1" ]]; then
		sudo python runs/u1p3premote.py -a $evseiplp3 -i $u1p3plp3id -p 3 -d $u1p3ppause
	fi
# lp4-lp8

# Done	
	echo 3 > ramdisk/u1p3pstat
fi

if [[ "$1" == "stop" ]]; then
	if [[ $evsecon == "modbusevse" ]]; then
		oldll=$(<ramdisk/llsoll)
		echo $oldll > ramdisk/tmpllsoll
		runs/set-current.sh 0 m
	fi
	if [[ $evsecon == "daemon" ]]; then
		oldll=$(<ramdisk/llsoll)
		echo $oldll > ramdisk/tmpllsoll
		runs/set-current.sh 0 m
	fi
	if [[ $evsecon == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep1ip -m "0"
		oldll=$(<ramdisk/llsoll)
		echo $oldll > ramdisk/tmpllsoll
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "daemon" ]]; then
		oldlls1=$(<ramdisk/llsolls1)
		echo $oldlls1 > ramdisk/tmpllsolls1
		runs/set-current.sh 0 s1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "extopenwb" ]]; then
		oldlls1=$(<ramdisk/llsolls1)
		echo $oldlls1 > ramdisk/tmpllsolls1
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep2ip -m "0"
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "extopenwb" ]]; then
		oldlls2=$(<ramdisk/llsolls2)
		echo $oldlls2 > ramdisk/tmpllsolls2
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep3ip -m "0"
	fi
# lp4-lp8

	if [[ $evsecon == "ipevse" ]]; then ## Alter Satellit ohne Pi3
		oldll=$(<ramdisk/llsoll)
		echo $oldll > ramdisk/tmpllsoll
		runs/set-current.sh 0 m
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "modbusevse" && $u1p3plp2aktiv == "1" ]]; then
		oldlls1=$(<ramdisk/llsolls1)
		echo $oldlls1 > ramdisk/tmpllsolls1
		runs/set-current.sh 0 s1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "ipevse" && $u1p3plp2aktiv == "1" ]]; then
		oldlls1=$(<ramdisk/llsolls1)
		echo $oldlls1 > ramdisk/tmpllsolls1
		runs/set-current.sh 0 s1
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "ipevse" && $u1p3plp3aktiv == "1" ]]; then
		oldlls2=$(<ramdisk/llsolls2)
		echo $oldlls2 > ramdisk/tmpllsolls2
		runs/set-current.sh 0 s2
	fi
# lp4-lp8

fi

if [[ "$1" == "start" ]]; then
	if [[ $evsecon == "modbusevse" ]]; then
		oldll=$(<ramdisk/tmpllsoll)
		runs/set-current.sh $oldll m
	fi
	if [[ $evsecon == "daemon" ]]; then
		oldll=$(<ramdisk/tmpllsoll)
		runs/set-current.sh $oldll m
	fi

	if [[ $evsecon == "ipevse" ]]; then ## Alter Satellit ohne Pi3
		oldll=$(<ramdisk/tmpllsoll)
		runs/set-current.sh $oldll m
	fi
	if [[ $evsecon == "extopenwb" ]]; then
		oldll=$(<ramdisk/tmpllsoll)
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep1ip -m "$oldll"
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "extopenwb" ]]; then
		oldlls1=$(<ramdisk/tmpllsolls1)
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep2ip -m "$oldlls1"
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "extopenwb" ]]; then
		oldlls2=$(<ramdisk/tmpllsolls2)
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep3ip -m "$oldlls1"
	fi
# lp4-lp8

	if [[ $lastmanagement == 1 && $evsecons1 == "modbusevse" && $u1p3plp2aktiv == "1" ]]; then
		oldlls1=$(<ramdisk/tmpllsolls1)
		runs/set-current.sh $oldlls1 s1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "daemon" && $u1p3plp2aktiv == "1" ]]; then
		oldlls1=$(<ramdisk/tmpllsolls1)
		runs/set-current.sh $oldlls1 s1
	fi

	if [[ $lastmanagement == 1 && $evsecons1 == "ipevse" && $u1p3plp2aktiv == "1" ]]; then
		oldlls1=$(<ramdisk/tmpllsolls1)
		runs/set-current.sh $oldlls1 s1
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "ipevse" && $u1p3plp3aktiv == "1" ]]; then
		oldlls2=$(<ramdisk/tmpllsolls2)
		runs/set-current.sh $oldlls2 s2
	fi
# lp4-lp8

fi

if [[ "$1" == "startslow" ]]; then
	if [[ $evsecon == "modbusevse" ]]; then
		runs/set-current.sh $minimalapv m
	fi
	if [[ $evsecon == "daemon" ]]; then
		runs/set-current.sh $minimalapv m
	fi
	if [[ $evsecon == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep1ip -m "$minimalapv"
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep2ip -m "$minimalapv"
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "extopenwb" ]]; then
		mosquitto_pub -r -t openWB/set/isss/Current -h $chargep3ip -m "$minimalapv"
	fi
# lp4-lp8
	if [[ $evsecon == "ipevse" ]]; then ## Alter Satellit ohne Pi3
		runs/set-current.sh $minimalapv m
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "modbusevse" && $u1p3plp2aktiv == "1" ]]; then
		runs/set-current.sh $minimalapv s1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "daemon" && $u1p3plp2aktiv == "1" ]]; then
		runs/set-current.sh $minimalapv s1
	fi
	if [[ $lastmanagement == 1 && $evsecons1 == "ipevse" && $u1p3plp2aktiv == "1" ]]; then
		runs/set-current.sh $minimalapv s1
	fi
	if [[ $lastmanagements2 == 1 && $evsecons2 == "ipevse" && $u1p3plp3aktiv == "1" ]]; then
		runs/set-current.sh $minimalapv s2
	fi
# lp4-lp8
fi
