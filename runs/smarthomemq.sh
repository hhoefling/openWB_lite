#!/bin/bash
#
# now in packes/smarthome/smarthomemq.py 
# modules/smarthome ist for old smarthomehandler
# packages/modules/smarthome is used for this version
#
# pwd >/tmp/x
# env >>/tmp/x
python3 packages/smarthome/smarthomemq.py >>/var/www/html/openWB/ramdisk/smarthome.log 2>&1 &
exit 0
