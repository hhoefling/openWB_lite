#!/bin/bash
# send by MQTT RequestDayGraph=Date

mosquitto_pub -t openWB/system/DayGraphData1 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +0 | head -n 24)" &
mosquitto_pub -t openWB/system/DayGraphData2 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +25 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData3 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +50 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData4 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +75 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData5 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +100 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData6 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +125 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData7 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +150 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData8 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +175 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData9 -r  -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +200 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData10 -r -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +225 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData11 -r -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +250 | head -n 25)" &
mosquitto_pub -t openWB/system/DayGraphData12 -r -m "$(</var/www/html/openWB/web/logging/data/daily/$1.csv tail -n +275 | head -n 25)" &

(sleep 3 && mosquitto_pub -t openWB/set/graph/RequestDayGraph -r -m "0")& 
