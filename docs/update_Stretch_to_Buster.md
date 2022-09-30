
Ich verwende pri-clone um eine Kopie der laufenden Stretch Version zu erzeugen. 

( https://github.com/billw2/rpi-clone )

 *rpi-clone -v -p 256M sdb*
  
Hierbei ist /dev/sda die im Kartenleser liegende Quell-SD Karte (32GB)
und /dev/sdb eine leere 16GB Karte. Diese wird dann auf Buster "upgedated"
Der Pi3B+ bootet nur dann von externen USB Ports wenn der interne KEINE oder eine leere SD Karte enthält.
Um also meine neue Karte alternativ booten zu können ohne immer mühselig die SD Karte aus dem internen Leser zu fummeln
habe ich die Quelle ebenfalls in einem Kartenleser extern via USB angeschlossen.
Daher ist die Quelle /dev/sda. 	Der PI3B+ bootet davon ohne Probleme. Lediglich die Bootzeit verlängert sich.
		

Hier nun die Mitschrift von rpi-clone

```
Booted disk: sda 31.9GB                    Destination disk: sdb 16.0GB
---------------------------------------------------------------------------
Part      Size    FS     Label           Part   Size  FS  Label
1 /boot    43.5M  fat32  --
2 root     29.7G  ext4   --
---------------------------------------------------------------------------
== Initialize: IMAGE partition table - partition number mismatch: 2 -> 0 ==
1 /boot               (29.0M used)   : RESIZE  MKFS  SYNC to sdb1
2 root                (4.1G used)    : RESIZE  MKFS  SYNC to sdb2
---------------------------------------------------------------------------
-p 256M                : resize /boot to 524288 blocks of 512 Bytes.
Run setup script       : no.
Verbose mode           : yes.
-----------------------:
## WARNING ##          : All destination disk sdb data will be overwritten!
-----------------------:

Initialize and clone to the destination disk sdb?  (yes/no): yes
```
Weiter gehts nach dem booten mit der nun kleineren 16GB Karte.
Ich habe mich orientiert an der Anleitung:
https://pimylifeup.com/upgrade-raspbian-stretch-to-raspbian-buster/


```
sudo apt update
sudo apt dist-upgrade -y
```
Bei mir wurden nun 32 Packete aktualisiert.

Als nächstes nur in /etc/apt/source.list und /etc/apt/source.list.d/*
jeweils "stretch" gegen "buster" austauschen. 


Weiter mit
```
sudo apt-get remove apt-listchanges
sudo apt update
sudo apt dist-upgrade
```

Das sind nun:

1070 aktualisiert, 495 neu installiert, 9 zu entfernen und 0 nicht aktualisiert.

Das dauert etwas ......


 
