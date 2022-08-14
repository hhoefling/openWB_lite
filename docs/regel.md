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
- hook.sh	Plugin/plugoff/ChargeStart/ChargeStop (Web)Hooks ausführen lassem
- graphing  Live-Grafiken mit dem Messwerten versorgen/Weiterschreiben (10-sekundlich und minütlch)
 - Stop hier wenn noch U1P3 aktiv ist
 - evseinttest
 - U1P3 testen und durchführen 
 - Stop hier wenn jetzt U1P3 aktiv ist
 - CP druchführen wenn für LP1 / LP2 (alls DUO)
 - Leds nachführen.
 - RSE abtesten, evl. Ladung nötigenfalls stoppen.
 - evsemodbuscheck
 - slavemode.sh Bei YC Version ist hier schluss.
 - Wenn STOP Mode , wirklich alle Ladungen stoppen (auslademodus)
 - Loadcharing LP1/2 durchführen und Ladung evt anpassen (set-current)
 **Nun kommen enflich die Regelmodule zum Einsatz**
 - Zielladen checken und Ende wenn aktiv.
 - Nachladen checken und Ende wenn aktiv.
 - Anzahl der Verwendeten Phasen bestimmen (>3 Ampere) oder defaultwert je nach Lademode
 - Sofortladen checken und Ende wenn aktiv.
 - Überschuss berechnen für die PV gestützen Regler
 - MinUndPV checken, immer (set-current) 
 - NurPV alle Varianten checke, (set-current) Ende wenn eingegriffen.
 - SemiAuslademodes falls Standbymode und geladen wird, Ladung stoppen.
 - Fertig.

