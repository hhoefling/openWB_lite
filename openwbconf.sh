# Sync function 
# openwb -> mqtt 
# Sync nur wenn mqtt fehlt, oder openwb.conf neuer als lastsync timestamp in der Ramdisk
# auf minimalen overhead ausgelegt, wenn openwb.conf sich nicht ändert


doopenWBconfsyncorinitmain=0

declare -F openwbDebugLog &> /dev/null || {
    cd /var/www/html/openWB
	# source  ./helperFunctions.sh
    function openwbDebugLog()
    {
     shift 
     shift
     echo $*
    }
    source  ./loadconfig.sh
    set -o pipefail
    set -o nounset
    doopenWBconfsyncorinitmain=1
}


#########################################################
### Openwb.conf Sync module 
#########################################################

#
# Dateiname , zu prüfen ob sync nötig ist
#
lastMQTTcvctimecheckerfile="ramdisk/mqttcvc/lasttimeOWBCchanged"

# cacheverzeichniss um die Daten nur bei ver#änderung zum MQTT zu senden
function initMqttcvc()
{
 if [ -d ramdisk/mqttcvc ] ; then
   rm -r ramdisk/mqttcvc
 fi
 mkdir ramdisk/mqttcvc
 chown pi:pi ramdisk/mqttcvc
 openwbDebugLog "DEB" 0 "MQTTcvc cache cleared"
 for mq in "${!mqttconfvar[@]}"; do     # all keys also die mqtt-pfade
   name="${mqttconfvar[$mq]}"
   declare -n pointertovar=$name
    if ${pointertovar+"false"}
    then
        openwbDebugLog "DEB" 2 "MQTTcvc config variable $name ist not defined as shell variable"
    else
       echo "#noval#" > ramdisk/mqttcvc/${name}
    fi   
 done
 echo "0" > $lastMQTTcvctimecheckerfile    # init -> sofortiges sync
}

function syncopenwbconf()
{
   for mq in "${!mqttconfvar[@]}"; do     # all keys also die mqtt-pfade
        thevarname=${mqttconfvar[$mq]:-""}
        theval=${!thevarname:-""}
        oldname=mqttcvc/${mqttconfvar[$mq]}
        oldval=""
        if [ -r ramdisk/${oldname} ] ; then
            read oldval <ramdisk/${oldname}
        fi
        if [[ "${oldval}" != "$theval" ]]; then
                    openwbDebugLog "DEB" 2 "MQTTcvc $thevarname changed [${oldval}] to [$theval] store to $mq"
                    # tempPubList="${tempPubList}\nopenWB/${mq}=${theval}"
                    mqtttempPubList="${mqtttempPubList}\nopenWB/${mq}=${theval}"
                    echo $theval > ramdisk/${oldname}
       fi
  done
}


function doopenWBconfsyncorinit()
{
	declare -A mqttconfvar
    declare -i needsync=0
    #
    # Abtesten ob anlegen/syncen noetig ist =1 =10 =11
    #
    [ ! -d ramdisk/mqttcvc ] && needsync+=10    # after reboot
    #  format=%Y     time of last data modification, seconds since Epoch
    lasttimeOWBCchanged=$(stat --format='%Y'  openwb.conf)
    [ -r $lastMQTTcvctimecheckerfile ] && ox=$(<$lastMQTTcvctimecheckerfile)
    ox=${ox:-"0"}
    openwbDebugLog "DEB" 0 "MQTTvc syncopenwbconf lasttimeOWBCchanged:$lasttimeOWBCchanged ox:$ox" 
    
    if (( lasttimeOWBCchanged > ox )) ; then    # after openwb.conf has changed
        needsync+=1    
    fi
    mqttconfvar["system/lasttimeOWBCchanged2"]=lasttimeOWBCchanged
    
    mqtttempPubList=""
    if (( needsync > 0  )) ; then
        openwbDebugLog "MAIN" 2 "MQTTcvc needsource:$needsync "
        # nun ausführen nachdem das array gelesen wurde
        openwbDebugLog "DEB" 0 "MQTTcvc syncopenwbconf needsource:$needsync Loading nqttvarconf.sh"
        source ./mqttconfvar.sh
        openwbDebugLog "DEB" 0 "MQTTcvc mqttconfvar has ${#mqttconfvar[@]} elems"
        (( needsync > 10 )) && initMqttcvc
        (( needsync > 0  )) && syncopenwbconf
    else
        openwbDebugLog "MAIN" 2 "MQTTcvc nothing to do "
	fi
    if (( ${#mqtttempPubList}> 0 )); then
      if (( debug > 1 )); then
          echo "MQTTcvc ------- openwbconf.Publist: bytes lang:${#mqtttempPubList} "
          echo -e $mqtttempPubList
          echo "MQTTcvc ------- "
      fi
      echo -e $mqtttempPubList | python3 runs/mqttpub.py -q 0 -r &
    fi
}

#########################################################################                        

# sofort main selbst aufrufen ? 
 if (( doopenWBconfsyncorinitmain == 1 )) ; then
  doopenWBconfsyncorinit
 fi


