# openWB_lite



Dies ist eine Kopie der stable17 von snaptec
( https://github.com/snaptec/openWB/tree/stable17 )
Erweitert um fehlende Module die ich für meine Hardware brauche, 
die aber erst in der 1.9.250 enthalten sind (rct2)
Weiterhin wird diese Version auf den Rapsi 3B+ hin optimiert um
die Stabilität zu erhöhen.

Aktuell wird nur getestet auf einem:
```
Raspberry Pi 3 Model B Plus Rev 1.3
Kernel: Linux 4.19.66-v7+ GNU/Linux
Python 3.5.3
```


Die folgenden Schritte lassen eine laufenden snaptec/openwb auf dieses Repository umziehen.
```
cd /var/www/html/openWB
git remote -v  # Anzeigen der aktuellen Basis
origin  https://github.com/snaptec/openWB.git (fetch)
origin  https://github.com/snaptec/openWB.git (push)

git remote set-url origin https://github.com/hhoefling/owb1.9.250x.git
git remote -v
origin  https://github.com/hhoefling/openWB_litegit (fetch)
origin  https://github.com/hhoefling/openWB_lite.git (push)
```
Update auf diese Version (Master) als Benutzer pi
```
# fetch new release from GitHub
cd /var/www/html/openWB
sudo git fetch origin
sudo git reset --hard origin/master
```



Die folgen modificationen sind auf meinen Test-Pi-3B+ getestet worden.
Der Test-Raspi wurde mit einer Kopie der original-SD Karte betrieben.

**Reduzierung der /var/log/auth.log die sonst pro Minute um mehrer Zeilen wächst.**

File: **/etc/pam.d/sudo**

```
#%PAM-1.0
#>>>--- Added.
session [success=done default=ignore] pam_succeed_if.so quiet uid = 0 user = root ruser = pi
session    required   pam_env.so readenv=1 user_readenv=0
session    required   pam_env.so readenv=1 envfile=/etc/default/locale user_readenv=0
#<<<--End Added
@include common-auth
@include common-account
@include common-session-noninteractive
```

File: **/etc/pam.d/common-session-noninteractive**

Suche
```
session required        pam_unix.so
```
Ersetze gegen
```
session     [success=1 default=ignore] pam_succeed_if.so service in cron quiet use_uid
session required        pam_unix.so
```

File: **/etc/sudoers**

Oben unter den anderen "Defaults" Zeilen folgen drei Zeilen einfügen
```
Defaults:pi     !syslog
Defaults:cron   !syslog
Defaults:root   !syslog
```

Reduzierung der Meldungen im apache2 error.log

File: **/etc/apache2/apache2.conf**

Zeile hinzufügen
```
ServerName      127.0.0.1
```

*******************************************************
Hilfreiche Infos, gesamelt im Forum

Die unterschiedlichen Zählertypen und ihre Internen Adressen
```
Typ	IP     Port Unit_id
EVU Kit
MPM3PM 192.168.193.15 8899 5 
SDM630 192.168.193.15 8899 115
Lovato 192.168.193.15 8899 2

PV Kit
MPM3PM 192.168.193.13 8899 8
SDM630 192.168.193.13 8899 116
Lovato 192.168.193.13 8899 8

PV Kit and EVU Kit
MPM3PM 192.168.193.15 8899 8
SDM630 192.168.193.15 8899 116 (flex-Kit)
Lovato 192.168.193.15 8899 8

Speicherkit
SDM120 192.168.193.19 8899 9
SDM630 an EVU 192.168.193.15 8899 117
MPM3PM 192.168.193.19 8899 1
```
