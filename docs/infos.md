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
1006: EVSE Status 2
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
