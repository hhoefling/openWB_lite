#!/bin/bash
# Sowohl include von als auch direktstart
# atreboot/cron5min, also auch saveconfig.php

if [[ -z "$OPENWBBASEDIR" ]]; then
    OPENWBBASEDIR=$(cd "$(dirname "$0")/../" && pwd)
fi


runmain=0

function services_log()
{
 (( runmain==1 )) && echo "SERVICE: $*"
}


declare -F openwbDebugLog &>/dev/null || {
    source "$OPENWBBASEDIR/loadconfig.sh"
    source "$OPENWBBASEDIR/helperFunctions.sh"
    runmain=1
    services_log "$0: Seems like openwb.conf is not loaded. Reading file."
    services_log "$0: chdir to /var/www/html/openWB"
    cd /var/www/html/openWB
}
LOGFILE="$OPENWBBASEDIR/ramdisk/openWB.log"


######### Need ISSS ? ###################
#   file misss.py exists -> use it 
#   isss   evsecon   ppbuchse evsecons1 --> isss_mode 
#    1/0    daemon   egal     daemon    --> duo  
#    1/0    buchse   16/32    -         --> socket
#     1     egal     -        -         --> daemon         
#     0                                 --> None  Kein start
#


needIsss=0          # 0,1,2 
isss_mode=""
isss_32=32
ISSS=isss.py

function checkIfIsssIsNeeded()  # -> none or cmd to start
{
 x=$(pwd)
 openwbDebugLog "MAIN" 2 "$x"
 openwbDebugLog "MAIN" 2 "needs issss isss:$isss evsecon:$evsecon evsecons1:$evsecons1 lastmanagement:$lastmanagement"

 if [[ -r runs/misss.py ]] ; then
    ISSS=misss.py
 fi
 isss_32=32
 
 if [[ "$evsecon" == "daemon" ]] && [[ "$evsecons1" == "daemon" ]] && (( lastmanagement == 1 )) ; then
      isss_mode="duo"
      needIsss=1
  elif [[ "$evsecon" == "buchse" ]]; then
      isss_mode="socket"
      needIsss=1
      if [[ -r /home/pi/ppbuchse ]] ; then
         read isss_32 </home/pi/ppbuchse
         re='^[0-9]+$'
         if ! [[ $isss_32 =~ $re ]] ; then
           openwbDebugLog "MAIN" 0 "Invalid or no value in ppbuchse. use default 32."
           isss_32=32
         fi  
      else   
        isss_32=32
      fi
  elif (( isss == 1 )) || [[ "$evsecon" == "daemon"  ]] ; then
      isss_mode="daemon"
      needIsss=1
  else
      isss_mode=""
      needIsss=0
 fi
 services_log "isss:$isss mode:$isss_mode needed:$needIsss $isss_32  daemon is $ISSS"
 openwbDebugLog "MAIN" 2 "isss:$isss mode:$isss_mode needed:$needIsss $isss_32 daemon is $ISSS"
}

##

########## RSE running as PI #####################################
function rse_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/rse.py' | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 1 )) ; then
    services_log "rse enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rse_start
    else
      services_log "rse allready run"
    fi
 else    
    services_log "rse disabled"
    if (( ${isrun:-0} != 0 )) ; then
    rse_stop 
    else
      services_log "rse disabled and not running"
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
   services_log "rse not running"
 fi
 if (( $1 == 1  )) ; then
    isrun=$(pgrep -f '^python.*/rse.py')
    services_log "rse enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rse_start
    else
      services_log "rse allready run"
    fi
 else
    services_log "rse disabled, no start needed"
 fi 
}
function rse_start() 
{
  if ! pgrep -f '^python.*/rse.py' > /dev/null ; then
   services_log "startup rse";
   openwbDebugLog "MAIN" 0 "SERVICE: startup rse"
   sudo -u pi bash -c "python3 runs/rse.py >>\"$LOGFILE\" 2>&1 & "
  else
    services_log "rse allready running"
 fi
}
function rse_stop() 
{
   if pgrep -f '^python.*/rse.py' > /dev/null ; then
      sudo pkill -f "^python.*/rse.py"
      services_log  "kill rse daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rse daemon"
   else
      services_log "rse daemon is actually not running "
   fi
}
function rse_status() # $1=eneabled
{
 if (( $1 == 1  )) ; then
    if pgrep -f '^python.*/rse.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/rse.py')
       services_log "rse runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: rse runs: [$line]"
    else
      services_log "rse daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rse daemon shut run, but dont"
    fi  
 else
    services_log "rse is disabled ";
    openwbDebugLog "MAIN" 2 "SERVICE: rse is disabled"
 fi
}

