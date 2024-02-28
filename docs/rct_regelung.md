## Regelung der Batterie meines RCT DC6 ##

Um meinen Tibber Account besser zu nutzen ist es nötig den Netzbezug besser steuern zu können.
Nicht optimal ist es z.b wenn bei niedrigpreis der Hausakku voll ist. Dann zieht der PKW erst den
Hausakku leer bevor günstiger Netztbezug entsteht. Der DC6 kann ja 6kw aus dem AKku holen.
Wenn dann später der Strompreis wieder hoch ist, ist der Hausakku leer und es entsteht dann Netzbezug zum hohen Preis.
Auch schecht ist es wenn der niedrige Strompreis nicht genutzt werden kann um den Tagesverbrauch im Akku zu bunkern.
Das wird Wirschaftlich bei ca. 10Cent Unterschied zwischen Hoch/Tief-Preis. Diew kommt aber nicht so häufig vor wie man sich das erhoft.
Also wird der Haupnutzen darin liegen den Akku vor ungewünschter Entladung zu schützen.

Es wurden Eingriffe un die folgen Module gemacht:

- hook.sh
	- Sende "Ladestart" Event via mqtt
 	- Sende "Ladestop" Event via mqtt

- regel.sh
  
  	testet ob der Preis das Laden ermöglicht und sendet entsprechende Events über mqtt
  
- initRadisk.sh, updateConfig.sh, loadvars.sh
 
 	Diverse Scripte wurden um die neuen Variablen erweitert

- web/theme/colors-HH
 
	Stellt den Zustand dar und sendet Steuerevents via mqtt
	Der Tibber Preis wird dauerhaft und nicht nur bei "Sofortladen" dargestellt.

 - mqttsub.py
 
 	Empfängt die Events und ruft damit rct_setter.sh auf

- rct_setter.sh
 
	Nach diversen logischen Prüfungen wird via
	rct_set.py und rctw.py der Wechselrichrer beeinfusst
  
 Im wesendlichen werden zwei Funktionen realsiert und automatisiert aufgerufen.
 - "loadbat" - Stellt die Rahmenbedinungen im RCT so ein das er sich aus dem Netz aufläd. Hiebei wird eine "Erhaltungsladung" ausgelöst.
 - "NoDrain" - Verhindert die Endladung. Genauer, es wird der Maximale Endladestrom auf 1A reduziert. (~230W)

Beide Modes bekommen einen Watchdog der sie nach maxmal 3 Stunden wieder abschaltet. Warum 3 Stunden? Mein Akku ist mit der gewählten Ladeleistung von 3kw nach maximal 2,5 Std voll. Somit sollter der 3-Std Watchdog eigentlich nie erreicht werden. Beim PKW Laden sind nach 3 Std ~21kw in meinen Citygo gelanded. Ich hatte noch keinen Fall wo das Laden bis 80% länger als drei Stunden gedauert hat.

Beide modes sind nun Implementiert.

Im Colour Theme ist das Batterie Widget moodifiziert.

![tib2](https://github.com/hhoefling/openWB_lite/assets/89247538/cbd2c1d5-c082-470f-8dd2-9a875a99905a)

Dort wird der Status eingeblendet und dort ist ein Submenü zur Steuerung vorhanden.





 
