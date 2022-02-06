**Hilfreiche Infos, gesamelt im Forum**

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
SDM630 an EVU 192.168.193.15 8899 117
MPM3PM 192.168.193.19 8899 1
```

******************************************

EVSE Registers (modbis id =1)
```
1000: Configured Current 12
1001: Actual Current 12
1002: Vehicle Status 2
1003: PP-Limit 32
1004: Turn off bit 0
1005: Firmware Version 12
1006: EVSE Status 2+
1007: evseRcdStatus (??)
2000: Current after boot 32
2001: Modbus Status 1
2002: Min. Current Value 6
2003: Analog Input Config 1
2004: Amps after boot (evse-button) 0
2005: Register 2005 8192
2006: Current Sharing Mode 0
2007: PP-Detection 0 
2009: BootFirmware;  (??)
```


Integrierter Zähle SDM72D-M (modbus id = 105)
```
30001 Phase 1 line to neutral volts. 4 Float V 00 00
30003 Phase 2 line to neutral volts. 4 Float V 00 02
30005 Phase 3 line to neutral volts. 4 Float V 00 04
30007 Phase 1 current. 4 Float A 00 06
30009 Phase 2 current. 4 Float A 00 08
30011 Phase 3 current. 4 Float A 00 0A
30013 Phase 1 active power. 4 Float W 00 0C
30015 Phase 2 active power. 4 Float W 00 0E
30017 Phase 3 active power. 4 Float W 00 10
30019 Phase 1 apparent power. 4 Float VA 00 12
30021 Phase 2 apparent power. 4 Float VA 00 14
30023 Phase 3 apparent power. 4 Float VA 00 16
30025 Phase 1 reactive power. 4 Float VAr 00 18
30027 Phase 2 reactive power. 4 Float VAr 00 1A
30029 Phase 3 reactive power. 4 Float VAr 00 1C
--
30031 Phase 1 power factor (1). 4 Float None 00 1E
30033 Phase 2 power factor (1). 4 Float None 00 20
30035 Phase 3 power factor (1). 4 Float None 00 22
30043 Average line to neutral volts. 4 Float V 00 2A
30047 Average line current. 4 Float A 00 2E
30049 Sum of line currents. 4 Float A 00 30
30053 Total system power. 4 Float W 00 34
30057 Total system volt amps. 4 Float VA 00 38
30061 Total system VAr. 4 Float VAr 00 3C
30063 Total system power factor (1). 4 Float None 00 3E
30071 Frequency of supply voltages. 4 Float Hz 00 46
30073 Import active energy 4 Float kWh 00 48
30075 Export active energy 4 Float kWh 00 4A
30201 Line 1 to Line 2 volts. 4 Float V 00 C8
30203 Line 2 to Line 3 volts. 4 Float V 00 CA
30205 Line 3 to Line 1 volts. 4 Float V 00 CC
30207 Average line to line volts. 4 Float V 00 CE
30225 Neutral current. 4 Float A 00 E0
30343 Total active Energy (2) 4 Float kWh 01 56
30345 Total reactive energy 4 Float kVArh 01 58
30385 resettable total active energy 4 Float kWh 01 80
30389 resettable import active energy 4 Float kWh 01 84
30391 resettable export active energy 4 Float kWh 01 86
30397 Net kWh (Import - Export) 4 Float kWh 01 8C
31281 Total import active power 4 Float W 05 00
31283 Total export active power 4 Float W 05 02
40000-- Write Register u.a mit Passwort/Reset/baudrate etc
```
