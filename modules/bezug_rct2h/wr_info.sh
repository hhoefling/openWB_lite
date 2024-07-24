#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
MODULEDIR=$(cd `dirname $0` && pwd)

# check if config file is already in env
if [[ -z "$debug" ]]; then
    . $OPENWBBASEDIR/loadconfig.sh
fi

verb=''
if (( debug > 2 )) ; then
 verb='-v'
fi
timeout -k 9 3 python3 $MODULEDIR/rct_read_wr_info2.py $verb --ip=$bezug1_ip


rc=$?
if  [[ ($rc == 143)  || ($rc == 124) ]] ; then
  echo "PV-Info Script timed out"
fi
exit $rc

