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
            pvVA      = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[0].u_sg_lp')
            pvVB      = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[1].u_sg_lp')
            pvPP      = rct_lib.add_by_name(MyTab, 'buf_v_control.power_reduction_max_solar')
            pvPF      = rct_lib.add_by_name(MyTab, 'buf_v_control.power_reduction_max_solar_grid')
            pvPR      = rct_lib.add_by_name(MyTab, 'buf_v_control.power_reduction')

            pvWA      = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[0].p_dc_lp')
            pvWB      = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[1].p_dc_lp')
            pvWA2     = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[0].p_dc')
            pvWB2     = rct_lib.add_by_name(MyTab, 'dc_conv.dc_conv_struct[1].p_dc')


            pvEDA= rct_lib.add_by_name(MyTab, 'energy.e_dc_day[0]')
            pvEDB= rct_lib.add_by_name(MyTab, 'energy.e_dc_day[1]')
            pvEMA= rct_lib.add_by_name(MyTab, 'energy.e_dc_month[0]')
            pvEMB= rct_lib.add_by_name(MyTab, 'energy.e_dc_month[1]')
            pvEYA= rct_lib.add_by_name(MyTab, 'energy.e_dc_year[0]')
            pvEYB= rct_lib.add_by_name(MyTab, 'energy.e_dc_year[1]')
            pvETA= rct_lib.add_by_name(MyTab, 'energy.e_dc_total[0]')
            pvETB= rct_lib.add_by_name(MyTab, 'energy.e_dc_total[1]')

            # read parameters
            response = rct_lib.read(clientsocket, MyTab)
            rct_lib.close(clientsocket)
            
            # output all response elements
            rct_lib.dbglog("Overall access time: {:.3f} seconds".format(time.time() - start_time))
            rct_lib.dbglog(rct_lib.format_list(response))


            AV =  int(pvVA.value * 100.0) / 100.0
            print( "PV String A          : " + str(AV) + ' V')
            AW =  int(pvWA.value)#  * 100.0) / 100.0
            AW2 =  int(pvWA2.value)#  * 100.0) / 100.0
            print( "PV String A          : " + str(AW) + ' W (' + str(AW2) + ' W)')
            EDA =  int(pvEDA.value) / 1000.0
            print( "PV String A Day      : " + str(EDA) + ' kWh')
            EMA =  int(pvEMA.value) / 1000.0
            print( "PV String A Month    : " + str(EMA) + ' kWh')
            EYA =  int(pvEYA.value) / 1000.0
            print( "PV String A Year     : " + str(EYA) + ' kWh')
            ETA =  int(pvETA.value) / 1000.0
            print( "PV String A Total    : " + str(ETA) + ' kWh')


            BV =  int(pvVB.value * 100.0) / 100.0
            print( "PV String B          : " + str(BV) + ' V')
            BW =  int(pvWB.value)#  * 100.0) / 100.0
            BW2 = int(pvWB2.value)#  * 100.0) / 100.0
            print( "PV String B          : " + str(BW) + ' W (' + str(BW2) + ' W)')
            EDB =  int(pvEDB.value) / 1000.0
            print( "PV String B Day      : " + str(EDB) + ' kWh')
            EMB =  int(pvEMB.value) / 1000.0
            print( "PV String B Month    : " + str(EMB) + ' kWh')
            EYB =  int(pvEYB.value) / 1000.0
            print( "PV String B Year     : " + str(EYB) + ' kWh')
            ETB =  int(pvETB.value) / 1000.0
            print( "PV String B Total    : " + str(ETB) + ' kWh')


            print ( '<hr>')

            print( "PV Peek Power        : " + str(pvPP.value) + ' W')
            PR = int( (pvPR.value+0.0049999) * 100.0) 
            print( "PV max Feed Power    : " + str(pvPF.value) + ' W, Reduced to ' + str(PR) + '%')


        except Exception as e:
            rct_lib.close(clientsocket)
            raise(e)
            
    sys.exit(0)

if __name__ == "__main__":
    main()
    
    
