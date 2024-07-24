#!/bin/bash
# Mirror changed Values to mqtt
# Source is
# - openwb.conf 
# - ramdisk 
# - BASH-Variablen
# cache in ramdisk/mqttv and ramdisk/mqttc

# set >ramdisk/pubmqtt.set.txt
# env >ramdisk/pubmqtt.env.txt

read version <web/version

#debug=4

declare -F openwbDebugLog &>/dev/null || {
    function openwbDebugLog()
    {
	shift
 	shift
    if (( debug > 0 )) ; then
  	  timestamp=$(date +"%Y-%m-%d %H:%M:%S:")
      echo "$timestamp $$ SYNC: $@"
    fi
    }
}

# Init Once,  move to initRamdisk.sh 
if [ ! -d ramdisk/mqttc ] ; then
   mkdir ramdisk/mqttc
   sudo chown pi:pi ramdisk/mqttc
   sudo chmod 0777  ramdisk/mqttc
   openwbDebugLog "MAIN" 2 "SYNC Create Cacheddir ramdisk/mqttc for config "
fi
if [ ! -d ramdisk/mqttv ] ; then
   mkdir ramdisk/mqttv
   sudo chown pi:pi ramdisk/mqttv
   sudo chmod 0777  ramdisk/mqttv
   openwbDebugLog "MAIN" 2 "SYNC Create Cacheddir ramdisk/mqttv for ramdisk vars"
fi
    
#
# private
#
function resetsynctime()
{
  openwbDebugLog "MAIN" 2 "Reset Synctime to sync all next loop"
  rm -r ramdisk/mqttc/* >/dev/null	 2>&1 # cache leeren
  rm -r ramdisk/mqttv/* >/dev/null	 2>&1 # cache leeren
  touch -t 202201010000 ramdisk/mqttv/nextsynctime
}

declare -a pubarr

#
# private
#
function publish_mqtt_one() # topic value cachename
{
 local t=${1}
 local val=$2
 local mc="ramdisk/${3}"
 local oldm
 if [ -f "$mc" ] ; then	# mqtt cache vorhanden
    read oldm <$mc
    if [[ "$oldm" == "$val" ]] ; then
       (( debug > 3 )) && openwbDebugLog "MAIN" 2 "SYNC mqtt:${1} [$oldm]=[$val], same, skip publishing"
       return
    fi
 fi
 pubarr+=("openWB/${t}=${val}")
 (( debug > 3 )) && openwbDebugLog "MAIN" 2 "SYNC mqtt:${1} store [$val] in $mc (old=[$oldm])"
 echo "$val" > $mc;	# cache last stored mqtt value
}

#
# private
#
function initpublish()
{
 timestamp="$(date +%s)"
 
 pubarr=()
 pubarr+=("openWB/system/Date=$(date)")
 # pubarr+=("openWB/system/Uptime=$(uptime)")     mach sysdaem selbst
 pubarr+=("openWB/system/Timestamp=${timestamp}")
 
 if [ ! -r ramdisk/mqttv/nextsynctime ] ; then
     # first time or resync forced
     resetsynctime
 fi
 mv -f ramdisk/mqttv/nextsynctime ramdisk/mqttv/synctime
 touch ramdisk/mqttv/nextsynctime
}

 
source runs/mqttvar.sh

# MAIN 



# Testweiese mit Find die namen auflisten die gesymc werdem  müssen
# ca 100 wobei dann 10-20 übrig bleiben
# eventuell mit mqtttopic/file das topic holen statt mqttramvar[]
#ptstart
#while IFS= read -r file; do
#  if [ -r ramdisk/mqttv/$file ] ; then
#    read y <ramdisk/mqttv/$file
#    read x <ramdisk/$file
#    if [ "$x" != "$y" ] ; then
#       openwbDebugLog "MAIN" 2 "xxx $file [$x] [$y]"
#   fi
#  fi
#done < <(cd ramdisk; find . -type f  -newer mqttv/synctime  -printf '%P\n'  )
#ptend "pubmqttnew xxx" 10


ptstart

# pubarr vorbereitem reset bedingung testen
initpublish
 
mqtc=0
# openwb.conf ==> mqtt wenn openwb.conf neuer als synctime
if [[ openwb.conf  -nt ramdisk/mqttv/synctime ]]; then
    openwbDebugLog "MAIN" 2 "openwb.conf newer, now check for openwb.conf changes"
        for mq in "${!mqttconfvar[@]}"; do
            let "mqtc++"
            vn=${mqttconfvar[$mq]}
            newval=${!vn}
            (( debug > 2 )) && openwbDebugLog "MAIN" 2 "SYNC CONF $vn $mq"
            publish_mqtt_one $mq "$newval" mqttc/${vn}
        done
else
       (( debug > 3 )) && openwbDebugLog "MAIN" 2 "openwb.conf is older"
fi
# Bash var, sind wie config-var nur das sie immer getestet werden
for mq in "${!mqttbashvar[@]}"; do
    let "mqtc++"
    vn=${mqttbashvar[$mq]}
    newval=${!vn}
    # (( debug > 2 )) && openwbDebugLog "MAIN" 2 "BASH $vn $mq"
    publish_mqtt_one $mq "$newval" mqttv/${vn}
done



# now ramvars 
for mq in "${!mqttramvar[@]}"; do
    let "mqtc++"
    vn=${mqttramvar[$mq]}

    if [ -f ramdisk/${vn} ] ; then	
		read -r newval <ramdisk/${vn} 
		publish_mqtt_one $mq "$newval" mqttv/${vn}
    else
       (( debug > 1 )) && openwbDebugLog "MAIN" 2 "WARN $vn not found, ignored"

    fi
done

# endpublish pubarr
# was zum publishen dabei gewesen?
if (( ${#pubarr[@]} > 0 )) ; then
    if (( debug > 1 )); then
       openwbDebugLog "MAIN" 2 "pubarr: mqtt #mqttx:$mqtc #pubarr:${#pubarr[@]}"
       for mq in "${pubarr[@]}"; do
          echo "pubmqtt SYNC: $mq"
       done
    fi   
    openwbDebugLog "MAIN" 2 "Running Python3: runs/mqttpub.py -q 0 -r &"
    ( 
    for mq in "${pubarr[@]}"; do
            echo "$mq"
    done 
    ) | python3 runs/mqttpub.py -q 0 -r &
    openwbDebugLog "MAIN" 2 "pubarr: #mqttx:$mqtc #pubarr:${#pubarr[@]}"
else
    openwbDebugLog "MAIN" 2 "pubarr empty"
fi

ptend "pubmqttnew debug:($debug)" 10


