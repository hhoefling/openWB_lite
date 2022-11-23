
## Installation auf einer Pi3B+/Pi4B+ ##
 ( auf einem alten Pi 1/2 -> siehe weiter unten )
Vorbereiten
- Ein Stretch oder Buster Image mit Desktop wählen.
- ssh aktivieren (ssh in boot ablegen)
- (optional) root password setzen
- (optional) root für ssh freischalten
- apt update/upgrade ausführen

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash

oder

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash 2>&1 | tee /var/log/install-openWB.log

## Installation auf einem Raspi mit Display (4.3 oder 7" per DMS angeschlossen) ##

Zuerst normal installieren wie oben.
- Per Browser die Grundkonfg durchführen und dabei unter Einstellungen->Verschiedenes das Display einschalten. (Hierdurch wird die openWB konfiguration geändert.)
- Nun nocheinmal neu booten (Hierdurch wird die Konfiguration des XServers geändert.)
- Nun nocheinmal neu booten Jetzt erscheint nicht mehr der LX-Desktop sondern es wird der Chromium-Browser im Kiost mode gestartet.

## Backports ##

Abfrage des Ist-Zustandes
```
#$ cd /var/www/html/openWB
#$ more web/version
1.9.263
```
Dann
```
$ git checkout  -B 85cd805
Reset branch '85cd805'
#$ more web/version
1.9.254
```
Die Zahl 85cd805 muss man sich bei Github raussuchen


## Mosquitto ##

Bei Problemen mit clienten -> "ungültige Client-Id"
ist ein backport von 2.0.12->2.0.11 nötig<br>
( siehe https://github.com/dotnet/MQTTnet/issues/1290  und https://github.com/eclipse/mosquitto/issues/2383 )

```
apt-get install mosquitto=2.0.11-0mosquitto1~buster1 -V
```


## Installation auf einem Pi1 oder PI2+ ##

Dieser Raspi hat nur 512MB Ram daher wählen wir eine variante ohne Desktop 
Der Raspi sollte auch kein (LC)-Display angeschlossen haben. (Ein Kontrollmonitor darf am HDMI angeschlossen sein)

Vorbereiten:
- Ein Buster Image ohne Desktop wählen, also die Lite-Variante.
- ssh aktivieren (ssh in boot ablegen)
- (optional) root password setzen
- (optional) root für ssh freischalten
- apt update/upgrade ausführen
 

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash

oder

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash 2>&1 | tee /var/log/install-openWB.log

Viel Geduld.....

Die Installation der Module ist teils so langsam das die 10 Minuten Maximal Laufzeit vom atreboot.sh nicht ausreicht.
Also warten.....
Wenn atreboot.sh durch ist und trotzden nicht alles läuft ->  ein weiterr Reboot erledigt dann den Rest.



