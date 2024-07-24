#!/bin/bash

# echo "echo huhu >>/var/www/html/openWB/ramdisk/events.log "  | at -q O now + 10 minutes

for j in $(sudo atq -q O | cut -f 1 | sort -n)
 do 
   a=$( sudo atq -q O | grep -P "^$j\t")
   b=$(sudo at -c "$j" | tail -n 2)
   echo  $a $b
 done
						




