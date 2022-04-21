
## Installation auf einer Pi3B+/Pi4B+ ##

Vorbereiten
- Ein Stretch oder Buster Image mit Desktop wählen.
- ssh aktivieren (ssh in boot ablegen)
- root password setzen
- root für ssh freischalten
- apt update/upgrade ausführen

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash

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
