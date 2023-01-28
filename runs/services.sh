#!/bin/bash
if [[ -z "$OPENWBBASEDIR" ]]; then
    OPENWBBASEDIR=$(cd "$(dirname "$0")/../" && pwd)
fi


runmain=0

function deblog()
{
 (( runmain==1 )) && echo "SERVICE: $*"
}


declare -F openwbDebugLog &>/dev/null || {
    source "$OPENWBBASEDIR/loadconfig.sh"
    source "$OPENWBBASEDIR/helperFunctions.sh"
    runmain=1
    deblog "$0: Seems like openwb.conf is not loaded. Reading file."
}
LOGFILE="$OPENWBBASEDIR/ramdisk/openWB.log"

# 0          0       -         -       
# 0          1       kill      kill     
# 1          0       run       run       
# 1          1       kill/run   -      


########## RSE running as PI #####################################
function rse_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/rse.py')
 deblog "isrun:$isrun"
 if (( $1 == 1  && $isss == 0 )) ; then
    deblog "rse enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rse_start
    else
      deblog "rse allready run"
    fi
 else    
    deblog "rse disabled"
    if (( ${isrun:-0} != 0 )) ; then
    rse_stop 
    else
      deblog "rse disabled and not running"
    fi
 fi 
}
function rse_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/rse.py')
 if (( ${isrun:-0} != 0 )) ; then
    rse_stop
 else
   deblog "rse not running"
 fi
 if (( $1 == 1  && isss == 0 )) ; then
    isrun=$(pgrep -f '^python.*/rse.py')
    deblog "rse enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rse_start
    else
      deblog "rse allready run"
    fi
 else
    deblog "rse disabled, not start needed"
 fi 
}
function rse_start() 
{
  if ! pgrep -f '^python.*/rse.py' > /dev/null ; then
   deblog "startup rse";
   openwbDebugLog "MAIN" 0 "SERVICE: startup rse"
   sudo -u pi bash -c "python3 runs/rse.py >>\"$LOGFILE\" 2>&1 & "
  else
    deblog "rse allready running"
 fi
}
function rse_stop() 
{
   if pgrep -f '^python.*/rse.py' > /dev/null ; then
      deblog  "kill rse daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rse daemon"
      sudo pkill -f "^python.*/rse.py"
   else
      deblog "rse daemon is actually not running "
   fi
}
function rse_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0 )) ; then
    if pgrep -f '^python.*/rse.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/rse.py')
       deblog "rse $line"
       openwbDebugLog "MAIN" 0 "SERVICE: rse enabled: $line"
    else
      deblog "rse daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rse daemon shut run, but dont"
    fi  
 else
    deblog "rse is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: rse is disabled"
 fi
}

########## Tasker #####################################
function tasker_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^tsp')
 deblog "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    deblog "tasker enabled"
    if (( ${isrun:-0} == 0 )) ; then
      tasker_start
    else
      deblog "tasker allready run"
    fi
 else
    deblog "tasker disabled"
    if (( ${isrun:-0} != 0 )) ; then
       tasker_stop
    else
      deblog "tasker disabled and not running"
    fi
 fi 
}
function tasker_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^tsp')
 if (( ${isrun:-0} != 0 )) ; then
    tasker_stop
 else
   deblog "tasker not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^tsp')
    deblog "tasker enabled"
    if (( ${isrun:-0} == 0 )) ; then
      tasker_start
    else
      deblog "tasker allready run"
    fi
 else
    deblog "tasker disabled, not start needed"
 fi 
}
function tasker_start() 
{
  if ! pgrep -f '^tsp' > /dev/null ; then
   deblog "startup tasker";
   openwbDebugLog "MAIN" 0 "SERVICE: startup tasker"
    export TS_MAXFINISHED=10
    export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
    # export  TS_ENV='pwd;set;mount'.
    sudo -u pi tsp -K
    sudo -u pi tsp >/dev/null
  else
    deblog "tasker allready running"
  fi
}
function tasker_stop() 
{
   if pgrep -f '^tsp' > /dev/null ; then
      deblog  "kill tasker daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill tasker daemon"
      export TS_MAXFINISHED=10
      export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
      # export  TS_ENV='pwd;set;mount'.
      sudo -u pi tsp -K
   else
      deblog "tasker daemon is actually not running "
   fi
}
function tasker_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^tsp' > /dev/null ; then
       line=$(pgrep -fa '^tsp')
       deblog "tasker $line"
       openwbDebugLog "MAIN" 0 "SERVICE: tasker enabled: $line"
    else
      deblog "tasker daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: tasker daemon shut run, but dont"
    fi  
 else
    deblog "tasker is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: tasker is disabled"
 fi
}

