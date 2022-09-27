Ich habe testweise mal ein update eines Buster (auf raspi 4) zu bullseye durchgeführt.


also der Reihe nach.
Erst mal das Buster nachgeführt
```
apt update
apt full-upgrade
```
Dann die Quelle auf bullseye umschreiben (/etc/apt/source...)

Dann wieder
```
apt update
apt full-upgrade
```
Das fürt zu einem Fehler, 
```
Die folgenden Pakete haben unerfüllte Abhängigkeiten:
 libc6-dev : Beschädigt: libgcc-8-dev (< 8.4.0-2~) aber 8.3.0-6+rpi1 soll installiert werden
E: Fehler: Unterbrechungen durch pkgProblemResolver::Resolve hervorgerufen; dies könnte durch zurückgehaltene Pakete verursacht worden sein.
```
daher erst mal
```
sudo apt-get install gcc-8-base libgcc-8-dev
```
Da habe alles abgenickt und danach mit 

```
apt full-upgrade
apt autoremove
```
weitergemacht.


