#!/bin/bash

function geraete()
{
# Gerät 1..3
	if (( hook1_aktiv == "1" )); then		# is configured?
		if (( hook1akt == 0 )); then
			read hook1einschaltverzcounter <ramdisk/hook1einschaltverzcounter
			if (( uberschuss > hook1ein_watt )); then
				if (( hook1einschaltverzcounter > hook1einschaltverz)); then
					echo 0 > /var/www/html/openWB/ramdisk/hook1einschaltverzcounter
					echo 0 > /var/www/html/openWB/ramdisk/hook1counter
					if [ ! -e ramdisk/hook1aktivstamp ]; then
						touch ramdisk/hook1aktivstamp
						echo 1 > ramdisk/hook1akt
						curl -s --connect-timeout 5 $hook1ein_url > ramdisk/hookmsg
						openwbDebugLog "CHARGESTAT" 0 "WebHook 1 aktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hookmsg)"
						rm ramdisk/hookmsg
						openwbDebugLog "MAIN" 1 "Gerät 1 aktiviert"
						if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
							./runs/pushover.sh "Gerät 1 eingeschaltet bei $uberschuss"
						fi
					fi
				else
					hook1einschaltverzcounter=$((hook1einschaltverzcounter +10))
					echo $hook1einschaltverzcounter > /var/www/html/openWB/ramdisk/hook1einschaltverzcounter
				fi
			else
				hook1einschaltverzcounter=0
			fi
		fi

		if [ -e ramdisk/hook1aktivstamp  ]; then
			if test $(find "ramdisk/hook1aktivstamp" -mmin +$hook1_dauer); then
				if (( uberschuss < hook1aus_watt )); then
					read hook1counter <ramdisk/hook1counter
					if (( hook1counter < hook1_ausverz )); then
						hook1counter=$((hook1counter + 10))
						echo $hook1counter > /var/www/html/openWB/ramdisk/hook1counter
					else
						rm ramdisk/hook1aktivstamp
						echo 0 > ramdisk/hook1akt
						curl -s --connect-timeout 5 $hook1aus_url > ramdisk/hookmsg
						openwbDebugLog "CHARGESTAT" 0 "WebHook 1 deaktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hookmsg)"
						rm ramdisk/hookmsg
						openwbDebugLog "MAIN" 1 "Gerät 1 deaktiviert"
						if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
							./runs/pushover.sh "Gerät 1 ausgeschaltet bei $uberschuss"
						fi
					fi
				fi
			fi
		fi
	fi

	if (( hook2_aktiv == "1" )); then	# is configured?
		if (( hook2akt == 0 )); then
			read hook2einschaltverzcounter <ramdisk/hook2einschaltverzcounter
			if (( uberschuss > hook2ein_watt )); then
				if (( hook2einschaltverzcounter > hook2einschaltverz)); then
					echo 0 > /var/www/html/openWB/ramdisk/hook2einschaltverzcounter
					echo 0 > /var/www/html/openWB/ramdisk/hook2counter
					if [ ! -e ramdisk/hook2aktiv ]; then
						touch ramdisk/hook2aktiv
						echo 1 > ramdisk/hook2akt
						curl -s --connect-timeout 5 $hook2ein_url > ramdisk/hook2msg
						openwbDebugLog "CHARGESTAT" 0 "WebHook 2 aktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hook2msg)"
						rm ramdisk/hook2msg
						openwbDebugLog "MAIN" 1 "Gerät 2 aktiviert"
						if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
							./runs/pushover.sh "Gerät 2 eingeschaltet bei $uberschuss"
						fi
					fi
				else
					hook2einschaltverzcounter=$((hook2einschaltverzcounter +10))
					echo $hook2einschaltverzcounter > /var/www/html/openWB/ramdisk/hook2einschaltverzcounter
				fi
			else
				hook2einschaltverzcounter=0
			fi
		fi

		if [ -e ramdisk/hook2aktiv  ]; then
			if test $(find "ramdisk/hook2aktiv" -mmin +$hook2_dauer); then
				if (( uberschuss < hook2aus_watt )); then
					read hook2counter <ramdisk/hook2counter
					if (( hook2counter < hook2_ausverz )); then
						hook2counter=$((hook2counter + 10))
						echo $hook2counter > /var/www/html/openWB/ramdisk/hook2counter
					else
						rm ramdisk/hook2aktiv
						echo 0 > ramdisk/hook2akt
						curl -s --connect-timeout 5 $hook2aus_url > ramdisk/hook2msg
						openwbDebugLog "CHARGESTAT" 0 "WebHook 2 deaktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hook2msg)"
						rm ramdisk/hook2msg
						openwbDebugLog "MAIN" 1 "Gerät 2 deaktiviert"
						if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
							./runs/pushover.sh "Gerät 2 ausgeschaltet bei $uberschuss"
						fi
					fi
				fi
			fi
		fi
	fi

	if (( hook3_aktiv == "1" )); then	# is configured?
		if (( uberschuss > hook3ein_watt )); then
			echo 0 > /var/www/html/openWB/ramdisk/hook3counter
			if [ ! -e ramdisk/hook3aktiv ]; then
				touch ramdisk/hook3aktiv
				echo 1 > ramdisk/hook3akt
				curl -s --connect-timeout 5 $hook3ein_url > /dev/null
				openwbDebugLog "CHARGESTAT" 0 "WebHook 3 aktiviert"
				openwbDebugLog "MAIN" 1 "Gerät 3 aktiviert"
				if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
					./runs/pushover.sh "Gerät 3 eingeschaltet bei $uberschuss"
				fi
			fi
		fi
		if [ -e ramdisk/hook3aktiv  ]; then
			if test $(find "ramdisk/hook3aktiv" -mmin +$hook3_dauer); then
				if (( uberschuss < hook3aus_watt )); then
					read hook3counter <ramdisk/hook3counter
					if (( hook3counter < hook3_ausverz )); then
						hook3counter=$((hook3counter + 10))
						echo $hook3counter > /var/www/html/openWB/ramdisk/hook3counter
					else
						rm ramdisk/hook3aktiv
						echo 0 > ramdisk/hook3akt
						curl -s --connect-timeout 5 $hook3aus_url > /dev/null
						openwbDebugLog "CHARGESTAT" 0 "WebHook 3 deaktiviert"
						openwbDebugLog "MAIN" 1 "Gerät 3 deaktiviert"
						if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
							./runs/pushover.sh "Gerät 3 ausgeschaltet bei $uberschuss"
						fi
					fi
				fi
			fi
		fi
	fi
}