#################################################################

function rfid1_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/readrfid.py')
 deblog "isrun:$isrun"
 if (( $1 >= 1  && $isss == 0 )) ; then
    deblog "rfid1 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid1_start
    else
      deblog "rfid1 allready run"
    fi
 else    
    deblog "rfid1 disabled"
    if (( ${isrun:-0} != 0 )) ; then
    rfid1_stop 
    else
      deblog "rfid1 disabled and not running"
    fi
 fi 
}
function rfid1_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/readrfid.py')
 if (( ${isrun:-0} != 0 )) ; then
    rfid1_stop
 else
   deblog "rfid1 not running"
 fi
 if (( $1 >= 1  && isss == 0 )) ; then
    isrun=$(pgrep -f '^python.*/readrfid.py')
    deblog "rfid1 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid1_start
    else
      deblog "rfid1 allready run"
    fi
 else
    deblog "rfid1 disabled, not start needed"
 fi 
}
function rfid1_start() 
{
    # daemon for input0
    
#    [[ -c /dev/input/event0 ]] && deblog "check  event0"
#    [[ -c /dev/input/event1 ]] && deblog "check  event1"
    
    
    if [[ -c /dev/input/event0 ]]; then
        deblog "startup rfid1 for event0"
        pgrep -f '^python.*/readrfid.py -d event0'
        if pgrep -f '^python.*/readrfid.py -d event0' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid1 configured and handler for event0 is running"
  else
            openwbDebugLog "MAIN" 1 "rfid1 configured but handler for event0 not running; starting process"
            sudo bash -c "python3 runs/readrfid.py -d event0 >>\"$LOGFILE\" 2>&1 & "
        fi
    fi

    if [[ -c /dev/input/event1 ]]; then
        deblog "startup rfid1 for event1"
        if pgrep -f '^python.*/readrfid.py -d event1' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid1 configured and handler for event1 is running"
        else
            openwbDebugLog "MAIN" 1 "rfid1 configured but handler for event1 not running; starting process"
            sudo bash -c "python3 runs/readrfid.py -d event1 >>\"$LOGFILE\" 2>&1 & "
        fi
 fi
}
function rfid1_stop() 
{
   if pgrep -f '^python.*/readrfid.py' > /dev/null ; then
      deblog  "kill rfid1 daemons"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rfid1 daemons"
      sudo pkill -f "^python.*/readrfid.py"
   else
      deblog "rfid1 daemon is actually not running "
   fi
}
function rfid1_status() # $1=eneabled
{
 if (( $1 >= 1  && isss == 0 )) ; then
    if pgrep -f '^python.*/readrfid.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/readrfid.py')
       deblog "rfid1 $line"
       openwbDebugLog "MAIN" 0 "SERVICE: rfid1 enabled: $line"
    else
      deblog "rfid1 daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rfid1 daemon shut run, but dont"
    fi  
 else
    deblog "rfid1 is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: rfid1 is disabled"
 fi
}

