#!/usr/bin/python3
import sys
import os
import rct_lib
import fnmatch
#  date --date @1631599500 +"%d.%m.%Y %H:%M"



# Author Heinz Hoefling
# Version 1.0 Okt.2021
# Fragt die Werte gebuendelt ab, nicht mit einer Connection je Wert 


#
# Schreib und logge einen Wert in die Ramdisk 
#
def writeRam(fn,val, rctname):
    fnn = "/var/www/html/openWB/ramdisk/"+str(fn)
    if rct_lib.bVerbose == True:
        f = open(fnn,'r')
        oldv = (f.read()).strip()
        f.close()
        rct_lib.dbglog("field " + str(fnn)+ " newval:["+ str(val) + "] oldval:["+ str(oldv) + "] "  + str(rctname) )
    f = open(fnn,'w')
    f.write(str(val))
    f.close()



# Entry point with parameter check
def main():
    rct_lib.init(sys.argv)
    rct_lib.dbglog("bb=" , str(rct_lib.bb) )
    rct_lib.dbglog("wr=" , str(rct_lib.wr) )
    rct_lib.dbglog("sp=" , str(rct_lib.sp) )
    rct_lib.dbglog("ii=" , str(rct_lib.ii) )
    rct_lib.dbglog('bm5 ', str(rct_lib.bm5) )
    clientsocket = rct_lib.connect_to_server()
    if clientsocket is not None:
#
######################################################
#
     if rct_lib.bb:
        if rct_lib.bm5:
            rct_lib.dbglog("--m5 set, get EVU totals")
            # Counter nur alle 5 Mintuen auslesen
            totalfeed=int(rct_lib.read(clientsocket,0x44D4C533 )*-1.0) 
            writeRam('einspeisungkwh', totalfeed, '0x44D4C533 energy.e_grid_feed_total')

            totalload=int(rct_lib.read(clientsocket,0x62FBE7DC )) 
            writeRam('bezugkwh',        totalload, '#0x62FBE7DC energy.e_grid_load_total')
                
        value = rct_lib.read(clientsocket, 0x6002891F )
        writeRam('wattbezug', int(value )*1  , '#0x6002891F g_sync.p_ac_sc_sum')

        volt1=int(rct_lib.read(clientsocket,0xCF053085 ))
        volt1=int(volt1 * 10) / 10.0
        writeRam('evuv1', volt1, '0xCF053085 g_sync.u_l_rms[0] ')

        volt2=int(rct_lib.read(clientsocket,0x54B4684E ))
        volt2=int(volt2 * 10) / 10.0
        writeRam('evuv2', volt2, '0x54B4684E g_sync.u_l_rms[1] ')

        volt3=int(rct_lib.read(clientsocket,0x2545E22D ))
        volt3=int(volt3 * 10) / 10.0
        writeRam('evuv3', volt3, '0x2545E22D g_sync.u_l_rms[2] ')

        watt=int(rct_lib.read(clientsocket,0x27BE51D9 ))
        writeRam('bezugw1', watt  , '0x27BE51D9 als Watt g_sync.p_ac_sc[0]')
        ampere=int( watt / volt1 * 10.0) / 10.0
        writeRam('bezuga1', ampere, '0x27BE51D9 als Ampere g_sync.p_ac_sc[0]')

        watt=int(rct_lib.read(clientsocket,0xF5584F90 ))
        writeRam('bezugw2', watt  , '0xF5584F90 als Watt g_sync.p_ac_sc[1]')
        ampere=int( watt / volt2 * 10.0) / 10.0
        writeRam('bezuga2', ampere, '0xF5584F90 als Ampere g_sync.p_ac_sc[1]')

        watt=int(rct_lib.read(clientsocket,0xB221BCFA ))
        writeRam('bezugw3', watt  , '0xB221BCFA als Watt g_sync.p_ac_sc[2]')
        ampere=int( watt / volt3 * 10.0) / 10.0
        writeRam('bezuga3', ampere, '0xF5584F90 als Ampere g_sync.p_ac_sc[2]')


        freq=rct_lib.read(clientsocket,0x1C4A665F )
        freq=int(freq * 100) / 100.0
        writeRam('evuhz', freq, '0x1C4A665F grid_pll[0].f')
        writeRam('llhz', freq, '0x1C4A665F grid_pll[0].f')


        stat1 = int(rct_lib.read(clientsocket,0x37F9D5CA ))
        stat2 = int(rct_lib.read(clientsocket,0x234B4736 ))
        stat3 = int(rct_lib.read(clientsocket,0x3B7FCD47 ))
        stat4 = int(rct_lib.read(clientsocket,0x7F813D73 ))
        
       
        faultStr=' '
        faultState=0

        if ( stat1 + stat2 + stat3 + stat4) > 0:
            rct_lib.dbglog("status " , stat1, stat2, stat3 , stat4 ) 
            faultStr = "ALARM EVU Status nicht 0"
            faultState=2
            rct_lib.dbglog("faultstate: ", faultState, faultStr) 
             # speicher in mqtt 
            os.system('mosquitto_pub -r -t openWB/evu/faultState -m "' + str(faultState) +'"')
            os.system('mosquitto_pub -r -t openWB/evu/faultStr -m "' + str(faultStr) +'"')
        else:
            # Kein fehler loesche alle 5 mintuen den statzus
            if rct_lib.bm5:
                os.system('mosquitto_pub -r -t openWB/evu/faultState -m "' + str(faultState) +'"')
                os.system('mosquitto_pub -r -t openWB/evu/faultStr -m "' + str(faultStr) +'"')
        

