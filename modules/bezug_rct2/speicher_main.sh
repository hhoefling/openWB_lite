#!/bin/bash

# debug=$(</var/www/html/openWB/ramdisk/debug)
BSELF=$(cd `dirname $BASH_SOURCE`  &&  pwd)
debug=${debug:-3}
ip=${bezug1_ip:-192.168.208.63}



if (( debug > 2 )) ; then
  echo "BSelf:$BSELF debug:$debug"
  python3 $BSELF/rct_read_speicher.py -v --ip=$ip 2>&1
else
  python3 $BSELF/rct_read_speicher.py --ip=$ip  >>/var/log/openWB.log 2>&1
fi

	  
#
# return no value
#
exit 0
