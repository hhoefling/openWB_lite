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


*******************************************************
Die weitere Entwicklung

- Unter der Annahme das ich keine 8 Ladepunkte brauche werde ich die Software auf 3 Ladepunkte zurückfahren.
- Ladesteuerung an meine Wünsche anpassen, insbesonder Nachtladen und Zielladen.
- Ladelog um KM ergänzen (aus dem SOC Module)
- 220V Steckdose mit Notladekabel als 3-Wallbox integrieren
*******************************************************




Die folgenden Schritte lassen eine laufenden snaptec/openwb auf dieses Repository umziehen.
(Beutzer pi)
```
# Schritt 1, Git Konfiguration anpassen
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
# Schritt 2 , Initiales Update vom  Git holen
cd /var/www/html/openWB
# Save old running config
cp -p openwb.conf openwb.conf.sav
# switch repository
sudo git fetch origin
sudo git reset --hard origin/master
# restore config
cp -p openwb.conf.sav openwb.conf
# fix access rights
sudo chmod +x runs/*.sh
sudo chmod +x *.sh
# run normal after-update-handling
./runs/update.sh

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


******************

**[History](docs/history.ms)**

******************

**[Infos](docs/info.ms)**

