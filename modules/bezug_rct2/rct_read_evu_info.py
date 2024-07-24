#!/usr/bin/python3
import sys
import rct_lib2
import time

# Author Heinz Hoefling
# Version 1.0 Okt.2021

# Entry point with parameter check
def main():
    start_time = time.time()
    rct_lib2.init(sys.argv)

    clientsocket = rct_lib2.connect_to_server()
    if clientsocket is not None:
        try:
            # generate id list for fast bulk read
            MyTab = []

            sn= rct_lib2.add_by_name(MyTab, 'inverter_sn')

            evuFeedD= rct_lib2.add_by_name(MyTab, 'energy.e_grid_feed_day')
            evuFeedM= rct_lib2.add_by_name(MyTab, 'energy.e_grid_feed_month')
            evuFeedY= rct_lib2.add_by_name(MyTab, 'energy.e_grid_feed_year')
            evuFeedT= rct_lib2.add_by_name(MyTab, 'energy.e_grid_feed_total')

            evuLoadD= rct_lib2.add_by_name(MyTab, 'energy.e_grid_load_day')
            evuLoadM= rct_lib2.add_by_name(MyTab, 'energy.e_grid_load_month')
            evuLoadY= rct_lib2.add_by_name(MyTab, 'energy.e_grid_load_year')
            evuLoadT= rct_lib2.add_by_name(MyTab, 'energy.e_grid_load_total')

            evuHausD= rct_lib2.add_by_name(MyTab, 'energy.e_load_day')
            evuHausM= rct_lib2.add_by_name(MyTab, 'energy.e_load_month')
            evuHausY= rct_lib2.add_by_name(MyTab, 'energy.e_load_year')
            evuHausT= rct_lib2.add_by_name(MyTab, 'energy.e_load_total')

            # read parameters
            response = rct_lib2.read(clientsocket, MyTab)
            rct_lib2.close(clientsocket)
            
            # output all response elements
            rct_lib2.dbglog("Overall access time: {:.3f} seconds".format(time.time() - start_time))
            rct_lib2.dbglog(rct_lib2.format_list(response))
            
            print( "Inverter SN          : " + str(sn.value) )

            evuFeedD=  int(evuFeedD.value) / 1000.0 * -1.0
            print( "EVU Feed Day         : " + str(evuFeedD) + ' kWh')

            evuFeedM=  int(evuFeedM.value) / 1000.0 * -1.0
            print( "EVU Feed month       : " + str(evuFeedM) + ' kWh')

            evuFeedY=  int(evuFeedY.value) / 1000.0 * -1.0
            print( "EVU Feed year        : " + str(evuFeedY) + ' kWh')

            evuFeedT=  int(evuFeedT.value) / 1000.0 * -1.0
            print( "EVU Feed Total       : " + str(evuFeedT) + ' kWh')


            evuLoadD=  int(evuLoadD.value) / 1000.0 
            print( "EVU Load Day         : " + str(evuLoadD) + ' kWh')

            evuLoadM=  int(evuLoadM.value) / 1000.0 
            print( "EVU Load month       : " + str(evuLoadM) + ' kWh')

            evuLoadY=  int(evuLoadY.value) / 1000.0 
            print( "EVU Load year        : " + str(evuLoadY) + ' kWh')

            evuLoadT=  int(evuLoadT.value) / 1000.0 
            print( "EVU Load Total       : " + str(evuLoadT) + ' kWh')


            evuHausD=  int(evuHausD.value) / 1000.0 
            print( "EVU Haus Day         : " + str(evuHausD) + ' kWh')

            evuHausM=  int(evuHausM.value) / 1000.0 
            print( "EVU Haus month       : " + str(evuHausM) + ' kWh')

            evuHausY=  int(evuHausY.value) / 1000.0 
            print( "EVU Haus year        : " + str(evuHausY) + ' kWh')

            evuHausT=  int(evuHausT.value) / 1000.0 
            print( "EVU Haus Total       : " + str(evuHausT) + ' kWh')



        except Exception as e:
            rct_lib2.close(clientsocket)
            raise(e)
            
    sys.exit(0)

if __name__ == "__main__":
    main()
    
    