########## Tasker #####################################
function tasker_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^tsp' | head -1)
 if (( $1 == 1  && isss == 0  )) ; then
    services_log "tasker is enabled"
    if (( ${isrun:-0} == 0 )) ; then
      tasker_start
    else
      services_log "tasker allready run"
    fi
 else
    services_log "tasker is disabled, or isss is running"
    if (( ${isrun:-0} != 0 )) ; then
        openwbDebugLog "MAIN" 2 "SERVICE: tasker_cron5 isrun:$isrun"
        tasker_stop
    else
      services_log "tasker disabled or isss is running and not running"
    fi
 fi 
}
function tasker_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^tsp' | head -1 )
 openwbDebugLog "MAIN" 2 "SERVICE: tasker_reboot isrun:[$isrun]"
 if (( ${isrun:-0} != 0 )) ; then
    tasker_stop
 else
   services_log "tasker not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^tsp$'|head -1)
    services_log "tasker enabled"
    if (( ${isrun:-0} == 0 )) ; then
      tasker_start
    else
      services_log "tasker allready run"
    fi
 else
    services_log "tasker disabled or isss is running, not start needed"
 fi 
}
function tasker_start() 
{
  if ! pgrep -f '^tsp' > /dev/null ; then
    services_log "startup tasker";
    openwbDebugLog "MAIN" 0 "SERVICE: tasker_start startup tasker"
    export TS_MAXFINISHED=10
    export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
    # export  TS_ENV='pwd;set;mount'.
    sudo -u pi tsp -K
    sudo -u pi tsp >/dev/null
  else
    services_log "tasker allready running"
  fi
}
function tasker_stop() 
{
   if pgrep -f '^tsp' > /dev/null ; then
      export TS_MAXFINISHED=10
      export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
      # export  TS_ENV='pwd;set;mount'.
      sudo -u pi tsp -K
      services_log  "kill tasker daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: tasker_stop kill tasker daemon"
   else
      services_log "tasker daemon is actually not running "
   fi
}
function tasker_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^tsp' > /dev/null ; then
       line=$(pgrep -fa '^tsp')
       services_log "tasker runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: tasker runs: [$line]"
    else
      services_log "tasker daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: tasker daemon shut run, but dont"
    fi  
 else
    services_log "tasker is disabled or issss mode aktive";
    openwbDebugLog "MAIN" 2 "SERVICE: tasker is disabled or issss mode aktive"
 fi
}

#################################################################

