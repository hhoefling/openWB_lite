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
a2ensite *openwb*
systemctl restart apache2



					



