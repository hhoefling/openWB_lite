**Simulation einer ExtopenWB**

Als als LP1 (oder LP2) den Hardwaretyp "externe openWB" auswählen.


***Aktionen auf dem MASTER***
																

**CP Unterbrechnung** (aus regel.sh)

---> MQTT publish openWB/set/isss/Cpulp1 "1" an Slave senden.

**Ladestrom einstellen** (aus set-current.sh)

--> MQTT publish openWB/set/isss/Current an Slave senden  
--> MQTT publish openWB/set/isss/Lp2Current an Slave senden

**U1P3 Umschaltung** (aus u1p3pcheck.sh)

-> MQTT publish openWB/set/isss/U1p3p "1" an Slave senden  
-> MQTT publish openWB/set/isss/U1p3p "3" an Slave senden  

**Automatischen Update** (aus update.sh)

-->  MQTT publish openWB/set/system/releaseTrain an Slave senden  
-->  MQTT publish openWB/set/system/PerformUpdate an Slave senden  


Via Ladeleistungsmode wird dann auch noch extopenwblp1|2|3 aufgerufen
daher noch

**Zähler auslesen** (aus loadvars.sh -> extopenwblpx/main.sh)  
Zählerdaten in Ramdisk des Masteres übernehmen  
--> ramdisk/ll* plugstat chargstat sowie die Watt Angabe  
--> MQTT publish openWB/set/isss/parentWB to Slave  
--> MQTT publish openWB/set/isss/openWB/set/isss/parentCPlp1|2 an Slave  
--> MQTT publish openWB/set/isss/heartbeat an Slave  

--> MQTT publish  openWB/set/lp/$chargepcp/%Soc  an Slave  
wenn lastScannedRfidTag übernommen wurde  
--> MQTT publish  openWB/set/isss/ClearRfid "1" an Slave  

MQTT Read  openWB/lp/$chargepcp/# from Slave <---  


***Aktionen auf dem Slave (extopenWB)***

**regel.sh** des Slaves  
erhöht ramdisk/heartbeat und hält Uptime/Timestamp/Date in Slave-MQTT aktuell.

**isss.py** des Slaves  
Liest hardware aus. Akutallisiert slave-MQTT (zur auslesen durch master) und  
--> publish direkt in MQTT des Masters (als parenWB) 
--> publish openWB/lp/"+parentCPlp1|2+"/W to Master  
--> publish openWB/lp/"+parentCPlp1|2+"/VPhase1|2|3 to Master  
--> publish openWB/lp/"+parentCPlp1|2+"/APhase1|2|3 to Master  
--> publish openWB/lp/"+parentCPlp1|2+"/countPhasesInUse to Master  
--> publish openWB/lp/"+parentCPlp1|2+"/boolPlugStat to Master  
--> publish openWB/lp/"+parentCPlp1|2+"/boolChargeStat to Master  



--