function rfid1_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/readrfid.py' | head -1)
 services_log "isrun:$isrun"
 if (( $1 >= 1  )) ; then
    services_log "rfid1 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid1_start
    else
      services_log "rfid1 allready run"
    fi
 else    
    services_log "rfid1 disabled "
    if (( ${isrun:-0} != 0 )) ; then
    rfid1_stop 
    else
      services_log "rfid1 disabled and not running"
    fi
 fi 
}
function rfid1_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/readrfid.py'  | head -1)
 if (( ${isrun:-0} != 0 )) ; then
    rfid1_stop
 else
   services_log "rfid1 not running"
 fi
 if (( $1 >= 1 )) ; then
    isrun=$(pgrep -f '^python.*/readrfid.py')
    services_log "rfid1 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid1_start
    else
      services_log "rfid1 allready run"
    fi
 else
    services_log "rfid1 disabled, not start needed"
 fi 
}
function rfid1_start() 
{
    # daemon for input0
    
#    [[ -c /dev/input/event0 ]] && services_log "check  event0"
#    [[ -c /dev/input/event1 ]] && services_log "check  event1"
    
    
    if [[ -c /dev/input/event0 ]]; then
        services_log "startup rfid1 for event0"
        pgrep -f '^python.*/readrfid.py -d event0'
        if pgrep -f '^python.*/readrfid.py -d event0' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid1 configured and handler for event0 is running"
  else
            openwbDebugLog "MAIN" 1 "rfid1 configured but for event0 not running; starting process"
            sudo bash -c "python3 runs/readrfid.py -d event0 >>\"$LOGFILE\" 2>&1 & "
        fi
    fi

    if [[ -c /dev/input/event1 ]]; then
        services_log "startup rfid1 for event1"
        if pgrep -f '^python.*/readrfid.py -d event1' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid1 configured and handler for event1 is running"
        else
            openwbDebugLog "MAIN" 1 "rfid1 configured but for event1 not running; starting process"
            sudo bash -c "python3 runs/readrfid.py -d event1 >>\"$LOGFILE\" 2>&1 & "
        fi
 fi
}
function rfid1_stop() 
{
   if pgrep -f '^python.*/readrfid.py' > /dev/null ; then
      sudo pkill -f "^python.*/readrfid.py"
      services_log  "kill rfid1 daemons"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rfid1 daemons"
   else
      services_log "rfid1 daemon is actually not running "
   fi
}
function rfid1_status() # $1=eneabled
{
 if (( $1 >= 1 )) ; then
    if pgrep -f '^python.*/readrfid.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/readrfid.py')
       services_log "rfid1 runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: rfid1 runs: [$line]"
    else
      services_log "rfid1 daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rfid1 daemon shut run, but dont"
    fi  
 else
    services_log "rfid1 is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: rfid1 is disabled"
 fi
}

#################################################################
function rfid2_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/rfid.py'  | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 2 )) ; then
    services_log "rfid2 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid2_start
    else
      services_log "rfid2 allready run"
    fi
 else    
    services_log "rfid2 disabled"
    if (( ${isrun:-0} != 0 )) ; then
    rfid2_stop 
    else
      services_log "rfid2 disabled and not running"
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
   services_log "rfid2 not running"
 fi
 if (( $1 == 2 )) ; then
    isrun=$(pgrep -f '^python.*/rfid.py')
    services_log "rfid2 enabled"
    if (( ${isrun:-0} == 0 )) ; then
      rfid2_start
    else
      services_log "rfid2 allready run"
    fi
 else
    services_log "rfid2 disabled, no start needed"
 fi 
}
function rfid2_start() 
{
        services_log "startup rfid2";
        if pgrep -f '^python.*/rfid.py' >/dev/null; then
            openwbDebugLog "MAIN" 2 "rfid2 allredy running "
        else
            openwbDebugLog "MAIN" 1 "rfid2 configured but handler not running; starting process"
            sudo -u pi bash -c "python3 runs/rfid.py >>\"$LOGFILE\" 2>&1 &" 
        fi
}
function rfid2_stop() 
{
   if pgrep -f '^python.*/rfid.py' > /dev/null ; then
      sudo pkill -f "^python.*/rfid.py"
      services_log  "kill rfid2 daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill rfid2 daemon"
   else
      services_log "rfid2 daemon is actually not running "
   fi
}
function rfid2_status() # $1=eneabled
{
 if (( $1 == 2  )) ; then
    if pgrep -f '^python.*/rfid.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/rfid.py')
       services_log "rfid2 runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: rfid2 runs: [$line]"
    else
      services_log "rfid2 daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: rfid2 daemon shut run, but dont"
    fi  
 else
    services_log "rfid2 is disabled ";
    openwbDebugLog "MAIN" 2 "SERVICE: rfid2 is disabled"
 fi
}

#################################################################

