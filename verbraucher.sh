#!/bin/bash

# Called before graphing,sh


function doverbraucher()
{
  declare -r IsNumRegex='^[+-]?[0-9]+([.][0-9]+)?$'


# C verbraucher1_aktiv verbraucher1_typ verbraucher1_source verbraucher1_id verbraucher1_ip verbraucher1_tempwh
# F verbraucher1vorhanden verbraucher1_watt verbraucher1_wh
# V verbraucher1_watt -> fuer graphing.sh verbraucher1_wh  
    if (( verbraucher1_aktiv == 1)); then
        verbraucher1_watt=0  
        # echo 1 > ramdisk/verbraucher1vorhanden  NC
        case $verbraucher1_typ in
        "http")
               if [[ ! "$verbraucher1_urlw" =~ ^http:\/\/url$ ]] ; then   
                    verbraucher1_watt=$(curl --connect-timeout 3 -s $verbraucher1_urlw )
                    openwbDebugLog "MAIN" 2 "verb curl:[$verbraucher1_urlw] -> [$verbraucher1_watt]"
                    if ! [[ "$verbraucher1_watt" =~ $IsNumRegex ]]; then
                        openwbDebugLog "MAIN" 0 "verb [$verbraucher1_watt] is not a number"
                        $verbraucher1_watt=0
                    fi
               fi     
               if [[ ! "$verbraucher1_urlh" =~ ^http:\/\/url$ ]] ; then   
                    verbraucher1_wh=$(curl --connect-timeout 3 -s $verbraucher1_urlh &)
                    openwbDebugLog "MAIN" 2 "verb curl:[$verbraucher1_urlh] -> [$verbraucher1_wh]"
                    if [[ "$verbraucher1_wh" =~ $IsNumRegex ]]; then
                        openwbDebugLog "MAIN" 1 "verb store verbraucher1_wh=[$verbraucher1_wh]"
                        echo $verbraucher1_wh > ramdisk/verbraucher1_wh
                    else                
                        openwbDebugLog "MAIN" 0 "verb [$verbraucher1_wh] is not a number"
                        verbraucher1_wh=0
                    fi
                fi    
                ;;
    "mpm3pm")
            if [[ $verbraucher1_source == *"dev"* ]]; then
                sudo python modules/verbraucher/mpm3pmlocal.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            else
                sudo python modules/verbraucher/mpm3pmremote.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            fi
            ;;
    "sdm630")
            if [[ $verbraucher1_source == *"dev"* ]]; then
                sudo python modules/verbraucher/sdm630local.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            else
                sudo python modules/verbraucher/sdm630remote.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            fi
            ;;
    "sdm120")
            if [[ $verbraucher1_source == *"dev"* ]]; then
                sudo python modules/verbraucher/sdm120local.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            else
                sudo python modules/verbraucher/sdm120remote.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
            fi
            ;;
    "abb-b23")
                python modules/verbraucher/abb-b23remote.py 1 $verbraucher1_source $verbraucher1_id &
                verbraucher1_watt=$(cat ramdisk/verbraucher1_watt)
                sleep .3
                ;;
    "tasmota")
            local out=$(curl --connect-timeout 3 -s $verbraucher1_ip/cm?cmnd=Status%208 )
            verbraucher1_watt=$(echo $out | jq '.StatusSNS.ENERGY.Power')
                           wh=$(echo $out | jq '.StatusSNS.ENERGY.Total')    # in KW
            # messwert des tages + summe vortage 
            verbraucher1_wh=$(echo "scale=0;(($wh * 1000) + $verbraucher1_tempwh)  / 1" | bc)
            openwbDebugLog "MAIN" 1 "verb store verbraucher1_wh=[$verbraucher1_wh]"
            echo $verbraucher1_wh > ramdisk/verbraucher1_wh
            ;;
     "shelly")
            local out=$(curl --connect-timeout 3 -s $verbraucher1_ip/status )
            openwbDebugLog "MAIN" 2 "verb curl:[$verbraucher1_ip/status]"
            verbraucher1_watt=$(echo $out |jq '.meters[0].power' | sed 's/\..*$//')
