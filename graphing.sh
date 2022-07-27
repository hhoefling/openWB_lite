#!/bin/bash
graphing(){
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

#NC	echo $pvgraph >> ramdisk/pv-live.graph
#NC	echo $wattbezugint >> ramdisk/evu-live.graph
#NC	echo $ladeleistung >> ramdisk/ev-live.graph
#NC	echo $soc >> ramdisk/soc-live.graph
#NC	date +%H:%M >> ramdisk/time-live.graph
#NC	echo $hausverbrauch >> ramdisk/hausverbrauch-live.graph
#NC	if (( verbraucher1_aktiv == 1 )); then
#NC		echo $verbraucher1_watt >> ramdisk/verbraucher1-live.graph
#NC	fi
#NC	if (( verbraucher2_aktiv == 1 )); then
#NC		echo $verbraucher2_watt >> ramdisk/verbraucher2-live.graph
#NC	fi

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

	openwbDebugLog "MAIN" 2 "graphing.sh ---- make all-live.graph with $livegraph lines"
	
	echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w,$shd1_t0,$shd1_t1,$shd1_t2 >> ramdisk/all-live.graph
#NC	echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt > ramdisk/all-live.graph?incremental=y
	
	echo "$(tail -$livegraph ramdisk/all-live.graph)" > ramdisk/all-live.graph
#NC	echo "$(tail -$livegraph ramdisk/hausverbrauch-live.graph)" > ramdisk/hausverbrauch-live.graph
#NC	echo "$(tail -$livegraph ramdisk/pv-live.graph)" > ramdisk/pv-live.graph
#NC	echo "$(tail -$livegraph ramdisk/soc-live.graph)" > ramdisk/soc-live.graph
#NC	echo "$(tail -$livegraph ramdisk/evu-live.graph)" > ramdisk/evu-live.graph
#NC	echo "$(tail -$livegraph ramdisk/ev-live.graph)" > ramdisk/ev-live.graph
#NC	echo "$(tail -$livegraph ramdisk/ev1-live.graph)" > ramdisk/ev1-live.graph

#NC	if (( verbraucher1_aktiv == 1 )); then
#NC		echo "$(tail -$livegraph ramdisk/verbraucher1-live.graph)" > /ramdisk/verbraucher1-live.graph
#NC	fi
#NC	if (( verbraucher2_aktiv == 1 )); then
#NC		echo "$(tail -$livegraph ramdisk/verbraucher2-live.graph)" > ramdisk/verbraucher2-live.graph
#NC	fi
#NC	if (( lastmanagement == 1 )); then
#NC		echo "$(tail -$livegraph ramdisk/ev2-live.graph)" > ramdisk/ev2-live.graph
#NC	fi
#NC	echo "$(tail -$livegraph ramdisk/time-live.graph)" > ramdisk/time-live.graph
#NC	if ((speichervorhanden == 1 )); then
#NC		echo "$(tail -$livegraph ramdisk/speicher-live.graph)" > ramdisk/speicher-live.graph
#NC		echo "$(tail -$livegraph ramdisk/speichersoc-live.graph)" > ramdisk/speichersoc-live.graph
#NC	fi
#NC	if [[ $socmodul1 != "none" ]]; then
#NC		echo "$(tail -$livegraph ramdisk/soc1-live.graph)" > ramdisk/soc1-live.graph
#NC	fi

	mosquitto_pub -t openWB/graph/alllivevalues -r -m "$(cat ramdisk/all-live.graph | tail -n 50)" &
	mosquitto_pub -t openWB/graph/lastlivevalues -r -m "$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w" &
#NC, maybee for cloud
	mosquitto_pub -t openWB/system/lastlivevalues -r -m "$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$shd1_w,$shd2_w,$shd3_w,$shd4_w,$shd5_w,$shd6_w,$shd7_w,$shd8_w,$shd9_w" &

#	mosquitto_pub -t openWB/graph/1alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"0" | head -n "$((50 - 0))")" &
	all1livevalues=$(< ramdisk/all-live.graph tail -n +"0"  | head -n "$((50 - 0))")
	all2livevalues=$(< ramdisk/all-live.graph tail -n +"50" | head -n "$((100 - 50))")
	all3livevalues="$(< ramdisk/all-live.graph tail -n +"100" | head -n "$((150 - 100))")"
	all4livevalues="$(< ramdisk/all-live.graph tail -n +"150" | head -n "$((200 - 150))")"
	all5livevalues="$(< ramdisk/all-live.graph tail -n +"200" | head -n "$((250 - 200))")"
	all6livevalues="$(< ramdisk/all-live.graph tail -n +"250" | head -n "$((300 - 250))")"
	all7livevalues="$(< ramdisk/all-live.graph tail -n +"300" | head -n "$((350 - 300))")"
	all8livevalues="$(< ramdisk/all-live.graph tail -n +"350" | head -n "$((400 - 350))")"
	all9livevalues="$(< ramdisk/all-live.graph tail -n +"400" | head -n "$((450 - 400))")"
	all10livevalues="$(< ramdisk/all-live.graph tail -n +"450" | head -n "$((500 - 450))")"
	all11livevalues="$(< ramdisk/all-live.graph tail -n +"500" | head -n "$((550 - 500))")"
	all12livevalues="$(< ramdisk/all-live.graph tail -n +"550" | head -n "$((600 - 550))")"
	all13livevalues="$(< ramdisk/all-live.graph tail -n +"600" | head -n "$((650 - 600))")"
	all14livevalues="$(< ramdisk/all-live.graph tail -n +"650" | head -n "$((700 - 650))")"
	all15livevalues="$(< ramdisk/all-live.graph tail -n +"700" | head -n "$((750 - 700))")"
	all16livevalues="$(< ramdisk/all-live.graph tail -n +"750" | head -n "$((800 - 750))")"
	mosquitto_pub -t openWB/graph/1alllivevalues -r -m "$([ ${#all1livevalues} -ge 10 ] && echo "$all1livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/2alllivevalues -r -m "$([ ${#all2livevalues} -ge 10 ] && echo "$all2livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/3alllivevalues -r -m "$([ ${#all3livevalues} -ge 10 ] && echo "$all3livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/4alllivevalues -r -m "$([ ${#all4livevalues} -ge 10 ] && echo "$all4livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/5alllivevalues -r -m "$([ ${#all5livevalues} -ge 10 ] && echo "$all5livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/6alllivevalues -r -m "$([ ${#all6livevalues} -ge 10 ] && echo "$all6livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/7alllivevalues -r -m "$([ ${#all7livevalues} -ge 10 ] && echo "$all7livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/8alllivevalues -r -m "$([ ${#all8livevalues} -ge 10 ] && echo "$all8livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/9alllivevalues -r -m "$([ ${#all9livevalues} -ge 10 ] && echo "$all9livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/10alllivevalues -r -m "$([ ${#all10livevalues} -ge 10 ] && echo "$all10livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/11alllivevalues -r -m "$([ ${#all11livevalues} -ge 10 ] && echo "$all11livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/12alllivevalues -r -m "$([ ${#all12livevalues} -ge 10 ] && echo "$all12livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/13alllivevalues -r -m "$([ ${#all13livevalues} -ge 10 ] && echo "$all13livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/14alllivevalues -r -m "$([ ${#all14livevalues} -ge 10 ] && echo "$all14livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/15alllivevalues -r -m "$([ ${#all15livevalues} -ge 10 ] && echo "$all15livevalues" || echo "-")" &
	mosquitto_pub -t openWB/graph/16alllivevalues -r -m "$([ ${#all16livevalues} -ge 10 ] && echo "$all16livevalues" || echo "-")" &

	
# Bleibe bim Inc. ind regel.sh
# graphtimer=$(<ramdisk/graphtimer)
# echo $(( graphtimer = (graphtimer+1)%6 )) >ramdisk/graphtimer
#
	
	#Long Time Graphing, ein mal je Minute bzw jeden 6 call		
	if (( graphtimer == 1 )); then
		openwbDebugLog "MAIN" 2 "graphing.sh ---- make long time graph"	
		if (( dspeed == "3" )); then
			livegraphtime="240"
		else
			livegraphtime="720"
		fi
		longlivetime=$((livegraphtime*2))
		echo $(date '+%Y/%m/%d %H:%M:%S'),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt >> ramdisk/all.graph
		echo "$(tail -$longlivetime ramdisk/all.graph)" > ramdisk/all.graph
	fi
}