function modbus_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/modbusserver.py' | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 1 )) ; then
    services_log "modbusserver enabled"
    if (( ${isrun:-0} == 0 )) ; then
      modbus_start
    else
      services_log "modbusserver allready run"
    fi
 else
    services_log "modbusserver disabled"
    if (( ${isrun:-0} != 0 )) ; then
       modbus_stop
    else
      services_log "modbusserver disabled and not running"
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
   services_log "modbusserver not running"
 fi
 if (( $1 == 1  )) ; then
    isrun=$(pgrep -f '^python.*/modbusserver.py')
    services_log "modbusserver enabled"
    if (( ${isrun:-0} == 0 )) ; then
      modbus_start
    else
      services_log "modbusserver allready run"
    fi
 else
    services_log "modbusserver disabled, not start needed"
 fi 
}
function modbus_start() 
{
  if ! pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
   services_log "startup modbusserver";
   openwbDebugLog "MAIN" 0 "SERVICE: startup modbusserver"
   #sudo bash -c "python3 \"$OPENWBBASEDIR/runs/modbusserver/modbusserver.py\" >>\"$LOGFILE\" 2>&1 & "
   # nicht als PI, bind socket<1024   
   sudo bash -c "python3 runs/modbusserver/modbusserver.py >>\"$LOGFILE\" 2>&1 & "
  else
    services_log "modbusserver allready running"
  fi
}
function modbus_stop() 
{
   if pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
      sudo pkill -f "^python.*/modbusserver.py"
      services_log  "kill modbusserver daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill modbusserver daemon"
   else
      services_log "modbusserver daemon is actually not running "
   fi
}
function modbus_status() # $1=eneabled
{
 if (( $1 == 1  )) ; then
    if pgrep -f '^python.*/modbusserver.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/modbusserver.py')
       services_log "modbus runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: modbusserver runs: [$line]"
    else
      services_log "modbusserver daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: modbusserver daemon shut run, but dont"
    fi  
 else
    services_log "modbusserver is disabled or isss is running";
    openwbDebugLog "MAIN" 2 "SERVICE: modbusserver is disabled"
 fi
}



#################################################################
function button_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/ladetaster.py' | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 1  )) ; then
    services_log "button enabled"
    if (( ${isrun:-0} == 0 )) ; then
      button_start
    else
      services_log "button allready run"
    fi
 else
    services_log "button disabled"
    if (( ${isrun:-0} != 0 )) ; then
       button_stop
    else
      services_log "button disabled and not running"
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
   services_log "button not running"
 fi
 if (( $1 == 1 )) ; then
    isrun=$(pgrep -f '^python.*/ladetaster.py')
    services_log "button enabled"
    if (( ${isrun:-0} == 0 )) ; then
      button_start
    else
      services_log "button allready run"
    fi
 else
    services_log "button disabled, not start needed"
 fi 
}
function button_start() 
{
  if ! pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
   services_log "startup button";
   openwbDebugLog "MAIN" 0 "SERVICE: startup button"
   sudo -u pi bash -c "python3 runs/ladetaster.py >>\"$LOGFILE\" 2>&1 & "
  else
    services_log "button allready running"
  fi
}
function button_stop() 
{
   if pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
      sudo pkill -f "^python.*/ladetaster.py"
      services_log  "kill button daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill button daemon"
   else
      services_log "button daemon is actually not running "
   fi
}
function button_status() # $1=eneabled
{
 if (( $1 == 1  )) ; then
    if pgrep -f '^python.*/ladetaster.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/ladetaster.py')
       services_log "button runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: button runs:  [$line]"
    else
      services_log "button daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: button daemon shut run, but dont"
    fi  
 else
    services_log "button is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: button is disabled"
 fi
}



