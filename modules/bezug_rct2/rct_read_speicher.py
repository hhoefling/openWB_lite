#!/usr/bin/python3
import os
import sys
import rct_lib
import fnmatch
import time
#
# Author Heinz Hoefling
# Version 1.0 Okt.2021
# Fragt die Werte gebuendelt ab, 
#

def MinSecOld(fn):
    fnn = "/var/www/html/openWB/ramdisk/"+str(fn)
    age = time.time() - os.stat(fnn).st_mtime
    if rct_lib.bVerbose == True:
        rct_lib.dbglog("file:" + str(fnn)+ " is "+ str(age) + " ses old")
    return age


def writeRam(fn,val, rctname):
    fnn = "/var/www/html/openWB/ramdisk/"+str(fn)
    if rct_lib.bVerbose == True:
        f = open(fnn,'r')
        oldv = f.read()
        f.close()
        rct_lib.dbglog("field " + str(fnn)+ " val is "+ str(val) + " oldval:"+ str(oldv) + " "  + str(rctname) )
    
    f = open(fnn,'w')
    f.write(str(val))
    f.close()
    

# Entry point with parameter check
def main():
    rct_lib.init(sys.argv)

    clientsocket = rct_lib.connect_to_server()
    if clientsocket is not None:

        # 0xC642B9D6 acc_conv.i_discharge_max 20.0
        discharge_max = rct_lib.read(clientsocket,0xC642B9D6 )
        writeRam('HB_discharge_max', discharge_max, '0xC642B9D6 acc_conv.i_discharge_max')
 
        # 0x1D2994EA power_mng.soc_charge_power 100.0
        loadWatt = rct_lib.read(clientsocket,0x1D2994EA )
        writeRam('HB_loadWatt', loadWatt, '0x1D2994EA power_mng.soc_charge_power')
          
 
        socx = rct_lib.read(clientsocket,0x959930BF )
        soc =int(socx * 100.0)
        writeRam('speichersoc', soc, '0x959930BF battery.soc')

        watt =int(rct_lib.read(clientsocket,0x400F015B ) * -1.0 ) 
        writeRam('speicherleistung', watt, '0x400F015B g_sync.p_acc_lp')

        if MinSecOld('speicherikwh')>120:
            watt =int(rct_lib.read(clientsocket,0x5570401B ))
            #rct_lib.dbglog("speicherikwh will be battery.stored_energy "+ str(watt)) 
            writeRam('speicherikwh', watt, '0x5570401B battery.stored_energy')

            watt =int(rct_lib.read(clientsocket,0xA9033880 ))
            #rct_lib.dbglog("speicherekwh will be battery.used_energy "+ str(watt))         
            writeRam('speicherekwh', watt, '#0xA9033880 battery.used_energy')

        # battery.bat_status
        stat1 = int(rct_lib.read(clientsocket,0x70A2AF4F )) # battery.bat_status Current battery status (bitfield) 
        stat2 = int(rct_lib.read(clientsocket,0x71765BD8 )) # battery.status Battery status
        stat3 = int(rct_lib.read(clientsocket,0x0DE3D20D )) # battery.status2' Battery extra status

        rct_lib.dbglog("battery.status "+ str(stat1)+" "+str(stat2)+" "+str(stat3) )
        
        faultStr=' '
        faultState=0
        if( int(stat1)==0 and int(stat3) == 256):
            stat3 = 0   #  Igrnore bat-Full meldung

        if ( stat1 + stat2 + stat3 ) > 0:
            if( int(stat1) == 256):
                faultStr = "??? (bat_status C256)"
                faultState=1
            elif( int(stat1) == 512):
                faultStr = "Leistungstest (bat_status C512)"
                faultState=1
            elif( int(stat1) == 1024):
                faultStr = "Battery Callibrating (bat_status C1024)"
                faultState=1
            elif( int(stat1) == 8 ):
                faultStr = "Battery Callibrating (bat_status C8)"
                faultState=1
#            elif( int(stat1)==0 and int(stat3)==256 ):
#                faultStr = "Battery Extra (256)"
#                faultState=1
            else:
                faultStr = "Battery ALARM Battery-Status " + str(stat1)+"|"+str(stat2)+"|"+str(stat3)
                faultState=2
            # speicher in mqtt 
            os.system('mosquitto_pub -r -t openWB/set/houseBattery/faultState -m "' + str(faultState) +'"')
            os.system('mosquitto_pub -r -t openWB/set/houseBattery/faultStr -m "' + str(faultStr) +'"')
        # akuelles Ladeziel des Hausspeichers fuer die Anzeige weitereeichen. 
        socsoll = int(rct_lib.read(clientsocket,0x8B9FF008 ) * 100.0 )
        if( socsoll==97 and int(stat1) == 0):
            writeRam('HB_iskalib', "0", "is_kalib")
            # writeRam('HB_iskaliblog', str(socsoll)+" "+str(stat1), "is_kaliblog") 
        else:
            writeRam('HB_iskalib', "1", "is_kalib") 
            # writeRam('HB_iskaliblog', str(socsoll)+" "+str(stat1), "is_kaliblog")

        s = str(int(discharge_max)) + " " + str(socsoll)
        writeRam('HB_soctarget', s, 'soc target')
        # os.system('mosquitto_pub -r -t openWB/housebattery/soctarget -m "' + str(s) +'"')
        
   
        rct_lib.close(clientsocket)
    sys.exit(0)
    
if __name__ == "__main__":
    main()
