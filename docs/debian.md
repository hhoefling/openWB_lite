**Infos zu anderen Debian/raspian Versionen**

**Interfacenamen bei Buster/Bullseye**

Wenn auf VM's oder anderer Hardeare installiert werden soll
und die Schnittstellennamen geändert wurden
gibt es viele Fehlermeldungen in den Scripten

Bei einem OS das Grub als Bootloader verwendet ist folgende Änderung nötig
um zu den Namen eth0 und wlan0 zurückzukehren.

sudo nano /etc/default/grub
```
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
```


