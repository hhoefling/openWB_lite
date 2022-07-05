#!/bin/bash
exit 0
# Remove OpenWB from Raspi
cd /var/www/html

kill $(ps aux |grep '[s]marthomehandler.py' | awk '{print $2}')
kill $(ps aux |grep '[m]qttsub.py' | awk '{print $2}')
kill $(ps aux |grep '[m]qttpuller.py' | awk '{print $2}')
kill $(ps aux |grep '[p]uller.py' | awk '{print $2}')

umount /var/www/html/openWB/ramdisk
cp /etc/fstab /tmp/fstab
cat /tmp/fstab | grep -v openWB >/etc/fstab
rm /var/spool/cron/crontabs/root
rm /var/spool/cron/crontabs/pi
rm -r /var/www/html/openWB
/etc/init.d/mosquitto stop
rm /etc/mosquitto/conf.d/openwb.conf
rm /etc/sudoers.d/010_pi-nopasswd
ls -l




