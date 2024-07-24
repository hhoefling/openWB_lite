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
            BMSVersion = rct_lib2.add_by_name(MyTab, 'battery.bms_power_version')
            BMS2Version= rct_lib2.add_by_name(MyTab, "battery.bms_software_version")
            Ser       = rct_lib2.add_by_name(MyTab, "battery.bms_sn")
            Status    = rct_lib2.add_by_name(MyTab, "battery.bat_status")
            btyp      = rct_lib2.add_by_name(MyTab, "power_mng.battery_type")
            cap       = rct_lib2.add_by_name(MyTab, "battery.ah_capacity") 
            cycl      = rct_lib2.add_by_name(MyTab, "battery.cycles")
            Eff       = rct_lib2.add_by_name(MyTab, "battery.efficiency")
            Soh       = rct_lib2.add_by_name(MyTab, "battery.soh")
            SoC       = rct_lib2.add_by_name(MyTab, "battery.soc") 
            temp      = rct_lib2.add_by_name(MyTab, "battery.max_cell_temperature")
            Stat1     = rct_lib2.add_by_name(MyTab, "battery.status")
            Stat2     = rct_lib2.add_by_name(MyTab, "battery.status2") 
            Stor      = rct_lib2.add_by_name(MyTab, "battery.stored_energy") 
            Used      = rct_lib2.add_by_name(MyTab, "battery.used_energy")
            bxt		  = rct_lib2.add_by_name(MyTab, "battery.temperature")
#            bxv		  = rct_lib2.add_by_name(MyTab, "battery.voltage")
#            bxp		  = rct_lib2.add_by_name(MyTab, "battery.prog_sn")
            soc97      = rct_lib2.add_by_name(MyTab, "battery.soc_target")
            
            socP7      = rct_lib2.add_by_name(MyTab, "power_mng.soc_min")     
            socP5      = rct_lib2.add_by_name(MyTab, "power_mng.soc_charge")  
            socWatt    = rct_lib2.add_by_name(MyTab, "power_mng.soc_charge_power")
 
 
#            bxsth	  = rct_lib2.add_by_name(MyTab, "battery.soc_target_high")
#            bxstl	  = rct_lib2.add_by_name(MyTab, "battery.soc_target_low")
#            bxus	  = rct_lib2.add_by_name(MyTab, "battery.soc_update_since")
            ms1       = rct_lib2.add_by_name(MyTab, "battery.module_sn[0]")
            ms2       = rct_lib2.add_by_name(MyTab, "battery.module_sn[1]") 
            ms3       = rct_lib2.add_by_name(MyTab, "battery.module_sn[2]")
            ms4       = rct_lib2.add_by_name(MyTab, "battery.module_sn[3]") 
            ms5       = rct_lib2.add_by_name(MyTab, "battery.module_sn[4]") 
            ms6       = rct_lib2.add_by_name(MyTab, "battery.module_sn[5]") 
            ms7		  = rct_lib2.add_by_name(MyTab, "battery.module_sn[6]") 
            sc1		  = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[0]")
            sc2 	  = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[1]")
            sc3       = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[2]")
            sc4       = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[3]")
            sc5       = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[4]")
            sc6       = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[5]")
            sc7       = rct_lib2.add_by_name(MyTab, "battery.stack_cycles[6]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[0]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[1]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[2]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[3]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[4]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[5]")
#            rct_lib2.add_by_name(MyTab, "battery.stack_software_version[6]")

            nextcal=rct_lib2.add_by_name(MyTab, "power_mng.bat_next_calib_date")

            # read parameters
            response = rct_lib2.read(clientsocket, MyTab)
            rct_lib2.close(clientsocket)
            
            # output all response elements
            rct_lib2.dbglog("Overall access time: {:.3f} seconds".format(time.time() - start_time))
            rct_lib2.dbglog(rct_lib2.format_list(response))

            print( "Battery Controller   : " + str(rct_lib2.host) )
            print( "Version              : BMS:" + str(BMSVersion.value) + " / " + str(BMS2Version.value) )
            print( "Serial Nr            : " + str(Ser.value) )
            print( "Bat-Status           : "  + str(Status.value) )
            print( "Batt Status 1/2      : "  + str(Stat1.value) + ' ' + str(Stat2.value) )
            print( "Max.Lade/Enladetrom A: "  + str(cap.value) + ' A' )
            print( "Durchlaufene Zyklen  : "  + str(cycl.value) )
            Eff =  int(Eff.value * 10000) / 100.0
            print( "Efficency            : "  + str(Eff) + '%' )
            print( "SoH                  : "  + str(Soh.value) )
            print( "Naechste Calibrierung: " +  str(nextcal.value) )
            SoC =  int(SoC.value *10000) / 100
            print( "SoC                  : "  + str(SoC)+'%' )

            soc97 =  int(soc97.value *10000) / 100
            socP7 =  int(socP7.value *10000) / 100
            socP5 =  int(socP5.value *10000) / 100            
            print( "SoC Targets          : "  +  str(socP5)+'% << ' + str(socP7)+'% << ' + str(soc97)+'%' )
            print( "SoC Load Power       : "  +  str(socWatt.value)+' W' )
            
            
            temp =  int(temp.value * 100) / 100.0
            bt = int(bxt.value * 100) / 100.0 
            print( "Cell Temp.           : "  + str(bt) + ' Grad (Max:' + str(temp) + ' Grad)' )
            Stor=  (int(Stor.value) / 1000.0)
            print(  "Gespeicherte Energy  : "  + str(Stor) + ' kWh' )
            Used=  (int(Used.value) / 1000.0)
            print(  "Entnommene Energy    : "  + str(Used) + ' kWh' )

            # print(  '<hr>' )
            if btyp.value == 0:
                bts='Lead-acid Powerfit'
            if btyp.value == 1:
                bts='Li-Ion Akesol'
            if btyp.value == 2:
                bts='Laukner'
            if btyp.value == 3:
                bts='Li-Ion RCT Power'
            if btyp.value == 4:
                bts='Li-Ion Zach'
            if btyp.value == 5:
                bts='No battery'
            if btyp.value == 6:
                bts='Power loop 200 V'
            if btyp.value == 7:
                bts='BYD D-BOX H'
            print(  "Battery type         : "  + str(btyp.value) + ' ' + bts )


            if  str(ms1.value)>"  ":
                print( "Batt.Pack 1 SN       : "  + str(ms1.value) + " (" + str(sc1.value) + " Zyklen)")
            if  str(ms2.value)>"  ":
                print( "Batt.Pack 2 SN       : "  + str(ms2.value) + " (" + str(sc2.value) + " Zyklen)")
            if  str(ms3.value)>"  ":
                print( "Batt.Pack 3 SN       : "  + str(ms3.value) + " (" + str(sc3.value) + " Zyklen)")
            if  str(ms4.value)>"  ":
                print( "Batt.Pack 4 SN       : "  + str(ms4.value) + " (" + str(sc4.value) + " Zyklen)")
            if  str(ms5.value)>"  ":
                print( "Batt.Pack 5 SN       : "  + str(ms5.value) + " (" + str(sc5.value) + " Zyklen)")
            if  str(ms6.value)>"  ":
                print( "Batt.Pack 6 SN       : "  + str(ms6.value) + " (" + str(sc6.value) + " Zyklen)")


        except Exception as e:
            rct_lib2.close(clientsocket)
            raise(e)
            
    sys.exit(0)

if __name__ == "__main__":
    main()
    
    
