#!/usr/bin/python3
import sys
import os
import time
import json
from os import path
from datetime import datetime, timedelta

import urllib.request
from typing import Any
import logging
from smarthome.smartlog import initlog, initMainlog
from smarthome.smartret import writeret
import helpermodules.log


def totalPowerFromShellyJson(answer: Any, workchan: int) -> int:
    if (workchan == 0):
        if 'meters' in answer:
            meters = answer['meters']   # shelly
        else:
            meters = answer['emeters']  # shellyEM & shelly3EM
        total = 0
        # shellyEM has one meter, shelly3EM has three meters:
        for meter in meters:
            total = total + meter['power']
        return int(total)
    workchan = workchan - 1
    try:
        total = int(answer['meters'][workchan]['power'])   # Abfrage shelly
    except Exception:
        total = int(answer['emeters'][workchan]['power'])  # Abfrage shellyEM
    return int(total)


named_tuple = time.localtime()   # getstruct_time
time_string = time.strftime("%m/%d/%Y, %H:%M:%S shelly watty.py", named_tuple)
devicenumber = int(sys.argv[1])
# initlog('Shelly',devicenumber)
# log = logging.getLogger("Shelly")
initMainlog()
mlog = logging.getLogger('smarthome.shelly.watt')

initlog("shelly", devicenumber)
log = logging.getLogger("shelly.watt")

ipadr = str(sys.argv[2])
uberschuss = int(sys.argv[3])
try:
    chan = int(sys.argv[4])
except Exception:
    chan = 0
# chan = 0 alle Meter, Kan 0
# chan = 1 meter 1, Kan 0
# chan = 2 meter 2, kan 1
shaut = int(sys.argv[5])
user = str(sys.argv[6])
pw = str(sys.argv[7])


# Setze Default-Werte, andernfalls wird der letzte Wert ewig fortgeschrieben.
# Insbesondere wichtig für aktuelle Leistung
# Zähler wird beim Neustart auf 0 gesetzt, darf daher nicht übergeben werden.
powerc = 0
temp0 = '0.0'
temp1 = '0.0'
temp2 = '0.0'
aktpower = 0
relais = 0
gen = '1'
model = '???'
profile='triphase'

log.info("......Shelly watt " + str(ipadr) )

# lesen endpoint, gen bestimmem. gen 1 hat unter Umstaenden keinen Eintrag
fbase = '/var/www/html/openWB/ramdisk/smarthome_device_ret.'
fname = fbase + str(ipadr) + '_shelly_info'
fnameg = fbase + str(ipadr) + '_shelly_infogv1'

if os.path.isfile(fnameg):
    with open(fnameg, 'r') as f:
        jsonin = json.loads(f.read())
        gen = str(jsonin['gen'])
        model = str(jsonin['model'])
        log.info(['cached ', gen,model])
        profile = str(jsonin['profile'])
else:
    url = "http://" + str(ipadr) + "/shelly"
    log.info('get info and infogv1 for ip ' + str(ipadr) )
    aread = urllib.request.urlopen(url, timeout=3).read().decode("utf-8")
    agen = json.loads(str(aread))
    log.info(['cachede written'])
    with open(fname, 'w') as f:
        json.dump(agen, f)
    if 'gen' in agen:
        gen = str(int(agen['gen']))
    if 'model' in agen:
        model = str(agen['model'])
    elif 'type' in agen:
        model = str(agen['type'])
    if 'profile' in agen:
        profile = str(agen['profile'])
    else:        
        profile = 'none'

    jsontype = {"gen": str(gen), "model": str(model), "profile": str(profile) }
    with open(fnameg, 'w') as f:
        f.write(json.dumps(jsontype))

fn='/var/www/html/openWB/ramdisk/smarthome_device_ret.' + str(ipadr) + '_shelly'
log.info('ip' + str(ipadr) + ' devicenummer:' + str(devicenumber) + ' chan:' + str(chan) + ' GEN:' + str(gen) + ' profile:' + str(profile)  )
log.info('device file is ' + str(fn) )


refresh=0
if os.path.isfile(fn):
    two_secs_ago = datetime.now() - timedelta(seconds=3)
    filetime = datetime.fromtimestamp(path.getctime(fn))
    if filetime < two_secs_ago:
        log.info("device File is more than 3 secs old, refresh" )
        refresh=1
else:
        log.info("device File not found, refresh")
        refresh=1
