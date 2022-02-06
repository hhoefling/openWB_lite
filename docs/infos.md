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

EVSE Registers
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


Integrierter Zähle SDM72D-M
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
```
