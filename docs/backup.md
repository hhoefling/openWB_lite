# Backup

Um ein Backup zu erzeugen gibt es viele Wege.
Auf jeden Fall ist ein Root zugriff auf den Raspi erforderlich.

**1  IMG Datei erstellen über das Netzwerk**

Eine Möglchkeit besteht darin einfach die ganze SD Karte komplett zu kopieren.
Hier wird häufig vorgeschlagen die SD Karte auszubauen und auf einem PC zu Klonen.

Ich verwende hierzu meinen Linux-Rechner der hier im Hausnetz integriert ist.
Es geht aber auch alles was via ssh erreichbar ist und genug Platz hat.

Diese Kommando wird in einer Root-Shell auf dem Raspi ausgeführt. 
```
dd if=/dev/mmcblk0 bs=512 | ssh root@hal1 "dd of=/data9/openWB_SD_16GB.IMG 
```
Hierbei ist */dev/mcblk0* die SD Karte im laufenden Raspi. (im SD Slot, kein USB!)

*hal1* ist mein Linux Host 

*/data9/openWB_SD_16GB.IMG* die Backupdatei die auf dem Host abgelegt wird.

Das ganze dauert bei einem 100'er Ethernet einige Minuten. Also Geduld!

Die Backupdatei kann mit auf eine neue gleichgroße neue SD Karte kopiert werden.
Beim ersten Start wird sich das Filesystem selbst prüfen (fsck) da es "online" kopiert wurde.
Probleme sind dabei bisher nicht aufgetreten. 


**2 Kopieren auf anders Speichermedium**

Ein weiteres Speichermedium per USB direkt an den Raspi anschliesen.
Bei mir möglch da die Box im Haus montiert ist und ein öffnen bzw offen lassen beim Backup 
durchaus möglich ist.

Ich verwende hier in der Anleitung eine betagte 64GB-SSD im 2.5" Format. Die ist mit einem USB Adpater per USB Kabel am Raspi angeschlossen.

Nach dem Anschlissen prüfen wie die SSD erreichbat ist.

```
root@pi61:~# fdisk -l
Disk /dev/mmcblk0: 29,7 GiB, 31914983424 bytes, 62333952 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00121dac

Device         Boot  Start      End  Sectors  Size Id Type
/dev/mmcblk0p1        8192   532479   524288  256M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      532480 62333951 61801472 29,5G 83 Linux


Disk /dev/sda: 58,7 GiB, 63023063040 bytes, 123091920 sectors
Disk model: SDSSDP064G
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 33553920 bytes
Disklabel type: dos
Disk identifier: 0x592196a7
root@pi61:~#
```
Die SSD (hier /dev/sda) hat noch keine Partitionen. 

Die SD-Karte ist eine 32GB Type in  /dev/mmcblk0

Wir legen zuerst die Partionen an.
Eine kleine Boot-Partion im W95/Fat32 format mit 40-256 MB
Eine ca. 15GB Große Root-Partione im  ext4 Format.
Der Rest der SSD bleibt erst mal frei.

```
root@pi61:~#fdisk /dev/sda
n p 1 <ret> 524288 <ret>y
t 0c
n p 2 <ret> +15G <ret>
t 2 83
p
Disk /dev/sda: 58,7 GiB, 63023063040 bytes, 123091920 sectors
Disk model: SDSSDP064G
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 33553920 bytes
Disklabel type: dos
Disk identifier: 0x592196a7

Device     Boot  Start      End  Sectors  Size Id Type
/dev/sda1        65535   524288   458754  224M  c W95 FAT32 (LBA)
/dev/sda2       589815 32046614 31456800   15G 83 Linux

Filesystem/RAID signature on partition 1 will be wiped.
w
root@pi61:~#

```
Wir merken uns den "Disk identifier", hier 592196a7 ohne das 0x Prefix.

Nun müssen wir die Filesystem anlegen lassen und auch die Mounts Pointes auf der SD erstellen.

```
root@pi61:~# mkdosfs /dev/sda1
mkfs.fat 4.1 (2017-01-24)
root@pi61:~#
root@pi61:~# mkfs -t ext4 /dev/sda2
mke2fs 1.44.5 (15-Dec-2018)
Creating filesystem with 3932100 4k blocks and 983040 inodes
Filesystem UUID: f54278a9-c763-43af-8193-0159029b1427
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@pi61:~#
root@pi61:/# mkdir /media/bootfs
root@pi61:/# mkdir /media/rootfs

```

