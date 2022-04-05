**History**

Einige Steps der Entwicklung


12.2021 
- Das Nachladen, auch von 4-Uhr bis 7-Uhr Nachts, mit einhaltung der 80%=80% klappt einwandfrei.

11.2022 
- Das Colour-Thema erhält eine 4 Farbe, rein Schwarz.

12.2022 
- Die System-Statusseite zeigt weitere Details zum System. Offene Netzwerkverbindungen und Processe des User Pi 

1.2022
- Begin der Reduktion auf LP1-3, wenn ich mal 4 oder mehr openWB's habe, dann nehme ich wieder die 2.0 Software :-).  Aktuell reichen mir 3 Ladepunkte
- Nach reduzierung auf LP1..LP3 ist die gemittelte Startzeit des Color-Themas von (53/10) auf (33/10) also von 5,3 azf 3,3 Sekunden gesunken.
- Der Ladelog enthält den Km Stand des PKW sofern dieser verfügbar ist. (Soc-Skoda macht es)

3.2022 
- Alle Versuche die RCT2 Module mit dem Legathy-Run-Server zu betreiben sind bisher fehlgeschlagen. Ich bleibe bei den normalen Pyhton Modules. Durch reduktion auf ein einziges Phyton module für EVU/WR/BAT singt die Laufzeit der Regelschleife weiter von 7/8 auf 5/6 Sekunden.

4.2022 
- rct2h hinzugefügt um nicht mit rct2 (von peter.O ) zu kollidieren. Regelschleife nun 3-4 Sekunden. 
- Der Name der Distribution wird im System-Info mit angezeigt. 
- Hilfscript statregel.sh im die Laufzeitstatistik der Regelschleife anzuzeigen.
- Hoffendlich nun alle referenten auf LP4-LP8 entfernt. Dadurch schnelle Ladezeiten der Weboberfläche
- Alle internen IP Adressen von 192.168.193.x zu 192.168.192.x gewechselt
