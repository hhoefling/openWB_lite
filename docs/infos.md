**Hilfreiche Infos, gesamelt im Forum**

**Modbus Adressen des OpenWB internen modbus Server (tcp) (veraltet, nicht mehr benutzt)**

```
110  rse
111  configured chardpoints
(W)112  Lademodustaster
(W)113  rfidleser 
300 Wattbezug
302 Bezug A1
303 Bezug A2
304 Bezug A3
305 Bezug V1
306 Bezug V2
307 Bezug V3
308 Bezug Kwh
310 Einspeisung Kwh
400 pv Watt
402 pv Wh
500 bat Watt
502 Bat Soc
503 Bat KwhIn
505 BatKwhOut
>10999 Ladepunkte
 subnr
  0  llaktuell
  2  llkwh
  4  llv1
  5  llv2
  6  llv3
  7  lla1
  8  lla2
  9  lla3
  10  mqttlastmanagement
  11  lpXenabled
  12  rfidlp
  14  plugstat
  15  chargestat
  16  llsoll
(W) 51 lpXenabled  
(W) 52 lpXsofortll  
19916 llsolllp8  
```  

***Die unterschiedlichen Zählertypen und ihre Internen Adressen***
```
Typ	IP     Port Unit_id
EVU Kit
MPM3PM 192.168.193.15 8899 5 
SDM630 192.168.193.15 8899 115
Lovato 192.168.193.15 8899 2

PV Kit
MPM3PM 192.168.193.13 8899 8
SDM630 192.168.193.13 8899 116
Lovato 192.168.193.13 8899 8

PV Kit and EVU Kit
MPM3PM 192.168.193.15 8899 8
SDM630 192.168.193.15 8899 116 (flex-Kit)
Lovato 192.168.193.15 8899 8

Speicherkit
SDM120 192.168.193.19 8899 9
SDM630 192.168.193.15 8899 117 (als EVU)
MPM3PM 192.168.193.19 8899 1

Interner Zähler  /dev/tty/USB0
type  	id
sdm	105	
mpm	5	
b23	201	

```

******************************************

EVSE Registers (modbis id =1)

Die neue OLC-Auflösung mit 0,01A (ab FW18 mgl.)
```
1000: Configured Current 12
1001: Actual Current 12
1002: Vehicle Status 2
                        1: ready
                        2: EV is present
                        3: charging
                        4: charging with ventilation
                        5: failure (e.g. diode check)
1003: PP-Limit 32
1004: Turn off bit 0
1005: Firmware Version 12
1006: EVSE Status 2+
			1: steady 12V
                        2: PWM is being generated (only if 1000 >= 6)
                        3: OFF, steady 12V
1007: evseRcdStatus (??)
2000: Current after boot 32
2001: Modbus Status 1
2002: Min. Current Value 6
2003: Analog Input Config 1
2004: Amps after boot (evse-button) 0
2005: Register 2005 8192    bit 7 enables 0.01A Steps in 1000 ab FW17
2006: Current Sharing Mode 0
2007: PP-Detection 0 
2009: BootFirmware;  (??)
2010             R/W     6      Amps value 1
2011             R/W     10     Amps value 2
2012             R/W     16     Amps value 3
2013             R/W     25     Amps value 4
2014             R/W     32     Amps value 5
2015             R/W     48     Amps value 6
2016             R/W     63     Amps value 7
2017             R/W     80     Amps value 8
```


Integrierter Zähle SDM72D-M (modbus id = 105)
```
30001 Phase 1 line to neutral volts. 4 Float V 0000
30003 Phase 2 line to neutral volts. 4 Float V 0002
30005 Phase 3 line to neutral volts. 4 Float V 0004
30007 Phase 1 current. 4 Float A 0006
30009 Phase 2 current. 4 Float A 0008
30011 Phase 3 current. 4 Float A 000A
30013 Phase 1 active power. 4 Float W 000C
30015 Phase 2 active power. 4 Float W 000E
30017 Phase 3 active power. 4 Float W 0010
30019 Phase 1 apparent power. 4 Float VA 0012
30021 Phase 2 apparent power. 4 Float VA 0014
30023 Phase 3 apparent power. 4 Float VA 0016
30025 Phase 1 reactive power. 4 Float VAr 0018
30027 Phase 2 reactive power. 4 Float VAr 001A
30029 Phase 3 reactive power. 4 Float VAr 001C
--
30031 Phase 1 power factor (1). 4 Float None 001E
30033 Phase 2 power factor (1). 4 Float None 0020
30035 Phase 3 power factor (1). 4 Float None 0022
30043 Average line to neutral volts. 4 Float V 002A
30047 Average line current. 4 Float A 002E
30049 Sum of line currents. 4 Float A 0030
30053 Total system power. 4 Float W 0034
30057 Total system volt amps. 4 Float VA 0038
30061 Total system VAr. 4 Float VAr 003C
30063 Total system power factor (1). 4 Float None 003E
30071 Frequency of supply voltages. 4 Float Hz 0046
30073 Import active energy 4 Float kWh 0048
30075 Export active energy 4 Float kWh 004A
30201 Line 1 to Line 2 volts. 4 Float V 00C8
30203 Line 2 to Line 3 volts. 4 Float V 00CA
30205 Line 3 to Line 1 volts. 4 Float V 00CC
30207 Average line to line volts. 4 Float V 00CE
30225 Neutral current. 4 Float A 00E0
30343 Total active Energy (2) 4 Float kWh 0156
30345 Total reactive energy 4 Float kVArh 0158
30385 resettable total active energy 4 Float kWh 0180
30389 resettable import active energy 4 Float kWh 0184
30391 resettable export active energy 4 Float kWh 0186
30397 Net kWh (Import - Export) 4 Float kWh 018C
31281 Total import active power 4 Float W 0500
31283 Total export active power 4 Float W 0502
40000-- Write Register u.a mit Passwort/Reset/baudrate etc
```

**Chargemode**
```
Sofort	0
Min+PV	1
NurPV		2
Stop	  3
Standby	4
(Nachladen 7)


```



Die Verschieden Speichermedien und ihre Geschwindigkeit.
```
apt install hdparm
hdparm -tT /dev/mmcblk0  
hdparm -tT /dev/sda
```

!---Karte ---- | Port  | Leserate<br>MB/sec | Schreibrate<br>MB/sec |
|--------------|-------|--------------------|-----------------------|
| R3B+/32GB SDHC | Intern |584.59 |22.38 |
| R4B+/32GB SDHC | Intern | 519.06 |44.40 |
| R4B+/16GB SDHC | USB Kartenleser|585.22 |33.09|
| R4B+/16GB SDHC | USB3 Kartenleser| 586.95 | 82.60 |
| R4B+/32GB Stick | USB3 | 613.43 | 128.80 |
| R4B+/64GB SSD | USB3 | 570.11 | 183.26|


******************************************

**Display**

Um das Display der OpenWB aufzuwecken bin ich mit folgendem Kommando zum Erfolg gekommen.

```
#/bin/bash
XAUTHORITY=~pi/.Xauthority DISPLAY=:0 xset dpms force on
```
Aufgerufen wird diese kleine Script in der openWB_Lite von mqttssub.py 
wenn auf openWB/set/system/reloadDisplay geschrieben wird






