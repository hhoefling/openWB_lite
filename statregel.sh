#!/bin/bash

echo -e "| Seconds | count |\n| ---: | --- |"; grep -Po '(?<=Regulation loop needs )\d+' /var/www/html/openWB/ramdisk/openWB.log | sort -n | uniq -c | sed -r 's/^[ ]*([0-9]+) ([0-9]+).*/| \2 | \1 |/'