#################################################################
function rfid2_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/rfid.py')
 deblog "isrun:$isrun"
 if (( $1 == 2  && $isss == 0 )) ; then
    deblog "rfid2 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid2_start
    else
      deblog "rfid2 allready run"
    fi
 else    
    deblog "rfid2 disabled"
    if (( ${isrun:-0} != 0 )) ; then
    rfid2_stop 
    else
      deblog "rfid2 disabled and not running"
    fi
 fi 
}
function rfid2_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/rfid.py')
 if (( ${isrun:-0} != 0 )) ; then
    rfid2_stop
 else
   deblog "rfid2 not running"
 fi
 if (( $1 == 2  && isss == 0 )) ; then
    isrun=$(pgrep -f '^python.*/rfid.py')
    deblog "rfid2 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid2_start
    else
      deblog "rfid2 allready run"
    fi
 else
    deblog "rfid2 disabled, not start needed"
 fi 
}
function rfid2_start() 
{
        deblog "startup rfid2";
        if pgrep -f '^python.*/rfid.py' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid2 configured "
        else
            openwbDebugLog "MAIN" 1 "rfid2 configured but handler not running; starting process"
            sudo -u pi bash -c "python3 runs/rfid.py >>\"$LOGFILE\" 2>&1 &" 
        fi
}
function rfid2_stop() 
{
   if pgrep -f '^python.*/rfid.py' > /dev/null ; then
      deblog  "kill rfid2 daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rfid2 daemon"
      sudo pkill -f "^python.*/rfid.py"
   else
      deblog "rfid2 daemon is actually not running "
   fi
}
function rfid2_status() # $1=eneabled
{
 if (( $1 == 2  && isss == 0 )) ; then
    if pgrep -f '^python.*/rfid.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/rfid.py')
       deblog "rfid2 $line"
       openwbDebugLog "MAIN" 0 "SERVICE: rfid2 enabled: $line"
    else
      deblog "rfid2 daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rfid2 daemon shut run, but dont"
    fi  
 else
    deblog "rfid2 is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: rfid2 is disabled"
 fi
}

#################################################################

function modbus_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/modbusserver.py')
 deblog "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    deblog "modbusserver enabled"
    if (( ${isrun:-0} == 0 )) ; then
      modbus_start
    else
      deblog "modbusserver allready run"
    fi
 else
    deblog "modbusserver disabled"
    if (( ${isrun:-0} != 0 )) ; then
       modbus_stop
    else
      deblog "modbusserver disabled and not running"
    fi
 fi 
}
function modbus_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/modbusserver.py')
 if (( ${isrun:-0} != 0 )) ; then
    modbus_stop
 else
   deblog "modbusserver not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/modbusserver.py')
    deblog "modbusserver enabled"
    if (( ${isrun:-0} == 0 )) ; then
      modbus_start
    else
      deblog "modbusserver allready run"
    fi
 else
    deblog "modbusserver disabled, not start needed"
 fi 
}
function modbus_start() 
{
  if ! pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
   deblog "startup modbusserver";
   openwbDebugLog "MAIN" 0 "SERVICE: startup modbusserver"
   #sudo bash -c "python3 \"$OPENWBBASEDIR/runs/modbusserver/modbusserver.py\" >>\"$LOGFILE\" 2>&1 & "
   sudo bash -c "python3 runs/modbusserver/modbusserver.py >>\"$LOGFILE\" 2>&1 & "
  else
    deblog "modbusserver allready running"
  fi
}
function modbus_stop() 
{
   if pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
      deblog  "kill modbusserver daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill modbusserver daemon"
      sudo pkill -f "^python.*/modbusserver.py"
   else
      deblog "modbusserver daemon is actually not running "
   fi
}
function modbus_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/modbusserver.py')
       deblog "modbus $line"
       openwbDebugLog "MAIN" 0 "SERVICE: modbusserver enabled: $line"
    else
      deblog "modbusserver daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: modbusserver daemon shut run, but dont"
    fi  
 else
    deblog "modbusserver is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: modbusserver is disabled"
 fi
}



#################################################################
function button_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/ladetaster.py')
 deblog "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    deblog "button enabled"
    if (( ${isrun:-0} == 0 )) ; then
      button_start
    else
      deblog "button allready run"
    fi
 else
    deblog "button disabled"
    if (( ${isrun:-0} != 0 )) ; then
       button_stop
    else
      deblog "button disabled and not running"
    fi
 fi 
}
function button_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/ladetaster.py')
 if (( ${isrun:-0} != 0 )) ; then
    button_stop
 else
   deblog "button not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/ladetaster.py')
    deblog "button enabled"
    if (( ${isrun:-0} == 0 )) ; then
      button_start
    else
      deblog "button allready run"
    fi
 else
    deblog "button disabled, not start needed"
 fi 
}
function button_start() 
{
  if ! pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
   deblog "startup button";
   openwbDebugLog "MAIN" 0 "SERVICE: startup button"
   sudo -u pi bash -c "python3 runs/ladetaster.py >>\"$LOGFILE\" 2>&1 & "
  else
    deblog "button allready running"
  fi
}
function button_stop() 
{
   if pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
      deblog  "kill button daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill button daemon"
      sudo pkill -f "^python.*/ladetaster.py"
   else
      deblog "button daemon is actually not running "
   fi
}
function button_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/ladetaster.py')
       deblog "button $line"
       openwbDebugLog "MAIN" 0 "SERVICE: button enabled: $line"
    else
      deblog "button daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: button daemon shut run, but dont"
    fi  
 else
    deblog "button is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: button is disabled"
 fi
}



