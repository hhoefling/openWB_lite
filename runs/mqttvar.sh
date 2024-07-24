

export konstant1=1

# mqtttopics die aus der openwb.conf versorgt werten
# 
declare -A mqttconfvar
	
    
# NC mqttconfvar["lp/3/boolDirectChargeModeSocX"]=sofortsocstatlp3



# Neue standorte, war voher alles unter openWB/
mqttconfvar["config/get/global/boolChargeAtNight_direct"]=nlakt_sofort
mqttconfvar["config/get/global/boolChargeAtNight_minpv"]=nlakt_minpv
mqttconfvar["config/get/global/boolChargeAtNight_nurpv"]=nlakt_nurpv
mqttconfvar["config/get/global/boolChargeAtNight_standby"]=nlakt_standby
mqttconfvar["config/get/global/boolDisplayDailyCharged"]=heutegeladen
mqttconfvar["config/get/global/boolDisplayHouseConsumption"]=hausverbrauchstat	# neu
mqttconfvar["config/get/global/boolEvuSmoothedActive"]=evuglaettungakt	# neu


mqttconfvar["config/get/display/chartBatteryMinMax"]=displayspeichermax
mqttconfvar["config/get/display/chartEvuMinMax"]=displayevumax
mqttconfvar["config/get/display/chartHouseConsumptionMax"]=displayhausmax
mqttconfvar["config/get/display/chartLp/1/max"]=displaylp1max
mqttconfvar["config/get/display/chartLp/2/max"]=displaylp2max
mqttconfvar["config/get/display/chartLp/3/max"]=displaylp3max
mqttconfvar["config/get/display/chartPvMax"]=displaypvmax
mqttconfvar["config/get/display/displayLight"]=displayLight
mqttconfvar["config/get/display/displayPinAktiv"]=displaypinaktiv
mqttconfvar["config/get/display/showHouseConsumption"]=displayhausanzeigen
mqttconfvar["config/get/global/dataProtectionAcknoledged"]=datenschutzack
mqttconfvar["config/get/global/maxEVSECurrentAllowed"]=maximalstromstaerke
mqttconfvar["config/get/global/minEVSECurrentAllowed"]=minimalstromstaerke
mqttconfvar["config/get/lp/1/stopchargeafterdisc"]=stopchargeafterdisclp1
mqttconfvar["config/get/lp/2/stopchargeafterdisc"]=stopchargeafterdisclp2
mqttconfvar["config/get/lp/3/stopchargeafterdisc"]=stopchargeafterdisclp3
mqttconfvar["config/get/pv/adaptiveChargingFactor"]=adaptfaktor
mqttconfvar["config/get/pv/batteryDischargePowerAtBattPriority"]=speicherwattnurpv
mqttconfvar["config/get/pv/boolAdaptiveCharging"]=adaptpv
mqttconfvar["config/get/pv/boolShowPriorityIconInTheme"]=speicherpvui
mqttconfvar["config/get/pv/chargeSubmode"]=pvbezugeinspeisung
mqttconfvar["config/get/pv/lp/1/maxSoc"]=stopchargepvpercentagelp1
mqttconfvar["config/get/pv/lp/1/maxSocToChargeTo"]=maxnurpvsoclp1
mqttconfvar["config/get/pv/lp/1/minCurrent"]=minimalapv
mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeTo"]=minnurpvsoclp1
mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeToCurrent"]=minnurpvsocll
mqttconfvar["config/get/pv/lp/1/socLimitation"]=stopchargepvatpercentlp1
mqttconfvar["config/get/pv/lp/2/maxSoc"]=stopchargepvpercentagelp2
mqttconfvar["config/get/pv/lp/2/minCurrent"]=minimalalp2pv
mqttconfvar["config/get/pv/lp/2/socLimitation"]=stopchargepvatpercentlp2
mqttconfvar["config/get/pv/maxPowerConsumptionBeforeStop"]=abschaltuberschuss
mqttconfvar["config/get/pv/minBatteryChargePowerAtEvPriority"]=speichermaxwatt
mqttconfvar["config/get/pv/minBatteryDischargeSocAtBattPriority"]=speichersocnurpv
mqttconfvar["config/get/pv/minCurrentMinPv"]=minimalampv
mqttconfvar["config/get/pv/minFeedinPowerBeforeStart"]=mindestuberschuss
mqttconfvar["config/get/pv/nurpv70dynact"]=nurpv70dynact
mqttconfvar["config/get/pv/nurpv70dynw"]=nurpv70dynw
mqttconfvar["pv/bool70PVDynActive"]=nurpv70dynact   # NC ?
mqttconfvar["pv/W70PVDyn"]=nurpv70dynw              # NC ?
mqttconfvar["config/get/pv/priorityModeEVBattery"]=speicherpveinbeziehen
mqttconfvar["config/get/pv/regulationPoint"]=offsetpv
mqttconfvar["config/get/pv/socStartChargeAtMinPv"]=speichersocminpv
mqttconfvar["config/get/pv/socStopChargeAtMinPv"]=speichersochystminpv
mqttconfvar["config/get/pv/startDelay"]=einschaltverzoegerung
mqttconfvar["config/get/pv/stopDelay"]=abschaltverzoegerun
mqttconfvar["config/get/sofort/lp/1/chargeLimitation"]=msmoduslp1
mqttconfvar["config/get/sofort/lp/2/chargeLimitation"]=msmoduslp2
mqttconfvar["config/get/sofort/lp/3/chargeLimitation"]=msmoduslp3
mqttconfvar["config/get/sofort/lp/1/energyToCharge"]=lademkwh
mqttconfvar["config/get/sofort/lp/2/energyToCharge"]=lademkwhs1
mqttconfvar["config/get/sofort/lp/3/energyToCharge"]=lademkwhs2
mqttconfvar["config/get/sofort/lp/1/socToChargeTo"]=sofortsoclp1
mqttconfvar["config/get/sofort/lp/2/socToChargeTo"]=sofortsoclp2
mqttconfvar["config/get/u1p3p/isConfigured"]=u1p3paktiv
mqttconfvar["config/get/u1p3p/minundpvPhases"]=u1p3pminundpv
mqttconfvar["config/get/u1p3p/nachtPhases"]=u1p3pnl
mqttconfvar["config/get/u1p3p/nurpvPhases"]=u1p3pnurpv
mqttconfvar["config/get/u1p3p/sofortPhases"]=u1p3psofort
mqttconfvar["config/get/u1p3p/standbyPhases"]=u1p3pstandby
mqttconfvar["global/awattar/boolAwattarEnabled"]=etprovideraktiv
mqttconfvar["global/ETProvider/modulePath"]=etprovider
mqttconfvar["global/rfidConfigured"]=rfidakt
mqttconfvar["hook/1/boolHookConfigured"]=hook1_aktiv
mqttconfvar["hook/2/boolHookConfigured"]=hook2_aktiv
mqttconfvar["hook/3/boolHookConfigured"]=hook3_aktiv
mqttconfvar["lp/1/boolChargeAtNight"]=nachtladen
mqttconfvar["lp/2/boolChargeAtNight"]=nachtladens1
mqttconfvar["lp/1/boolChargePointConfigured"]=konstant1
mqttconfvar["lp/2/boolChargePointConfigured"]=lastmanagement
mqttconfvar["lp/3/boolChargePointConfigured"]=lastmanagements2
mqttconfvar["lp/1/boolDirectChargeModeSoc"]=sofortsocstatlp1
mqttconfvar["lp/2/boolDirectChargeModeSoc"]=sofortsocstatlp2
mqttconfvar["lp/1/boolFinishAtTimeChargeActive"]=zielladenaktivlp1
mqttconfvar["lp/1/energyConsumptionPer100km"]=durchslp1
mqttconfvar["lp/2/energyConsumptionPer100km"]=durchslp2
mqttconfvar["lp/3/energyConsumptionPer100km"]=durchslp3
mqttconfvar["lp/1/strChargePointName"]=lp1name
mqttconfvar["lp/2/strChargePointName"]=lp2name
mqttconfvar["lp/3/strChargePointName"]=lp3name
mqttconfvar["lp/1/boolDirectModeChargekWh"]=lademstat
mqttconfvar["lp/2/boolDirectModeChargekWh"]=lademstats1
mqttconfvar["lp/3/boolDirectModeChargekWh"]=lademstats2
mqttconfvar["system/devicename"]=devicename
mqttconfvar["system/debug"]=debug
mqttconfvar["system/priceForKWh"]=preisjekwh
mqttconfvar["system/wizzardDone"]=wizzarddone
mqttconfvar["Verbraucher/1/Configured"]=verbraucher1_aktiv
mqttconfvar["Verbraucher/1/Name"]=verbraucher1_name
mqttconfvar["Verbraucher/2/Configured"]=verbraucher2_aktiv
mqttconfvar["Verbraucher/2/Name"]=verbraucher2_name