#################################################################
function isss_cron5() # $needIsss $isss_mode  $isss_32
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f "^python.*/$ISSS"| head -1)
 services_log "isrun:$isrun"
 if (( $1 >= 1)) ; then
    # sollte starten, check korrekt mode and resttart if mode changed
    isss_start $1 $2 $3  
 else
    if (( ${isrun:-0} != 0 )) ; then
       services_log "isss disabled, stop it"
       isss_stop $1 $2 $3
    else
      services_log "isss disabled and not running"
    fi
 fi 
}
function isss_reboot() # $needIsss $isss_mode  $isss_32
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f "^python.*/$ISSS")
 if (( ${isrun:-0} != 0 )) ; then
    isss_stop $1 $2 $3
 else
   services_log "$ISSS not running"
 fi
 if (( $1 >= 1)) ; then
    isrun=$(pgrep -f "^python.*/$ISSS")
    services_log "$ISSS enabled"
    if (( ${isrun:-0} == 0 )) ; then
      isss_start $1 $2 $3
    else
      services_log "$ISSS allready run"
    fi
 else
    services_log "$ISSS disabled, not start needed"
 fi 
}
function isss_start() # $needIsss $isss_mode  $isss_32 
{
 local LFILE
 LFILE="$OPENWBBASEDIR/ramdisk/isss.log"
 
  if pgrep -f "^python.*/$ISSS" > /dev/null ; then
     # any runns
     services_log "any $ISSS runns";
     if ! pgrep -f "^python.*/$ISSS.*$isss.*$2.*$3" > /dev/null ; then
        #line=$(pgrep -fa "^python.*/$ISSS")
        #services_log "any run: $line, but with wrong param, so stop it"
        services_log "$ISSS runs, but with wrong params, so stop it"
        isss_stop $1 $2 $3
     else    
        services_log "$ISSS runs with korrekt param, nothing to do";
     fi
  fi
  if ! pgrep -f "^python.*/$ISSS" > /dev/null ; then
   # nothing runs
   services_log "startup $ISSS [$isss] [$2] [$3]";
   openwbDebugLog "MAIN" 0 "SERVICE: startup $ISSS [$isss] [$2] [$3] "
   sudo -u pi bash -c "python3 runs/$ISSS $isss $2 $3 >>\"$LFILE\" 2>&1 & "
   line=$(pgrep -fa "^python.*/$ISSS")
   services_log "now $ISSS $line"
  else
    services_log "$ISSS allready running"
  fi
}


function isss_stop() # $1 $2 $3 
{
# kill any variant 
   if pgrep -f "^python.*/$ISSS" > /dev/null ; then
      sudo pkill -f "^python.*/$ISSS"
      services_log  "kill $ISSS daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill $ISSS daemon"
   else
      services_log "$ISSS daemon is actually not running "
   fi
}
function isss_status() # $needIsss $isss_mode  $isss_32
{
 if (( $1 >= 1)) ; then
    if pgrep -f "^python.*/$ISSS" > /dev/null ; then
       # any running
       line=$(pgrep -fa "^python.*/$ISSS")
       services_log "any runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: any $ISSS is aktiv $line"
       if pgrep -f "^python.*/$ISSS.*$isss.*$2.*$3" > /dev/null ; then
          services_log "SERVICE: $ISSS runs wth correkt mode [$isss] [$2] [$3]"
          openwbDebugLog "MAIN" 0 "SERVICE: $ISSS runs wth correkt mode [$isss] [$2] [$3]"
       else
          services_log "SERVICE: $ISSS runs but not with [$isss] [$2] [$3]"
          openwbDebugLog "MAIN" 0 "SERVICE: $ISSS runs but not with [$isss] [$2] [$3]"
       fi
    else
      services_log "$ISSS [$isss] [$2] [$3] shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: $ISSS [$isss] [$2] [$3] shut run, but dont"
    fi  
 else
    if pgrep -f '^python.*/$ISSS' > /dev/null ; then
       services_log "$ISSS is disabled but running";
       openwbDebugLog "MAIN" 2 "SERVICE: $ISSS is disabled but running"
    else
        services_log "$ISSS is disabled and not running";
        openwbDebugLog "MAIN" 2 "SERVICE: $ISSS is disabled and not running"
    fi    
 fi
}

