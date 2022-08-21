## Umstellung einer openWB 1.9.27x auf HTTPS ##

**Es wird eine openWB box mit Strech (Debian 9) auf HTTPS umgestellt.**

Zuerst einmal die notigen apache module aktivieren.

a2enmod ssl
systemctl restart apache2


Schlüsselpaar neu erzeugen, z.b Nach änderung des Hostnamens.
```
sudo make-ssl-cert generate-default-snakeoil --force-overwrite
systemctl reload apache2
```

Zertifkat anzeigen (wegen Hostname, Laufzeit)
```
openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -text
```




