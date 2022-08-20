## Installation der Original-openWB 1.9.x innerhalb einer VM ##

**Systemvoraussetzung**
- Laufenden VM (VMware oder Virutalbox)
- 1 GB Ram, 1 Kern
- Debian 11.4 / Kern 5.10.0-10-amd64  Bulleye) frisch upgedated.
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
cat openwb-innstall.sh | sudo bash 
```

verwenden.

Nachtragen der von der Crontab von pi nicht vergessen.

Damit scheinen die rudimentären Funktionen sofort zu funktionieren.


