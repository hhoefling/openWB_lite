## Installation von openWB_lite innerhalb einer WM ##
( Original openWB siehe weiter unten )

Download von https://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2021-01-12/   
das IMG File 2021-01-11-raspios-buster-i386.iso ( letztes Buster image)

**Verwendet wurden von mir*
- VM (VMware oder Virutalbox) mit 2 GB Ram und 4 Kernen.
- raspian-386 Image mit Buster

Bei vmware kann eine Zeile 

bios.bootDelay = "30000" 

Helfen von CD zu starten wenn die VM schon mal verwendet wurde.



## Installation der Original-openWB 1.9.x innerhalb einer VM ##

**Systemvoraussetzung**
- Laufenden VM (VMware oder Virutalbox)
- 1 GB Ram, 1 Kern
- Debian 11.4 / Kern 5.10.0-10-amd64  (Bulleye) frisch upgedated.
- Instalierte Packete:  apache2, ssh , samba, python2.7 
- Netzwerkdevice auf eth0 umgestellt ([Siehe debian](debian.md))
- In diesem Fall ist php 8.1 installiert.

Die openwb-install.sh muss angepasst werden für php 8.1, Also runterladen in /var/www/html und im Editor das folgende einfügen

```
if [ -d "/etc/php/8.1/" ]; then
	echo "OS Bullseye"
	sudo /bin/su -c "echo 'upload_max_filesize = 300M' > /etc/php/8.1/apache2/conf.d/20-uploadlimit.ini"
	sudo /bin/su -c "echo 'post_max_size = 300M' >> /etc/php/8.1/apache2/conf.d/20-uploadlimit.ini"
elif [ -d "/etc/php/7.0/" ]; then
```

statt 

``` 
if [ -d "/etc/php/7.0/" ]; then
``` 

Nach dieser Änderung dann 

```
cd /var/www/html
cat openwb-innstall.sh | sudo bash 
```

verwenden.

Nachtragen der Crontab von pi nicht vergessen.

Damit scheinen die rudimentären Funktionen sofort zu funktionieren.

Aber *programmloggerinfo.php* liefert für die Hardware noch nichts oder falsche Werte. Das sind scheinbar nur Schönheitsfehler.
Da aber pubmqtt.sh ebenfalls diese Werte ausliest müssen wir hier leider zwei Zeilen stillegen
also in runs/pubmqtt.sh 

aus:

```
tempPubList="${tempPubList}\nopenWB/global/cpuTemp=$(echo "scale=2; $(echo ${sysinfo} | jq -r '.cputemp') / 1000" | bc)"
tempPubList="${tempPubList}\nopenWB/global/cpuFreq=$(($(echo ${sysinfo} | jq -r '.cpufreq') / 1000))"
```
dann
```
tempPubList="${tempPubList}\nopenWB/global/cpuTemp=44"  # "$(echo "scale=2; $(echo ${sysinfo} | jq -r '.cputemp') / 1000" | bc)"
tempPubList="${tempPubList}\nopenWB/global/cpuFreq=444" # "$(($(echo ${sysinfo} | jq -r '.cpufreq') / 1000))"
```
machen (dabei die " beachten)

