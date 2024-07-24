#!/bin/sh
#
# ACHTUNG KEIN BASH Script, sondern dash/sh 
#

OPENWBBASEDIR=/var/www/html/openWB

########## Re-Run as PI if not
USER=${USER:-`id -un`}
# [ "$USER" != "pi" ] && exec sudo -u pi "$0" -- "$@"

cd /var/www/html/openWB || exit 0
openwbDebugLog()
    {
	  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      d1=$1
      shift; shift;
      echo "$timestamp $$ $d1 $*" >>/var/www/html/openWB/ramdisk/openWB.log
    }

# Hal1 
# debloggerip=""
debloggerip=${debloggerip:-192.168.208.1}
# echo $debloggerip

rlog()  # rlog TAG Messages
{
 if [ -n "$debloggerip" ] ; then
   d=$1
   shift;
   logger --id=$$ -t $d -n $debloggerip -- $*
 fi
}



TAG=SHED
REGEL=regel.sh
dspeed=${dspeed:-0}


#read ip<ramdisk/ipaddress 2>/dev/null
ip=${ip:-1.1.1.4}
sleeper=$(echo $ip | cut -d "." -f 4)
sleeper=$(( (sleeper % 10) -1 ))
sleep $sleeper

# dspeed=2

case $dspeed in
	1)
		ticksec=5
		;;
	2)
		ticksec=20
		;;
	3)
		ticksec=60
		;;
	*)
		ticksec=10
		;;
esac

openwbDebugLog "MAIN" 1 "SHED regler starti as $USER (dspeed:$dspeed ticksec:$ticksec)"

loop=0
while [ "$loop" -lt 60 ] ; do

   if pidof -xs $REGEL >/dev/null ; then
  	rlog $TAG "$REGEL is still running, skip (loop:$loop)"
  	openwbDebugLog "MAIN" 0 "SHED Skip $REGEL, is still running (loop:$loop)"
  else
    openwbDebugLog "MAIN" 1 "SHED Start $REGEL & (loop:$loop)"
   	env -i - HOME=/home/pi ./$REGEL >>ramdisk/openWB.log 2>&1 &
   fi 
   # rlog $TAG sleeps for $ticksec
  loop=$(( loop + ticksec ))
  if [ $loop -lt 60 ] ; then
      sleep $ticksec
  fi
done
openwbDebugLog "MAIN" 2 "SHED Exit regler"
exit 0
