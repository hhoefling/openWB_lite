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




