
** Installation auf einer .....**

Vorbereiten
- ssh aktivieren (ssh in boot ablegen)
- root password setzen
- root für ssh freischalten
- apt update/upgrade ausführen

curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash

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
