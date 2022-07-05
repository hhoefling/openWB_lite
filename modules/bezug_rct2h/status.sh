#!/bin/bash
SELF=$(cd `dirname $0`   &&  pwd)
OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
MODULEDIR=$(cd `dirname $0` && pwd)

# check if config file is already in env
if [[ -z "$debug" ]]; then
	. $OPENWBBASEDIR/loadconfig.sh
fi

if [ -n "$bezug1_ip" ]; then
  opt=" -v --info"
else
  echo "$0 Debughilfe bezug1_ip parameter not supplied use 192.168.208.63"
  bezug1_ip=192.168.208.63
  opt=" -v --info"
fi
#
#
timeout -k 9 10 python3 $SELF/rct_read_status.py $opt --ip=$bezug1_ip 



