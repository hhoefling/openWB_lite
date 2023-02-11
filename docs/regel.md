## Der Ablauf der "Regel"-Schleife (durch die regel.sh) ##

##### (Weiter unten auch Cront5min.sh und cornnighly.sh) #####
Hier in "Pseudo-Kode" der ablauf der Regelschleife. (Standard 10Sek Interwall)

- test ob Update oder Boot nocht aktiv ist, falls ja sofort wieder **Ende**
- openwb.config einlesen in Shell-Variablen (loadconfig.sh)
- Restliche Unterfunctionen aus *.sh einlesen (nur openWB Verzeichniss) 
- Falls "Nur-Ladepunkt"  aktiv wird nur der "Heartbeat" versorgt und regel.sh geht hier zu **Ende**
- Falls dspeed=1 (doppelt, einen Klone im 5 Sekunden abstand losschicken)
- (Asyncron) einmal pro Minute testen ob durch autolook ein Sperren/Entsprerren nötig ist und dies ausführen (MQTT)
- (Asyncron) Ladelog versorgen, wenn ladeende erkannt wurde (->csv)
- 7" Display-Helligkeit einstellen/nachführen.
- goecheck.sh  (evse=goe) direkt auslesen wenn verwendet (curl)
- nrgkickcheck.sh (evse=nrkick) direkt auslesen wenn verwendet(curl)
- **loadvars.sh**  Alle anderen  konfigurierten Hardwaremodule abfragen EVSE/EVU/PW/BAT (alles in modules/)
- am Ende von loadvars.sh MQTT nachführen um die Messwerte wiederzuspiegeln.
- hook.sh	Plugin/plugoff/ChargeStart/ChargeStop (Web)Hooks ausführen lassen (*1)
- graphing  Live-Grafiken mit dem Messwerten versorgen/Weiterschreiben (10-sekundlich und minütlch) (*1)
- Test ob noch U1P3 aktiv ist (**Blockall1**), wenn ja **Ende**
- evseinttest
- U1P3 testen und durchführen 
- test ob jetzt U1P3 jetzt aktiv ist (**Blockall2**), wenn ja **Ende**
- CP durchführen ->MQTT oder Hardware direkt
- Leds nachführen. (*2)
- RSE abtesten, evl. Ladung stoppen. (*2)
- Wenn speedmodus=3 nur einmal pro Minute weiterlaufen lassen sonst hier **Ende**
- evsemodbuscheck (alle 5 minuten )
- slavemode.sh Bei YC-Version ist hier **Ende**
- Wenn STOP Mode , wirklich alle Ladungen stoppen (auslademodus) und **Ende***
- Loadcharing LP1/2 durchführen und Ladung evt anpassen (set-current)
- **ab hier kommen endlich die Regelmodule zum Einsatz**
- Zielladen checken und **Ende** wenn aktiv.
- Nachladen checken und **Ende** wenn aktiv.
- Anzahl der Verwendeten Phasen bestimmen (>3 Ampere) oder defaultwert je nach Lademode
- Sofortladen checken und **Ende** wenn aktiv.
- Überschuss berechnen für die PV gestützten Regler
- MinUndPV checken, immer (set-current) 
- NurPV alle Varianten checken, (set-current) **Ende** wenn eingegriffen.
- SemiAuslademodes wenn Standby-Mode Ladung stoppen.
- Fertig.


(1*) war vorher hinter dem ersten Blockall, wurde also mit blockiert.<br>
(2*) war vorher hinter dem speed=3  abbruch, wurde also nur "Langsam" ausgeführt.

## Aufaben die runs/cron5min.sh erledigt ##
Hier in "Pseudo-Kode" des Ablaufs (Alle 5 Minuten)

