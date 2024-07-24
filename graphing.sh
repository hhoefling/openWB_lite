#!/bin/bash

# shellcheck disable=SC2002,SC2005,SC2086,SC2046

# ladeleistung , Summe aller LP's
graphing(){

xpt=$ptx

	#local verbraucher1_watt=${verbraucher1_watt:-0}
	local re=${re:-}
	local dspeed=${dspeed:-0}
	local graphtimer=${graphtimer:-0}
	local livegraph=${livegraph:-}
	
	local wattbezugint=${wattbezugint:-0}
	local ladeleistung=${ladeleistung:-0}
	local pvgraph=${pvgraph:-0}
	local pv2wattmodul=${pv2wattmodul:-} 
	local speicherleistung=${speicherleistung:-0}
	local speichersoc=${speichersoc:-0}
	local soc=${soc:-0}
	local soc1=${soc1:-0}
	local hausverbrauch=${hausverbrauch:-0}
	local verbraucher1_watt=${verbraucher1_watt:-0}
	local verbraucher2_watt=${verbraucher2_watt:-0}
	local ladeleistunglp1=${ladeleistunglp1:-0}
	local ladeleistunglp2=${ladeleistunglp2:-0}
	local ladeleistunglp3=${ladeleistunglp3:-0}
	local ladeleistunglp4=${ladeleistunglp4:-0}
	local ladeleistunglp5=${ladeleistunglp5:-0}
	local ladeleistunglp6=${ladeleistunglp6:-0}
	local ladeleistunglp7=${ladeleistunglp7:-0}
	local ladeleistunglp8=${ladeleistunglp8:-0}
	local shd1_w=${shd1_w:-0}
	local shd2_w=${shd2_w:-0}
	local shd3_w=${shd3_w:-0}
	local shd4_w=${shd4_w:-0}
	local shd5_w=${shd5_w:-0}
	local shd6_w=${shd6_w:-0}
	local shd7_w=${shd7_w:-0}
	local shd8_w=${shd8_w:-0}
	local shd9_w=${shd9_w:-0}
	local shd1_t0=${shd1_t0-0}
	local shd1_t1=${shd1_t1-0}
	local shd1_t2=${shd1_t2-0}

ptstart

	#Ladestatuslog keurzen
	# HH nicht noetig, macht cleanup, alle 5 Minuten 
	#echo "$(tail -100 ramdisk/ladestatus.log)" > ramdisk/ladestatus.log
	
	

	#Live Graphing
	if [[ $pv2wattmodul != "none" ]]; then
		read pvwatt <ramdisk/pvallwatt
	else
		read pvwatt <ramdisk/pvwatt
	fi
	pvgraph=$((-pvwatt))

#NC	if (( speichervorhanden == 1 )); then
#NC		echo $speicherleistung >> ramdisk/speicher-live.graph
#NC		echo $speichersoc >> ramdisk/speichersoc-live.graph
#NC	fi
#NC	if [[ $socmodul1 != "none" ]]; then
#NC		echo $soc1 >> ramdisk/soc1-live.graph
#NC	fi

#NC	echo $ladeleistunglp1 >> ramdisk/ev1-live.graph

#NC	if (( lastmanagement == 1 )); then
#NC		echo $ladeleistunglp2 >> ramdisk/ev2-live.graph
#NC	fi

#NC	echo $wattbezugint >> ramdisk/evu-live.graph
#NC	echo $ladeleistung >> ramdisk/ev-live.graph
#NC	echo $soc >> ramdisk/soc-live.graph
#NC	date +%H:%M >> ramdisk/time-live.graph
#NC	if (( verbraucher1_aktiv == 1 )); then
#NC		echo $verbraucher1_watt >> ramdisk/verbraucher1-live.graph
#NC	fi
#NC	if (( verbraucher2_aktiv == 1 )); then
#NC		echo $verbraucher2_watt >> ramdisk/verbraucher2-live.graph
#NC	fi

NCladeleistunglp4=0
NCladeleistunglp5=0
NCladeleistunglp6=0
NCladeleistunglp7=0
NCladeleistunglp8=0
     
# Configwert 20-120 Minuten	 
	if [[ $livegraph =~ $re ]] ; then
		livegraph=$((livegraph * 6 ))
		if ! [[ $livegraph =~ $re ]] ; then
			livegraph="180"
		fi
	fi

	openwbDebugLog "MAIN" 0 "graphing.sh ---- make all-live.graph.csv with $livegraph lines"
	line="$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$NCladeleistunglp4,$NCladeleistunglp5,$NCladeleistunglp6,$NCladeleistunglp7,$NCladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w,$shd1_t0,$shd1_t1,$shd1_t2"
	echo $line >> ramdisk/all-live.graph.csv
	echo "$(tail -$livegraph ramdisk/all-live.graph.csv)" > ramdisk/all-live.graph.csv

#   display/gauge/live.js
#   display/simple/live.js
	mosquitto_pub -t openWB/graph/alllivevalues -r -m "$(cat ramdisk/all-live.graph.csv | tail -n 50)" &
    mosquitto_pub -t openWB/graph/lastlivevalues -r -m "$line" &
        
# maybee for cloud
	mosquitto_pub -t openWB/system/lastlivevalues -r -m "$line" &

ptend teil-1 100

ptstart
	
# 720 zeilen und 16 slots macht 45 Zeilen Je Slot
step=48  # 8 Minuten je slot
von=0
bis=$step

for i in {1..16}
do 
    # echo i $von $bis
	allx=$(< ramdisk/all-live.graph.csv tail -n +"$von"  | head -n "$step")
	t="openWB/graph/${i}alllivevalues"
	# openwbDebugLog "MAIN" 0 "graphing.sh ---- TIME v:$von b:$bis s:$step  ${#allx} lines"
	mosquitto_pub -t $t -r -m "$([ ${#allx} -ge 10 ] && echo "$allx" || echo "-")" &
   (( von = von + step  ))
   (( bis = bis + step  ))
 done

 ptend loop16 100

	
	
# Bleibe bim Inc. ind regel.sh
# read graphtimer <ramdisk/graphtimer
# echo $(( graphtimer = (graphtimer+1)%6 )) >ramdisk/graphtimer
#
	
 ptstart
	#Long Time Graphing, ein mal je Minute bzw jeden 6 call		
	if (( graphtimer == 1 )); then
		if (( dspeed == "3" )); then
			livegraphtime="240"
		else
			livegraphtime="720"
		fi
		longlivetime=$((livegraphtime*2))
		openwbDebugLog "MAIN" 2 "graphing.sh ---- make long time graph all.graph.csv $longlivetime lines"	
		echo $(date '+%Y/%m/%d %H:%M:%S'),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistunglp3,$NCladeleistunglp4,$NCladeleistunglp5,$NCladeleistunglp6,$NCladeleistunglp7,$NCladeleistunglp8,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt >> ramdisk/all.graph.csv
		echo "$(tail -$longlivetime ramdisk/all.graph.csv)" > ramdisk/all.graph.csv
	fi
 ptend rest 100
 ptx=$xpt
}
