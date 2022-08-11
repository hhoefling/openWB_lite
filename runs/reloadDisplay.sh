#!/bin/bash
log=/var/log/openWB.log
echo $0 $* >>$log

XAUTHORITY=~pi/.Xauthority DISPLAY=:0 xset dpms force on >>$log 2>&1

exit 0


