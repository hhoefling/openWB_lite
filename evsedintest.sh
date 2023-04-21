#!/bin/bash
# shellcheck disable=SC2009,SC2086

evsedintest() {
	evsedintestlp1=$(<ramdisk/evsedintestlp1)
	if [[ $evsedintestlp1 == "ausstehend" ]]; then
		if [[ $evsecon == "modbusevse" ]]; then 
			if [[ $modbusevsesource = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			# 1000: Configured Current
			sudo python runs/evsewritembusdev.py $modbusevsesource $modbusevseid 1000 9
			sleep 1
				evsedinstat=$(sudo python3 runs/readmodbus.py $modbusevsesource $modbusevseid 1000 1)
			if [[ $evsedinstat == "9" ]]; then
				openwbDebugLog "MAIN" 0 "EVSE LP1 Prüfung erfolgreich"
				echo "erfolgreich" > ramdisk/evsedintestlp1
			else
				openwbDebugLog "MAIN" 0 "EVSE LP1 Prüfung NICHT erfolgreich"
				echo "Fehler" > ramdisk/evsedintestlp1
			fi
			sleep 1
			sudo python runs/evsewritembusdev.py $modbusevsesource $modbusevseid 1000 0
			sleep 1
		elif [[ $evsecon == "masterethframer" ]]; then		# NUR bei LP1
			sudo python runs/evsewritembusethframerdev.py 192.168.193.18 1 1000 9
			sleep 1
			evsedinstat=$(sudo python runs/readmodbusethframer.py 192.168.193.18 1 1000 1)
			if [[ $evsedinstat == "[9]" ]]; then
				openwbDebugLog "MAIN" 0 "EVSE LP1 Prüfung erfolgreich"
				echo "erfolgreich" > ramdisk/evsedintestlp1
			else
				openwbDebugLog "MAIN" 0 "EVSE LP1 Prüfung NICHT erfolgreich"
				echo "Fehler" > ramdisk/evsedintestlp1
			fi
			sleep 1
			sudo python runs/evsewritembusethframerdev.py 192.168.193.18 1 1000 0
			sleep 1
			openwbDebugLog "MAIN" 0 "*** EVSE EXIT 0"
			exit 0		# Regel.sh abbrechen
		else
			openwbDebugLog "MAIN" 0 "EVSE LP1 nothing to do for $evsecon"
			echo "$evsecon konfiguriert" > ramdisk/evsedintestlp1
		fi
	fi
	evsedintestlp2=$(<ramdisk/evsedintestlp2)
	if [[ $evsedintestlp2 == "ausstehend" ]]; then
		if [[ $evsecons1 == "modbusevse" ]]; then
			if [[ $evsesources1 = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources1,raw tcp:$evselanips1:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources1,raw tcp:$evselanips1:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			sudo python runs/evsewritembusdev.py $evsesources1 $evseids1 1000 9
			sleep 1
			evsedinstat=$(sudo python3 runs/readmodbus.py $evsesources1 $evseids1 1000 1)
			if [[ $evsedinstat == "9" ]]; then
				openwbDebugLog "MAIN" 0 "EVSE LP2 Prüfung erfolgreich"
				echo "erfolgreich" > ramdisk/evsedintestlp2
			else
				openwbDebugLog "MAIN" 0 "EVSE LP2 Prüfung NICHT erfolgreich"
				echo "Fehler" > ramdisk/evsedintestlp2
			fi
			sleep 1
			sudo python runs/evsewritembusdev.py $evsesources1 $evseids1 1000 0
			sleep 1
			openwbDebugLog "MAIN" 0 "*** EVSE EXIT 0"
			exit 0
		else
			openwbDebugLog "MAIN" 0 "EVSE LP2 nothing to do for $evsecons1"
			echo "$evsecons1 konfiguriert" > ramdisk/evsedintestlp2
		fi
	fi
	evsedintestlp3=$(<ramdisk/evsedintestlp3)
	if [[ $evsedintestlp3 == "ausstehend" ]]; then
		if [[ $evsecons2 == "modbusevse" ]]; then
			if [[ $evsesources2 = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources2,raw tcp:$evselanips2:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources2,raw tcp:$evselanips2:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			sudo python runs/evsewritembusdev.py $evsesources2 $evseids2 1000 9
			sleep 1
			evsedinstat=$(sudo python3 runs/readmodbus.py $evsesources2 $evseids2 1000 1)
			if [[ $evsedinstat == "9" ]]; then
				openwbDebugLog "MAIN" 0 "EVSE LP3 Prüfung erfolgreich"
				echo "erfolgreich" > ramdisk/evsedintestlp3
			else
				openwbDebugLog "MAIN" 0 "EVSE LP3 Prüfung NICHT erfolgreich"
				echo "Fehler" > ramdisk/evsedintestlp3
			fi
			sleep 1
			sudo python runs/evsewritembusdev.py $evsesources2 $evseids2 1000 0
			sleep 1
			openwbDebugLog "MAIN" 0 "*** EVSE EXIT 0"
			exit 0
		else
			openwbDebugLog "MAIN" 0 "EVSE LP3 nothing to do for $evsecons2"
			echo "$evsecons2 konfiguriert" > ramdisk/evsedintestlp3
		fi
	fi

	evseausgelesen=$(<ramdisk/evseausgelesen)
	if [[ $evseausgelesen == "0" ]]; then
		openwbDebugLog "MAIN" 0 "EVSE LPx config auslesen"
		if [[ $evsecon == "modbusevse" ]]; then 
			if [[ $modbusevsesource = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			# 2000: Current after boot 32
			evselp12000=$(sudo python3 runs/readmodbus.py $modbusevsesource $modbusevseid 2000 1)
			echo $evselp12000 > /var/www/html/openWB/ramdisk/progevsedinlp12000
			sleep 1
			# 2007: PP-Detection 0 
			evselp12007=$(sudo python3 runs/readmodbus.py $modbusevsesource $modbusevseid 2007 1)
			echo $evselp12007 > /var/www/html/openWB/ramdisk/progevsedinlp12007
			sleep 1
		elif [[ $evsecon == "masterethframer" ]]; then
			sleep 1
			evselp12000=$(sudo python runs/readmodbusethframer.py 192.168.193.18 1 2000 1)
			echo $evselp12000 > /var/www/html/openWB/ramdisk/progevsedinlp12000
			sleep 1
			evselp12007=$(sudo python runs/readmodbusethframer.py 192.168.193.18 1 2007 1)
			echo $evselp12007 > /var/www/html/openWB/ramdisk/progevsedinlp12007
			sleep 1
		fi

		if [[ $evsecons1 == "modbusevse" ]]; then
			if [[ $evsesources1 = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources1,raw tcp:$evselanips1:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources1,raw tcp:$evselanips1:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1

			evselp22000=$(sudo python3 runs/readmodbus.py $evsesources1 $evseids1 2000 1)
			echo $evselp22000 > ramdisk/progevsedinlp22000
			sleep 1
			evselp22007=$(sudo python3 runs/readmodbus.py $evsesources1 $evseids1 2007 1)
			echo $evselp22007 > ramdisk/progevsedinlp22007
			sleep 1
		fi
		echo 1 > ramdisk/evseausgelesen
	fi
	
	
	progevselp1=$(<ramdisk/progevsedinlp1)
	if [[ $progevselp1 == "1" ]]; then
		if [[ $evsecon == "modbusevse" ]]; then 
			if [[ $modbusevsesource = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26" > /dev/null
				then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			lp12000=$(<ramdisk/progevsedinlp12000)
			sudo python runs/evsewritembusdev.py $modbusevsesource $modbusevseid 2000 $lp12000
			sleep 1
			lp12007=$(<ramdisk/progevsedinlp12007)
			sudo python runs/evsewritembusdev.py $modbusevsesource $modbusevseid 2007 $lp12007
		elif [[ $evsecon == "masterethframer" ]]; then
			lp12000=$(<ramdisk/progevsedinlp12000)
			sudo python runs/evsewritembusethframerdev.py 192.168.193.18 1 2000 $lp12000
			sleep 1
			lp12007=$(<ramdisk/progevsedinlp12007)
			sudo python runs/evsewritembusethframerdev.py 192.168.193.18 1 2007 $lp12007
		fi
		echo 0 > ramdisk/progevsedinlp1
	fi
	progevselp2=$(<ramdisk/progevsedinlp2)
	if [[ $progevselp2 == "1" ]]; then
		if [[ $evsecons1 == "modbusevse" ]]; then 
			if [[ $modbusevsesource = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources1,raw tcp:$evselanips1:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources1,raw tcp:$evselanips1:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			sleep 1
			lp22000=$(<ramdisk/progevsedinlp22000)
			sudo python runs/evsewritembusdev.py $evsesources1 $evseids1 2000 $lp22000
			sleep 1
			lp22007=$(<ramdisk/progevsedinlp22007)
			sudo python runs/evsewritembusdev.py $evsesources1 $evseids1 2007 $lp22007
		fi
		echo 0 > ramdisk/progevsedinlp2
	fi
}

evsemodbuscheck5() {
	if [[ $evsecon == "modbusevse" ]]; then
		if [[ $modbusevsesource = *virtual* ]]; then
			if ps ax |grep -v grep |grep "socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26" > /dev/null; then
				echo "test" > /dev/null
			else
				sudo socat pty,link=$modbusevsesource,raw tcp:$modbusevselanip:26 &
			fi
		else
			echo "echo" > /dev/null
		fi
		evsedinstat=$(sudo python3 runs/readmodbus.py $modbusevsesource $modbusevseid 1000 1)
		sleep 1
		if [[ $evsedinstat == "$llalt" ]]; then
			openwbDebugLog "MAIN" 1 "LP1 Modbus $llalt korrekt"
		else
			openwbDebugLog "MAIN" 1 "LP1 Modbus $llalt nicht korrekt, re-set"
			sudo python runs/evsewritembusdev.py $modbusevsesource $modbusevseid 1000 $llalt
		fi
	fi
	if (( lastmanagement == 1 )); then 
		if [[ $evsecons1 == "modbusevse" ]]; then
			if [[ $evsesources1 = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources1,raw tcp:$evselanips1:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources1,raw tcp:$evselanips1:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			evsedinstat=$(sudo python3 runs/readmodbus.py $evsesources1 $evseids1 1000 1)
			sleep 1
			if [[ $evsedinstat == "$llalts1" ]]; then
				openwbDebugLog "MAIN" 1 "LP2 Modbus $llalts1 korrekt"
			else
				openwbDebugLog "MAIN" 1 "LP2 Modbus $llalts1 nicht korrekt, re-set"
				sudo python runs/evsewritembusdev.py $evsesources1 $evseids1 1000 $llalts1
			fi
		fi
	fi		
	if (( lastmanagements2 == 1 )); then
		if [[ $evsecons2 == "modbusevse" ]]; then
			if [[ $evsesources2 = *virtual* ]]; then
				if ps ax |grep -v grep |grep "socat pty,link=$evsesources2,raw tcp:$evselanips2:26" > /dev/null; then
					echo "test" > /dev/null
				else
					sudo socat pty,link=$evsesources2,raw tcp:$evselanips2:26 &
				fi
			else
				echo "echo" > /dev/null
			fi
			evsedinstat=$(sudo python3 runs/readmodbus.py $evsesources2 $evseids2 1000 1)
			if [[ $evsedinstat == "$llalts2" ]]; then
				openwbDebugLog "MAIN" 1 "LP3 Modbus $llalts2 korrekt"
			else
				openwbDebugLog "MAIN" 1 "LP3 Modbus $llalts2 nicht korrekt, re-set"
				sudo python runs/evsewritembusdev.py $evsesources2 $evseids2 1000 $llalts2
			fi
		fi
	fi

}
