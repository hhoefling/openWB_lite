#!/bin/bash
ps -elf | grep mqttsub.py

# restart mqttsub handler
echo "restart mqttsub handler..."
if ps ax |grep -v grep |grep "python3.*runs/mqttsub.py" > /dev/null
then
  echo "kill runnung mqttsub handler..."
  sudo kill $(ps aux |grep '[m]qttsub.py' | awk '{print $2}')
fi
cd /var/www/html/openWB
sudo -u pi python3 ./runs/mqttsub.py &
sleep 1

ps -elf | grep mqttsub.py

