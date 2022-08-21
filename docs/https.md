## Umstellung einer openWB 1.9.27x auf HTTPS ##

**Es wird eine openWB box mit Strech (Debian 9) auf HTTPS umgestellt.**

Zuerst einmal die notigen apache module aktivieren.

sudo a2enmod ssl
sudo a2enmod proxy_wstunnel
sudo systemctl restart apache2


Schlüsselpaar neu erzeugen, z.b Nach änderung des Hostnamens.
```
sudo make-ssl-cert generate-default-snakeoil --force-overwrite
sudo systemctl reload apache2
```

Zertifkat anzeigen (wegen Hostname, Laufzeit)
```
openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -text
```

Neue https Konfiguration aktivieren


Datei:  /etc/apache2/sites-available/001-openwb_ssl.conf
```
IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin webmaster@localhost
                DocumentRoot /var/www/html
                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on

                SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

                ProxyPass "/mqtt" "ws://localhost:9001"
                ProxyPass "/ws" "ws://localhost:9001"
        </VirtualHost>
</IfModule>
```

Aktivieren der neuen https Konfiguration
```
sudo a2ensite *openwb*
sudo systemctl restart apache2
```



Damit auch die MQTTT Ankopplung mit den WebSockets weiterhin klappt sind noch ein paar weiter Änderungen nötig. In meinen openwb_lite sind diese änderungen schon alle eingearbeitet. Wer eine original openWB über https betreiben will muss also noch weiter änderungen einpflegen. Es ist eigendlich immer das gleiche. In den Jscript files die für die MQTT Konnection zuständig sind steht immer etwas der Art:

setupMqttServices.js
<pre><code>
//Connect Options
var isSSL = location.protocol == 'https:'
var options = {
	timeout: 5,
	useSSL: isSSL,
	//Gets Called if the connection has been established
	onSuccess: function () {
		retries = 0;
		topicsToSubscribe.forEach((topic) => {
			client.subscribe(topic[0], { qos: 0 });
		});
		subscribeDayGraph(new Date());
	},
	//Gets Called if the connection could not be established
	onFailure: function (message) {
		setTimeout(function () { client.connect(options); }, 5000);
	}
};

var clientuid = Math.random().toString(36).replace(/[^a-z]+/g, "").substr(0, 5);
var client = new Messaging.Client(location.hostname, 9001, clientuid);
</pre></code>

Daraus wird dann

<pre><code>
//Connect Options
var isSSL = location.protocol == 'https:'
<b>port = isSSL ? 443 : 9001;</b>
var options = {
	timeout: 5,
	useSSL: isSSL,
	//Gets Called if the connection has sucessfully been established
	onSuccess: function () {
		retries = 0;
		topicsToSubscribe.forEach((topic) => {
			client.subscribe(topic[0], { qos: 0 });
		});
		subscribeDayGraph(new Date());
	},
	//Gets Called if the connection could not be established
	onFailure: function (message) {
		setTimeout(function () { client.connect(options); }, 5000);
	}
};

var clientuid = Math.random().toString(36).replace(/[^a-z]+/g, "").substr(0, 5);
var client = new Messaging.Client(location.hostname, <b>port</b>, clientuid);
</pre></code>

Nun wird bei Verwendung von HTTPS die MQTT Verbindung auch über HTTPS getunnelt. (daher das <b>proxy_wstunnel</b> weiter oben)

Diese Änderung ist bei allen Themen nötig. Auch bei den Display-Themen sofern diese ebenfalls über HTTTPS im Browser verwendet werden sollen.

Wer den MQTT-Explorer verwendet kann die Verbindung ebenfalls über den HTTPS Port leiten.
Also 
<pre>
Encryption ON
Validate certificate OFF (Leider da kein "officielles" Zerticate)
protokoll  ws:// 
host: <<>> Hostname oder IP-Adresse
Port: 443
Basepath mqtt
</pre>










