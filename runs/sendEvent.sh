#!/bin/bash
# Sende http-web events und/oder Pushover 
#
# wird asyncron in eigener Shell ausgeführt
# 
#
# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "Seems like openwb.conf is not loaded. Reading file."
	OPENWBBASEDIR=/var/www/html/openWB
	RAMDISKDIR="$OPENWBBASEDIR/ramdisk"
	DMOD="MAIN"
	# try to load config
	. $OPENWBBASEDIR/loadconfig.sh
	. $OPENWBBASEDIR/helperFunctions.sh
fi

# From openWB.conf use
# pushbplug, pushbstart, pushbstop, pushbenachrichtigung, pushovertoken, pushoveruser
# angesteckthooklp1_url, angesteckthooklp1
# abgesteckthooklp1_url, abgesteckthooklp1
# ladestarthooklp1_url, ladestarthooklp1
# ladestophooklp1_url, ladestophooklp1
# eventtomail eventosend


function sendPushover() # msg , eventname
{
	curl -s \
	--form-string "token=$pushovertoken" \
	--form-string "user=$pushoveruser" \
	--form-string "message=$1" \
	https://api.pushover.net/1/messages.json >> /dev/null
	openwbDebugLog "CHARGESTAT" 0 "pushover for $2 ausgeführt"
}


function sendHttpevent()	# url, enventname
{
	curl -s --connect-timeout 5 $1 > /dev/null
	openwbDebugLog "CHARGESTAT" 0 "WebHook $2 ausgeführt"
	openwbDebugLog "MAIN" 1 "Webhook $2 ausgeführt"
}

function xsendmail()  # event msg
{
   if (( eventtosend )) ; then
	to=${eventtomail:-webmaster}
	subject="$1 message from OpenWB/Raspi"
	msg="$1 $2"
	openwbDebugLog "CHARGESTAT" 0 "sendmail to $to"
	echo -e "To: ${to}\nSubject: ${subject}\n\n${msg}" | sendmail -t  &
   fi
}
 

openwbDebugLog "CHARGESTAT" 2 "Event [$1]:[$2]"
case $1 in

  plugin)
	 (( pushbplug == 1 )) && (( pushbenachrichtigung == 1 )) && (sendPushover $2 $1)
 	 (( angesteckthooklp1 == 1 )) && (sendHttpevent $angesteckthooklp1_url $1 )
 	 (( 1== 1 )) && (xsendmail "Angesteckt" $2)
  	 ;;
  	 
  plugout)
	(( abgesteckthooklp1 == 1 )) && (sendHttpevent $abgesteckthooklp1_url $1 )  
 	 (( 1== 1 )) && (xsendmail "Abgesteckt" $2)
    ;;
    
  startcharge)
 	(( pushbstart== 1 )) && (( pushbenachrichtigung == 1 )) && (sendPushover $2 $1)
 	(( ladestarthooklp1 == 1 )) && (sendHttpevent $ladestarthooklp1_url $1 )
 	 (( 1== 1 )) && (xsendmail "Ladestart" $2)
  	;;
	  	
  stopcharge)
 	(( pushbstop== 1 )) && (( pushbenachrichtigung == 1 )) && (sendPushover $2 $1)
 	(( ladestophooklp1 == 1 )) && (sendHttpevent $ladestophooklp1_url $1 )
 	 (( 1== 1 )) && (xsendmail "Ladeende" $2)
  	;;
  	
  endmonat)
 	 (( 1== 1 )) && (xsendmail "Monatsdaten" $2)
  	;;
  	
  smarthome)
	(( pushbsmarthome== 1 )) && (( pushbenachrichtigung == 1 )) && (sendPushover $2 $1)
	(( 1== 1 )) && (xsendmail "Smarthome" $2)
	;;
  	
  *)
 	openwbDebugLog "MAIN" 0 "Event [$1] unknown"
 	;;
  
esac

exit 0


