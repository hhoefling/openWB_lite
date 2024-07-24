#!/bin/bash
input=$1

mosquitto_pub -t openWB/system/MonthLadelogData1 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +0 | head -n 24)" &
mosquitto_pub -t openWB/system/MonthLadelogData2 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +25 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData3 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +50 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData4 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +75 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData5 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +100 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData6 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +125 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData7 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +150 | head -n 25)" & 
mosquitto_pub -t openWB/system/MonthLadelogData8 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +175 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData9 -r  -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +200 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData10 -r -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +225 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData11 -r -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +250 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthLadelogData12 -r -m "$(</var/www/html/openWB/web/logging/data/ladelog/$1.csv tail -n +275 | head -n 25)" &
(sleep 3 && mosquitto_pub -t openWB/set/graph/RequestMonthLadelog -r -m "0")& 
