

##  Python 3.11.3 ##
 Ich versuche auf einem openWB-Stretch Pi3b+ Python 3.11.3 zu installieren. Dies ist nötig um das Skoda-Citigo SOC Module
 laufen lassen zu können. Das erfordert mindestens Python-3.9

### Voraussetzungen: ###

### openssl 1.1.1 ###
Download von https://www.openssl.org/source/

Ich habe diese Version verwendet.
```
9650  	2023-Feb-07 15:38:20  	openssl-1.1.1t.tar.gz (SHA256) (PGP sign) (SHA1)
```

Entpackt in /usr/local/src

```
tar -xvzf openssl-1.1.1t.tar.gz
./config
make
make install
``` 	
### Nun die Libs umlinken ###
 
```
cd /usr/lib/arm-linux-gnueabihf
mv libssl.so.1.1 libssl.so.1.1.0
mv libcrypto.so.1.1  libcryto.so.1.1.0
ln -fs /usr/local/lib/libssl.so.1.1 libssl.so.1.1
ln -fs /usr/local/lib/libssl.so.1.1 libssl.so
ln -fs /usr/local/lib/libcrypto.so.1.1 libcrypto.so.1.1
ln -fs /usr/local/lib/libcrypto.so.1.1 libcrypto.so
cd /etc/ld.so.conf.d/
vi openssl.1.1.1.conf 
i /usr/local/lib
wq

ldconfig -v

```

Danach testen
```
root@pi67:~# openssl version
OpenSSL 1.1.1t  7 Feb 2023
```

## lib-ffi ##

```
apt install libffi-dev
```

## Nun Python3.11.3 installieren ##

Go to

https://www.python.org/downloads/

Download z.b Python 3.11.3 Gzipped Source-Tarball to /opt auf dem Pi

```
cd /opt
tar -zxvf Python-3.11.3.tgz
cd Python-3.11.3
./configure --enable-optimizations
sudo make altinstall
```
warten.... 
Auf dem 3B+ dauert das über zwei Stunden, inclusive Selbsttest.

```
Successfully installed pip-22.3.1 setuptools-65.5.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting 
behaviour with the system package manager. It is recommended to use a 
virtual environment instead: https://pip.pypa.io/warnings/venv
```

Dann noch ein 
```
strip /local/bin/python3.11
```
Um die Datei von ~16MB auf 3.8Mb zu reduzieren.

( anleitung  von  https://linuxhint.com/update-open-ssl-raspberry-pi/ )


## python 3.11.3 Module ##

```
python3.11 -m pip install --upgrade pip
python3.11 -m pip install aiohttp
python3.11 -m pip install pyjwt bs4 paho-mqtt urllib3
python3.11 -m pip install pymodbus==2.5.3
ython3.11 -m pip list

Package            Version
------------------ -------
aiohttp            3.8.4
aiosignal          1.3.1
async-timeout      4.0.2
attrs              23.1.0
beautifulsoup4     4.12.2
bs4                0.0.1
charset-normalizer 3.1.0
frozenlist         1.3.3
idna               3.4
multidict          6.0.4
paho-mqtt          1.6.1
pip                23.1.2
PyJWT              2.6.0
pymodbus           2.5.3
pyserial           3.5
setuptools         65.5.0
six                1.16.0
soupsieve          2.4.1
urllib3            2.0.1
yarl               1.9.2

```
	
Damit klappt nun die Soc-Abfrage vom 3B+ aus.
(Bisher wurde von mir eine VM mit Pyhton3.9 verwendet)

