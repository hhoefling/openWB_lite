#!/bin/bash

OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)

# for backward compatibility only
# functionality is in soc_manuallp2Skoda
$OPENWBBASEDIR/modules/soc_manualSkoda/main.sh 2
exit 0