declare -A mqttramvar
# Neu, waren vorher auf /
mqttramvar["hook/1/boolHookActive"]=hook1akt
mqttramvar["hook/2/boolHookActive"]=hook2akt
mqttramvar["hook/3/boolHookActive"]=hook3akt

mqttramvar["config/get/sofort/lp/1/current"]=lp1sofortll
mqttramvar["config/get/sofort/lp/2/current"]=lp2sofortll
mqttramvar["config/get/sofort/lp/3/current"]=lp3sofortll
mqttramvar["config/get/SmartHome/Devices/1/mode"]=smarthome_device_manual_1
mqttramvar["config/get/SmartHome/Devices/2/mode"]=smarthome_device_manual_2
mqttramvar["config/get/SmartHome/Devices/3/mode"]=smarthome_device_manual_3
mqttramvar["config/get/SmartHome/Devices/4/mode"]=smarthome_device_manual_4
mqttramvar["config/get/SmartHome/Devices/5/mode"]=smarthome_device_manual_5
mqttramvar["config/get/SmartHome/Devices/6/mode"]=smarthome_device_manual_6
mqttramvar["config/get/SmartHome/Devices/7/mode"]=smarthome_device_manual_7
mqttramvar["config/get/SmartHome/Devices/8/mode"]=smarthome_device_manual_8
mqttramvar["config/get/SmartHome/Devices/9/mode"]=smarthome_device_manual_9

