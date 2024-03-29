#!/bin/bash
re='^-?[0-9]+$'
rekwh='^[-+]?[0-9]+\.?[0-9]*$'

output=$(curl --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/getParameters)
if ! [ -z "$output" ]; then
	watt=$(echo $output | jq '.list[] | .actualPower')
	lla1=$(echo $output | jq '.list[] | .currentP1')
	lla1=$(echo "scale=0;$lla1 / 1" |bc)
	lla2=$(echo $output | jq '.list[] | .currentP2')
	lla2=$(echo "scale=0;$lla2 / 1" |bc)
	lla3=$(echo $output | jq '.list[] | .currentP3')
	lla3=$(echo "scale=0;$lla3 / 1" |bc)
	llv1=$(echo $output | jq '.list[] | .voltageP1')
	llv1=$(echo "scale=0;$llv1 / 1" |bc)
	llv2=$(echo $output | jq '.list[] | .voltageP2')
	llv2=$(echo "scale=0;$llv2 / 1" |bc)
	llv3=$(echo $output | jq '.list[] | .voltageP3')
	llv3=$(echo "scale=0;$llv3 / 1" |bc)
	llkwh=$(echo $output | jq '.list[] | .meterReading')
	evsewifiplugstatelp3=$(echo $output | jq '.list[] | .vehicleState') 
	rfidtag=$(echo $output | jq -r '.list[] | .RFIDUID') 
	llakt=$(echo $output | jq '.list[] | .actualCurrent')

	watt=$(echo "scale=0;$watt * 1000 /1" |bc)
	if [[ $watt =~ $re ]] ; then
		echo $watt > /var/www/html/openWB/ramdisk/llaktuells2
	fi
	if [[ $lla1 =~ $rekwh ]] ; then
		echo $lla1 > /var/www/html/openWB/ramdisk/llas21
	fi
	if [[ $lla2 =~ $rekwh ]] ; then
		echo $lla2 > /var/www/html/openWB/ramdisk/llas22
	fi
	if [[ $lla3 =~ $rekwh ]] ; then
		echo $lla3 > /var/www/html/openWB/ramdisk/llas23
	fi
	if [[ $llv1 =~ $rekwh ]] ; then
		echo $llv1 > /var/www/html/openWB/ramdisk/llvs21
	fi
	if [[ $llv2 =~ $rekwh ]] ; then
		echo $llv2 > /var/www/html/openWB/ramdisk/llvs22
	fi
	if [[ $llv3 =~ $rekwh ]] ; then
		echo $llv3 > /var/www/html/openWB/ramdisk/llvs23
	fi

	if [[ $llkwh =~ $rekwh ]] ; then
		echo $llkwh > /var/www/html/openWB/ramdisk/llkwhs2
	fi
	if [[ $evsewifiplugstatelp3 > "1" ]] ; then
		echo 1 > /var/www/html/openWB/ramdisk/plugstatlp3
	else
		echo 0 > /var/www/html/openWB/ramdisk/plugstatlp3
	fi
	if [[ $evsewifiplugstatelp3 > "2" ]] ; then
		echo 1 > /var/www/html/openWB/ramdisk/chargestatlp3
	else
		echo 0 > /var/www/html/openWB/ramdisk/chargestatlp3
	fi
	if [ ${#rfidtag} -ge 3 ];then
		echo $rfidtag > /var/www/html/openWB/ramdisk/readtag
		curl --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/clearRfid
	fi
	read llswb3 </var/www/html/openWB/ramdisk/llsolls2
	if [[ $llakt != $llswb3 ]]; then
		curl --silent --connect-timeout $evsewifitimeoutlp3 -s http://$evsewifiiplp3/setCurrent?current=$llswb3 > /dev/null
	fi

fi
