#!/bin/bash
#
# debug=$(</var/www/html/openWB/ramdisk/debug)
BSELF=$(cd `dirname $BASH_SOURCE`  &&  pwd)

debug=${debug:-3}
ip=${bezug1_ip:-192.168.208.63}

export PYTHONIOENCODING=utf8 

if (( debug > 2 )) ; then
  echo "BSelf:$BSELF debug:$debug"
  python3 $BSELF/rct_read_wr_info2.py -v --ip=$ip 2>&1
else
  if (( debug > 1 )) ; then
    echo $BSELF
  fi
  python3 $BSELF/rct_read_wr_info2.py --ip=$ip 2>&1
fi

exit 0

