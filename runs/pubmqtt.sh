#!/bin/bash
# Alle Werte aus ENV ?bergeben
# Asyncron gestartet am Ende von loadvars.sh und slavemode.sh 

declare -A mqttvar
mqttvar["system/IpAddress"]=ipaddress
mqttvar["system/ConfiguredChargePoints"]=ConfiguredChargePoints
mqttvar["evu/APhase1"]=bezuga1
mqttvar["evu/APhase2"]=bezuga2
mqttvar["evu/APhase3"]=bezuga3
mqttvar["evu/VPhase1"]=evuv1
mqttvar["evu/VPhase2"]=evuv2
mqttvar["evu/VPhase3"]=evuv3
mqttvar["evu/Hz"]=evuhz
mqttvar["evu/PfPhase1"]=evupf1
mqttvar["evu/PfPhase2"]=evupf2
mqttvar["evu/PfPhase3"]=evupf3
mqttvar["lp/1/ChargeStatus"]=ladestatus
mqttvar["lp/2/ChargeStatus"]=ladestatuss1
mqttvar["lp/3/ChargeStatus"]=ladestatuss2
mqttvar["lp/2/VPhase1"]=llvs11
mqttvar["lp/2/VPhase2"]=llvs12
mqttvar["lp/2/VPhase3"]=llvs13
mqttvar["lp/1/VPhase1"]=llv1
mqttvar["lp/1/VPhase2"]=llv2
mqttvar["lp/1/VPhase3"]=llv3
mqttvar["lp/3/VPhase1"]=llvs21
mqttvar["lp/3/VPhase2"]=llvs22
mqttvar["lp/3/VPhase3"]=llvs23
mqttvar["lp/2/APhase1"]=llas11
mqttvar["lp/2/APhase2"]=llas12
mqttvar["lp/2/APhase3"]=llas13
mqttvar["lp/3/APhase1"]=llas21
mqttvar["lp/3/APhase2"]=llas22
mqttvar["lp/3/APhase3"]=llas23
mqttvar["lp/1/APhase1"]=lla1
mqttvar["lp/1/APhase2"]=lla2
mqttvar["lp/1/APhase3"]=lla3
mqttvar["global/kWhCounterAllChargePoints"]=llkwhges
mqttvar["lp/1/kWhCounter"]=llkwh
mqttvar["lp/2/kWhCounter"]=llkwhs1
mqttvar["lp/3/kWhCounter"]=llkwhs2
mqttvar["Verbraucher/1/Watt"]=verbraucher1_watt
mqttvar["Verbraucher/1/WhImported"]=verbraucher1_wh
mqttvar["Verbraucher/1/WhExported"]=verbraucher1_whe
mqttvar["Verbraucher/1/DailyYieldImportkWh"]=daily_verbraucher1ikwh
mqttvar["Verbraucher/1/DailyYieldExportkWh"]=daily_verbraucher1ekwh
mqttvar["Verbraucher/2/Watt"]=verbraucher2_watt
mqttvar["Verbraucher/2/WhImported"]=verbraucher2_wh
mqttvar["Verbraucher/2/WhExported"]=verbraucher2_whe
mqttvar["Verbraucher/2/DailyYieldImportkWh"]=daily_verbraucher2ikwh
mqttvar["Verbraucher/2/DailyYieldExportkWh"]=daily_verbraucher2ekwh
mqttvar["evu/WhExported"]=einspeisungkwh
mqttvar["evu/WhImported"]=bezugkwh
mqttvar["housebattery/WhExported"]=speicherekwh
mqttvar["housebattery/WhImported"]=speicherikwh
mqttvar["lp/1/MeterSerialNumber"]=lp1Serial
mqttvar["lp/1/PfPhase1"]=llpf1
mqttvar["lp/1/PfPhase2"]=llpf2
mqttvar["lp/1/PfPhase3"]=llpf3
mqttvar["lp/1/ChargePointEnabled"]=lp1enabled
mqttvar["lp/2/ChargePointEnabled"]=lp2enabled
mqttvar["lp/3/ChargePointEnabled"]=lp3enabled
mqttvar["evu/WAverage"]=glattwattbezug
mqttvar["global/strLastmanagementActive"]=lastregelungaktiv
mqttvar["evu/ASchieflast"]=schieflast
mqttvar["evu/WPhase1"]=bezugw1
mqttvar["evu/WPhase2"]=bezugw2
mqttvar["evu/WPhase3"]=bezugw3
mqttvar["lp/1/AConfigured"]=llsoll
mqttvar["lp/2/AConfigured"]=llsolls1
mqttvar["lp/3/AConfigured"]=llsolls2
mqttvar["lp/1/kWhActualCharged"]=aktgeladen
mqttvar["lp/2/kWhActualCharged"]=aktgeladens1
mqttvar["lp/3/kWhActualCharged"]=aktgeladens2
mqttvar["lp/1/boolPlugStat"]=plugstat
mqttvar["lp/2/boolPlugStat"]=plugstats1
mqttvar["lp/3/boolPlugStat"]=plugstatlp3
mqttvar["lp/1/boolChargeStat"]=chargestat
mqttvar["lp/2/boolChargeStat"]=chargestats1
mqttvar["lp/3/boolChargeStat"]=chargestatlp3
mqttvar["lp/1/kWhChargedSincePlugged"]=pluggedladungbishergeladen
mqttvar["lp/2/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp2
mqttvar["lp/3/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp3
mqttvar["lp/1/AutolockStatus"]=autolockstatuslp1
mqttvar["lp/2/AutolockStatus"]=autolockstatuslp2
mqttvar["lp/3/AutolockStatus"]=autolockstatuslp3
mqttvar["lp/1/AutolockConfigured"]=autolockconfiguredlp1
mqttvar["lp/2/AutolockConfigured"]=autolockconfiguredlp2
mqttvar["lp/3/AutolockConfigured"]=autolockconfiguredlp3
mqttvar["pv/CounterTillStartPvCharging"]=pvcounter
mqttvar["pv/bool70PVDynStatus"]=nurpv70dynstatus
mqttvar["pv/WhCounter"]=pvallwh
mqttvar["pv/DailyYieldKwh"]=daily_pvkwhk
mqttvar["pv/MonthlyYieldKwh"]=monthly_pvkwhk
mqttvar["pv/YearlyYieldKwh"]=yearly_pvkwhk
mqttvar["pv/1/W"]=pv1watt
mqttvar["pv/1/WhCounter"]=pvkwh
mqttvar["pv/1/DailyYieldKwh"]=daily_pvkwhk1
mqttvar["pv/1/MonthlyYieldKwh"]=monthly_pvkwhk1
mqttvar["pv/1/YearlyYieldKwh"]=yearly_pvkwhk1
mqttvar["pv/2/W"]=pv2watt
mqttvar["pv/2/WhCounter"]=pv2kwh
mqttvar["pv/2/DailyYieldKwh"]=daily_pvkwhk2
mqttvar["pv/2/MonthlyYieldKwh"]=monthly_pvkwhk2
mqttvar["pv/2/YearlyYieldKwh"]=yearly_pvkwhk2
mqttvar["evu/DailyYieldImportKwh"]=daily_bezugkwh
mqttvar["evu/DailyYieldExportKwh"]=daily_einspeisungkwh
mqttvar["global/DailyYieldAllChargePointsKwh"]=daily_llakwh
mqttvar["global/DailyYieldHausverbrauchKwh"]=daily_hausverbrauchkwh
mqttvar["housebattery/DailyYieldImportKwh"]=daily_sikwh
mqttvar["housebattery/DailyYieldExportKwh"]=daily_sekwh
mqttvar["SmartHome/Devices/1/DailyYieldKwh"]=daily_d1kwh
mqttvar["SmartHome/Devices/2/DailyYieldKwh"]=daily_d2kwh
mqttvar["SmartHome/Devices/3/DailyYieldKwh"]=daily_d3kwh
mqttvar["SmartHome/Devices/4/DailyYieldKwh"]=daily_d4kwh
mqttvar["SmartHome/Devices/5/DailyYieldKwh"]=daily_d5kwh
mqttvar["SmartHome/Devices/6/DailyYieldKwh"]=daily_d6kwh
mqttvar["SmartHome/Devices/7/DailyYieldKwh"]=daily_d7kwh
mqttvar["SmartHome/Devices/8/DailyYieldKwh"]=daily_d8kwh
mqttvar["SmartHome/Devices/9/DailyYieldKwh"]=daily_d9kwh
mqttvar["global/boolRse"]=rsestatus
mqttvar["hook/1/boolHookStatus"]=hook1akt
mqttvar["hook/2/boolHookStatus"]=hook2akt
mqttvar["hook/3/boolHookStatus"]=hook3akt
mqttvar["lp/1/countPhasesInUse"]=lp1phasen
mqttvar["lp/2/countPhasesInUse"]=lp2phasen
mqttvar["lp/3/countPhasesInUse"]=lp3phasen
mqttvar["config/get/sofort/lp/1/current"]=lp1sofortll
mqttvar["config/get/sofort/lp/2/current"]=lp2sofortll
mqttvar["config/get/sofort/lp/3/current"]=lp3sofortll
mqttvar["config/get/SmartHome/Devices/1/mode"]=smarthome_device_manual_1
mqttvar["config/get/SmartHome/Devices/2/mode"]=smarthome_device_manual_2
mqttvar["config/get/SmartHome/Devices/3/mode"]=smarthome_device_manual_3
mqttvar["config/get/SmartHome/Devices/4/mode"]=smarthome_device_manual_4
mqttvar["config/get/SmartHome/Devices/5/mode"]=smarthome_device_manual_5
mqttvar["config/get/SmartHome/Devices/6/mode"]=smarthome_device_manual_6
mqttvar["config/get/SmartHome/Devices/7/mode"]=smarthome_device_manual_7
mqttvar["config/get/SmartHome/Devices/8/mode"]=smarthome_device_manual_8
mqttvar["config/get/SmartHome/Devices/9/mode"]=smarthome_device_manual_9
mqttvar["system/CommitHash"]=currentCommitHash
mqttvar["system/CommitBranches"]=currentCommitBranches

if [[ "$standardSocketInstalled" == "1" ]]; then
	mqttvar["config/get/slave/SocketActivated"]=socketActivated
	mqttvar["config/get/slave/SocketRequested"]=socketActivationRequested
	mqttvar["config/get/slave/SocketApproved"]=socketApproved
	mqttvar["socket/A"]=socketa
	mqttvar["socket/V"]=socketv
	mqttvar["socket/W"]=socketp
	mqttvar["socket/kWhCounter"]=socketkwh
	mqttvar["socket/Pf"]=socketpf
	mqttvar["socket/MeterSerialNumber"]=socketSerial
fi

#for i in $(seq 1 8);
for i in $(seq 1 3);
do
	for f in \
		"lp/${i}/plugStartkWh:pluggedladunglp${i}startkwh" \
		"lp/${i}/pluggedladungakt:pluggedladungaktlp${i}" \
		"lp/${i}/lmStatus:lmStatusLp${i}" \
		"lp/${i}/tagScanInfo:tagScanInfoLp${i}"
	do
		IFS=':' read -r -a tuple <<< "$f"
		#echo "Setting mqttvar[${tuple[0]}]=${tuple[1]}"
		mqttvar["${tuple[0]}"]=${tuple[1]}
	done
done


timestamp="$(date +%s)"
tempPubList="openWB/system/Date=$(date)"
tempPubList="${tempPubList}\nopenWB/system/Timestamp=${timestamp}"

[ -f  /sys/class/thermal/thermal_zone0/temp ] &&  tempPubList="${tempPubList}\nopenWB/global/cpuTemp=$(echo "scale=2; `cat /sys/class/thermal/thermal_zone0/temp` / 1000" | bc)"

for mq in "${!mqttvar[@]}"; do
	declare o${mqttvar[$mq]}
	declare ${mqttvar[$mq]}
	tempnewname=${mqttvar[$mq]}
	tempoldname=o${mqttvar[$mq]}

	if [ -r ramdisk/"${mqttvar[$mq]}" ]; then

		tempnewname=$(<ramdisk/"${mqttvar[$mq]}")

		if [ -r ramdisk/mqtt"${mqttvar[$mq]}" ]; then
			tempoldname=$(<ramdisk/mqtt"${mqttvar[$mq]}")
		else
			tempoldname=""
		fi

		if [[ "$tempoldname" != "$tempnewname" ]]; then
			tempPubList="${tempPubList}\nopenWB/${mq}=${tempnewname}"
			echo $tempnewname > ramdisk/mqtt${mqttvar[$mq]}
		fi
		#echo ${mqttvar[$mq]} $mq
	fi
done

# macht cron5Min alle 5 Minuten
#sysinfo=$(cd web/tools; sudo php programmloggerinfo.php 2>/dev/null)
#tempPubList="${tempPubList}\nopenWB/global/cpuModel=$(cat /proc/cpuinfo | grep -m 1 "model name" | sed "s/^.*: //")"
#tempPubList="${tempPubList}\nopenWB/global/cpuUse=$(echo ${sysinfo} | jq -r '.cpuuse')"
#tempPubList="${tempPubList}\nopenWB/global/cpuTemp=$(echo "scale=2; $(echo ${sysinfo} | jq -r '.cputemp') / 1000" | bc)"
#tempPubList="${tempPubList}\nopenWB/global/cpuFreq=$(($(echo ${sysinfo} | jq -r '.cpufreq') / 1000))"
#tempPubList="${tempPubList}\nopenWB/global/memTotal=$(echo ${sysinfo} | jq -r '.memtot')"
#tempPubList="${tempPubList}\nopenWB/global/memUse=$(echo ${sysinfo} | jq -r '.memuse')"
#tempPubList="${tempPubList}\nopenWB/global/memFree=$(echo ${sysinfo} | jq -r '.memfree')"
#tempPubList="${tempPubList}\nopenWB/global/diskUse=$(echo ${sysinfo} | jq -r '.diskuse')"
#tempPubList="${tempPubList}\nopenWB/global/diskFree=$(echo ${sysinfo} | jq -r '.diskfree')"


if [[ $debug == "2" ]]; then	
	echo "pubmqtt.Publist:"
	echo -e $tempPubList
	#echo "Running Python: runs/mqttpub.py -q 0 -r &"
fi	
echo -e $tempPubList | python3 runs/mqttpub.py -q 0 -r &