#################################################################
function isss_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/isss.py')
 deblog "isrun:$isrun"
 if (( $1 == 1)) ; then
    deblog "isss enabled"
    if (( ${isrun:-0} == 0 )) ; then
      isss_start
    else
      deblog "isss allready run"
    fi
 else
    deblog "isss disabled"
    if (( ${isrun:-0} != 0 )) ; then
       isss_stop
    else
      deblog "isss disabled and not running"
    fi
 fi 
}
function isss_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/isss.py')
 if (( ${isrun:-0} != 0 )) ; then
    isss_stop
 else
   deblog "isss not running"
 fi
 if (( $1 == 1)) ; then
    isrun=$(pgrep -f '^python.*/isss.py')
    deblog "isss enabled"
    if (( ${isrun:-0} == 0 )) ; then
      isss_start
    else
      deblog "isss allready run"
    fi
 else
    deblog "isss disabled, not start needed"
 fi 
}
function isss_start() 
{
 local LFILE
 LFILE="$OPENWBBASEDIR/ramdisk/isss.log"
  if ! pgrep -f '^python.*/isss.py' > /dev/null ; then
   deblog "startup isss";
   openwbDebugLog "MAIN" 0 "SERVICE: startup isss"
   sudo -u pi bash -c "python3 runs/isss.py >>\"$LFILE\" 2>&1 & "
  else
    deblog "isss allready running"
  fi
}
function isss_stop() 
{
   if pgrep -f '^python.*/isss.py' > /dev/null ; then
      deblog  "kill isss daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill isss daemon"
      sudo pkill -f "^python.*/isss.py"
   else
      deblog "isss daemon is actually not running "
   fi
}
function isss_status() # $1=eneabled
{
 if (( $1 == 1)) ; then
    if pgrep -f '^python.*/isss.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/isss.py')
       deblog "isss $line"
       openwbDebugLog "MAIN" 0 "SERVICE: isss enabled: $line"
    else
      deblog "isss daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: isss daemon shut run, but dont"
    fi  
 else
    deblog "isss is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: isss is disabled"
 fi
}

#################################################################
function smarthome_cron5() 
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/smarthomehandler.py')
 deblog "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    deblog "smarthomehandler enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smarthome_start
    else
      deblog "smarthomehandler allready run"
    fi
 else
    deblog "smarthomehandler disabled"
    if (( ${isrun:-0} != 0 )) ; then
       smarthome_stop
    else
      deblog "smarthomehandler disabled and not running"
    fi
 fi 
}
function smarthome_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/smarthomehandler.py')
 if (( ${isrun:-0} != 0 )) ; then
    smarthome_stop
 else
   deblog "smarthomehandler not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/smarthomehandler.py')
    deblog "smarthomehandler enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smarthome_start
    else
      deblog "smarthomehandler allready run"
    fi
 else
    deblog "smarthomehandler disabled, not start needed"
 fi 
}
function smarthome_start() 
{
 local LFILE
 LFILE="$OPENWBBASEDIR/ramdisk/smarthome.log"
  if pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
     smartmq_stop
  fi
  
  if ! pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
   deblog "startup smarthome";
   openwbDebugLog "MAIN" 0 "SERVICE: startup smarthomehandler"
   sudo -u pi bash -c "python3 runs/smarthomehandler.py >>\"$LFILE\" 2>&1 & "
  else
    deblog "smarthomehandler allready running"
  fi
}
function smarthome_stop() 
{
   if pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
      deblog  "kill smarthomehandler daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill smarthomehandler daemon"
      sudo pkill -f "^python.*/smarthomehandler.py"
   else
      deblog "smarthomehandler daemon is actually not running "
   fi
}
function smarthome_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/smarthomehandler.py')
       deblog "smarthomehandler $line"
       openwbDebugLog "MAIN" 0 "SERVICE: smarthomehandler enabled: $line"
    else
      deblog "smarthomehandler daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: smarthomehandler daemon shut run, but dont"
    fi  
 else
    deblog "smarthomehandler is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: smarthomehandler is disabled"
 fi
}


