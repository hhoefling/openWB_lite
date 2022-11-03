#!/bin/bash

# called from loadvar.sh timeout 10 modules/$ladeleistungmodul/main.sh

# check if config file is already in env
declare -F openwbDebugLog &> /dev/null || {
    . "$OPENWBBASEDIR/loadconfig.sh"
	. "$OPENWBBASEDIR/helperFunctions.sh"
}

re='^[-+]?[0-9]+\.?[0-9]*$'
r2e='^-?[0-9]+$'

function getone()  # url, ramdisk
{
  declare -r url=${1:-http://url}
  declare -r ram=$2
  local erg
 
  if [[ "$url" == "http://url" ]] ;  then
	#openwbDebugLog "MAIN" 2 "httpll  [$url] irgnore"
	#echo "0" >"/var/www/html/openWB/ramdisk/$ram"
	return
  fi
  erg=$(curl --connect-timeout 3 -s $url)
  if ! [[ $erg =~ $re ]] ; then
	openwbDebugLog "MAIN" 2 "httpll  [$url]->[$erg] illegal, use 0"
    echo "0" >"/var/www/html/openWB/ramdisk/$ram"
	return
  fi
  openwbDebugLog "MAIN" 2 "httpll  curl [$url] -> [$erg] to [$ram]"
  echo $erg >"/var/www/html/openWB/ramdisk/$ram"
}


getone "$httpll_w_url"   "llaktuell"
getone "$httpll_kwh_url" "llkwh"
getone "$httpll_a1_url"  "lla1"
getone "$httpll_a2_url"  "lla2"
getone "$httpll_a3_url"  "lla3"

plugstat=$(curl --connect-timeout 2 -s $httpll_ip/plugstat)
chargestat=$(curl --connect-timeout 2 -s $httpll_ip/chargestat)
if ! [[ $plugstat =~ $r2e ]] ; then
	   plugstat="0"
fi
if ! [[ $chargestat =~ $r2e ]] ; then
	   chargestat="0"
fi
echo $plugstat > /var/www/html/openWB/ramdisk/plugstat
echo $chargestat > /var/www/html/openWB/ramdisk/chargestat
