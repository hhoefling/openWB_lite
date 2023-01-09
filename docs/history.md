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
- Hilfscript statregel.sh um die Laufzeitstatistik der Regelschleife anzuzeigen.
- Hoffendlich nun alle referenten auf LP4-LP8 entfernt. Dadurch schnelle Ladezeiten der Weboberfläche
- Alle internen IP Adressen von 192.168.193.x zu 192.168.192.x gewechselt
- Die Statuszeite zeigt die Seriennummer der Ladepunktzähler an, wenn verfügbar
- Ladelog-Export an deutsches Excel angepasst (; als Trenner und , als Komma) dadurch kann die Ausgabe direkt an Excel übergeben werden. 
- Um die Grafiken in der Cloud-Version von web.openwb.de angezeigt zu bekommen sollte man die Fernwartung aktivieren. Das ist mir zuviel. Daher habe ich nur das "graph" Subtopic erlaubt und voila, die Grafiken sind auch ohne Scheunentor verfügbar (abschaltbar sind sie ja schon) 

5.2022
- Display Helligkeit auf dem Intern Display ist jetzt einstellbar. Hierzuf  im Color-Thema oben links auf das Datum/Uhrzeit Element tippen.
 ![display_color_Helligkeit](https://user-images.githubusercontent.com/89247538/171632336-a993bf4a-72f0-4677-bd8f-d5394fc75627.png) ![display_color_status](https://user-images.githubusercontent.com/89247538/171632896-04ba30c0-762f-4684-bb59-5ccbbd8b9d57.png)
- Color Thema hat nun eine möglichkeit zur normalen Darstellung zu wechseln. (Home Button). Nur bei Debuglevel=2 sichtbar. Ausserdem muss eine PIN definiert und eingegben worden sein. Erst dann erscheint der Home-Button
- In Hauptmenue verzweigung zum Display-Thema im Debuglevel=2
- Ladelog Jahresexport zugefügt

7.2022
- HTTPS:// ermöglicht. Hierzu apache Proxy-wstunnel benutzt um TLS zu für mqtt zu ermöglichen.
- 
![firefox_for_openWBCloud2_ff](https://user-images.githubusercontent.com/89247538/162584594-13cdf614-d317-4a75-95ba-29594fc64b7e.png)

Um auch Firefox (99.0 64B Windows) verwenden zu können muss man in about:config folgendes Einstellen:
![firefox_for_openWBCloud](https://user-images.githubusercontent.com/89247538/162584648-74edda22-49f4-41cc-8a3b-dde2aa2f192b.png)

- Die Konfiguration des integrierten Display ist in die Installatiom mit aufgenommen worden (Chrome-browser und Config)
- Das Interne Dispaly-Thema "Color" bekommt links zu normalem Web Oberfläche und einige Detailänderungen zur besseren Lesbarkeit. Zusätzliche Spalte mit der Temp1.
- Mqtt-Puller zugefügt. Er kopiert die Daten aus dem MQTT der echten OpenWB und beschreibt die MQTT  Topics der Test-OpenWB.
- Meine RCT2 Module wurden noch weiter optimiert. Die Zeit um die 23/39 Werte abzufragen liegt nun bei unter einer Sekunde. Die gesamte Regelzeit liegt bei 3 bis 4 Sekunden.
- Das Color schema wurde erweitert um eine Angabe zur möglichen Reichweite mit dem aktuellen SoC des PKW. ![New01_ff](https://user-images.githubusercontent.com/89247538/181804438-a97009fc-f7bd-4059-9e83-5c7882620b39.png)  Die Infomation werden vom SOC Module geliefert.

8.2022
- Interner Debug-mode zur Anzeige der beeinflussten Variablen auf den Setup-Seiten.
- Absicherung des Update-processes gegen gleichzeitiges laufen von cron*.sh
- Umstellung auf https und "Same Site=lax", sowie tunneln der MQTT Daten über den HTTPS Port. Auch nutzbar für MQTT-Desktop.
- Übernahme von Trivialänderungen der snaptec/openWB z.b Einrückungen, optionale "" oder Kommentatre.- 
- Übernahme vom einigen änderungen an den Basismodule aus der snaptec/openWB.
- Backup/Restore überarbeitet. Es wird der Zustand des MQTT Servers mitgesichert. Der Dateiname enthält den Hostnamen und die IP Addresse. <br>
  ![backup](https://user-images.githubusercontent.com/89247538/185985391-9207616a-4465-4981-b309-8e630eb34779.png) <br>Die Mitschrift im oberen Kasten erscheint nur wenn der Debugmode >0 gesetzt wird.
		
1.2023
- Colors Thema überarbeitet. Änderungen von snaptec 1.9.28x übernommen. Backport um Firefox68/Kitkat4.4 zu ermöglichen. Indexfehler LP behoben.

![Screenshot_2023-01-06-00-24-05](https://user-images.githubusercontent.com/89247538/210899669-53230389-45b5-4f9c-b18e-d7bea1665cb4.png)

( Screenshot von einem Galaxy Tab3 10" und Firefox68 auf KitKat 4.4.1 ) 

9.1.2023 Letzte Aktualisierung des Colour-Themas. Runde Ecken soweie Eingenverbrauch und Autarkiegrad übernommen. Die Visuelen Ändergnen wurden nicht übernommen da sie auf meinen Geräten zu einer schlechteren Lesebarkeit führen würde. Die weitere Entwicklung auf Snaptec geht nun in Richtung openWB 2.0 (mit VUE).
