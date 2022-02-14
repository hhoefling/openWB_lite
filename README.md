# openWB_lite



Dies ist eine Kopie der stable17 von snaptec
( https://github.com/snaptec/openWB/tree/stable17 )
Erweitert um fehlende Module die ich für meine Hardware brauche, 
die aber erst in der 1.9.250 enthalten sind (rct2)
Weiterhin wird diese Version auf den Rapsi 3B+ hin optimiert um
die Stabilität zu erhöhen.

Aktuell wird nur getestet auf einem:
```
Raspberry Pi 3 Model B Plus Rev 1.3
Kernel: Linux 4.19.66-v7+ GNU/Linux
Python 3.5.3
```

## Abweichungen zur normalen openWB
- Reduktion auf LP1-LP3, weitgehend abgeschlossen.
- Nicht übernommen wurde die Umwidmung der mqtt Zuweisungen zur pv Leistung. Bei der 1.9'er bis hin zur 254 wurde dort ein negativer Wert von der Datenquelle abgelegt. Irgendwann Dez/Jan 2022 wurde das umgestellt auf eine positive Zahl. Dadurch werden alle MQTT-PV Datequellen ungültig und es müste die openWB Version berücksichtig werden um zu entscheiden ob eine posivie oder einen negaive Zahl an openWB zu übegeben sei. Diese Inkompatibilität behindert den Vergleichenden Test mit einer ältern Version.
Auch verlieren älter Backups dann ihr gültigkeit wenn die MQTT Quelle notgedrungen auf posivive Werte umgestellt wurde. Daher wird in meiner Lite weiterhin ein negavtive Zahl via MQTT übergeben.
- Ladelog um KM ergänzen (aus dem SOC Module LP1/LP2)

 *******************************************************
Die weitere Entwicklung
- Ladesteuerung an meine Wünsche anpassen, insbesonder Nachtladen und Zielladen.
- 220V Steckdose mit Notladekabel als 3-Wallbox integrieren
*******************************************************

**[Umzug auf openwb_lite](docs/umzug.md)**

*****************

**[info zu Buster/Bullseye](docs/debian.md)**

****************

**[History](docs/history.md)**

******************

**[Infos](docs/infos.md)**

