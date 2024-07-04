**Infos zu anderen Debian/raspian Versionen**

**Interfacenamen bei Buster/Bullseye**

Wenn auf VM's oder anderer Hardeware installiert werden soll
und die Schnittstellennamen geändert wurden
gibt es viele Fehlermeldungen in den Scripten

Bei einem OS das Grub als Bootloader verwendet ist folgende Änderung nötig
um zu den Namen eth0 und wlan0 zurückzukehren.

sudo nano /etc/default/grub
```
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
update-grub
```


**IPV6 deaktivieren**


```
echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf
sysctl -p
```


**Laufzeiten**

Im Rahmen der Regelschleife werden viele Processe gestartet. Die meisten sind Bash-Scripte
Ein Zentraler bestandteil zum bilden der Zählersimulationen ist aber das Python-Script  simcount.py
Es wird je zu Software-Zähler einmal aufgerufen. ALso durchaus mehrfach je durchlauf der Regelschleife.

Hier mal die Laufzeiten auf den verschiedenen Plattformen.
| Hardware | Software | Laufzeit | Diff.|
| -------------| ------------| ------------- |------|
| Pi3B+ Stretch | python 2.7.13 | 60 ms | 100% |
| Pi3B+ Stretch | python3 3.5.3 | 147 ms | 241% |
| Pi3B+ Stretch | pypy 5.6.0/2.7.12| 144 ms | 240% |
| -------------| ------------| ------------- |------|
| Pi3B+ Buster | python 2.7.16 | 62 ms | `103%` |
| Pi3B+ Buster | python3 3.7.3 | 92 ms | 153% |
| Pi3B+ Buster | pypy 7.0.0/2.7.13 | 173 ms | 286% |
| -------------| ------------| ------------- |------|
| Pi4 Bullseye| python 3.9.2 | 87 ms | 145% |
| Pi4 Bullseye| python2 2.7.18 | 31 ms | `51%` |
| Pi4 Bullseye| pypy 7.3.3/2.7.18 | 69 ms | `115%` |

Gemessen und gemittelt wurden wurden jeweils 300 Aufrufe von openWB/runs/simcount.py

Bei der Umstellung der Python2 Scripte auf Pyhton3 ist also zu prüfen wie häufig sie innerhalb der Regelscheife aufgerufen werden.