answer=''
if refresh==1:
    # Versuche Daten von Shelly abzurufen.
    try:
        # print(str(shaut) + user + pw)
        if (gen == "1"):
            url = "http://" + str(ipadr) + "/status"
            if (shaut == 1):
                passman = urllib.request.HTTPPasswordMgrWithDefaultRealm()
                passman.add_password(None, url, user, pw)
                authhandler = urllib.request.HTTPBasicAuthHandler(passman)
                opener = urllib.request.build_opener(authhandler)
                urllib.request.install_opener(opener)

            log.info(['read gen1', url])
            with urllib.request.urlopen(url, timeout=4) as response:
                aread = response.read().decode("utf-8")
            answer = json.loads(str(aread))
            with open(fn, 'w') as f:
                f.write(str(aread))
            log.info(str(url)) 
            log.info("device file refreshed " + str(len(aread)) )
        else:
            url = "http://"+str(ipadr) + "/rpc/Shelly.GetStatus"
            log.info(['read gen2', url])
            aread = urllib.request.urlopen(url, timeout=3).read().decode("utf-8")
            answer = json.loads(str(aread))
            with open(fn, 'w') as f:
                f.write(str(aread))
            log.info(str(url)) 
            log.info("device file refreshed " + str(len(aread))) 
    except Exception as e1:
        log.info("watt.py ERROR failed to connect to device on " + ipadr)
        log.info(str(e1) )
        log.info("use cached device file1 ") 
        try:
            with open(fn, 'r') as f:
                answer=json.loads(f.read()) 
        except Exception as e1:
            log.info("watt.py ERROR failed to connect to device on " + ipadr)
            log.info(str(e1) )
            answer='{}';
            pass
        pass
else:
        log.info("use cached device file ") 
        with open(fn, 'r') as f:
                answer=json.loads(f.read()) 

log.info(['answer1 len:', len(answer)])
#  Versuche Werte aus der Antwort zu extrahieren.
try:
    if (gen == "1"):
        aktpower = totalPowerFromShellyJson(answer, chan)
    elif (gen == "2"):
#        if (chan > 0):
#            workchan = chan - 1
#        else:
        workchan = chan
        sw = 'switch:' + str(workchan)
        if ("SPEM-003CE" in model):
            if profile=='triphase':
                if (workchan == 1):
                    aktpower = int(answer['em:0']['a_act_power'])
                    powerc = int(answer['emdata:0']['a_total_act_energy'])
                elif (workchan == 2):
                    aktpower = int(answer['em:0']['b_act_power'])
                    powerc = int(answer['emdata:0']['b_total_act_energy'])
                elif (workchan == 3):
                    aktpower = int(answer['em:0']['c_act_power'])
                    powerc = int(answer['emdata:0']['c_total_act_energy'])
                else:
                    aktpower = int(answer['em:0']['total_act_power'])
                    powerc = int(answer['emdata:0']['total_act'])
            else:
                if (workchan == 1):
                    aktpower = int(answer['em1:0']['act_power'])
                    powerc = int(answer['em1data:0']['total_act_energy'])
                elif (workchan == 2):
                    aktpower = int(answer['em1:1']['act_power'])
                    powerc = int(answer['em1data:1']['total_act_energy'])
                elif (workchan == 3):
                    aktpower = int(answer['em1:2']['act_power'])
                    powerc = int(answer['em1data:2']['total_act_energy'])
                else:
                    aktpower = 0
                    powerc = 0

        elif ("PM-001PCEU16" in model):
            #   "SNPM-001PCEU16" (gen 2) und "S3PM-001PCEU16" (gen 3)
            aktpower = int(answer['pm1:0']['apower'])
        else:
            aktpower = int(answer[sw]['apower'])
    else:
        log.info("not GEN1/2")
        aktpower = 0 
        
except Exception as e1:
    log.info( str(e1) )
    # pass

try:
    if (chan > 0):
        workchan = chan - 1
    else:
        workchan = chan
    if (gen == "1"):
        relais = int(answer['relays'][workchan]['ison'])
    else:
        # shelly pro 3em mit add on hat fix id 100 als switch Kanal, das Device muss auf jeden fall mit separater
        # Leistunsmessung erfasst werden, da die Leistung auf drei verschieden Kanäle angeliefert werden kann
        if ("SPEM-003CE" in model):
            workchan = 100
        sw = 'switch:' + str(workchan)
        relais = int(answer[sw]['output'])
except Exception:
    pass

try:
    if gen == "1":
        temp0 = str(answer['ext_temperature']['0']['tC'])
    else:
        temp0 = str(answer['temperature:100']['tC'])
except Exception:
    pass

try:
    if gen == "1":
        temp1 = str(answer['ext_temperature']['1']['tC'])
    else:
        temp1 = str(answer['temperature:101']['tC'])
except Exception:
    pass

try:
    if gen == "1":
        temp2 = str(answer['ext_temperature']['2']['tC'])
    else:
        temp2 = str(answer['temperature:102']['tC'])
except Exception:
    pass
answer = '{"power":' + str(aktpower) + ',"powerc":' + str(powerc)
answer += ',"on":' + str(relais) + ',"temp0":' + str(temp0)
answer += ',"temp1":' + str(temp1) + ',"temp2":' + str(temp2) + '}'
writeret(answer, devicenumber)
log.info( "Device:" + str(devicenumber) + " Watt:" + str(aktpower) + " Wh:" + str(powerc) )
time.sleep(0.2)
log.info('......')
