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
