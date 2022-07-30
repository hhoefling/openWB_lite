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

Die SD-Karte ist eine 32GB Type in Disk /dev/mmcblk0

ir legen zuerst die Partionen und die Mount-Points an.

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
Wir merken uns den "Disk identifier", hier 592196a7 ohne das 0x Prefix 
Nun müssen wir die Filesystem anlegen lassen.
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
Anlegen der Mount-Points (auf der Root SD)



