#!/bin/bash
source /var/www/html/openWB/loadconfig.sh


sleep 2

if ((pushbenachrichtigung == 0 )); then
   echo "huhu $debug [$zielladenuhrzeitlp1] from testcharge" >>/var/www/html/openWB/ramdisk/event.log
fi   