#################################################################
function smartmq_cron5() 
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/smarthomemq.py')
 deblog "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    deblog "smartmq enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smartmq_start
    else
      deblog "smartmq allready run"
    fi
 else
    deblog "smartmq disabled"
    if (( ${isrun:-0} != 0 )) ; then
       smartmq_stop
    else
      deblog "smartmq disabled and not running"
    fi
 fi 
}
function smartmq_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/smarthomemq.py')
 if (( ${isrun:-0} != 0 )) ; then
    smartmq_stop
 else
   deblog "smartmq not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/smarthomemq.py')
    deblog "smartmq enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smartmq_start
    else
      deblog "smartmq allready run"
    fi
 else
    deblog "smartmq disabled, not start needed"
 fi 
}
function smartmq_start() 
{
  local LFILE
  LFILE="$OPENWBBASEDIR/ramdisk/smarthome.log"
  if pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
     smarthome_stop
  fi
  
  if ! pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
   deblog "startup smartmq";
   openwbDebugLog "MAIN" 0 "SERVICE: startup smartmq"
   sudo -u pi bash -c "python3 runs/smarthomemq.py >>\"$LFILE\" 2>&1 & "
  else
    deblog "smartmq allready running"
  fi
}
function smartmq_stop() 
{
   if pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
      deblog  "kill smartmq daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill smartmq daemon"
      sudo pkill -f "^python.*/smarthomemq.py"
   else
      deblog "smartmq daemon is actually not running "
   fi
}
function smartmq_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/smarthomemq.py')
       deblog "smarthomemq $line"
       openwbDebugLog "MAIN" 0 "SERVICE: smartmq enabled: $line"
    else
      deblog "smartmq daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: smartmq daemon shut run, but dont"
    fi  
 else
    deblog "smartmq is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: smartmq is disabled"
 fi
}



#################################################################
function mqttsub_cron5() 
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/mqttsub.py')
 deblog "isrun:$isrun"

    if (( ${isrun:-0} == 0 )) ; then
      mqttsub_start
    else
      deblog "mqttsub allready run"
    fi
}
function mqttsub_reboot() 
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/mqttsub.py')
 if (( ${isrun:-0} != 0 )) ; then
    mqttsub_stop
 else
   deblog "mqttsub not running"
 fi

    isrun=$(pgrep -f '^python.*/mqttsub.py')
    if (( ${isrun:-0} == 0 )) ; then
      mqttsub_start
    else
      deblog "mqttsub allready run"
    fi
}
function mqttsub_start() 
{
  if ! pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
   deblog "startup mqttsub";
   openwbDebugLog "MAIN" 0 "SERVICE: startup mqttsub"
   sudo -u pi bash -c "python3 runs/mqttsub.py >>\"$LOGFILE\" 2>&1 & "
  else
    deblog "mqttsub allready running"
  fi
}
function mqttsub_stop() 
{
   if pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
      deblog  "kill mqttsub daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill mqttsub daemon"
      sudo pkill -f "^python.*/mqttsub.py"
   else
      deblog "mqttsub daemon is actually not running "
   fi
}
function mqttsub_status() 
{
    if pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/mqttsub.py')
       deblog "mqttsub $line"
       openwbDebugLog "MAIN" 0 "SERVICE: mqttsub enabled: $line"
    else
      deblog "mqttsub daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: mqttsub daemon shut run, but dont"
    fi  
}