#################################################################
function smarthome_cron5()  
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/smarthomehandler.py' | head -1  )
 services_log "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    services_log "smarthomehandler enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smarthome_start
    else
      services_log "smarthomehandler allready run"
    fi
 else
    services_log "smarthomehandler disabled"
    if (( ${isrun:-0} != 0 )) ; then
       smarthome_stop
    else
      services_log "smarthomehandler disabled and not running"
    fi
 fi 
}
function smarthome_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/smarthomehandler.py' | head -1 )
 if (( ${isrun:-0} != 0 )) ; then
    smarthome_stop
 else
   services_log "smarthomehandler not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/smarthomehandler.py' | head -1)
    services_log "smarthomehandler enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smarthome_start
    else
      services_log "smarthomehandler allready run"
    fi
 else
    services_log "smarthomehandler disabled or isss is running or smartmq aktiv, not start needed "
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
   services_log "startup smarthome";
   openwbDebugLog "MAIN" 0 "SERVICE: startup smarthomehandler"
   sudo -u pi bash -c "python3 runs/smarthomehandler.py >>\"$LFILE\" 2>&1 & "
  else
    services_log "smarthomehandler allready running"
  fi
}
function smarthome_stop() 
{
   if pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
      sudo pkill -f "^python.*/smarthomehandler.py"
      services_log  "kill smarthomehandler daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill smarthomehandler daemon"
   else
      services_log "smarthomehandler daemon is actually not running "
   fi
}
function smarthome_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/smarthomehandler.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/smarthomehandler.py')
       services_log "smarthomehandler runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: smarthomehandler runs: [$line]"
    else
      services_log "smarthomehandler daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: smarthomehandler daemon shut run, but dont"
    fi  
 else
    services_log "smarthomehandler is disabled or isss is running";
    openwbDebugLog "MAIN" 2 "SERVICE: smarthomehandler is disabled or isss is running"
 fi
}


#################################################################
function smartmq_cron5() 
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/smarthomemq.py' | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 1  && isss == 0  )) ; then
    services_log "smartmq enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smartmq_start
    else
      services_log "smartmq allready run"
    fi
 else
    services_log "smartmq disabled or isss is running"
    if (( ${isrun:-0} != 0 )) ; then
       smartmq_stop
    else
      services_log "smartmq disabled and not running or isss is running"
    fi
 fi 
}
function smartmq_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f '^python.*/smarthomemq.py' | head -1 )
 if (( ${isrun:-0} != 0 )) ; then
    smartmq_stop
 else
   services_log "smartmq not running"
 fi
 if (( $1 == 1  && isss == 0  )) ; then
    isrun=$(pgrep -f '^python.*/smarthomemq.py')
    services_log "smartmq enabled"
    if (( ${isrun:-0} == 0 )) ; then
      smartmq_start
    else
      services_log "smartmq allready run"
    fi
 else
    services_log "smartmq disabled or isss is running, or old smarthome aktiv , no start needed"
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
   services_log "startup smartmq";
   openwbDebugLog "MAIN" 0 "SERVICE: startup smartmq"
   sudo -u pi bash -c "python3 runs/smarthomemq.py >>\"$LFILE\" 2>&1 & "
  else
    services_log "smartmq allready running"
  fi
}
function smartmq_stop() 
{
   if pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
      sudo pkill -f "^python.*/smarthomemq.py"
      services_log  "kill smartmq daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill smartmq daemon"
   else
      services_log "smartmq daemon is actually not running "
   fi
}
function smartmq_status() # $1=eneabled
{
 if (( $1 == 1  && isss == 0  )) ; then
    if pgrep -f '^python.*/smarthomemq.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/smarthomemq.py')
       services_log "smarthomemq runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: smartmq runs:  [$line]"
    else
      services_log "smartmq daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: smartmq daemon shut run, but dont"
    fi  
 else
    services_log "smartmq is disabled or isss is running";
    openwbDebugLog "MAIN" 2 "SERVICE: smartmq is disabled or isss is running"
 fi
}