# mqttramvar["ChargeStatus"]=ladestatus   # NC? same als lp/1/ChargeStatus 

mqttramvar["evu/APhase1"]=bezuga1
mqttramvar["evu/APhase2"]=bezuga2
mqttramvar["evu/APhase3"]=bezuga3
mqttramvar["evu/ASchieflast"]=schieflast
mqttramvar["evu/DailyYieldExportKwh"]=daily_einspeisungkwh
mqttramvar["evu/DailyYieldImportKwh"]=daily_bezugkwh
mqttramvar["evu/Hz"]=evuhz
mqttramvar["evu/PfPhase1"]=evupf1
mqttramvar["evu/PfPhase2"]=evupf2
mqttramvar["evu/PfPhase3"]=evupf3
mqttramvar["evu/VPhase1"]=evuv1
mqttramvar["evu/VPhase2"]=evuv2
mqttramvar["evu/VPhase3"]=evuv3
mqttramvar["evu/W"]=wattbezug
mqttramvar["evu/WAverage"]=glattwattbezug	   # NC ??
mqttramvar["evu/WhExported"]=einspeisungkwh
mqttramvar["evu/WhImported"]=bezugkwh
mqttramvar["evu/WPhase1"]=bezugw1
mqttramvar["evu/WPhase2"]=bezugw2
mqttramvar["evu/WPhase3"]=bezugw3
mqttramvar["global/boolRse"]=rsestatus
mqttramvar["global/DailyYieldAllChargePointsKwh"]=daily_llakwh
mqttramvar["global/DailyYieldHausverbrauchKwh"]=daily_hausverbrauchkwh
mqttramvar["global/kWhCounterAllChargePoints"]=llkwhges
mqttramvar["global/strLastmanagementActive"]=lastregelungaktiv
mqttramvar["global/WHouseConsumption"]=hausverbrauch
mqttramvar["global/ChargeMode"]=lademodus
mqttramvar["global/awattar/MaxPriceForCharging"]=etprovidermaxprice
mqttramvar["global/awattar/ActualPriceForCharging"]=etproviderprice
mqttramvar["global/u1p3p_urcounter"]=urcounter
mqttramvar["global/u1p3p_uhcounter"]=uhcounter

