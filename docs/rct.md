** Hier sammle ich Informationen über meinen RCT Wechserichter **


## Ablauf der Kalibrierung ##

| bat_status (B1) | batery_status (B2) | battery-status2 (B3) | Bemerkung |
|:-------------- |:-------------------:|:--------------------:|----------:|
| 0 | 0 | 0 | Normal |
| 0x0008 (8) | 0	|0x0008 (8)  BAT_STATUS2_CALIBRATION | Start Kalibration bei ca. Soc=80% -> Target auf 100%, Ladung auch aus Netz (war Nachts) |
|	0x0008 (8) | 0 | 0x0108 (264)  BAT_STATUS2_CALIBRATION BAT_STATUS2_BATTERY_FULL | Soc 100% Erreicht, dann ca. 20 Minuten |
| 0x0400 (1024) | 0 | 0x0400 (1024)  BAT_STATUS2_CALIBRATION_EMPTY | Start Endladung ->Soc Target auf 0%	 |
|	0	| 0  | 	0 | Soc 0% Erreicht, Target wieder auf 97% |

Also B1  in  [8,1024] -> Kalibrierung läuft.
Oder B3 in [8,264,1024] -> Kalibrierung läuft.
Während des gesamten Procedur war der WR zu jeder Zeit abfragbar und lieferte alle Werte
Also auch bezüglich des Akkus, (Ströme, Spannungen und Soc etc.)

Balacing habe ich noch nicht verfolgen können.







