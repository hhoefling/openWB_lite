**Simulation einer ExtopenWB**

Als als LP1 (oder LP2) den Hardwaretyp "externe openWB" auswählen.

**MASTER**<<<<<-------------------->>>>>**ExtOpenWB (slave)**

ip-Adresse> LPnr (in Slave) ->
																	<- ParentWB ip und ParentWB LP Nr			
																	

**CP Unterbrechnung** (aus regel.sh)

---> MQTT publish openWB/set/isss/Cpulp1 "1" an Slave senden.

**Ladestrom einstellen** (aus set-current.sh)

--> MQTT publish openWB/set/isss/Current an Slave senden  
--> MQTT publish openWB/set/isss/Lp2Current an Slave senden

**U1P3 Umschaltung** (aus u1p3pcheck.sh)

-> MQTT publish openWB/set/isss/U1p3p "1" an Slave senden  
-> MQTT publish openWB/set/isss/U1p3p "3" an Slave senden  

**Automatischen Update** (aus update.sh)

-->  MQTT publish openWB/set/system/releaseTrain   
-->  MQTT publish openWB/set/system/PerformUpdate  



