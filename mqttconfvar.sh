



mqttconfvar["hook/1/boolHookConfiguredX"]=hook1_aktiv
mqttconfvar["hook/2/boolHookConfiguredX"]=hook2_aktiv
mqttconfvar["hook/3/boolHookConfiguredX"]=hook3_aktiv

mqttconfvar["hook/1/boolHookConfigured"]=hook1_aktiv
mqttconfvar["hook/2/boolHookConfigured"]=hook2_aktiv
mqttconfvar["hook/3/boolHookConfigured"]=hook3_aktiv

mqttconfvar["lp/1/boolDirectChargeModeSocX"]=sofortsocstatlp1
mqttconfvar["lp/2/boolDirectChargeModeSocX"]=sofortsocstatlp2
mqttconfvar["lp/3/boolDirectChargeModeSocX"]=sofortsocstatlp3

mqttconfvar["lp/1/boolDirectModeChargekWh"]=lademstat
mqttconfvar["lp/2/boolDirectModeChargekWh"]=lademstats1
mqttconfvar["lp/3/boolDirectModeChargekWh"]=lademstats2

mqttconfvar["lp/1/boolDirectChargeModeSoc"]=sofortsocstatlp1
mqttconfvar["lp/2/boolDirectChargeModeSoc"]=sofortsocstatlp2
mqttconfvar["lp/3/boolDirectChargeModeSoc"]=sofortsocstatlp3

mqttconfvar["lp/1/energyConsumptionPer100km"]=durchslp1
mqttconfvar["lp/2/energyConsumptionPer100km"]=durchslp2
mqttconfvar["lp/3/energyConsumptionPer100km"]=durchslp3

mqttconfvar["lp/1/boolFinishAtTimeChargeActive"]=zielladenaktivlp1
mqttconfvar["lp/1/boolChargeAtNight"]=nachtladen
mqttconfvar["lp/2/boolChargeAtNight"]=nachtladens1

mqttconfvar["boolChargeAtNight_direct"]=nlakt_sofort
mqttconfvar["boolChargeAtNight_nurpv"]=nlakt_nurpv
mqttconfvar["boolChargeAtNight_minpv"]=nlakt_minpv
mqttconfvar["boolChargeAtNight_standby"]=nlakt_standby
mqttconfvar["boolDisplayHouseConsumption"]=hausverbrauchstat
mqttconfvar["boolDisplayDailyCharged"]=heutegeladen
mqttconfvar["boolEvuSmoothedActive"]=evuglaettungakt

mqttconfvar["lp/1/strChargePointName"]=lp1name
mqttconfvar["lp/2/strChargePointName"]=lp2name
mqttconfvar["lp/3/strChargePointName"]=lp3name

konstant1=1
mqttconfvar["lp/1/boolChargePointConfigured"]=konstant1
mqttconfvar["lp/2/boolChargePointConfigured"]=lastmanagement
mqttconfvar["lp/3/boolChargePointConfigured"]=lastmanagements2


mqttconfvar["Verbraucher/1/Name"]=verbraucher1_name
mqttconfvar["Verbraucher/2/Name"]=verbraucher2_name
mqttconfvar["Verbraucher/1/Configured"]=verbraucher1_aktiv
mqttconfvar["Verbraucher/2/Configured"]=verbraucher2_aktiv


mqttconfvar["config/get/pv/lp/1/minCurrent"]=minimalapv
mqttconfvar["config/get/pv/lp/2/minCurrent"]=minimalalp2pv
mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeTo"]=minnurpvsoclp1
mqttconfvar["config/get/pv/lp/1/maxSocToChargeTo"]=maxnurpvsoclp1
mqttconfvar["config/get/pv/lp/1/minSocAlwaysToChargeToCurrent"]=minnurpvsocll
mqttconfvar["config/get/pv/lp/1/socLimitation"]=stopchargepvatpercentlp1
mqttconfvar["config/get/pv/lp/2/socLimitation"]=stopchargepvatpercentlp2
mqttconfvar["config/get/pv/lp/1/maxSoc"]=stopchargepvpercentagelp1
mqttconfvar["config/get/pv/lp/2/maxSoc"]=stopchargepvpercentagelp2
mqttconfvar["config/get/pv/priorityModeEVBattery"]=speicherpveinbeziehen
mqttconfvar["config/get/pv/minFeedinPowerBeforeStart"]=mindestuberschuss
mqttconfvar["config/get/pv/maxPowerConsumptionBeforeStop"]=abschaltuberschuss
mqttconfvar["config/get/pv/stopDelay"]=abschaltverzoegerung
mqttconfvar["config/get/pv/startDelay"]=einschaltverzoegerung
mqttconfvar["config/get/pv/minCurrentMinPv"]=minimalampv
mqttconfvar["config/get/pv/chargeSubmode"]=pvbezugeinspeisung
mqttconfvar["config/get/pv/regulationPoint"]=offsetpv
mqttconfvar["config/get/pv/boolShowPriorityIconInTheme"]=speicherpvui
mqttconfvar["config/get/pv/minBatteryChargePowerAtEvPriority"]=speichermaxwatt
mqttconfvar["config/get/pv/minBatteryDischargeSocAtBattPriority"]=speichersocnurpv
mqttconfvar["config/get/pv/batteryDischargePowerAtBattPriority"]=speicherwattnurpv
mqttconfvar["config/get/pv/socStartChargeAtMinPv"]=speichersocminpv
mqttconfvar["config/get/pv/socStopChargeAtMinPv"]=speichersochystminpv
mqttconfvar["config/get/pv/boolAdaptiveCharging"]=adaptpv
mqttconfvar["config/get/pv/adaptiveChargingFactor"]=adaptfaktor
mqttconfvar["config/get/pv/nurpv70dynact"]=nurpv70dynact
mqttconfvar["config/get/pv/nurpv70dynw"]=nurpv70dynw

