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

dann noch ein 
```
reboot
```
und .....
- der pi booted...
- openWB Startbildschirm erscheint auf dem Display
- "Klicken zum Interface start" erscheint.
- Läuft :-)
- http aus dem Browser geht auch.
- https leider erst mal nicht :-(

Nach langem warten kommt auch die https Seite.
Also weiter...

python2 fehlt nun.
also sicherheisthalber noch 
```
apt install python2
root@pi61:~# python2 -V 
Python 2.7.18

root@pi61:~# python3 -V
Python 3.9.2
root@pi61:~# pip3 -V
pip 20.3.4 from /usr/lib/python3/dist-packages/pip (python 3.9)
```
pip2 fehlt, ich weiss nocht nicht  ob es gebraucht wird.
bei Buster waren es noch
```
root@pi67:~# pip -V
pip 9.0.1 from /usr/lib/python2.7/dist-packages (python 2.7)
root@pi67:~# pip3 -V
pip 9.0.1 from /usr/lib/python3/dist-packages (python 3.5)
```





`´´