# macht simcount.py            
#                           wh=$(echo $out | jq '.meters[0].total')   # in wh
#            verbraucher1_wh=$(echo "scale=0;(($wh * 1) + $verbraucher1_tempwh)  / 1" | bc)
#            openwbDebugLog "MAIN" 1 "verb store verbraucher1_wh=[$verbraucher1_wh]"
#            echo $verbraucher1_wh > ramdisk/verbraucher1_wh
            ;;
        *)
            verbraucher1_watt=0
            ;;
        esac
        openwbDebugLog "MAIN" 1 "verb store verbraucher1_watt=[$verbraucher1_watt]"
        echo $verbraucher1_watt > ramdisk/verbraucher1_watt
    else
        verbraucher1_watt=0
        echo $verbraucher1_watt > ramdisk/verbraucher1_watt
    fi

    if (( verbraucher2_aktiv == 1 )); then
        verbraucher2_watt=0
        # NC echo "1" > ramdisk/verbraucher2vorhanden
        case $verbraucher2_typ in
        "http")
                if [[ ! "$verbraucher2_urlw" =~ ^http:\/\/url$ ]] ; then   
                    verbraucher2_watt=$(curl --connect-timeout 3 -s $verbraucher2_urlw )
                    if  [[ "$verbraucher2_watt" =~ $IsNumRegex ]]; then
                        openwbDebugLog "MAIN" 0 "verb [$verbraucher2_watt] is not a number"
                        verbraucher2_watt=0
                    fi
                fi    
                if [[ ! "$verbraucher2_urlh" =~ ^http:\/\/url$ ]] ; then   
                    verbraucher2_wh=$(curl --connect-timeout 3 -s $verbraucher2_urlh &)
                    if [[ "$verbraucher2_wh" =~ $IsNumRegex ]]; then
                        echo $verbraucher2_wh > ramdisk/verbraucher2_wh
                    else                
                        openwbDebugLog "MAIN" 0 "verb [$verbraucher2_wh] is not a number"
                        verbraucher2_wh=0
                    fi
                fi     
            ;;
       "mpm3pm")
            if [[ $verbraucher2_source == *"dev"* ]]; then
                sudo python modules/verbraucher/mpm3pmlocal.py 2 $verbraucher2_source $verbraucher2_id &
            else
                sudo python modules/verbraucher/mpm3pmremote.py 2 $verbraucher2_source $verbraucher2_id &
            fi
            ;;
       "sdm630")
            if [[ $verbraucher2_source == *"dev"* ]]; then
                sudo python modules/verbraucher/sdm630local.py 2 $verbraucher2_source $verbraucher2_id &
                verbraucher2_watt=$(cat ramdisk/verbraucher2_watt)
            else
                sudo python modules/verbraucher/sdm630remote.py 2 $verbraucher2_source $verbraucher2_id &
                verbraucher2_watt=$(cat ramdisk/verbraucher2_watt)
            fi
            ;;
      "sdm120")
            if [[ $verbraucher2_source == *"dev"* ]]; then
                sudo python modules/verbraucher/sdm120local.py 2 $verbraucher2_source $verbraucher2_id &
                verbraucher2_watt=$(cat ramdisk/verbraucher2_watt)
            else
                sudo python modules/verbraucher/sdm120remote.py 2 $verbraucher2_source $verbraucher2_id &
                verbraucher2_watt=$(cat ramdisk/verbraucher2_watt)
            fi
            ;;
     "abb-b23")
            python modules/verbraucher/abb-b23remote.py 2 $verbraucher2_source $verbraucher2_id &
            verbraucher2_watt=$(cat ramdisk/verbraucher2_watt)
            sleep .3
            ;;
      "tasmota")
            local out=$(curl --connect-timeout 3 -s $verbraucher2_ip/cm?cmnd=Status%208 )
            openwbDebugLog "MAIN" 2 "verb curl:[$verbraucher2_ip/status]"
            verbraucher2_watt=$(echo $out | jq '.StatusSNS.ENERGY.Power')
                           wh=$(echo $out | jq '.StatusSNS.ENERGY.Total')
            # messwert des tages + summe vortage 
            verbraucher2_wh=$(echo "scale=0;(($wh * 1000) + $verbraucher2_tempwh)  / 1" | bc)
            echo $verbraucher2_wh > ramdisk/verbraucher2_wh            
            ;;
     "shelly")
            local out=$(curl --connect-timeout 3 -s $verbraucher2_ip/status )
            openwbDebugLog "MAIN" 2 "verb curl:[$verbraucher2_ip/status] "
            verbraucher2_watt=$(echo $out |jq '.meters[0].power' | sed 's/\..*$//')
# counter via simcount            
#                           wh=$(echo $out | jq '.meters[0].total')   # in wh
#            verbraucher2_wh=$(echo "scale=0;(($wh * 1) + $verbraucher2_tempwh)  / 1" | bc)
#            openwbDebugLog "MAIN" 1 "verb store verbraucher2_wh=[$verbraucher2_wh]"
#            echo $verbraucher2_wh > ramdisk/verbraucher2_wh
            ;;
        *)
            verbraucher2_watt=0
            ;;
        esac
        openwbDebugLog "MAIN" 1 "verb verbraucher2_watt=[$verbraucher2_watt]"
       echo $verbraucher2_watt > ramdisk/verbraucher2_watt
    else
        verbraucher2_watt=0
        echo $verbraucher2_watt > ramdisk/verbraucher2_watt
    fi
}



