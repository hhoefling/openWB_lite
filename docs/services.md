**Die Hintergrundprocesse der openWB**

Es gibt zwei arten von Dienste/Serivces die bei der 1.9'er openWB im Hintergrund laufen.
erstens die dringend nötigen und zweitens die nur auf Benutzerwunsche je nach Hardware verwendet werden.


| Service | Nötig | vom Benutzer<br>abschaltbar  | atreboot | cron5min | Bemerkung |
|:------------------ |:---------------:|:----------------:|-------------------:|-------------------:|-------------------:|
| mqttsub | JA | NEIN | restart | Start-If | Empfängt MQTT Nachrichten |
| rse | JA | JA | restart | Start-If |  via openWB.conf<br>evtl. vom Netzbetreiber benötigt. Netzdientlich|
| modbusserver| JA | NEIN | restart | Start-If |KfW, Netzdientlich |
| legacy_run_server | Ja | NEIN | restart | Start-If | nicht bei openWB_Lite |
| isss| JA | NEIN| restart | Start-If | bei "nur Ladepunkt" (1) auch bei "Buchse" |
| buchse| JA | NEIN | restart | Start-If | im Normalmode |
| smarthomehandler<br><sub>alt</sub> | NEIN | NEIN | restart | Start-If | nur einer der beiden ist aktiv |
| smarthomemq<br><sub>neu</sub> | NEIN | NEIN | restart | Start-If | nur einer der beiden ist aktiv |
| pushbutton| NEIN| JA | restart | Start-If| Nur wenn Ladetaster vorhanden |
| rfid| NEIN| JA| restart | Start-If | je nach RFID Mode|
| readrfid| NEIN| JA| restart | Start-If | je nach RFID Mode |
| tsp| NEIN |JA | restart | Start-If | Versendet Events  (3)|
| TWCManager| NEIN| JA| Start | --- | 
| Chrome | NEIN| JA| restart | --- | nur wenn Display vorhanden |
| X11 | NEIN| NEIN | -- | -- | nur wenn Display vorhanden |
| lightdm | NEIN | NEIN | Stop | | Stop wenn kein Display |


(1) Je nach Hardware gesteuert über Personalisierung der SD Karte.

(2) Nur bei der orginal openWB ab ca. 1.9.265.

(3) nur bei openWB_Lite


Ein Veruch die verschiedenen openWB Varianten zu verstehen.

| Name in GUI| evsecon | daemon normal | daemon standalone |Bemerkung |
|:-------------|------|:-----------|:-----------|-------------------:|
|openWB Daemon| daemon |  |nur als LP1 |
|Serie 1/2 Auto | modbusevse| | | LP1/LP2 *1 per ttyUSB0 Id=0|
|Serie 1/2 | modbusevse| |  | LP1 per ttyUSB0 ID=5|
|Serie 1/2 mid V1| modbusevse| |  |LP1/LP2 per ttyUSB0 ID=105|
|Serie 1/2 mid V2| modbusevse| |  |LP1 *1 per serial0 105|
|Ladepunkt an Standonle|*ethframer|| |lp1=master lp2=slaveeth lp3=thirdeth|
|Buchse|buchse| || nur LP1 |
|Satellit|ipevse|| alle 8|
|externe openWB|extopenwb||alle 8|
|openWB Pro|owbpro|| | alle 8|

*1 auch für LP2 bei einer DUO wird "modbusevse" verwendet. Der zweite Zahler/EVSE ist dam entweder am gleichen modbis mit andere ID oder
ab einen zweiten USB Adapter (/ttyUSB1) angeschlossen




