#!/bin/bash

cnt=${1:-"100"}
 
 if [[ $cnt -lt 250 ]] ; then
  if [[ $cnt -ge 10 ]] ; then
    if [ -f /sys/class/backlight/rpi_backlight/brightness ] ; then

	    #sudo echo $cnt >/sys/devices/platform/rpi_backlight/backlight/rpi_backlight/brightness
		
		#sudo echo  klappt nicht, da echo eingebautes Kommando ist
		# ergibt immer "Keine Berechtigung"
		# also die Zahl per cp in die Variable schreiben lassen,
		# das wird von sudo in einer subshell mit root rechten ausgef?hrt.
		cntf=/var/www/html/openWB/ramdisk/cnt$$ 
		echo "$cnt" >$cntf 
		sudo cp $cntf /sys/class/backlight/rpi_backlight/brightness
		rm $cntf
		
    fi
  fi 
fi  

