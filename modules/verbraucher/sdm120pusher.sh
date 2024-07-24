#!/bin/bash

vnr=${1:-"1"}
dev=${2:-"none"}
idnr=${3:-"9"}
puthost=${4:-"192.168.208.3"}
putvnr=${5:-"1"}

x=${0/%sh/py}
openwbDebugLog "MAIN" 0 "call $x to get V$vnr $dev:$idnr and push to $puthost target:$putvnr"


python3 /var/www/html/openWB/modules/verbraucher/sdm120pusher.py $vnr $dev $idnr $puthost $putvnr

exit 0

