Interesanntes Video hierzu
https://roboticsbackend.com/raspberry-pi-gpios-default-state/

https://raspberrypi.stackexchange.com/questions/100878/gpio-pins-set-to-output-on-boot-after-apt-get-updateupgrade

OpenWB Pins/ Gpios

gpio=4,5,7,11,17,22,23,24,25,26,27 = op,dl als Ausgang und auf LOW Setzen

gpio=6,8,9,10,12,13,16,21=ip,pu	= als Eingang und PullUP aktivieren

Achtung, innerhalb der openWB wird mal mit BOARD,  mal mit BCM addressiert
Hier eine Zuordnungstabelle

| Board PinNr| BCM GPIO  | Type | Verwendung |
|------|------|------|-------|
|    7 | G04 | Out | Led3 |
|   11 | G17 | Out | LP2 U1P3-- |
|   13 | G27 | Out | LP2 U1P3++ |
|   15 | G22 | Out | LP2 CP / Socket |
|   16 | G23 | Out | Led2 |
|   18 | G24 | Out | Led1 |
|   19 | G10 | IN PUP | Socket L-State |
|   21 | G09 | IN PUP| rse |
|   22 | G25 | Out | LP1 CP |
|   23 | G11 | Out | Socket LM Dir|
|   24 | G08 | IN PUP| rse |
|   26 | G07 | Out | Socket Power LM|
|   29 | G05 | Out  LP1 U1P3-- |
|   31 | G06 | IN PUP| T3=NurPv |
|   32 | G12 | IN PUP| T1=Sofort |
|   33 | G13 | IN PUP| T4=Stop |
|   36 | G16 | IN PUP| T2=MinPv |
|   37 | G26 | Out | LP1 U1P3++ |
|   40 | G21 | IN PUP| T5=Standby |
|------|------|------|-------|

![gaU6t](https://user-images.githubusercontent.com/89247538/212203387-25cb7925-7d6f-4e87-92c7-c18ef853296f.png)
