#!/bin/bash

#############################################
# rct_setter.sh
# Author Heinz Hoefling
# Steuert die Automatische Laduung des Hausakkus
# Steuert den Entladeschutz bei PKW Ladung aus Netz
# Wird aufgerufen nur von mqttsub,oy aks reaktion
# auf "Set" befehle.
# openWB/set/houseBattery/priceload 0/1 start/sup bat laden
# openWB/set/houseBattery/reset_rct manuels reset wat/current
# openWB/set/houseBattery/hooker  hookstart hookstop
# openWB/set/houseBattery/loadbat sec Manuelles Laden
# Diese "Set" Befehle stammen von hook.sh
# und regel.sh
#
#############################################

OPENWBBASEDIR=$(cd `dirname $0`/../../ && pwd)
cd /var/www/html/openWB/modules/tibber_rct
# rct2 oder rct2h oder rct2x
# check if config file is already in env
declare -F openwbDebugLog &>/dev/null  || {
    cd /var/www/html/openWB || exit 0
    source loadconfig.sh
    source helperFunctions.sh
    direct=1
}
declare -F log &>/dev/null  || {
    log()
    {
       timestamp=`date +"%Y-%m-%d %H:%M:%S"`
       echo "$timestamp $$ RCT: $*" >>/var/log/rct.log
       openwbDebugLog "MAIN" 0 "RCT: $*"
    }
}
[[ "${direct:-0}" == "1" ]]  && log "Directsart"

# Simuliere hardware
if grep -q "208.64" "/var/www/html/openWB/ramdisk/ipaddress"; then
  simul=0
  optv=" -v"
else
  simul=1
  optv=" -v"
fi

# set >/tmp/set.txt
# env >/tmp/env.txt

PWD=$(pwd)
debug=${debug:-3}
ip=${bezug1_ip:-192.168.208.63}
log "######### [$1] [$2] debug:[$debug] ###########"
openwbDebugLog "DEB" 2 "RCT:  [$1] [$2] debug:[$debug]"
iskalib=1	# alles ausperren
lademodus=3	# stop
discharge_max="20.0"
loadWatt=100
load_minutes=0
enable_discharge_max=1
ladungaktivlp1=0
id=$(id )
# log $id
#config file einlesen

########### Laufzeit protokolieren
start=$(date +%s)
function cleanup()
{
	ptend rct_setter 1
	[ -e ramdisk/rct_setteraktive ] &&	rm -r ramdisk/rct_setteraktive
}
ptstart
trap cleanup EXIT
########### End Laufzeit protokolieren


function init()
{
  [ -e ramdisk/HB_iskalib ] && read iskalib <ramdisk/HB_iskalib
  read lademodus  <ramdisk/lademodus
  read ladungaktivlp1 <ramdisk/ladungaktivlp1

  read enable_discharge_max <ramdisk/HB_enable_discharge_max
  read discharge_max <ramdisk/HB_discharge_max

  read enable_priceloading <ramdisk/HB_enable_priceloading
  read loadWatt <ramdisk/HB_loadWatt
  read load_minutes <ramdisk/HB_load_minutes

}

function check_kalib()
{
 if (( iskalib == 1 )) ; then
   log "check_kalib Kalibartion aktiv, EXIT 1"
   exit 1
 fi
# log "check_kalibm Ok"
}

function check_alone()
{
 if [ -e ramdisk/rct_setteraktive ]  ; then
   log "check_alone ERROR script allready runs, rct_setter.sh exit 1"
   exit 1
 fi
# log "check_alone check_alone Ok, rct_setteraktive touched"
 touch ramdisk/rct_setteraktive
}

function checklademode()
{
 # testen ob nicht,  irgendwie sind die Konstanten nicht vorhannden
 if (( lademodus == 3 )) || (( lademodus == 1))  ||  (( lademodus == 2 )) ; then 
   log "checklademode PV oder STOP, rct_setter.sh exit 1"
   exit 1
 fi
 #log  "checklademode Ok"
}

# echten timer setzen
function settimer()  # resetwatt oder resetcurrent , minuten
{
 was=${1:-reset}
 lange=${2:-2}
 log  "settimer  $was for $lange"
 echo "mosquitto_pub -q 2 -r -t openWB/set/houseBattery/reset_rct -m $was; echo \"at $was\" >>/var/log/rct.log" | at -q O "now + $lang minutes" >>/var/log/rct.log 2>&1
}

