# openWB_lite


Dies ist eine Kopie der stable17 (1.9.244) von snaptec
( https://github.com/snaptec/openWB/tree/stable17 )
Erweitert um fehlende Module die ich für meine Hardware brauche, die aber erst in der 1.9.250 enthalten sind (rct2)
Weiterhin wird diese Version auf den Raspi 3B+ hin optimiert um die Stabilität zu erhöhen.

Aktuell wird getestet auf einem:
```
Raspberry Pi 3 Model B Plus Rev 1.3
Kernel: Linux 4.19.66-v7+ GNU/Linux (Stretch)
Python 3.5.3
```
und auch auf:
```
Raspberry Pi 4 Model B Rev 1.4 (2GB)
Kernel: Linux 5.10.103-v7l+ GNU/Linux (Buster)
Python 3.7.3
```
Seit Januar 2023 wird alles auf Debian 11/Bulleye umgestellt.
Diese läuft jetzt auf:
```
Raspberry Pi 4 Model B Rev 1.4 (2GB)
Kernel: Linux 5.15.84-v7l+ GNU/Linux (Bullseye)
Python 3.9.2
```
Da die Firma openWB im Nov.2021 keine stabile Version der Software auf Basis der 1.9'er zur Verfügung stellt bei der die richtigen RCT2 Module enthalten sind bleibt mir nur auf Basis des alten Stretch-Kernels (4.19.66-v7) meine eigene Version zu pflegen. Zu Testzwecken läuft meine Version auch auf einem Pi4 mit Buster. Wobei hier natürlich nicht die Hardwareebene mit getestet werden kann. Alle Module die direkt mit der Hardware der openWB kommunizieren, können so nicht getestet werden. Dies sind meist auch noch Python2.x Module. Zum testen können, mit Hilfe meines Mqtt-Pullers, die Hardwaremodule aus der echten OpenWB mit Daten versorgt werden.
Inzwischen läuft auch das 7"Zoll Display an einem Pi3 und ein 4.3 Display hängt an einem Pi4. 

## Abweichungen zur normalen openWB
- Diese Version arbeite nicht mit dem Legathy-Run-Server (LRS) der ab 12.2022 sucessive eingebaut wurde. Gerade die RCT2 Module haben damit Probleme. Daher versuche ich die jeweils letzte Version der Module zu verwenden die noch ohne den LRS auskommt.
- Reduktion auf LP1-LP3, dies ist weitgehend abgeschlossen.
- Ich werde alle Module die ich nicht selbst verwende aus dem Repository herausnehmen. Wenn jemand dieser Module verwenden, oder sogar daran mitarbeiten möchte, kann ich sie gerne die in der letzen (vor LRS) Version heraussuchen und wieder hinzufügen. "auf Vorrat" werde ich die Module nicht mitpflegen. Im Einzelfall muss dann geprüft werden ob Aktualisierungen in der offiziellen OpenWB vorgenommen wurden und bei relevanz diese dann Nachpflegen. Rausgenommen wird ebenfalls die Preismodule. Mein Ziel ist einfaches PV-Überschuss laden. Strombezug ist zweitrangig.
- Nicht übernommen wurde die Umwidmung der mqtt Zuweisungen zur pv Leistung. Bei der 1.9'er bis hin zur 254 wurde dort ein negativer Wert von der Datenquelle abgelegt. Diese Version behält dies verhalten bei  da sonst auch älter Backups dann ihr gültigkeit verlieren würden. OpenwWB selbst hatte dies dann mit der 1.9.259 auch wieder zurückgenommen.
- Ladelog um KM ergänzen. wird via MQTT aus dem Skoda-SoC Module übergeben. 
- Ladelog Export nach Excel an die deutsche Variante der Trennzeichen angepasst. Ausserdem wurde ein Jahresexport zugefügt
- Nachladen. Die Startzeit für das Nachladen kann nun von 17:00 bis 4:00 Uhr Nachts gesetzt werden. Die Endzeit für das Nachladen kann nun von 20:00 bis 9:00 Uhr Morgens gesetzt werden. 
- Bei den SoC gesteuerten Lademodi wird die Regel 80%=80% eingehalten + Überladen bei 100% Einstellung (wie vorher)
- Der Modbusserver auf Port 502 ist nun abschaltbar da er von openWB selbst nicht mehr verwendet wird. 
- Datenexport zu Excel mit ',' / ';' statt '.'/ ','
- RCT2h weiter Optimierung, Regelschleife auf Pi3B+ von 6-7 auf 3-4 Sekunden gesenkt
- Weiter Hilfsscript statregel.sh und restsmat.sh
- Der Name der Linux Distribution wird mit angezeigt (Seite System-Info)
- Das Colour Thema wurde leicht angepasst. Sowohl eine neue 4 Farbe (Schwarz) als auch größer Schriften.
- Die openWB.Coud funktioniert bei mir. Mit eingriffen in die Firefox-Konfiguartion und die mosquitto Konfiguration
- Module die ich weiterhin mitpflegen werde da ich sie selbst verwende sind:
- - Bezug/Pv/Speicher  **RCT** / **RCT2** / **RCT2h** /  **MQTT** / **HTTP**
- - LP   In den OpenWB Varianten und  **HTTP** / **MQTT** 
- - SOC **Manual** /  **Citigo** / **MQTT** / **HTTP**
- - Sonstiges: Tibber
- Das Integrierte Display wird in seiner Funktion erweitert. Bei mir ist die openWB nicht öffentlich zugänglich (hängt auf der Innenseite der Aussenwand). Daher kann ich auf dem Display auch die normal Web-Oberfläche verwenden. Lediglich für die eventuell nötigen Tastattureingabe ist ein Zugang mit einem PC & Browser nötig.
- Die Helligkeit der Hintergrundbeleuchtung ist nun Regelbar.
- - Umstellung auf HTTPS und verwendung von "Same-Site=Lax"
- MQTT-Exlorer über TLS möglich (via https)
	
Weiter Info **[History](docs/history.md)**

*******************************************************

***Die weitere Entwicklung***

- Ladesteuerung an meine Wünsche anpassen, insbesondere Nachtladen und Zielladen.
- Eine 220V Steckdose mit Notladekabel als 3-Wallbox integrieren
- Ladelog, Ein Eintrag je Ab/AnStecken, nicht je Ladeunterbrechung
- Eigenes offenes Event-Sytem mit EMail Benachrichtigung statt PushOver.
- Eigenes Buster-ISO-Image mit unterstützung des integrierten Display.
- Bullseye hat keine verwendbares Pyhton2.x. (es fehlt z.b. GPIO nach dem Nachinstallieren). Da die Kernmodule alle noch in python2 geschrieben sind scheidet bullseye erst mal aus. Inzwischen habe ich python 2.7.16 und GPIO 0.7.0 installieren können. Also werde ich auch mit Bullseye weitertesten.
- Bullseye zum testen in einer VM auf dem PC
- Für mich irrelevante Functionen werden entfernen. (awatar, pushover, evse ) Wenn jemand diese Module benötigt, bitte melden, vieleicht lassen sie sich ja aus der alten 1'9er-24x übernehmen und weiterverwenden.
- Erweiterung der Log Funktion um die Regelmodule besser zu debugen. 
- Ich habe nun begonnen mich von Stretch und Buster zu verabschieden.
- Aktuell wird nur noch unter Bullseye weitergetestet. Damit hat aber endgültig Python2.7 ausgedient. Allerdings sind die vielen kleinen Python Sripte unter python3.9 ca. 50% langsamer als unter Python2.7 auf einenm Strech/Buster System. Aber sollange bei meiner Hadrware-Mischung keine Regel-Laufzeit über 8 Sekunden daraus resultiert werde ich das in Kauf nehmen. Aber eine Vollausgestatte Box mit Taster/Led/Rfid/DUO, da wird es schon eng mit der Laufzeit unter Python3.9
- Nov 2023. Seit ich Tibber als Stromanbieter habe kommen mir viele neue Idene wie man openWB und den Hausakku damit sinnvoll koppeln kann.
- In der Testphase befindet sich folgende Änderungen.
-	- Die Anzeige des Preisselektors bei allen Lademodi ausser Stop.
-	- Verwendung des Preiselektors um das Laden des Hausakkus zu niedrigpreis Zeiten zu ermöglichen.
-	- Entladesperre für den Hausakku um beim Sofortladen/Nachladen/Morgenladen das entladen des Hausakkus zu verhindern.
-	- Manuelles "Sofort-Laden" für den Hausakku.
-	- Anzeige diverser Statusinformationen über den Wechselrichter und den Hausakku.
-	- Grafisch wird das ganze in das Colors-Thema integriert (in das Batterie-Widget)
  
 *************
**[RCT DC6, Preis/Nachladen und anderes](docs/rct_regelung.md)**

 ****************

**[Umzug auf openwb_lite](docs/umzug.md)**

*****************

**[info zu Buster/Bullseye](docs/debian.md)**

****************

**[History](docs/history.md)**

******************

**[Infos](docs/infos.md)**

******************

**[Tips zur Instalation](docs/Install.md)**

******************

**[Tips zur Umstellung auf HTTPS](docs/https.md)**




