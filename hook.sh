#!/bin/bash

# private plugin/out and ladestart/stop webhooks
function hooker() # 
{
   local -i bool=$1		
   local  hookaktivname=$2	# angesteckthooklp1aktiv
   local  url="$3"
   local  txt="$4"
   local  hockaktivfile="ramdisk/${hookaktivname}"
#  openwbDebugLog "CHARGESTAT" 0 "hooker b:$bool f:$hockaktivfile t:$txt u:$url "
   
		if (( bool == 1 )); then
			if [ ! -e $hockaktivfile ]; then
				touch $hockaktivfile
				curl -s --connect-timeout 5 $url > /dev/null
				openwbDebugLog "CHARGESTAT" 0 "$txt LP1 ausgeführt touch ($hockaktivfile) "
				openwbDebugLog "MAIN" 1 "$txt LP1 ausgeführt"
			fi
		else
			if [  -e $hockaktivfile ]; then
				rm $hockaktivfile
				openwbDebugLog "CHARGESTAT" 0 "$txt LP1 rm ($hockaktivfile) "
				fi
			fi
}

# private pushover für geräte 
function pushover()
{
 if ((pushbsmarthome == "1")) && ((pushbenachrichtigung == "1")); then
	./runs/pushover.sh "$*"
		fi
}

# private smartHome1_geraet
smgeraet() # $1 gnr 1,2,3 
{
 # C hook1_aktiv hook1ein_watt hook1einschaltverz hook1ein_url hook1_dauer hook1aus_watt hook1aus_url hook1_ausverz
 # C hook2_aktiv hook2ein_watt hook2einschaltverz hook2ein_url hook2_dauer hook2aus_watt hook2aus_url hook2_ausverz
 # C hook3_aktiv hook3ein_watt hook3einschaltverz hook3ein_url hook3_dauer hook3aus_watt hook3aus_url hook3_ausverz
 declare -n  Chook_aktiv="hook${1}_aktiv"
 declare -n  Chookein_watt="hook${1}ein_watt"
 declare -n  Chookeinschaltverz="hook${1}einschaltverz" 
 declare -n  Chookein_url="hook${1}ein_url"
 declare -n  Chook_dauer="hook${1}_dauer" 
 declare -n  Chookaus_watt="hook${1}aus_watt" 
 declare -n  Chookaus_url="hook${1}aus_url" 
 declare -n  Chook_ausverz="hook${1}_ausverz"
# V hook1akt  
# V hook2akt  
# V hook3akt  
 declare -n Vhookakt="hook${1}akt"  # varname statusvar  
# F hook1akt hook1aktiv  hook1counter  hook1einschaltverzcounter 
# F hook2akt hook2aktiv  hook2counter  hook2einschaltverzcounter 
# F hook3akt hook3aktiv  hook3counter  hook3einschaltverzcounter 
 declare    Fhookakt="hook${1}akt"	# filename statusfile
 declare    Fhookaktiv="hook${1}aktiv"	# filename aktiv-status-file 
 declare    Fhookcounter="hook${1}counter"   
 declare    Fhookeinschaltverzcounter="hook${1}einschaltverzcounter" 


 openwbDebugLog "MAIN" 2 "Hook-Gerät $1 uberschuss:$uberschuss"
# openwbDebugLog "MAIN" 2 "Hook-C- $1 aktiv:$Chook_aktiv einwatt:$Chookein_watt einverz:$Chookeinschaltverz dauer:$Chook_dauer auswatt:$Chookaus_watt aus_verz:$Chook_ausverz "
# openwbDebugLog "MAIN" 2 "Hook-F- $1 ${Fhookakt} ${Fhookaktiv} ${Fhookcounter} "  
# openwbDebugLog "MAIN" 2 "Hook-V- $1 ${!Vhookakt}:${Vhookakt-.""}  " 

# V hook1akt hook1aktiv  hook1counter   V+F hook1einschaltverzcounter 
# T hook1msg       
# C Chook1_aktiv Chook1ein_watt Chook1einschaltverz hook1ein_url hook1_dauer hook1aus_watt hook1aus_url hook1_ausverz    
	if (( Chook_aktiv == "1" )); then
		if (( Vhookakt == 0 )); then		# von loadvars eingelesen
			if (( uberschuss > Chookein_watt )); then
			    Thookeinschaltverzcounter=$(<ramdisk/$Fhookeinschaltverzcounter)
			    openwbDebugLog "MAIN" 2 "Hook $Fhookeinschaltverzcounter is $Thookeinschaltverzcounter "
				if (( Thookeinschaltverzcounter > Chookeinschaltverz)); then
					echo 0 > ramdisk/$Fhookeinschaltverzcounter
					echo 0 > ramdisk/$Fhookcounter
					if [ ! -e ramdisk/$Fhookaktiv ]; then
						touch ramdisk/$Fhookaktiv
						echo 1 > ramdisk/$Fhookakt
						curl -s --connect-timeout 5 $Chookein_url > ramdisk/hookmsg
						openwbDebugLog "CHARGESTAT" 0 "WebHook $1 aktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hookmsg)"
						rm ramdisk/hookmsg
						openwbDebugLog "MAIN" 1 "Gerät $1 aktiviert bei $uberschuss"
						pushover  "Gerät $1 eingeschaltet bei $uberschuss"
					fi
				else
					Thookeinschaltverzcounter=$((Thookeinschaltverzcounter +10))
					echo $Thookeinschaltverzcounter > ramdisk/$Fhookeinschaltverzcounter
				fi
			fi
		fi

		if [ -e ramdisk/$Fhookaktiv  ]; then
		    #Chook_dauer=1
			if test $(find "ramdisk/$Fhookaktiv" -mmin +$Chook_dauer); then
				if (( uberschuss < Chookaus_watt )); then
					hookcounter=$(<ramdisk/$Fhookcounter)
					openwbDebugLog "MAIN" 2 "off counter $Fhookcounter is $hookcounter "
					if (( hookcounter < Chook_ausverz )); then
						hookcounter=$((Vhookcounter + 10))
						echo $hookcounter > ramdisk/$Fhookcounter
					else
						rm ramdisk/$Fhookaktiv
						echo 0 > ramdisk/$Fhookakt
						curl -s --connect-timeout 5 $Chookaus_url > ramdisk/hookmsg
						openwbDebugLog "CHARGESTAT" 0 "WebHook $1 deaktiviert"
						openwbDebugLog "CHARGESTAT" 0 "$(cat ramdisk/hookmsg)"
						rm ramdisk/hookmsg
						openwbDebugLog "MAIN" 1 "Gerät $1 deaktiviert bei $uberschuss"
						pushover "Gerät $1 ausgeschaltet bei $uberschuss"
		fi
	fi
			else
					openwbDebugLog "MAIN" 2 "hook wait for mintime "

						fi
					fi
				fi
}