-  Ramdisk noch nicht vorhanden -> Ende
-  Update oder boot in Arbeit-> Ende
-  neues (leeres) Montly-Ladelog File anlegen falls noch nicht vorhaden
-  Tagesdaten in web/logging/data/daily/<date>.csv forschreiben , eine Zeile alle 5 Minuten
-  Netzsschutz durchführen, also wenn Netzschutz eingeschaltet ist die Netzfreqenz abtesten und gegebenfalls  Lademodedus auf 3(Stop) umstellen. Bei wiederreicher des Normalbereiches alten Lademodus wiederherstellen.
-	Falls aktive Strompreisanbieter updaten 	
- Tagesverbrauch errechnen und in ramdisk/daily_* screiben
- Ip-Adresses anfragen und zur anzeige ablegen.
- Alle Services starten/stopen die aktive sein sollen (service.sh)
- auch isss.py starten wenn daemon-mode oder "Nur Ladepunkt"
- LAN/ WLAN Verbindungen und zweite Netzwerkadressen prüfen.
- (buchse.py stoppen falls nicht benötigt)	
- Tasker starten falls nötig.
- Pingcheck durchführen falls aktiv.
- EVSEcheck durchführen falls aktiv.
- Logdateien in der Ramdisk kürzen lassen.
- sysdaem.sh nachstarten/restarten falls nötig

	
## Aufaben die runs/cronnightly.sh erledigt ##
Hier in "Pseudo-Kode" des Ablaufs (0 Uhr nachts)

- reloadDisplay in mqtt auf 1 setzen ??
- mqtt.log resetten ???
- Zählerstande per pushover.sh senden lassen
- Montlyfile um neuen Tag verlängern
- für Verbraucher 1/2 und "tasmota" die Zähler resetten.
- ( für yourcharge die random wartezeit neu auswürfeln )
- Updateaufforderung an alle konfiguriertem openWB-Pro Boxen senden
- Logfile, wegen neuem Tag, erneuern (csvcalc.py)	

	
## Der Datenfluss ##
Es gibt mehrere Stellen an dehnen Daten aufbewahrt werden.
	
**ramdisk**  (etwa 350-400 Werte)

In der Ramdisk werden die aktuellen Werte der Regellogig aufbewahrt.
Hierauf greifen alle Sub-Sripte von regel.sh zu. 
Primär werden Daten hieraus gelesen und Ergebnisse hier abgelegt. Paralell zur ausführung durch die Hardware.
Die ist der "alte" Kern der openWB. Die Gui-Themen sowie die Statusseite greifen aber nicht auf diese Daten zu sondern auf den MQTT Server. Deshalb werden alle Änderungen die im Regelkreis auftreten ebenfalls zum MQTT "gepublished".
Wie der Name schon vermuten läst gehen alle Daten verloren wenn die openWB bzw. der Rapsi stromlos wird oder neu startet.
Die Hauptaufgabe dürfte aber darin bestehen die Regelschleife zu beschleunigen und die SD-Karte vor zu vielen Schreibzugriffen zu schützen


**openwb.conf**  (etwa 800-900 Werte)

Diese Datei enthält die Einstellungen der OpenWB beziehungsweise ihre Defaultwerte.
Ein Teil davon wird ebenfalls für die GUI in den MQTT gespiegelt.
Alle Änderungen an den Einstellungen werden an den MQTT "gepublished".
Die Datei ist so groß weil sie *alle* möglichen Werte enthält, auch von niemals benutzen Modulen oder Teil-Funktionen.
Die Datei wird im Normalfall nur gelesen. Ein Update überschreibt sie nicht, wohl aber die Wiederherstellung eines Backups.


**mqtt**  (etwa 650 Werte )

Hier ist der "öffentliche" Teil der Regeldaten und der Stammdaten zugreifbar. Sie ist in der Hauptsache als "Readonly" Datenbank gemeint.
Über die "Set"-Zweige sind die Daten auch beschreibbar. Was in die "Set" Topic "gepublished" wird, gelangt nach Prüfung in den "normalen" MQTT Teil sowie je nach Topic in die **openwb.conf** und die **ramdisk**

Diese Syncronisation zwischen MQTT und ramdisk sowie der openwb.conf macht einen nicht unerheblichen Teil der "Arbeit" des Regelreises aus.
z.b werden alle in dem MQTT "gepublischten" Daten noch einmal in der ramdisk zwischengespeichert um ein wiederholtes publishen des gleichen Wertes zu verhindern.<br> 
Aber die Funktion der ramdisk wird auch zunehmend übergangen und viele Module schreiben direkt in die Topics des MQTT.
Sofern die Module dann auch lesend auf den MQTT zugreifen können, kommen sie unter Umständen ganz ohne openwb.conf und ramdisk aus.

Bei der openWB 2.x wurde die ramdisk und die openwb.conf durch einen internen mqtt Server ersetzt.
Dort existieren also zwei MQTT Instancen wobei der interne nur von localen Processes aus erreichbar ist (localhost only)



