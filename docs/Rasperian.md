**Service unter Stretch**

```
/etc# service --status-all
 [ - ]  alsa-utils
 [ + ]  apache-htcacheclean
 [ + ]  apache2
 [ + ]  avahi-daemon
 [ - ]  bluetooth
 [ - ]  console-setup.sh
 [ + ]  cron
 [ + ]  dbus
 [ + ]  dhcpcd
 [ - ]  dnsmasq
 [ + ]  dphys-swapfile
 [ + ]  fake-hwclock
 [ - ]  hostapd
 [ - ]  hwclock.sh
 [ - ]  keyboard-setup.sh
 [ + ]  kmod
 [ + ]  lightdm
 [ + ]  mosquitto
 [ + ]  networking
 [ - ]  nfs-common
 [ - ]  paxctld
 [ - ]  plymouth
 [ - ]  plymouth-log
 [ + ]  procps
 [ + ]  raspi-config
 [ - ]  rpcbind
 [ - ]  rsync
 [ + ]  rsyslog
 [ + ]  ssh
 [ - ]  sudo
 [ + ]  triggerhappy
 [ + ]  udev
 [ - ]  x11-common
```

**Servce unter Buster**

```
:/etc# service --status-all
 [ - ]  alsa-utils
 [ - ]  apache-htcacheclean
 [ + ]  apache2
 [ + ]  avahi-daemon
 [ + ]  bluetooth
 [ - ]  console-setup.sh
 [ + ]  cron
 [ + ]  cups
 [ + ]  cups-browsed
 [ + ]  dbus
 [ + ]  dhcpcd
 [ - ]  dnsmasq
 [ + ]  dphys-swapfile
 [ + ]  fake-hwclock
 [ - ]  fio
 [ - ]  hostapd
 [ - ]  hwclock.sh
 [ - ]  keyboard-setup.sh
 [ - ]  kmod
 [ + ]  lightdm
 [ + ]  mosquitto
 [ + ]  networking
 [ - ]  nfs-common
 [ - ]  paxctld
 [ - ]  plymouth
 [ - ]  plymouth-log
 [ + ]  procps
 [ + ]  raspi-config
 [ ? ]  rng-tools
 [ - ]  rpcbind
 [ - ]  rsync
 [ + ]  rsyslog
 [ - ]  saned
 [ + ]  ssh
 [ - ]  sudo
 [ + ]  triggerhappy
 [ + ]  udev
 [ - ]  x11-common

```

**Installation Mosquitto 2.0.12**

Um auch TLS Nutzen zu können ist ein aktellerer mosquitto nötig.

file /etc/apt/source.list.d/mosquitto-buster.list
```
deb https://repo.mosquitto.org/debian buster main

```

```
cd /tmp
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
apt-key add mosquitto-repo.gpg.key
apt update
apt install mosquitto/buster
```

Fundstuck zum Display

```
If only using the console and not a desktop environment, you can edit the kernel’s /boot/firmware/cmdline.txt file to pass the required orientation to the system.

To rotate the console text, add video=DSI-1:800x480@60,rotate=90 to the cmdline.txt configuration file. Make sure everything is on the same line; do not add any carriage returns. Possible rotation values are 0, 90, 180 and 270.
```




