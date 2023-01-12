Interesanntes Video hierzu
https://roboticsbackend.com/raspberry-pi-gpios-default-state/

https://raspberrypi.stackexchange.com/questions/100878/gpio-pins-set-to-output-on-boot-after-apt-get-updateupgrade

OpenWB Pins/ Gpios

gpio=4,5,7,11,17,22,23,24,25,26,27 = op,dl als Ausgang und auf LOW Setzen

gpio=6,8,9,10,12,13,16,21=ip,pu	= als Eingang und PullUP aktivieren

Achtung, innerhalb der openWB wird mal mit BOARD,  mal mit BCM addressiert
Hier eine Zuordnungstabelle

| Board | BCM  | Type | ..|
|------|------|------|-------|
|   11 |------| Out |-------|
|   13 |------| Out |-------|
|   15 |------| Out | CP2 |
|   19 | -----| IN PUP | Socket L-State |
|   22 |------| Out | CP1 |
|   23 |------| Out | Socket LM Dir|
|   26|------| Out | Socket Power LM|
|   29 |------| Out |-------|
|   37 |------| Out |-------|
|------|------|------|-------|

