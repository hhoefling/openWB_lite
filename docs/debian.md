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


mailx wird gebraucht 
daher:
```
apt install bsd-mailx msmtp msmtp-mta
```

Parameter in der openWB
```
Xeventto='-a gmx xxx@yyy.de'
eventto='-a hal4 root@xxx.local'
eventtosend=1
```


/etc/msmtprc
```
#Set default values for all accounts.
defaults
auth on
tls on
tls_starttls on
tls_certcheck off
syslog LOG_MAIL
#logfile /var/log/msmtp.log

account gmx
host mail.gmx.net
port 587
from from@gmx.de
user userid
password passwd

account hal4
host hal4.xxx.local
port 25
from pi@pi.xxx.local
user localuser
password localuserpassword
tls off
auth off

#Set a default account
account default : gmx

```