Nun können wir die neuen Partitionen mounten.
```
root@pi61:/# mount /dev/sda1 /media/bootfs
root@pi61:/# mount /dev/sda2 /media/rootfs/
root@pi61:/# df
Dateisystem    1K-Blöcke Benutzt Verfügbar Verw% Eingehängt auf
/dev/root       30351740 4635600  24430496   16% /
...
/dev/mmcblk0p1    258095   49348    208747   20% /boot
...
/dev/sda1         229132       0    229132    0% /media/bootfs
/dev/sda2       15416024   40984  14572236    1% /media/rootfs

```
Wie haben nun zwei neue Partionen erreichbar.
Jetzt kopieren wird die Dateien rüber. Keine IMG Kopie!!!
```
root@pi61:/# cp -rpx /boot/* /media/bootfs/.
root@pi61:/# cp -rpx / /media/rootfs/.
root@pi61:/# df
Dateisystem    1K-Blöcke Benutzt Verfügbar Verw% Eingehängt auf
/dev/root       30351740 4636244  24429852   16% /
...
dev/mmcblk0p1    258095   49348    208747   20% /boot
....
/dev/sda1         229132   49984    179148   22% /media/bootfs
/dev/sda2       15416024 4666100   9947120   32% /media/rootfs
root@pi61:/#

```
Aus 16% von 32GB sind 32% von 15GB geworden. Wir haben also die Root-Partition verkleinert.
Die Boot Partition ist fast gleich groß geworden.

Um diese SSD nun auch Bootfähig zu machen müssen wir ein paar Referenzen anpassen.

Im Boot-Filesystem:
```
root@pi61:/# cd media/bootfs/
root@pi61:/media/bootfs# more cmdline.txt
console=serial0,115200 console=tty1 root=PARTUUID=00121dac-02 rootfstype=ext4 fsck.repair=yes rootwait
```
Hier ist noch die PARTUUID der SD Karten einzutragen. Also mit beliebigem Editor ändern zu:
```
root@pi61:/media/bootfs# more cmdline.txt
console=serial0,115200 console=tty1 root=PARTUUID=592196a7-02 rootfstype=ext4 fsck.repair=yes rootwait
root@pi61:/media/bootfs#
```
Die Angabe root=PARTUUID=592196a7-02 deutet dann auf die zweite Partition der neu erzuegt SSD.
Hierbei ist es nun egal wo die Angschlossen wird (USB1-4 oder per SATA Karte) Sollange der "Disk identifier" sich nicht 
ändert bleiben die Einträge in der Configuration gleich.

Zweitens ist noch die fstab anzupassen.
```
root@pi61:/media/rootfs/etc# more fstab
proc            /proc           proc    defaults          0       0
PARTUUID=00121dac-01  /boot           vfat    defaults          0       2
PARTUUID=00121dac-02  /               ext4    defaults,noatime  0       1
# a swapfile is not a swap partition, no line here
#   use  dphys-swapfile swap[on|off]  for that
tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0
```

Auch hier ist zweimal die disk-Id auszutauschen. Also zu:
```
root@pi61:/media/rootfs/etc# more fstab
proc            /proc           proc    defaults          0       0
PARTUUID=592196a7-01  /boot           vfat    defaults          0       2
PARTUUID=592196a7-02  /               ext4    defaults,noatime  0       1
# a swapfile is not a swap partition, no line here
#   use  dphys-swapfile swap[on|off]  for that
tmpfs /var/www/html/openWB/ramdisk tmpfs nodev,nosuid,size=32M 0 0
root@pi61:/media/rootfs/etc#
```

Je nachdem ob Raspi-3 oder Raspi-4 kann nun die neuen SSD gebootet werden.
pi3 - SD Karte rausnehmen oder gegen leere austauschen
pi4 - Einfach anschliesen, die SSD hat vorrang vor der SD. Hier muss ich die SSD als anstöpseln wenn ich NICHT will das von Ihr gestartet wird.



