#!/bin/bash
if [[ -z "$OPENWBBASEDIR" ]]; then
    OPENWBBASEDIR=$(cd "$(dirname "$0")/../" && pwd)
fi


runmain=0

function log()
{
 (( runmain==1 )) && echo "SERVICE: $*"
}


declare -F openwbDebugLog &>/dev/null || {
    source "$OPENWBBASEDIR/loadconfig.sh"
    source "$OPENWBBASEDIR/helperFunctions.sh"
    runmain=1
    log "$0: Seems like openwb.conf is not loaded. Reading file."
}
LOGFILE="$OPENWBBASEDIR/ramdisk/openWB.log"

# Sammlung von funktionen um alle Daemos zu starten oder zu stoppen.


########## RSE running as PI #####################################
function rse_start() # $1=eneabled
{
 if (( $1 == 1)) ; then
    if ! pgrep -f '^python.*/rse.py' > /dev/null ; then
      log "startup rse";
      openwbDebugLog "MAIN" 0 "SERVICE: startup rse"
      #sudo bash -c "python3 \"$OPENWBBASEDIR/runs/rse.py\" >>\"$LOGFILE\" 2>&1 & "
      sudo -u pi bash -c "python3 \"$OPENWBBASEDIR/runs/rse.py\" >>\"$LOGFILE\" 2>&1 & "
      #python3 "$OPENWBBASEDIR/runs/rse.py" >>"$LOGFILE" 2>&1 & 
    fi
 else    
    rse_stop 
 fi
}
function rse_stop() # $1 enabled 
{
  local enabled=$1
   if pgrep -f '^python.*/rse.py' > /dev/null ; then
      log  "kill rse daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rse daemon"
      sudo pkill -f "^python.*/rse.py"
   else
      if (( enabled == 1)) ; then  # shut run , but don't 
        log "rse daemon is actually not running "
        openwbDebugLog "MAIN" 2 "SERVICE: rse daemon is actually not running"
      #else        
        #openwbDebugLog "MAIN" 2 "SERVICE: rse shut not run"
      fi  
   fi
}
function rse_status() # $1=eneabled
{
 if (( $1 == 1)) ; then
    if pgrep -f '^python.*/rse.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/rse.py')
       log $line
       openwbDebugLog "MAIN" 0 "SERVICE: $line"
    else
      log "rse daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rse daemon shut run, but dont"
      # rse_start $1
    fi  
 else
    log "rse is disbaled";
    openwbDebugLog "MAIN" 2 "SERVICE: rse is disabled"
    rse_stop 0      
 fi
}
#################################################################



function rfid_status() # $1=eneabled
{
 echo "rfid is xxxxx";
}
function modbus_status() # $1=eneabled
{
 echo "modbus is xxxxx";
}
function led_status() # $1=eneabled
{
 echo "leds is xxxxx";
}
function button_status() # $1=eneabled
{
 echo "button is xxxxx";
}
function isss_status() # $1=eneabled
{
 echo "isss is xxxxx";
}
function smarthome_status() # $1=eneabled
{
 echo "smarthome is xxxxx";
}


function selectstatus()
{
 log "****ANF Status for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_status  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid_status  $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_status  0
 [[ "$1" == "all" || "$1" == "led" ]]  &&  led_status  0
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_status  0 
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_status  0 
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_status  0 
 log "****END Status for openWB.Services *************"
}

function selectstart()
{
 #log "****ANF Start for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_start  $rseenabled
}
function selectstop()
{
 #log "****ANF Stop for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_stop $rseenabled  
}

function service_main() # cmd what
{
 what=${2:-all}
 #log "****ANF service_main $1 $2 ***********"
 case "$1" in
    start)
        selectstart $what
        ;;
    stop)
        selectstop $what
        ;;
    status)
        selectstatus $what
        ;;
    restart)
        selectstop $what
        selectstart $what
        ;;
    *)
        echo "Usage: ${BASH_SOURCE[0]} {start|stop|restart|status [all|rse|rfid|modbus|smarthome|led|buttons|isss]}"
        ;;
 esac
}



if (( runmain>0 )) ; then
 echo "run $0 directly"
 service_main $1 $2
fi
 