#################################################################
function mqttsub_cron5() 
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f '^python.*/mqttsub.py' | head -1 )
 services_log "isrun:$isrun"

    if (( ${isrun:-0} == 0 )) ; then
      mqttsub_start
    else
      services_log "mqttsub allready run"
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
   services_log "mqttsub not running"
 fi

    isrun=$(pgrep -f '^python.*/mqttsub.py')
    if (( ${isrun:-0} == 0 )) ; then
      mqttsub_start
    else
      services_log "mqttsub allready run"
    fi
}
function mqttsub_start() 
{
  if ! pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
   services_log "startup mqttsub";
   openwbDebugLog "MAIN" 0 "SERVICE: startup mqttsub"
   sudo -u pi bash -c "python3 runs/mqttsub.py >>\"$LOGFILE\" 2>&1 & "
  else
    services_log "mqttsub allready running"
  fi
}
function mqttsub_stop() 
{
   if pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
      sudo pkill -f "^python.*/mqttsub.py"
      services_log  "kill mqttsub daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: kill mqttsub daemon"
   else
      services_log "mqttsub daemon is actually not running "
   fi
}
function mqttsub_status() 
{
    if pgrep -f '^python.*/mqttsub.py' > /dev/null ; then
       line=$(pgrep -fa '^python.*/mqttsub.py')
       services_log "mqttsub runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: mqttsub runs:  [$line]"
    else
      services_log "mqttsub daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: mqttsub daemon shut run, but dont"
    fi  
}

########## sysdaem  as PI #####################################
function sysdaem_cron5() # $1=eneabled
{
 # if enabed  start if not running
 # if disabled kill if running
 isrun=$(pgrep -f 'runs/sysdaem.sh' | head -1)
 services_log "isrun:$isrun"
 if (( $1 == 1)) ; then
    services_log "sysdaem enabled"
    if (( ${isrun:-0} == 0 )) ; then
      sysdaem_start
    else
      services_log "sysdaem allready run"
    fi
 else
    services_log "sysdaem disabled"
    if (( ${isrun:-0} != 0 )) ; then
       sysdaem_stop
    else
      services_log "sysdaem disabled and not running"
    fi
 fi 
}
function sysdaem_reboot() # $1=eneabled
{
 # kill if running
 # start if enabled
 isrun=$(pgrep -f 'runs/sysdaem.sh' |head -1)
 openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_reboot isrun:[$isrun] soll:[$1]"
 
 if (( ${isrun:-0} != 0 )) ; then
    sysdaem_stop
 else
   services_log "sysdaem not running"
 fi
 openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_reboot soll:[$1]"
 if (( $1 == 1)) ; then
    services_log "sysdaem enabled"
    isrun=$(pgrep -f 'runs/sysdaem.sh' |head -1)
    openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_reboot isrun:[$isrun] soll:[$1]"
    if (( ${isrun:-0} == 0 )) ; then
      sysdaem_start
    else
      services_log "sysdaem allready run"
    fi
 else
    services_log "sysdaem disabled, not start needed"
 fi 
}
function sysdaem_start() 
{
  if ! pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
   services_log "startup sysdaem";
   openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_start startup sysdaem"
   sudo -u pi bash -c "runs/sysdaem.sh $1 >>\"$LOGFILE\" 2>&1 & "
  else
    openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_start allready run"
    services_log "sysdaem_start sysdaem allready running"
  fi
}
function sysdaem_stop() 
{
   if pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
      sudo pkill -f "runs/sysdaem.sh"; 
      services_log  "kill sysdaem daemon"
      openwbDebugLog "MAIN" 0 "SERVICE: sysdaem_stop kill sysdaem daemon"
      if pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
          sudo pkill -f "runs/sysdaem.sh"; 
      fi
   else
      services_log "sysdaem_stop sysdaem is actually not running "
   fi
}
function sysdaem_status() # $1=eneabled
{
 if (( $1 == 1)) ; then
    if pgrep -f 'runs/sysdaem.sh' > /dev/null ; then
       line=$(pgrep -fa 'runs/sysdaem.sh')
       services_log "sysdaem runs: [$line]"
       openwbDebugLog "MAIN" 0 "SERVICE: sysdaem runs: [$line]"
    else
      services_log "sysdaem daemon shut run, but dont"
      openwbDebugLog "MAIN" 0 "SERVICE: sysdaem daemon shut run, but dont"
    fi  
 else
    services_log "sysdaem is disabled";
    openwbDebugLog "MAIN" 2 "SERVICE: sysdaem is disabled"
 fi
}