# mqttramvar["global/strLaderegler"]=LadereglerTxt
# NC mqttramvar["hook/1/boolHookStatus"]=hook1akt
# NC mqttramvar["hook/2/boolHookStatus"]=hook2akt
# NC mqttramvar["hook/3/boolHookStatus"]=hook3akt
mqttramvar["housebattery/boolHouseBatteryConfigured"]=speichervorhanden
mqttramvar["housebattery/DailyYieldExportKwh"]=daily_sekwh
mqttramvar["housebattery/DailyYieldImportKwh"]=daily_sikwh
mqttramvar["housebattery/discharge_max"]=HB_discharge_max
mqttramvar["housebattery/enable_discharge_max"]=HB_enable_discharge_max
mqttramvar["housebattery/enable_priceloading"]=HB_enable_priceloading
mqttramvar["housebattery/iskalib"]=HB_iskalib
mqttramvar["housebattery/load_minutes"]=HB_load_minutes
mqttramvar["housebattery/loadWatt"]=HB_loadWatt
mqttramvar["housebattery/soctarget"]=HB_soctarget
mqttramvar["housebattery/%Soc"]=speichersoc
mqttramvar["housebattery/W"]=speicherleistung
mqttramvar["housebattery/WhExported"]=speicherekwh
mqttramvar["housebattery/WhImported"]=speicherikwh
[ -r ramdisk/lp1Serial ] && mqttramvar["lp/1/MeterSerialNumber"]=lp1Serial
mqttramvar["lp/1/VPhase1"]=llv1
mqttramvar["lp/1/VPhase2"]=llv2
mqttramvar["lp/1/VPhase3"]=llv3
mqttramvar["lp/2/VPhase1"]=llvs11
mqttramvar["lp/2/VPhase2"]=llvs12
mqttramvar["lp/2/VPhase3"]=llvs13
mqttramvar["lp/3/VPhase1"]=llvs21
mqttramvar["lp/3/VPhase2"]=llvs22
mqttramvar["lp/3/VPhase3"]=llvs23

mqttramvar["lp/1/APhase1"]=lla1
mqttramvar["lp/1/APhase2"]=lla2
mqttramvar["lp/1/APhase3"]=lla3
mqttramvar["lp/2/APhase1"]=llas11
mqttramvar["lp/2/APhase2"]=llas12
mqttramvar["lp/2/APhase3"]=llas13
mqttramvar["lp/3/APhase1"]=llas21
mqttramvar["lp/3/APhase2"]=llas22
mqttramvar["lp/3/APhase3"]=llas23
mqttramvar["lp/1/PfPhase1"]=llpf1
mqttramvar["lp/1/PfPhase2"]=llpf2
mqttramvar["lp/1/PfPhase3"]=llpf3

