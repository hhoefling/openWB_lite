#!/bin/bash
# called as user  pi
OPENWBBASEDIR=$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $OPENWBBASEDIR
source "$OPENWBBASEDIR/helperFunctions.sh"

#get Gateway for Connection
gateway=$(ip route get 1 | awk '{print $3;exit}')
#get device
mydevice=$(ip route get 1 |awk '{print $5;exit}')


#ping the gateway to see if the connection is OK
ping -c1 $gateway >/dev/null
ret=$?
if (( $ret != 0 )); then
	openwbDebugLog "MAIN" 1 "******* pingcheck to Gateway ${gateway} with Device ${mydevice} Timed Out *****"
else
	openwbDebugLog "MAIN" 1 "pingcheck to Gateway ${gateway} with Device ${mydevice} Ok"
fi