function selectstatus()
{
 local -i smartmq smarthome
 read smartmq </var/www/html/openWB/ramdisk/smartmq
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 openwbDebugLog "MAIN" 2 "****ANF Status for openWB.Services $1 smartmq:$smartmq smarthome:$smarthome ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_status  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_status  $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_status  $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_status  $modbus502enabled
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_status  $ladetaster
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_status $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_status $smartmq  
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_status $needIsss $isss_mode  $isss_32   
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_status 1 
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_status $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_status 1
 services_log "****END Status for openWB.Services *************"
}

function selectstart()
{
 local -i smartmq smarthome
 read smartmq </var/www/html/openWB/ramdisk/smartmq
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 openwbDebugLog "MAIN" 2 "****ANF start for openWB.Services $1 smartmq:$smartmq smarthome:$smarthome ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_cron5  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_cron5 $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_cron5 $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_cron5 $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_cron5 $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_cron5 1 
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_cron5 $needIsss $isss_mode  $isss_32
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_cron5 $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_cron5 1

}
function selectstop()
{
 local -i smartmq smarthome
 read smartmq</var/www/html/openWB/ramdisk/smartmq
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #services_log "****ANF Stop for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_stop $rseenabled  
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_stop $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_stop $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_stop $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_stop $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_stop $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_stop  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_stop 1 
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_stop  
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_stop $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_stop 1

}
function selectcron5()
{
 local -i smartmq smarthome
 read smartmq</var/www/html/openWB/ramdisk/smartmq
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #services_log "****ANF cron5 for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_cron5  $rseenabled
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_cron5 $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_cron5 $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_cron5 $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_cron5 $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_cron5  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_cron5 1 
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_cron5  $needIsss $isss_mode  $isss_32
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_cron5 $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_cron5 1
}
function selectreboot()
{
 local -i smartmq smarthome
 read smartmq</var/www/html/openWB/ramdisk/smartmq
 if (( smartmq == 1 )) ; then smarthome=0; else smarthome=1; fi
 #services_log "****ANF reboot for openWB.Services $1 ***********"
 [[ "$1" == "all" || "$1" == "rse" ]]  &&  rse_reboot $rseenabled  
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid1_reboot $rfidakt
 [[ "$1" == "all" || "$1" == "rfid" ]] &&  rfid2_reboot $rfidakt
 [[ "$1" == "all" || "$1" == "modbus" ]]  &&  modbus_reboot $modbus502enabled
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smarthome_reboot $smarthome
 [[ "$1" == "all" || "$1" == "smarthome" ]]  &&  smartmq_reboot $smartmq  
 [[ "$1" == "all" || "$1" == "button" ]]  &&  button_reboot  $ladetaster
 [[ "$1" == "all" || "$1" == "mqttsub" ]]  &&  mqttsub_reboot 1 
 [[ "$1" == "all" || "$1" == "isss" ]]  &&  isss_reboot  $needIsss $isss_mode  $isss_32
 [[ "$1" == "all" || "$1" == "tasker" ]]  &&  tasker_reboot $taskerenabled
 [[ "$1" == "all" || "$1" == "sysdaem" ]]  &&  sysdaem_reboot 1

}
function service_main() # cmd what
{
 what=${2:-all}
 # services_log "****ANF service_main $1 $2 ***********"
 openwbDebugLog "MAIN" 2 "***ANF service..sh main [$1] [$2] *********"
 
 
    if ((isss == 0)) && [ -f "./ramdisk/parentWB" ]; then
        services_log "****Switch off isss, remove parentWB *********"
        sudo rm -f ./ramdisk/parentWB
        mosquitto_pub -t "openWB/system/parentWB" -m "localhost" -r
    fi
 
 
 
 checkIfIsssIsNeeded
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
    			echo "Usage: ${BASH_SOURCE[0]} {start|stop|restart|status [all|rse|rfid|modbus|smarthome|buttons|tasker|isss|mqttsub|sysdaem]}"
        ;;
 esac
}



if (( runmain>0 )) ; then
 #echo "run $0 directly or from php/apache"
 service_main $1 $2
fi
 

