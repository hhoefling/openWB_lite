#!/bin/bash

cnt=${1:-"100"}
if [[ $cnt -lt 250 ]] ; then
  if [[ $cnt -ge 10 ]] ; then
    if [ -f /sys/class/backlight/rpi_backlight/brightness ] ; then
 		sudo echo "$cnt" >/sys/class/backlight/rpi_backlight/brightness 
    fi
  fi 
fi   	