function disablepriceloading()
{
   log "disabled priceloading in ramdisk & mqtt"
   mosquitto_pub -r -t openWB/housebattery/enable_priceloading -m "0"
   echo "0" >ramdisk/HB_enable_priceloading
}

function setminutes()
{
   minuts=${1:-0}
   log "set load-minutes in ramdisk & mqtt to $minuts"
   mosquitto_pub -r -t openWB/housebattery/load_minutes -m $minuts
   echo "$minuts" >ramdisk/HB_load_minutes
}


function killtimer() # $1 welcher reset|resetcurrent  reset=alle
{
 was=${1:-#nix} # also beide
 log "Killtimer:$was "

  for j in $(atq -q O | cut -f 1 | sort -n)
   do
     a=$(atq -q O | grep -P "^$j\t")
     b=$(at -c "$j" | tail -n 2)
     if echo $b | grep -q "$was" ; then
        log "atrm [$a] [$b] "
        atrm $j
     else
        log "atq  [$a] [$b] "
     fi
   done
}

function deaktivateDrainmode()   
{
 # abschallten geht immer
 if [[ "$discharge_max" == "20.0" ]]  ; then
    log " schon aus , return"
    return 0
 fi

 killtimer resetcurrent
 if (( simul )) ; then
    log "simulioere Haedware  20->HB_discharge_max"
    echo "20.0" >ramdisk/HB_discharge_max
  else  
    log "call rct_set.py $optv -a resetcurrent"
    ./modules/tibber_rct/rct_set.py $optv -a resetcurrent >>/var/log/rct.log
 fi 
}

function aktivateDrainmode()
{
 lang=${1:-240}

 read soc <ramdisk/speichersoc
 if  (( soc < 10 )) ; then
    log "drain not needed akku sowieso leer, exit [$soc %]"
    return 0
 fi

 if (( enable_discharge_max == 0 )) ; then
   log "drain disabled, exit [$soc %]"
   return 0
 fi
 
 if  [[ "$discharge_max" == "1.0" ]]  ; then
    log "allredy reduced, exit [$soc %]"
    return 0
 fi
 
  killtimer resetcurrent
  if (( simul )) ; then
  	  log "simuliere Hardware 1->discharge_max [$soc %]"
      echo "1.0" >ramdisk/HB_discharge_max
  else
    log "call rct_set.py $optv -a drain1A [$soc %]"
    ./modules/tibber_rct/rct_set.py $optv -a drain1A >>/var/log/rct.log
  fi    
  settimer resetcurrent "now + ${lang} minutes"
}

function aktivate_loadbat() #  $1=zeit in minuten f?r den auto-reset
{
 lang=${1:-8}
  
 read soc <ramdisk/speichersoc
 if  (( soc > 80 )) ; then
   log "aktivate_loadbat , akku >80% voll, return [$soc %]"
   return 0
 fi 

 if (( lang == 0 )) || (( lang >= 180 )) ; then  # Autommodus nutze 3 strunden als resettime
   log "aktivate_loadbat Auto mode set reseetime to 180 [$soc %]"
   lang=180
 fi
  

 killtimer resetwatt
 log "aktivate_loadbat for $lang minutes"
  if (( simul )) ; then
      log "simuliere 3000.0 -> HB_loadWatt"
  	  echo "3000.0" >ramdisk/HB_loadWatt
  else
     log "call rct_set.py $optv -a loadbat -w 3000 [$soc %]"
    ./modules/tibber_rct/rct_set.py $optv -a loadbat -w 3000 >>/var/log/rct.log
 fi     
 settimer "resetwatt" "now + ${lang} minutes"
 setminutes $lang    
}

# Manuelles reset
function resetwatt() # $1 reset resetwatt resetcurrent  
{
  read soc <ramdisk/speichersoc
  log "resetwatt"
  killtimer resetwatt
  if (( simul )) ; then
          log "simuliere resetwatt 100.0->HB_loadWatt [$soc %]"
          echo "100.0" >ramdisk/HB_loadWatt
   else
     log "call rct_set.py $optv  -a resetwatt [$soc %]"
     ./modules/tibber_rct/rct_set.py $optv  -a resetwatt >>/var/log/rct.log
  fi    
}

# Manuelles reset
function resetcurrent() # $1   
{
 read soc <ramdisk/speichersoc
 # return
 log "resetcurrent"
 killtimer resetcurrent
  if (( simul )) ; then
    log "simuliere resetcurrent 20.0 -> HB_discharge_max"
    echo "20.0" >ramdisk/HB_discharge_max
 else
   log "call rct_set.py $optv  -a resetcurrent [$soc %]"
   ./modules/tibber_rct/rct_set.py $optv  -a resetcurrent >>/var/log/rct.log
 fi 
}

function timer()
{
  
  read soc  <ramdisk/speichersoc
  
  if (( load_minutes >0 )) && (( soc > 94 )) ; then
     log "Akku voll, stoppe ladung [$soc %]"
     resetwatt
     setminutes 0
   else
     log "load minutem:[$load_minutes] Watt:[$loadWatt] soc:[$soc]"
  fi  
    
}


#
# Alle Aktionen nur wenn keine Kalibrierung aktiv ist
# Kalib-Erkennung an SocTaret<>97  (0 oder 100 treten beim Kalib auf)
#

# log "[$1] starts (p2:[$2])"
 init
 log "[$1] isk:[$iskalib] ena:[$enable_discharge_max] dis:[$discharge_max] lmin:[$load_minutes] batena:[$enable_priceloading]  lWatt:[$loadWatt] lakt:[$ladungaktivlp1]"

 case $1 in
    "aktivateDrainmode")
                check_alone
                check_kalib
                aktivateDrainmode $2    #  opt param die minuten f?r das reset
                ;;
 