# public
hook(){

  if (( hook1_aktiv == "1" )); then
     smgeraet 1
			fi
  if (( hook2_aktiv == "1" )); then
     smgeraet 2
		fi
  if (( hook3_aktiv == "1" )); then
     smgeraet 3
	fi

	# Steckt der Stecker...
		plugstat=$(<ramdisk/plugstat)
	
	if (( angesteckthooklp1 == 1 )); then
	    hooker $((plugstat==1)) "angesteckthooklp1aktiv"  $angesteckthooklp1_url "Angesteckt-WebHook"
	fi
	if (( abgesteckthooklp1 == 1 )); then
		hooker  $((plugstat==0)) "abgesteckthooklp1aktiv"  $abgesteckthooklp1_url "Abgesteckt-WebHook"
		fi

	# geht bei ladeleustung>100w sofort auf 1 (ladelog.sh)
	# geht 50Sec nach ladestop auf 0 (von ladelog.sh) verzögert um u1p3 unterbrechungen zu überbrücken 
		ladungaktivlp1=$(<ramdisk/ladungaktivlp1)
	      
	if (( ladestarthooklp1 == 1 )); then
		hooker  $((ladungaktivlp1==1)) "ladestarthooklp1aktiv"  $ladestarthooklp1_url "Ladestart-WebHook"
	fi
	if (( ladestophooklp1 == 1 )); then
		hooker  $((ladungaktivlp1==0)) "ladestophooklp1aktiv"  $ladestophooklp1_url "Ladestop-WebHook"
	fi

}