mqttramvar["lp/1/AConfigured"]=llsoll
mqttramvar["lp/2/AConfigured"]=llsolls1
mqttramvar["lp/3/AConfigured"]=llsolls2
mqttramvar["lp/1/tagScanInfo"]=tagScanInfoLp1
mqttramvar["lp/2/tagScanInfo"]=tagScanInfoLp2
mqttramvar["lp/3/tagScanInfo"]=tagScanInfoLp3
# mqttramvar["lp/1/AutolockConfigured"]=autolockconfiguredlp1
# mqttramvar["lp/2/AutolockConfigured"]=autolockconfiguredlp2
# mqttramvar["lp/3/AutolockConfigured"]=autolockconfiguredlp3
# mqttramvar["lp/1/AutolockStatus"]=autolockstatuslp1
# mqttramvar["lp/2/AutolockStatus"]=autolockstatuslp2
# mqttramvar["lp/3/AutolockStatus"]=autolockstatuslp3
mqttramvar["lp/1/boolChargeStat"]=chargestat
mqttramvar["lp/2/boolChargeStat"]=chargestats1
mqttramvar["lp/3/boolChargeStat"]=chargestatlp3
mqttramvar["lp/1/boolPlugStat"]=plugstat
mqttramvar["lp/2/boolPlugStat"]=plugstats1
mqttramvar["lp/3/boolPlugStat"]=plugstatlp3
mqttramvar["lp/1/ChargePointEnabled"]=lp1enabled
mqttramvar["lp/2/ChargePointEnabled"]=lp2enabled
mqttramvar["lp/3/ChargePointEnabled"]=lp3enabled
mqttramvar["lp/1/ChargeStatus"]=ladestatus
mqttramvar["lp/2/ChargeStatus"]=ladestatuss1
mqttramvar["lp/3/ChargeStatus"]=ladestatuss2
mqttramvar["lp/1/countPhasesInUse"]=lp1phasen
mqttramvar["lp/2/countPhasesInUse"]=lp2phasen
mqttramvar["lp/3/countPhasesInUse"]=lp3phasen
mqttramvar["lp/1/kWhActualCharged"]=aktgeladen
mqttramvar["lp/2/kWhActualCharged"]=aktgeladens1
mqttramvar["lp/3/kWhActualCharged"]=aktgeladens2
mqttramvar["lp/1/kWhChargedSincePlugged"]=pluggedladungbishergeladen
mqttramvar["lp/2/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp2
mqttramvar["lp/3/kWhChargedSincePlugged"]=pluggedladungbishergeladenlp3
mqttramvar["lp/1/kWhCounter"]=llkwh
mqttramvar["lp/2/kWhCounter"]=llkwhs1
mqttramvar["lp/3/kWhCounter"]=llkwhs2
mqttramvar["lp/1/pluggedladungakt"]=pluggedladungaktlp1
mqttramvar["lp/2/pluggedladungakt"]=pluggedladungaktlp2 
mqttramvar["lp/3/pluggedladungakt"]=pluggedladungaktlp3 
mqttramvar["lp/1/plugStartkWh"]=pluggedladunglp1startkwh
mqttramvar["lp/2/plugStartkWh"]=pluggedladunglp2startkwh
mqttramvar["lp/3/plugStartkWh"]=pluggedladunglp3startkwh

mqttramvar["lp/1/%Soc"]=soc
mqttramvar["lp/2/%Soc"]=soc1
mqttramvar["lp/1/boolSocConfigured"]=socvorhanden
mqttramvar["lp/2/boolSocConfigured"]=soc1vorhanden
mqttramvar["lp/1/lastRfId"]=rfidlp1
mqttramvar["lp/2/lastRfId"]=rfidlp2
mqttramvar["lp/3/lastRfId"]=rfidlp3
mqttramvar["lp/1/TimeRemaining"]=restzeitlp1
mqttramvar["lp/2/TimeRemaining"]=restzeitlp2
mqttramvar["lp/3/TimeRemaining"]=restzeitlp3
mqttramvar["lp/1/kmCharged"]=gelrlp1
mqttramvar["lp/2/kmCharged"]=gelrlp2
mqttramvar["lp/3/kmCharged"]=gelrlp3
mqttramvar["pv/1/boolPVConfigured"]=pv1vorhanden
mqttramvar["pv/1/W"]=pv1watt
mqttramvar["pv/1/WhCounter"]=pvkwh
mqttramvar["pv/2/boolPVConfigured"]=pv2vorhanden
mqttramvar["pv/2/W"]=pv2watt
mqttramvar["pv/2/WhCounter"]=pv2kwh
mqttramvar["pv/bool70PVDynStatus"]=nurpv70dynstatus
# mqttramvar["pv/bool70PVDynActive"]=nurpv70dynact
mqttramvar["pv/DailyYieldKwh"]=daily_pvkwhk
mqttramvar["pv/MonthlyYieldKwh"]=monthly_pvkwhk
mqttramvar["pv/W"]=pvwatt
mqttramvar["pv/WhCounter"]=pvallwh
mqttramvar["pv/YearlyYieldKwh"]=yearly_pvkwhk

# fuer nurpv minpv
mqttramvar["pv/CounterTillStartPvCharging"]=pvecounter

# NC mqttramvar["pv/1/DailyYieldKwh"]=daily_pvkwhk1
# NC mqttramvar["pv/1/MonthlyYieldKwh"]=monthly_pvkwhk1
# NC mqttramvar["pv/1/YearlyYieldKwh"]=yearly_pvkwhk1
# NC mqttramvar["pv/2/DailyYieldKwh"]=daily_pvkwhk2
# NC mqttramvar["pv/2/MonthlyYieldKwh"]=monthly_pvkwhk2
# NC mqttramvar["pv/2/YearlyYieldKwh"]=yearly_pvkwhk2
mqttramvar["SmartHome/Devices/1/DailyYieldKwh"]=daily_d1kwh
mqttramvar["SmartHome/Devices/2/DailyYieldKwh"]=daily_d2kwh
mqttramvar["SmartHome/Devices/3/DailyYieldKwh"]=daily_d3kwh
mqttramvar["SmartHome/Devices/4/DailyYieldKwh"]=daily_d4kwh
mqttramvar["SmartHome/Devices/5/DailyYieldKwh"]=daily_d5kwh
mqttramvar["SmartHome/Devices/6/DailyYieldKwh"]=daily_d6kwh
mqttramvar["SmartHome/Devices/7/DailyYieldKwh"]=daily_d7kwh
mqttramvar["SmartHome/Devices/8/DailyYieldKwh"]=daily_d8kwh
mqttramvar["SmartHome/Devices/9/DailyYieldKwh"]=daily_d9kwh
mqttramvar["system/ConfiguredChargePoints"]=ConfiguredChargePoints
mqttramvar["system/IpAddress"]=ipaddress
mqttramvar["system/lastRfId"]=rfidlasttag
mqttramvar["system/regelneeds"]=regelneeds
mqttramvar["system/updateInProgress"]=updateinprogress
mqttramvar["Verbraucher/1/DailyYieldExportkWh"]=daily_verbraucher1ekwh
mqttramvar["Verbraucher/1/DailyYieldImportkWh"]=daily_verbraucher1ikwh
mqttramvar["Verbraucher/1/Watt"]=verbraucher1_watt
mqttramvar["Verbraucher/1/WhExported"]=verbraucher1_whe
mqttramvar["Verbraucher/1/WhImported"]=verbraucher1_wh
mqttramvar["Verbraucher/2/DailyYieldExportkWh"]=daily_verbraucher2ekwh
mqttramvar["Verbraucher/2/DailyYieldImportkWh"]=daily_verbraucher2ikwh
mqttramvar["Verbraucher/2/Watt"]=verbraucher2_watt
mqttramvar["Verbraucher/2/WhExported"]=verbraucher2_whe
mqttramvar["Verbraucher/2/WhImported"]=verbraucher2_wh

declare -A mqttbashvar
mqttbashvar["system/Version"]=version   # version ist nicht in ramdisk, daher als bashvar

mqttbashvar["lp/1/kWhDailyCharged"]=dailychargelp1
mqttbashvar["lp/2/kWhDailyCharged"]=dailychargelp2
mqttbashvar["lp/3/kWhDailyCharged"]=dailychargelp3
mqttbashvar["global/WAllChargePoints"]=ladeleistung
mqttbashvar["lp/1/W"]=ladeleistunglp1
mqttbashvar["lp/2/W"]=ladeleistungs1
mqttbashvar["lp/3/W"]=ladeleistungs2

(( debug > 1 )) &&  openwbDebugLog "MAIN" 2 "mqttvar.sh loaded"

