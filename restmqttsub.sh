#!/bin/bash
echo "Restart mqttsub.py"
sudo pkill -f "python3 /var/www/html/openWB/runs/mqttsub.py" >/dev/null
sudo -u pi python3 /var/www/html/openWB/runs/mqttsub.py >>/var/www/html/openWB/ramdisk/mqtt.log 2>&1 &
ps -elf | grep "[m]qttsub"