######################################################
     if rct_lib.wr and rct_lib.bb:
        # Wr 
        wrfaultStr=' '
        wrfaultState=0
        # aktuell
        pv1watt=int(rct_lib.read(clientsocket,0xB5317B78 ))
        pv2watt=int(rct_lib.read(clientsocket,0xAA9AA253 ))
        pv3watt=int(rct_lib.read(clientsocket,0xE96F1844 )) 
        rct_lib.dbglog("pvwatt A:"+ str(pv1watt) + "  B:"+ str(pv2watt) + " G:"+ str(pv3watt) )
        writeRam('pv1wattString1', int(pv1watt), 'pv1watt')
        writeRam('pv1wattString2', int(pv2watt), 'pv2watt')

        pvwatt = ( (pv1watt+pv2watt+pv3watt) * -1 )
        writeRam('pvwatt', int(pvwatt), 'negative Summe von pv1/2/3watt')
        
        # Alternative wr_ac out statt dc_in summe
        #pvwatt=int(rct_lib.read(clientsocket,0x4E49AEC5) ) *-1   #  g_sync.p_ac_sum 2580.68408203125
        #writeRam('pvwatt', int(pvwatt), 'wr out')

        

        if rct_lib.bm5:
            rct_lib.dbglog("--m5 set, get WR totals")
            #monthly
            mA=int(rct_lib.read(clientsocket,0x81AE960B ))  # energy.e_dc_month[0]  WH
            mB=int(rct_lib.read(clientsocket,0x7AB9B045 ))  # energy.e_dc_month[1]  WH
            mE=int(rct_lib.read(clientsocket,0x031A6110 ))  # energy.e_ext_month    WH
            monthly_pvkwhk = ( mA + mB + mE) / 1000.0   # -> KW
            writeRam('monthly_pvkwhk', monthly_pvkwhk, 'monthly_pvkwhk')

            #yearly
            yA=int(rct_lib.read(clientsocket,0xAF64D0FE ))  # energy.e_dc_total[0]  WH
            yB=int(rct_lib.read(clientsocket,0xBD55D796 ))  # energy.e_dc_total[1]  WH
            yE=int(rct_lib.read(clientsocket,0xA59C8428 ))  # energy.e_ext_total    WH
            yearly_pvkwhk = ( yA + yB + yE) / 1000.0   # -> KW
            writeRam('yearly_pvkwhk', yearly_pvkwhk, 'yearly_pvkwhk')

            # total
            pv1total=int(rct_lib.read(clientsocket,0xFC724A9E ))    # energy.e_dc_total[0]
            pv2total=int(rct_lib.read(clientsocket,0x68EEFD3D ))    # energy.e_dc_total[1]
            pv3total=int(rct_lib.read(clientsocket,0xA59C8428 ))    # energy.e_ext_total
            rct_lib.dbglog("pvtotal  A:"+ str(pv1total) + "  B:"+ str(pv2total) + " G:"+ str(pv3total) )
            pvkwh  = (pv1total + pv2total + pv3total) 
            writeRam('pvkwh', pvkwh, 'Summe von pv1total pv1total pv1total')