# Called via mqtt from hook.sh bei Ladestart im Sofortmodus 
   "hookstart") check_alone
                check_kalib 
                checklademode 
                aktivateDrainmode $2    #  opt param die minuten f?r das reset
                ;;
# Called via mqtt from hook.sh bei Ladestop im Sofortmodus 
   "hookstop")  check_alone
                # check_kalib    # deaktivierung geht immer
                # checklademode  # deaktivierung geht immer
                deaktivateDrainmode
                ;;
# called via mqtt form Manuel und automatischen Bat-Lade start
# 180 min=Auto sonst manuell
    "loadbat")  # $2 Minutenzahl 
                check_alone
                check_kalib     
                
                read soc <ramdisk/speichersoc
                
                if  (( soc > 94 )) ; then
                     log "aktivate_loadbat , akku schon voll, return [$soc %]"
                else
                    log "aktivate_loadbat "
                    aktivate_loadbat $2
                    # setminutes $2
                    # bei Manuel, Auto disablen
                    if (( $2  < 180 )) ; then
                        disablepriceloading
                    fi
                fi
                ;;
# called via mqtt bei Timoutout oder wenn Soc=94% erreicht. oder manueller reset
    "resetwatt") # check_kalib
                check_alone
                resetwatt  
                # bei Manuel, Auto disablen
                 #if (( load_minutes < 180 )) ; then
                    disablepriceloading
                 #fi
                 setminutes 0
                 if (( ladungaktivlp1 == 1 )); then
                    log "PKW Ladung noch aktive, stelle sicher das der Akku nicht sofort wieder leer wird"
                   aktivateDrainmode 
                 fi
                ;;
                
# called via mqtt timeout oder manueller reset
 "resetcurrent") # check_kalib
                 check_alone
                 resetcurrent
                ;;
                
    "reset")    # check_kalib
                check_alone
                resetwatt
                resetcurrent
                # bei Manuel, Auto disablen
                if (( load_minutes < 180 )) ; then
                    disablepriceloading
                fi
                setminutes 0
				;;

# called from regel.sh
    "timer")    check_alone
                timer
                ;;
                
    "status")   check_alone
                killtimer "#onlylisten#"
                ;;
                
    "init")     log "Set Right for rct.setter"
                sudo chown pi:pi ramdisk/*HB*
                sudo chmod a+w /var/log/rct.log
                killtimer reset
                ;;
                
    "test")     log "do test"
                check_kalib     
                check_alone
				killtimer "resetwatt"
                ;;
                                                  
    *)          log  "ERROR hook [$1]  unknown"
                log  "usgae: hookstart hookstop loadbat timer resetcurrent resetwatt reset init status test"
                ;;
 esac
 openwbDebugLog "MAIN" 2 "RCT: [$1] ends"




