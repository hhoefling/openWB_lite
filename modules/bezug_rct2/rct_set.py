#!/usr/bin/python3
import sys
import rctw
import time
import getopt
# import fnmatch


def xread(sock, objid):
    fmt = '#0x{:08X} {:'+str(rctw.param_len)+'}'# {:'+str(rctw.desc_len)+'}:'
    obj = rctw.find_by_id(objid)
    value = rctw.read(sock, obj.id)
    rctw.dbglog(fmt.format(obj.id, obj.name), value)
    return value

def oread(sock, obj):
    fmt = '#0x{:08X} {:'+str(rctw.param_len)+'}'# {:'+str(rctw.desc_len)+'}:'
    value = rctw.read(sock, obj.id)
    rctw.dbglog(fmt.format(obj.id, obj.name), value)
    return value


def read_ramdisk(name: str):
    try:
        with open('/var/www/html/openWB/ramdisk/' + name, 'r') as f:
            return f.read()
    except Exception as e:
        return "0"
        
actions=['status','reset','xstopdrain','drain', 'drain1A','loadbat','resetcurrent','resetwatt']

# globles
oP5 = None
oP7 = None
oPsoc = None
oP97 = None
oWatt = None
omaxDischarge = None
sollwatt=100.0
sollcurent=20.0


istP5 = 0.0
istP7 = 0.0
istPsoc = 0.0
istP97 = 0.0
istWatt = 0.0
istmaxDischarge = 0.0


