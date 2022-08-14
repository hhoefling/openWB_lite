## Der Ablauf der "Regel"-Schleife (durch die regel.sh) ##

Hier in "Pseudo-Kode" der ablauf der Regelschleife. (Standard 10Sek Interwall)

- test ob Update oder Boot nocht aktiv ist, falls ja sofort wieder Ende
- openwb.config einlesen in Shell-Variablen (loadconfig.sh)
- Restliche Unterfunctionen aus *.sh einlesen (nur openWB Verzeichniss) 
- Falls "Nur-Ladepunkt"  aktiv wird nur der "Heartbeat" versogt und regel.sh geht hier zu Ende.
- (Asyncron) einmal pro Minute testen ob autotatischen Ladepunkt Sperren/Entsprerren nötig ist und dies ausführen (MQTT)
- (Asyncron) Ladelog versorgen, wenn ladeende erkannt wurde (->csv)
- 7" Dipslay-Helligkeit einstellen/Nachführen.
- goecheck.sh  (evse=goe) direkt auslesen (curl)
- nrgkickcheck.sh (evse=nrkick) direkt auslesen (curl)
- **loadvars.sh**  Alle Konfigurierten Hardwaremodule abfragen EVSE/EVU/PW/BAT (alles in moduels/)
- am Ende von loadvars.sh MQTT nachführen um die Messwerte wiederzuspiegeln.
- hook.sh	Plugin/plugoff/ChargeStart/ChargeStop (Web)Hooks ausführen lassen (*1)
- graphing  Live-Grafiken mit dem Messwerten versorgen/Weiterschreiben (10-sekundlich und minütlch) (*1)
- Stop hier wenn noch U1P3 aktiv ist (Blockall1)
- evseinttest
- U1P3 testen und durchführen 
- Stop hier wenn jetzt U1P3 aktiv ist (Blockall2)
- CP durchführen wenn für LP1 / LP2 (alls DUO) ->MQTT oder Hardware direkt
- Leds nachführen. (*2)
- RSE abtesten, evl. Ladung nötigenfalls stoppen. (*2)
- Wenn speedmodus=3 nur einmal pro Minute weiterlaufen lassenm sonst hier **Ende**
 evsemodbuscheck (alle 5 minuten )
- slavemode.sh Bei YC Version ist hier **Ende**
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


(1*) war vorher hinter dem ersten Blockall, wurde also mit blockiert.
(2*) war vorher hinter dem speed=3  abbruch, wurde also nur "Langsam" ausgeführt.