mqttconfvar["config/get/global/maxEVSECurrentAllowed"]=maximalstromstaerke
mqttconfvar["config/get/global/minEVSECurrentAllowed"]=minimalstromstaerke
mqttconfvar["config/get/global/dataProtectionAcknoledged"]=datenschutzack
mqttconfvar["config/get/u1p3p/sofortPhases"]=u1p3psofort
mqttconfvar["config/get/u1p3p/standbyPhases"]=u1p3pstandby
mqttconfvar["config/get/u1p3p/nurpvPhases"]=u1p3pnurpv
mqttconfvar["config/get/u1p3p/minundpvPhases"]=u1p3pminundpv
mqttconfvar["config/get/u1p3p/nachtPhases"]=u1p3pnl
mqttconfvar["config/get/u1p3p/isConfigured"]=u1p3paktiv
mqttconfvar["config/get/sofort/lp/1/energyToCharge"]=lademkwh
mqttconfvar["config/get/sofort/lp/2/energyToCharge"]=lademkwhs1
mqttconfvar["config/get/sofort/lp/3/energyToCharge"]=lademkwhs2
mqttconfvar["config/get/sofort/lp/1/socToChargeTo"]=sofortsoclp1
mqttconfvar["config/get/sofort/lp/2/socToChargeTo"]=sofortsoclp2
mqttconfvar["config/get/sofort/lp/3/socToChargeTo"]=sofortsoclp3
# mqttconfvar["percentsofortlademodussoclp3"]=sofortsoclp3
mqttconfvar["config/get/sofort/lp/1/chargeLimitation"]=msmoduslp1
mqttconfvar["config/get/sofort/lp/2/chargeLimitation"]=msmoduslp2
mqttconfvar["config/get/sofort/lp/3/chargeLimitation"]=msmoduslp3
mqttconfvar["config/get/display/displayLight"]=displayLight
mqttconfvar["config/get/display/displayPinAktiv"]=displaypinaktiv
mqttconfvar["config/get/display/chartEvuMinMax"]=displayevumax
mqttconfvar["config/get/display/chartBatteryMinMax"]=displayspeichermax
mqttconfvar["config/get/display/chartPvMax"]=displaypvmax
mqttconfvar["config/get/display/showHouseConsumption"]=displayhausanzeigen
mqttconfvar["config/get/display/chartHouseConsumptionMax"]=displayhausmax
mqttconfvar["config/get/display/chartLp/1/max"]=displaylp1max
mqttconfvar["config/get/display/chartLp/2/max"]=displaylp2max
mqttconfvar["config/get/display/chartLp/3/max"]=displaylp3max

mqttconfvar["global/rfidConfigured"]=rfidakt
mqttconfvar["global/ETProvider/modulePath"]=etprovider
mqttconfvar["global/awattar/boolAwattarEnabled"]=etprovideraktiv
mqttconfvar["global/awattar/ActualPriceForCharging"]=etproviderprice
mqttconfvar["global/awattar/MaxPriceForCharging"]=etprovidermaxprice


mqttconfvar["system/priceForKWh"]=preisjekwh
mqttconfvar["system/wizzardDone"]=wizzarddone
mqttconfvar["system/devicename"]=devicename

# NC 
# mqttconfvar["pv/bool70PVDynActive"]=nurpv70dynact
mqttconfvar["config/get/pv/nurpv70dynact"]=nurpv70dynact

# NC ??
mqttconfvar["pv/W70PVDyn"]=nurpv70dynw
mqttconfvar["config/get/pv/nurpv70dynw"]=nurpv70dynw