########## sysdaem  as PI #####################################
function sysdaem_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f 'runs/sysdaem.sh')
 deblog "isrun:$isrun"
 if (( $1 == 1)) ; then
    deblog "sysdaem enabled"
    if (( ${isrun:-0} == 0 )) ; then
      sysdaem_start
    else
      deblog "sysdaem allready run"
    fi
 else
    deblog "sysdaem disabled"
    if (( ${isrun:-0} != 0 )) ; then
       sysdaem_stop
    else
      deblog "sysdaem disabled and not running"
    fi
 fi 
}
function sysdaem_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f 'runs/sysdaem.sh')
 if (( ${isrun:-0} != 0 )) ; then
    sysdaem_stop
 else
   deblog "sysdaem not running"
 fi
 if (( $1 == 1)) ; then
    isrun=$(pgrep -f 'runs/sysdaem.sh')
    deblog "sysdaem enabled"
    if (( ${isrun:-0} == 0 )) ; then
      sysdaem_start
    else
      deblog "sysdaem allready run"
    fi
 else
    deblog "sysdaem disabled, not start needed"
 fi 
}
function sysdaem_start() 
{
  if ! pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
   deblog "startup sysdaem";
   openwbDebugLog "MAIN" 0 "SERVICE: startup sysdaem"
   sudo -u pi bash -c "runs/sysdaem.sh $1 >>\"$LOGFILE\" 2>&1 & "
  else
    deblog "sysdaem allready running"
  fi
}
function sysdaem_stop() 
{
   if pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
      deblog  "kill sysdaem daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill sysdaem daemon"
      sudo pkill -f "runs/sysdaem.sh"
   else
      deblog "sysdaem daemon is actually not running "
   fi
}
function sysdaem_status() # $1=eneabled
{
 if (( $1 == 1)) ; then
    if pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
       line=$(pgrep -fa 'runs/sysdaem.sh')
       deblog "sysdaem $line"
       openwbDebugLog "MAIN" 0 "SERVICE: sysdaem enabled: $line"
    else
      deblog "sysdaem daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: sysdaem daemon shut run, but dont"
    fi  
 else
    deblog "sysdaem is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: sysdaem is disabled"
 fi
}


function selectstatus()
{
 local -i smartmq smarthome
 smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 deblog "****ANF Status for openWB.Services $1 $smartmq $smarthome ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_status  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_status  $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_status  $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_status  $modbus502enabled
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_status  $ladetaster
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_status $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_status $smartmq  
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_status  $isss 
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_status 1 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_status $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_status 1
 deblog "****END Status for openWB.Services *************"
}

function selectstart()
{
 local -i smartmq smarthome
 smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #deblog "****ANF Start for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_start  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_start $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_start $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_start $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_start $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_start $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_start $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_start 1 
# [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_start  $isss 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_start $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_start 1

}
function selectstop()
{
 local -i smartmq smarthome
 smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #deblog "****ANF Stop for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_stop $rseenabled  
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_stop $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_stop $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_stop $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_stop $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_stop $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_stop  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_stop 1 
# [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_stop  $isss 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_stop $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_stop 1

}
function selectcron5()
{
 local -i smartmq smarthome
 smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #deblog "****ANF cron5 for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_cron5  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_cron5 $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_cron5 $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_cron5 $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_cron5  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_cron5 1 
# [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_cron5  $isss 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_cron5 $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_cron5 1
}
function selectreboot()
{
 local -i smartmq smarthome
 smartmq=$(<"/var/www/html/openWB/ramdisk/smartmq")
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #deblog "****ANF reboot for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_reboot $rseenabled  
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_reboot $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_reboot $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_reboot $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_reboot $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_reboot $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_reboot  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_reboot 1 
# [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_reboot  $isss 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_reboot $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_reboot 1

}
function service_main() # cmd what
{
 what=${2:-all}
 #deblog "****ANF service_main $1 $2 ***********"
 case "$1" in
    cron5)
        selectcron5 $what
        ;;
    reboot)
        selectreboot $what
        ;;
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
        echo "Usage: ${BASH_SOURCE[0]} {start|stop|restart|status [all|rse|rfid|modbus|smarthome|led|buttons|isss|mqttsub]}"
        ;;
 esac
}



if (( runmain>0 )) ; then
 echo "run $0 directly"
 service_main $1 $2
fi
 