#mqttvar["pv/CounterTillStartPvCharging"]=pvcounter
#mqttvar["pv/bool70PVDynStatus"]=nurpv70dynstatus
#mqttvar["pv/WhCounter"]=pvallwh
#mqttvar["pv/DailyYieldKwh"]=daily_pvkwhk
#mqttvar["pv/MonthlyYieldKwh"]=monthly_pvkwhk
#mqttvar["pv/YearlyYieldKwh"]=yearly_pvkwhk
#mqttvar["pv/1/W"]=pv1watt
#mqttvar["pv/1/WhCounter"]=pvkwh
#mqttvar["pv/1/DailyYieldKwh"]=daily_pvkwhk1
#mqttvar["pv/1/MonthlyYieldKwh"]=monthly_pvkwhk1
#mqttvar["pv/1/YearlyYieldKwh"]=yearly_pvkwhk1
#mqttvar["pv/2/W"]=pv2watt
#mqttvar["pv/2/WhCounter"]=pv2kwh
#mqttvar["pv/2/DailyYieldKwh"]=daily_pvkwhk2
#mqttvar["pv/2/MonthlyYieldKwh"]=monthly_pvkwhk2
#mqttvar["pv/2/YearlyYieldKwh"]=yearly_pvkwhk2

#
#
######################################################
#
     if rct_lib.sp and rct_lib.bb:
        # Speicher 
        spfaultStr=' '
        spfaultState=0
        socx = rct_lib.read(clientsocket,0x959930BF )
        soc =int(socx * 100.0)
        writeRam('speichersoc', soc, '0x959930BF battery.soc')

        # akuelles Ladeziel des Hausspeichers fuer die Anzeige weitereeichen. 
        socsoll = int(rct_lib.read(clientsocket,0x8B9FF008 ) * 100.0 )
        os.system('mosquitto_pub -r -t openWB/housebattery/soctarget -m "' + str(socsoll) +'"')

        watt =int(rct_lib.read(clientsocket,0x400F015B ) * -1.0 ) 
        writeRam('speicherleistung', watt, '0x400F015B g_sync.p_acc_lp')

        if rct_lib.bm5:
            rct_lib.dbglog("--m5 set, get WR totals")
            watt =int(rct_lib.read(clientsocket,0x5570401B ))
            #rct_lib.dbglog("speicherikwh will be battery.stored_energy "+ str(watt)) 
            writeRam('speicherikwh', watt, '0x5570401B battery.stored_energy')

            watt =int(rct_lib.read(clientsocket,0xA9033880 ))
            #rct_lib.dbglog("speicherekwh will be battery.used_energy "+ str(watt))         
            writeRam('speicherekwh', watt, '#0xA9033880 battery.used_energy')
            

        stat1 = int(rct_lib.read(clientsocket,0x70A2AF4F ))
        rct_lib.dbglog("battery.bat_status "+ str(stat1))

        stat2 = int(rct_lib.read(clientsocket,0x71765BD8 ))
        rct_lib.dbglog("battery.status "+ str(stat2))

        stat3 = int(rct_lib.read(clientsocket,0x0DE3D20D ))
        rct_lib.dbglog("battery.status2 "+ str(stat3))
        
        spfaultStr=' '
        spfaultState=0
        if ( stat1 + stat2 + stat3) > 0:
            rct_lib.dbglog("Sp-Status " , stat1, stat2, stat3 ) 
            spfaultStr = "Battery ALARM Battery-Status nicht 0"
            spfaultState=2
            rct_lib.dbglog("spfaultstate: ", spfaultState, spfaultStr) 
            # speicher in mqtt 
            os.system('mosquitto_pub -r -t openWB/set/housebattery/faultState -m "' + str(spfaultState) +'"')
            os.system('mosquitto_pub -r -t openWB/set/housebattery/faultStr -m "' + str(spfaultStr) +'"')
        else:
            # Kein fehler loesche alle 5 mintuen den statzus
            if rct_lib.bm5:
                os.system('mosquitto_pub -r -t openWB/set/housebattery/faultState -m "' + str(spfaultState) +'"')
                os.system('mosquitto_pub -r -t openWB/set/housebattery/faultStr -m "' + str(spfaultStr) +'"')
        

#
######################################################
#
     if  rct_lib.ii and rct_lib.bb:
        # Info-Speicher 
        faultStr=' '
        faultState=0
#
######################################################
#

        rct_lib.close(clientsocket)

    sys.exit(0)
    
if __name__ == "__main__":
    main()
