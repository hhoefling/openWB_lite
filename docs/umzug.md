**Umzug einer openWB auf dieses Repository**



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




**Optimieren des OS (stretch)**


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

**Reduzierung der Meldungen im apache2 error.log**

File: **/etc/apache2/apache2.conf**

Zeile hinzufügen
```
ServerName      127.0.0.1
```

**Wenn die folgende Meldung in openwb.log auftaucht**
```
RequestsDependencyWarning: urllib3 (1.26.8) or chardet (3.0.4) doesn't match a supported version!
```
dann hilft

```
pip3 install --upgrade requests
```