def readold(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    istP5 = int(oread(sock, oP5) * 1000) / 1000.0
    istP7 = int(oread(sock, oP7) * 1000) / 1000.0
    istPsoc = int(oread(sock, oPsoc) * 1000) / 1000.0
    istP97 = int(oread(sock, oP97) * 1000) / 1000.0 
    istWatt = oread(sock, oWatt)
    istmaxDischarge = int(oread(sock, omaxDischarge) * 100) / 100
    rctw.dbglog('readold:' + str(istP5) + ' >> ' + str(istP7) + ' >> ' + str(istPsoc) + ' >> ' + str(istP97) + '  [' + str(istWatt) + ' W]')
    rctw.dbglog('readold: DischargeMax:' + str(istmaxDischarge))




def dostatus(sock):
    readold(sock)


def resetwatt(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    done=0
    readold(sock)
    rctw.dbglog('Do Reset watt')

    if istP5!=0.05:
        rctw.write(sock, oP5.id, 0.05)
        time.sleep(1)
        nowP5 = oread(sock, oP5)
        rctw.dbglog('Korrigiere ' + oP5.name + ' from ' + str(istP5) + ' to ' + str(nowP5))
        done=1
    else:
        rctw.dbglog(oP5.name + ' ' + str(istP5) + ' Ok')

    if istP7!=0.07:
        rctw.write(sock, oP7.id, 0.07)
        time.sleep(1)
        nowP7 = oread(sock, oP7)
        rctw.dbglog('Korrigiere ' + oP7.name + ' from ' + str(istP7) + ' to ' + str(nowP7))
        done=1
    else:
        rctw.dbglog(oP7.name + ' ' + str(istP7) + ' Ok')

    if istP97!=0.97:
        rctw.write(sock, oP97.id, 0.97)
        time.sleep(1)
        nowP97 = oread(sock, oP97)
        rctw.dbglog('Korrigiere ' + oP97.name + ' from ' + str(istP97) + ' to ' + str(nowP97))
        done=1
    else:
        rctw.dbglog(oP97.name + ' ' + str(istP97) + ' Ok')

    if istWatt!=100.0:
        rctw.write(sock, oWatt.id, 100.0)
        time.sleep(1)
        nowWatt = oread(sock, oWatt)
        rctw.dbglog('Korrigiere ' + oWatt.name + ' from ' + str(istWatt) + ' to ' + str(nowWatt))
        done=1
    else:
        rctw.dbglog(oWatt.name + ' ' + str(istWatt) + ' Ok')

    if( done>0):
        rctw.dbglog('Reload values')
        readold(sock)


def resetcurrent(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge

    readold(sock)
    rctw.dbglog('Do Reset current')
    done=0
    if istmaxDischarge != 20.0:
        rctw.write(sock, omaxDischarge.id, 20.0)
        time.sleep(1)
        nowmaxDischarge = oread(sock, omaxDischarge)
        rctw.dbglog('Korrigiere ' + omaxDischarge.name + ' from ' + str(istmaxDischarge) + ' to ' + str(nowmaxDischarge))
        done=1
    else:
        rctw.dbglog(omaxDischarge.name + ' ' + str(istmaxDischarge) + ' Ok')
    if( done>0):
        rctw.dbglog('Reload values')
        readold(sock)

def reset(sock):
    resetcurrent(sock)
    resetwatt(sock)


def loadbat(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    global sollwatt

    readold(sock)
    rctw.dbglog('Do loadbat, Akku aus netzt laden mit '+str(sollwatt) )

    if istPsoc >= istP97:
        print('Bat schon voll (soc>97) ')
    else:        
        newP7 = istP97 - 0.01
        newP5 = newP7 - 0.01
        newWatt = sollwatt
        if istPsoc > newP7:
            print('Soc schon voller')
        else:
            done=0    
            rctw.dbglog('new:' +   str(istPsoc) + ' >> ' + str(newP5) + ' >> ' + str(newP7) + ' >> '  + str(istP97) + '  [' + str(newWatt) + ' W]')
            if istP7 != newP7:
                rctw.write(sock, oP7.id, newP7)
                time.sleep(1)
                done=1
                rctw.dbglog(oP7.name + ' ' + str(istP7) + ' Written')
            else:
                rctw.dbglog(oP7.name + ' ' + str(istP7) + ' Ok')
            if istP5 != newP5:
                rctw.write(sock, oP5.id, newP5)
                time.sleep(1)
                done=1
                rctw.dbglog(oP5.name + ' ' + str(istP5) + ' Written')
            else:
                rctw.dbglog(oP5.name + ' ' + str(istP5) + ' Ok')
            if newWatt != istWatt:
                rctw.write(sock, oWatt.id, newWatt)
                time.sleep(1)
                done=1
                rctw.dbglog(oWatt.name + ' ' + str(istWatt) + ' Written')
            else:
                rctw.dbglog(oWatt.name + ' ' + str(istWatt) + ' Ok')
            if( done>0):
                rctw.dbglog('Reload values')
                readold(sock)


def xstopdrain(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    
    readold(sock)
    rctw.dbglog('Do xStopDrain, Akku nicht mehr entladen')
    newP7 = (istP97 - 0.01)     # p7 auf istP97 - 0.01 setzen

    if( newP7 < 0.07):
        print('Illegal P7 < P5  [' + str(newP7) +  ' < 0.07 ]')
    else:
        rctw.write(sock, oP7.id, newP7)
        time.sleep(1)
        nowP7 = oread(sock, oP7)
        rctw.dbglog('Set ' + oP7.name + ' from ' + str(istP7) + ' to ' + str(nowP7))
        # klappt aber dann wird pv nur noch in den Akku geladen und nicht mehr ins Haus
    


def drain1A(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    global sollcurent
    
    sollcurent = 1
    
    readold(sock)
    rctw.dbglog('Do Drain1A, Akku nicht mehr entladen')
    if istmaxDischarge != sollcurent:
        rctw.write(sock, omaxDischarge.id, sollcurent)
        time.sleep(1)
        nowmaxDischarge = oread(sock, omaxDischarge)
        rctw.dbglog('Set ' + omaxDischarge.name + ' from ' + str(istmaxDischarge) + ' to ' + str(nowmaxDischarge))
        # Klappt,  achku wird nur noch mit rund 300W Entladen (1*BatV) 
    else:
        rctw.dbglog(omaxDischarge.name + ' ' + str(istmaxDischarge) + ' Ok')


def drain(sock):
    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge
    global sollcurent
    done=0
    
    readold(sock)
    rctw.dbglog('Do Drain, Akku nicht mehr entladen')
    if istmaxDischarge != sollcurent:
        rctw.write(sock, omaxDischarge.id, sollcurent)
        time.sleep(1)
        nowmaxDischarge = oread(sock, omaxDischarge)
        rctw.dbglog('Set ' + omaxDischarge.name + ' from ' + str(istmaxDischarge) + ' to ' + str(nowmaxDischarge))
        # Klappt,  achku wird nur noch mit rund 300W Entladen (1*BatV) 
        done=1
    else:
        rctw.dbglog(omaxDischarge.name + ' ' + str(istmaxDischarge) + ' Ok')
    if( done>0):
        rctw.dbglog('Reload values')
        readold(sock)



# Entry point with parameter check
def main():

    global istP5,istP7,istPsoc,istP97,istWatt,istmaxDischarge
    global oP5,oP7,oPsoc,oP97,oWatt,omaxDischarge

    global sollwatt
    global sollcurent

    t = time.localtime()
    current_time = time.strftime("%Y-%m-%d %H:%M:%S", t)
    print(current_time)
    
    # parse command line arguments
    try:
        options, remainder = getopt.getopt(sys.argv[1:], 'c:w:a:i:vd', ['ip=','action=','current=', 'watt=' ])
    except getopt.GetoptError as err:
        # print help information and exit:
        rctw.errlog(err)  # will print something like "option -a not recognized"
        rctw.errlog('usage: ', argv[0], '[--ip_addr=<host>] [--current=20] [--watt=3000]')
        sys.exit(-1)

    rctw.host='192.168.208.63'
    action='status'
    for opt, arg in options:
        if opt in ('-c', '--current'):
            sollcurent = float(arg)
        elif opt in ('-w', '--watt'):
            sollwatt = float(arg)
        elif opt in ('-i', '--ip'):
            rctw.host = arg
        elif opt in ('-a', '--action'):
            action = arg
        elif opt in ('-v', '--verbose'):
            rctw.bVerbose = True
            rctw.dbglog('bVerbose:', rctw.bVerbose)
        elif opt in ('-d'):
            rctw.bDbg = True
            rctw.dbglog('bDbg:', rctw.bDbg)

    rctw.dbglog('action:['+ str(action)+ '] sollwatt:['+ str(sollwatt)+ '] sollcurent:['+ str(sollcurent)+']')
    if action not in actions:
        print('Illegal action [' + str(action) + ']')
        sys.exit(-1)

    rctw.init(['']);
    
    #
    # Zugriffsobjecte erzeugen auf alle Felder die wir so brachen.
    #
    oP5 = rctw.find_by_id(0xBD3A23C3)  # 0xBD3A23C3 power_mng.soc_charge   0.05000000074505806
    oP7 = rctw.find_by_id(0xCE266F0F)  # 0xCE266F0F power_mng.soc_min      0.07000000029802322
    oPsoc = rctw.find_by_id(0x959930BF)  # 0x959930BF battery.soc          0.7738908529281616 
    oP97 = rctw.find_by_id(0x97997C93)  # 0x97997C93 power_mng.soc_max     0.9700000286102295
    oWatt = rctw.find_by_id(0x1D2994EA)  # 0x1D2994EA power_mng.soc_charge_power 100.0
    omaxDischarge = rctw.find_by_id(0xC642B9D6)  # 0xC642B9D6 acc_conv.i_discharge_max                         20.0
    
    clientsocket = rctw.connect_to_server()
    if clientsocket is not None:
        if action == 'status':
            dostatus(clientsocket)
        elif action == 'reset':
            reset(clientsocket)
        elif action == 'resetwatt':
            resetwatt(clientsocket)
        elif action == 'resetcurrent':
            resetcurrent(clientsocket)
        elif action == 'xstopdrain':
            xstopdrain(clientsocket)
        elif action == 'drain1A':
            drain1A(clientsocket)
        elif action == 'drain':
            drain(clientsocket)
        elif action == 'loadbat':
            loadbat(clientsocket)
        rctw.close(clientsocket)
    sys.exit(0)


if __name__ == "__main__":
    main()
