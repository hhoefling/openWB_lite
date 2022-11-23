## Installation von openWB_lite innerhalb einer WM ##
( Original openWB siehe weiter unten )

Download von https://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2021-01-12/   
das IMG File 2021-01-11-raspios-buster-i386.iso ( letztes Buster image)

**Verwendet wurden von mir**

- VM (VMware oder Virutalbox) mit 2 GB Ram und 4 Kernen.
- File <2021-01-11-raspios-buster-i386.iso> mit Buster 

Zuerst mal 
```
apt update 
apt upgrade 
```
und sofort ein Snapshoot erzeugen.

Weiter gehts mit der Kontrolle ob auch die alten Netzwerknamen verwendet werden.
```
root@pi72:/home/pi# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:65:4e:69 brd ff:ff:ff:ff:ff:ff
    inet 192.168.208.219/24 brd 192.168.208.255 scope global dynamic noprefixroute eth0
       valid_lft 2268sec preferred_lft 1818sec
    inet6 fe80::c672:8fbf:8fc1:3e80/64 scope link
       valid_lft forever preferred_lft forever
root@pi72:/home/pi#
```			
Ok, eth0 ist korekt, ansonsten mit raspi-config ändern
Weiter gehts mit 

```
curl -s https://raw.githubusercontent.com/hhoefling/openWB_lite/master/openwb-install.sh | sudo bash 2>&1 | tee /var/log/install-openWB.log

```
----------------------------
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

