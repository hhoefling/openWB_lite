#!/bin/bash
# send fo rmqtt RequestMonthGraph=date
input=$1

# Get Data for first Day of next Month
month=${input: -2}
year=${input:: 4}
month=$(( ${month#0} +1))
if (( month >12 )) ; then
	month=1
	year=$(( ${year#0} +1))
fi
printf -v nextmonth '%04d%02d' $year $month

if [ -f /var/www/html/openWB/web/logging/data/monthly/$nextmonth.csv ]  ; then
  firstload=$(head -n 1 /var/www/html/openWB/web/logging/data/monthly/$nextmonth.csv)
else
  firstload=""
fi

mosquitto_pub -t openWB/system/MonthGraphData1 -r -m "$(</var/www/html/openWB/web/logging/data/monthly/$1.csv tail -n +0 | head -n 24)" &
mosquitto_pub -t openWB/system/MonthGraphData2 -r -m "$(</var/www/html/openWB/web/logging/data/monthly/$1.csv tail -n +25 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthGraphData3 -r -m "$(</var/www/html/openWB/web/logging/data/monthly/$1.csv tail -n +50 | head -n 25)" &
mosquitto_pub -t openWB/system/MonthGraphData4 -r -m "$firstload" &
#mosquitto_pub -t openWB/system/MonthGraphData4 -r -m "$(</var/www/html/openWB/web/logging/data/monthly/$1.csv tail -n +"75" | head -n "$((100 - 75))")" &
mosquitto_pub -t openWB/system/MonthGraphData5 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData6 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData7 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData8 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData9 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData10 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData11 -r -m "0" &
mosquitto_pub -t openWB/system/MonthGraphData12 -r -m "0" &

(sleep 3 && mosquitto_pub -t openWB/set/graph/RequestMonthGraph -r -m "0")& 
