# openWB_lite


Dies ist eine Kopie der stable17 (1.9.244) von snaptec
( https://github.com/snaptec/openWB/tree/stable17 )
Erweitert um fehlende Module die ich für meine Hardware brauche, die aber erst in der 1.9.250 enthalten sind (rct2)
Weiterhin wird diese Version auf den Raspi 3B+ hin optimiert um
die Stabilität zu erhöhen.

Aktuell wird nur getestet auf einem:
```
Raspberry Pi 3 Model B Plus Rev 1.3
Kernel: Linux 4.19.66-v7+ GNU/Linux
Python 3.5.3
```

## Abweichungen zur normalen openWB
- Diese Version arbeite nicht mit dem Legathy-Run-Server der ab 12.2022 sucessive eingebaut wurde. Gerade die RCT2 Module haben damit Probleme. Daher versuche ich die jeweils letzte Version der Module zu verwenden die noch ohne den LRS auskommt.
- Reduktion auf LP1-LP3, dies ist weitgehend abgeschlossen.
- Nicht übernommen wurde die Umwidmung der mqtt Zuweisungen zur pv Leistung. Bei der 1.9'er bis hin zur 254 wurde dort ein negativer Wert von der Datenquelle abgelegt. Irgendwann Dez/Jan 2022 wurde das umgestellt auf eine positive Zahl. Dadurch werden alle MQTT-PV Datequellen ungültig und es müste die openWB Version berücksichtig werden um zu entscheiden ob eine posivie oder einen negaive Zahl an openWB zu übegeben sei. Diese Inkompatibilität behindert den Vergleichenden Test mit einer ältern Version.
Auch verlieren älter Backups dann ihr gültigkeit wenn die MQTT Quelle notgedrungen auf posivive Werte umgestellt wurde. Daher wird in meiner Lite weiterhin ein negavtive Zahl via MQTT übergeben.
- Seit der 1.9.259 (24.3.2022) ist der MQTT Patch bei der originalen openWB nicht mehr nötig, es kann wie bisher eine negative Zahl übegeben werden.
- Ladelog um KM ergänzen. wird via MQTT aus dem Skoda-SoC Module übergeben.
- Nachladen.
Die Startzeit für das Nachladen kann nun von 17:00 bis 4:00 Uhr Nachts gesetzt werden.
Die Endzeit für das Nachladen kann nun von 20:00 bis 9:00 Uhr Morgens gesetzt werden.
Es wird die Regel 80%=80% eingehalten + Überladen bei 100% Einstellung (wie vorher)
- Der Modbusserver auf Port 502 ist nun abschaltbar da er von openWB selbst nicht mehr verwendet wird. 
- Datenexport zu Excel mit ',' und ';' statt '.' und ','
- RCT2h weiter Optimierung, Regelschleife auf Pi3B+ von 6-7 auf 3-4 Sekunden gesenkt
- Weiter Hilfsscript  statregel.sh und restsmat.sh
*******************************************************

***Die weitere Entwicklung***

- Ladesteuerung an meine Wünsche anpassen, insbesonder Nachtladen und Zielladen.
- 220V Steckdose mit Notladekabel als 3-Wallbox integrieren
- Ladelog, Ein Eintrag je Ab/AnStecken, nicht je Ladeunterbrechung
- Es wird eine EMail Benachrichtigung eingebau

**[Umzug auf openwb_lite](docs/umzug.md)**

*****************

**[info zu Buster/Bullseye](docs/debian.md)**

****************

**[History](docs/history.md)**

******************

**[Infos](docs/infos.md)**

