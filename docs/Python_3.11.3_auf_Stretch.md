

## Ich versuche Python 3.11.3 auf einem openWB-Stretch Pi3b+ zu installieren. ##


### Zuerst muss openssl 1.1.1 installiert werden ###
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

## Auch diese Libs muss nachinstalliert werden ##

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
warten.... (~40 Minuten)

es geht weiter...

Dann

```
0:00:00 load avg: 2.56 Run tests sequentially (timeout: 20 min)
0:00:00 load avg: 2.56 [ 1/44] test_array
0:00:21 load avg: 2.84 [ 2/44] test_base64
0:00:29 load avg: 2.88 [ 3/44] test_binascii
0:00:31 load avg: 2.88 [ 4/44] test_binop
0:00:33 load avg: 2.81 [ 5/44] test_bisect
0:00:35 load avg: 2.81 [ 6/44] test_bytes
0:01:59 load avg: 3.52 [ 7/44] test_bz2 -- test_bytes passed in 1 min 24 sec
0:02:00 load avg: 3.52 [ 8/44] test_cmath -- test_bz2 skipped
0:02:04 load avg: 3.40 [ 9/44] test_codecs
0:02:46 load avg: 2.81 [10/44] test_collections -- test_codecs passed in 42.3 sec
0:03:10 load avg: 2.74 [11/44] test_complex
0:03:16 load avg: 2.60 [12/44] test_dataclasses
0:03:28 load avg: 2.39 [13/44] test_datetime
0:04:13 load avg: 2.17 [14/44] test_decimal -- test_datetime passed in 45.1 sec
0:06:28 load avg: 2.14 [15/44] test_difflib -- test_decimal passed in 2 min 15 sec
0:06:55 load avg: 1.96 [16/44] test_embed
0:08:29 load avg: 2.23 [17/44] test_float -- test_embed passed in 1 min 34 sec
0:08:36 load avg: 2.22 [18/44] test_fstring
0:08:52 load avg: 2.33 [19/44] test_functools
0:09:02 load avg: 2.29 [20/44] test_generators
0:09:10 load avg: 2.17 [21/44] test_hashlib
0:09:26 load avg: 2.06 [22/44] test_heapq
0:09:42 load avg: 1.97 [23/44] test_int
0:10:13 load avg: 2.36 [24/44] test_itertools -- test_int passed in 31.1 sec
0:12:15 load avg: 3.65 [25/44] test_json -- test_itertools passed in 2 min 1 sec
0:12:59 load avg: 4.00 [26/44] test_long -- test_json passed in 44.8 sec
0:14:23 load avg: 3.51 [27/44] test_lzma -- test_long passed in 1 min 23 sec
0:14:25 load avg: 3.31 [28/44] test_math -- test_lzma skipped
0:15:41 load avg: 3.58 [29/44] test_memoryview -- test_math passed in 1 min 16 sec
0:15:55 load avg: 3.53 [30/44] test_operator
0:15:59 load avg: 3.53 [31/44] test_ordered_dict
0:16:27 load avg: 3.60 [32/44] test_patma
0:16:32 load avg: 4.03 [33/44] test_pickle
0:18:59 load avg: 3.41 [34/44] test_pprint -- test_pickle passed in 2 min 26 sec
0:19:06 load avg: 3.26 [35/44] test_re
0:19:29 load avg: 3.15 [36/44] test_set
0:21:21 load avg: 2.54 [37/44] test_sqlite3 -- test_set passed in 1 min 51 sec
0:21:22 load avg: 2.54 [38/44] test_statistics -- test_sqlite3 skipped
0:23:53 load avg: 1.78 [39/44] test_struct -- test_statistics passed in 2 min 30 sec
0:24:09 load avg: 1.75 [40/44] test_tabnanny
0:24:16 load avg: 1.71 [41/44] test_time
0:24:24 load avg: 1.65 [42/44] test_unicode
0:25:15 load avg: 1.92 [43/44] test_xml_etree -- test_unicode passed in 51.8 sec
0:25:31 load avg: 1.86 [44/44] test_xml_etree_c
Total duration: 25 min 55 sec
Tests result: SUCCESS
```

Und weiter gehts
das ganze ended mit
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


https://linuxhint.com/update-open-ssl-raspberry-pi/

## Benutzung von python 3.11.3 ##

```
python3.11 -m pip install --upgrade pip
python3.11 -m pip install aiohttp
python3.11 -m pip install pyjwt bs4 paho-mqtt
python3.11 -m pip list
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
pip                23.1.2
PyJWT              2.6.0
setuptools         65.5.0
soupsieve          2.4.1
yarl               1.9.2

```
	

