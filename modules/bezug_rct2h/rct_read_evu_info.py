#!/usr/bin/python3
import sys
import rct_lib
import time

# Author Heinz Hoefling
# Version 1.0 Okt.2021

# Entry point with parameter check
def main():
    start_time = time.time()
    rct_lib.init(sys.argv)

    clientsocket = rct_lib.connect_to_server()
    if clientsocket is not None:
        try:
            # generate id list for fast bulk read
            MyTab = []

            p_ac_sc_sum = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_sc_sum')
            volt1       = rct_lib.add_by_name(MyTab, 'g_sync.u_l_rms[0]')
            volt2       = rct_lib.add_by_name(MyTab, 'g_sync.u_l_rms[1]')
            volt3       = rct_lib.add_by_name(MyTab, 'g_sync.u_l_rms[2]')
            watt1       = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_sc[0]')
            watt2       = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_sc[1]')
            watt3       = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_sc[2]')
            freq        = rct_lib.add_by_name(MyTab, 'grid_pll[0].f')
            stat1       = rct_lib.add_by_name(MyTab, 'fault[0].flt')
            stat2       = rct_lib.add_by_name(MyTab, 'fault[1].flt')
            stat3       = rct_lib.add_by_name(MyTab, 'fault[2].flt')
            stat4       = rct_lib.add_by_name(MyTab, 'fault[3].flt')
            totalfeed   = rct_lib.add_by_name(MyTab, 'energy.e_grid_feed_total')
            totalload   = rct_lib.add_by_name(MyTab, 'energy.e_grid_load_total')
            
            house_load1  = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_load[0]')
            house_load2  = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_load[1]')
            house_load3  = rct_lib.add_by_name(MyTab, 'g_sync.p_ac_load[2]')


            # read parameters
            response = rct_lib.read(clientsocket, MyTab)
            rct_lib.close(clientsocket)
            
            # output all response elements
            rct_lib.dbglog("Overall access time: {:.3f} seconds".format(time.time() - start_time))
            rct_lib.dbglog(rct_lib.format_list(response))

            volt1=int(volt1.value)
            volt1=int(volt1 * 10) / 10.0
            volt2=int(volt2.value)
            volt2=int(volt2 * 10) / 10.0
            volt3=int(volt3.value)
            volt3=int(volt3 * 10) / 10.0

            watt1=int(watt1.value)
            ampere1=int( watt1 / volt1 * 10.0) / 10.0
            watt2=int(watt2.value)
            ampere2=int( watt2 / volt2 * 10.0) / 10.0
            watt3=int(watt3.value)
            ampere3=int( watt3 / volt3 * 10.0) / 10.0

            h1w=int(house_load1.value)
            h2w=int(house_load2.value)
            h3w=int(house_load3.value)
            
            
            # Counter nur alle 5 Mintuen auslesen
            p_ac_sc_sum = int(p_ac_sc_sum.value*1.0)
            if p_ac_sc_sum < 0:
              print( "aktual Feed           : " + str(p_ac_sc_sum ) + ' W')
            else:
              print( "aktual Feed           : " + str(p_ac_sc_sum ) + ' W')
            print( "Spannung              : " + str(volt1) + " / " + str(volt2) + " / " + str(volt3)  + ' Volt')
            print( "Strom                 : " + str(ampere1) + " / " + str(ampere2) + " / " + str(ampere3)  + ' Ampere')
            print( "Leistung              : " + str(watt1) + " / " + str(watt2) + " / " + str(watt3)  + ' Watt')
            print( "Hausverbrauch (RCT)   : " + str(h1w) + " / " + str(h2w) + " / " + str(h3w)  + ' Watt')

            totalfeed=int(totalfeed.value * -1.0) / 1000.0
            print( "Total-Feed           : " + str(totalfeed) + ' KWh')
            totalload=int(totalload.value) / 1000.0 
            print( "Total-Load           : " + str(totalload) + ' KWh')


            freq=freq.value
            freq=int(freq * 100) / 100.0
            print( "Frequenz             : " + str(freq) + ' Hz')


            print ( '<hr>')

        except Exception as e:
            rct_lib.close(clientsocket)
            raise(e)
            
    sys.exit(0)

if __name__ == "__main__":
    main()
    
    
