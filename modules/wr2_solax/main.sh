#!/bin/bash

python /var/www/html/openWB/modules/wr2_solax/solax.py $pv2ip

pv2watt=$(</var/www/html/openWB/ramdisk/pv2watt)
echo $pv2watt
