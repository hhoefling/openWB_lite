#!/bin/bash
graphing(){

xpt=$ptx

ptstart

	#Ladestatuslog keurzen
	# HH nicht noetig, macht cleanup, alle 5 Minuten 
	#echo "$(tail -100 ramdisk/ladestatus.log)" > ramdisk/ladestatus.log
	
	
	
	#Live Graphing
	if [[ $pv2wattmodul != "none" ]]; then
		pvwatt=$(<ramdisk/pvallwatt)
	else
		pvwatt=$(<ramdisk/pvwatt)
	fi
	pvgraph=$((-pvwatt))
	

ladeleistunglp4=0
ladeleistunglp5=0
ladeleistunglp6=0
ladeleistunglp7=0
ladeleistunglp8=0
     
# Configwert 20-120 Minuten	 
	if [[ $livegraph =~ $re ]] ; then
		livegraph=$((livegraph * 6 ))
		if ! [[ $livegraph =~ $re ]] ; then
			livegraph="180"
		fi
	fi

# Max 720 lines  (120 * 6 ) 
	openwbDebugLog "MAIN" 2 "graphing.sh ---- make all-live.graph with $livegraph lines"
	
	echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w,$shd1_t0,$shd1_t1,$shd1_t2 >> ramdisk/all-live.graph
	echo "$(tail -$livegraph ramdisk/all-live.graph)" > ramdisk/all-live.graph

	mosquitto_pub -t openWB/graph/alllivevalues -r -m "$(cat ramdisk/all-live.graph | tail -n 50)" &
	mosquitto_pub -t openWB/graph/lastlivevalues -r -m "$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w" &
#NC, maybee for cloud
	mosquitto_pub -t openWB/system/lastlivevalues -r -m "$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w" &

ptend teil-1 100

ptstart
	
# 720 zeilen und 16 slots macht 45 Zeilen Je Slot
step=48  # 8 Minuten je slot
von=0
bis=$step

for i in {1..16}
do 
    # echo i $von $bis
	allx=$(< ramdisk/all-live.graph tail -n +"$von"  | head -n "$step")
	t="openWB/graph/${i}alllivevalues"
	#openwbDebugLog "DEB" 0 "graphing.sh ---- TIME $von $bis  ${#allx} "	
	mosquitto_pub -t $t -r -m "$([ ${#allx} -ge 10 ] && echo "$allx" || echo "-")" &
   (( von = von + step  ))
   (( bis = bis + step  ))
done

ptend loop16 500

	

	
# Bleibe bim Inc. ind regel.sh
# graphtimer=$(<ramdisk/graphtimer)
# echo $(( graphtimer = (graphtimer+1)%6 )) >ramdisk/graphtimer
#
	
ptstart
	#Long Time Graphing, ein mal je Minute bzw jeden 6 call		
	if (( graphtimer == 1 )); then
		openwbDebugLog "MAIN" 2 "graphing.sh ---- TIME make long time graph"	
		if (( dspeed == "3" )); then
			livegraphtime="240"
		else
			livegraphtime="720"
		fi
		longlivetime=$((livegraphtime*2))
		echo $(date '+%Y/%m/%d %H:%M:%S'),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt >> ramdisk/all.graph
		echo "$(tail -$longlivetime ramdisk/all.graph)" > ramdisk/all.graph
	fi
 ptend rest 100
 ptx=$xpt
}
