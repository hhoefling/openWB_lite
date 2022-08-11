#!/bin/bash
OPENWBBASEDIR=$(cd `dirname $0`/../ && pwd)
RAMDISKDIR="$OPENWBBASEDIR/ramdisk"

# check if config file is already in env
if [[ -z "$debug" ]]; then
	echo "checknet.sh: Seems like openwb.conf is not loaded. Reading file."
	. $OPENWBBASEDIR/loadconfig.sh
	. $OPENWBBASEDIR/helperFunctions.sh
fi

networkautoconfig=1

# check for LAN/WLAN connection
openwbDebugLog "MAIN" 1 "LAN/WLAN..."
if (( networkautoconfig == 1 )); then
	ethstate=$(</sys/class/net/eth0/carrier)
	ethstate=0
	if (( ethstate == 1 )); then
		openwbDebugLog "MAIN" 1 "eth0 carrier detected"
		read a eth00ipaddr b <<<`sudo ifconfig eth0:0 | grep inet`
		if [[ $eth00ipaddr != $virtual_ip_eth0 ]]; then
			openwbDebugLog "MAIN" 1 "eth0:0 not detected; adding $virtual_ip_eth0"
			sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 up
		else
			openwbDebugLog "MAIN" 1 "eth0:0 already up with $eth00ipaddr, ok"
		fi
		if [ -d /sys/class/net/wlan0 ]; then
			read a wlan00ipaddr b <<<`sudo ifconfig wlan0:0 | grep inet`
			if [[ $"wlan00ipaddr" == "$virtual_ip_wlan0" ]]; then
				openwbDebugLog "MAIN" 1 "wlan0:0 IP $virtual_ip_wlan0 detected; removing"
				sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 down
			else
				openwbDebugLog "MAIN" 1 "wlan0:0 not present: ok"
			fi
			wlanstate=$(</sys/class/net/wlan0/carrier)
			if (( wlanstate == 1 )); then
				openwbDebugLog "MAIN" 1 "wifi still connected; stopping hostapd and dnsmasq"
				sudo systemctl stop hostapd
				sudo systemctl stop dnsmasq
			else
				openwbDebugLog "MAIN" 1 "wifi not connected: ok"
			fi
		else
			openwbDebugLog "MAIN" 1 "wifi device disabled at system level"
		fi
	else  # no eth0, activate wlan
		openwbDebugLog "MAIN" 1 "eth0 has no link; setting up wifi"
		if [ -d /sys/class/net/wlan0 ]; then
			read a wlan00ipaddr b <<<`sudo ifconfig wlan0:0 | grep inet`
			if [[ "$wlan00ipaddr" != "$virtual_ip_wlan0" ]]; then
				openwbDebugLog "MAIN" 0 "wlan0:0 not detected; adding with $virtual_ip_wlan0"
				sudo ifconfig wlan0:0 $virtual_ip_wlan0 netmask 255.255.255.0 up
			else
				openwbDebugLog "MAIN" 1 "wlan0:0 has $virtual_ip_wlan0, ok"
			fi
			openwbDebugLog "MAIN" 1 "wlan0 start hostapd and dnsmasq"
			sudo systemctl start hostapd
			sudo systemctl start dnsmasq
			read a eth00ipaddr b <<<`sudo ifconfig eth0:0 | grep inet`
			if [[ "$eth00ipaddr" != "$virtual_ip_eth0" ]]; then
				openwbDebugLog "MAIN" 1 "eth0:0 detected $virtual_ip_eth0; removing"
				# sudo ifconfig eth0:0 $virtual_ip_eth0 netmask 255.255.255.0 down
			else
				openwbDebugLog "MAIN" 1 "eth0:0 not present: ok"
			fi
		else
			openwbDebugLog "MAIN" 1 "wifi device disabled at system level"
			openwbDebugLog "MAIN" 0 "WARNING: no network connection!"
			# try restart both
			sudo ifconfig eth0  up 
		fi
	fi
else # No autoconfig, show status
	openwbDebugLog "MAIN" 1 "network autoconfig not activ"
	ethstate=$(</sys/class/net/eth0/carrier)
	if (( ethstate == 1 )); then
		read a eth0ipaddr b <<<`sudo ifconfig eth0 | grep inet` 
		read a eth00ipaddr b <<<`sudo ifconfig eth0:0 | grep inet` 
		openwbDebugLog "MAIN" 1 "eth0: IP [$eth0ipaddr], eth0:0 is [$eth00ipaddr]"
	else
		openwbDebugLog "MAIN" 0 "eth0 no carrier"
	fi

	if [ -d /sys/class/net/wlan0 ]; then
		wlanstate=$(</sys/class/net/wlan0/carrier)
		if (( wlanstate == 1 )); then
			read a wlan0ipaddr b <<<`sudo ifconfig wlan0 | grep inet` 
			read a wlan00ipaddr b <<<`sudo ifconfig wlan0:0 | grep inet` 
			openwbDebugLog "MAIN" 1 "wlan0: IP [$wlan0ipaddr], wlan0:0 is [$wlan00ipaddr]"
		else
			openwbDebugLog "MAIN" 0 "wlan0 no carrier"
		fi
	else
		openwbDebugLog "MAIN" 0 "wlan not active"
	fi
fi



