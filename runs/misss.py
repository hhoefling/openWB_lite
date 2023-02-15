#!/usr/bin/python3
import json
# import re
import os
import sys
import time
import struct
import traceback
from typing import Tuple

# Ausgelagert damit myisss.* auf logging zugreifen kann
from myisss.mylog import log_debug, read_from_ramdisk, write_to_ramdisk
# import RPi.GPIO as GPIO
# from pymodbus.client.sync import ModbusSerialClient
from myisss.mygpio import GPIO
from myisss.mymodbus import ModbusSerialClient
from myisss.mymodbus import lp1_00, lp1_02, lp1_04, lp1_06, lp1_08, lp1_0A, lp1_0C, lp1_0E, lp1_10, lp1_156, lp1_46
from myisss.mymodbus import lp2_00, lp2_02, lp2_04, lp2_06, lp2_08, lp2_0A, lp2_0C, lp2_0E, lp2_10, lp2_156
from myisss.mymodbus import evse1_1000, evse1_1002, evse2_1000, evse2_1002
import paho.mqtt.client as mqtt

# Globale values als Dictionary
# sys.getsizeof(myDict)   ->288 # Größe von myDict
DeviceValues = {}       # last to mqtt mclient geschriebene Werte
Values = {}
G_isss = 0
G_isss_mode = "none"
G_isss_32 = 32


G_sdmid = 0
# G_sdm2id = 106
G_metercounter = 0

G_mqttsub = None

def init_gpio() -> None:
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(37, GPIO.OUT)
    GPIO.setup(13, GPIO.OUT)
    GPIO.setup(22, GPIO.OUT)
    GPIO.setup(29, GPIO.OUT)
    GPIO.setup(11, GPIO.OUT)
    GPIO.setup(15, GPIO.OUT)
    # GPIOs for socket
    GPIO.setup(23, GPIO.OUT)
    GPIO.setup(26, GPIO.OUT)
    GPIO.setup(19, GPIO.IN, pull_up_down=GPIO.PUD_UP)


def init_values() -> None:
    global DeviceValues
    global Values
    global modbusvalues
    
    # global values
    DeviceValues.update({'rfidtag': str(5)})
    # values LP1
    DeviceValues.update({'lp1voltage1': str(5)})
    DeviceValues.update({'lp1voltage2': str(5)})
    DeviceValues.update({'lp1voltage3': str(5)})
    DeviceValues.update({'lp1lla1': str(5)})
    DeviceValues.update({'lp1lla2': str(5)})
    DeviceValues.update({'lp1lla3': str(5)})
    DeviceValues.update({'lp1llkwh': str(5)})
    DeviceValues.update({'lp1watt': str(5)})
    DeviceValues.update({'lp1countphasesinuse': str(5)})
    DeviceValues.update({'lp1chargestat': str(5)})
    DeviceValues.update({'lp1plugstat': str(5)})
    DeviceValues.update({'lp1readerror': str(0)})
    Values.update({'lp1plugstat': str(5)})
    Values.update({'lp1chargestat': str(5)})
    Values.update({'lp1evsell': str(1)})
    # values LP2
    DeviceValues.update({'lp2voltage1': str(5)})
    DeviceValues.update({'lp2voltage2': str(5)})
    DeviceValues.update({'lp2voltage3': str(5)})
    DeviceValues.update({'lp2lla1': str(5)})
    DeviceValues.update({'lp2lla2': str(5)})
    DeviceValues.update({'lp2lla3': str(5)})
    DeviceValues.update({'lp2llkwh': str(5)})
    DeviceValues.update({'lp2watt': str(5)})
    DeviceValues.update({'lp2countphasesinuse': str(5)})
    DeviceValues.update({'lp2chargestat': str(5)})
    DeviceValues.update({'lp2plugstat': str(5)})
    DeviceValues.update({'lp2readerror': str(0)})
    Values.update({'lp2plugstat': str(5)})
    Values.update({'lp2chargestat': str(5)})
    Values.update({'lp2evsell': str(1)})





    

# read all meter values and publish to mqtt broker
def read_meter():

    global G_metercounter
    global evsefailure
    global modbusclient
    global G_isss_mode   # lp2installed
    global G_sdmid
    # global G_sdm2id
    global lp1countphasesinuse
    global lp2countphasesinuse
    global lp1evsehres
    global lp2evsehres
    global rfidtag

    if G_metercounter > 0:
        G_metercounter = G_metercounter - 0.5
        
    if G_sdmid == 0:
        log_debug(2, "Erkenne verbauten Zaehler2. SDM")
        try:
            voltage = mbusclient.read_input_registers(0x00, 2, unit=105)
            if int(voltage) > 20:
                G_sdmid = 105
                log_debug(2, "SDM Zaehler erkannt")
        except Exception:
            pass
    
    if G_sdmid == 0:
        log_debug(2, "Erkenne verbauten Zaehler1. B23")
        try:
            voltage = mbusclient.read_holding_registers(0x5B00, 2, unit=201)
            if int(voltage) > 20:
                G_sdmid = 201
                log_debug(2, "B23 Zaehler erkannt")
        except Exception:
            pass
            
    if G_sdmid == 0:
        log_debug(2, "Kein Zaehler1 erkannt")
        return
        
    log_debug(2, "Zaehler1 id " + str(G_sdmid))
        

    lp1llw1 = mbusclient.readvalue(lp1_0C)
    lp1llw1 = int(lp1llw1)

    lp1llw2 = mbusclient.readvalue(lp1_0E)
    lp1llw2 = int(lp1llw2)
    
    lp1llw3 = mbusclient.readvalue(lp1_10)
    lp1llw3 = int(lp1llw3)
    lp1llg = lp1llw1 + lp1llw2 + lp1llw3
    if lp1llg < 10:
        lp1llg = 0
    write_to_ramdisk("llaktuell", str(lp1llg))

    voltage = float(mbusclient.readvalue(lp1_00))
    lp1voltage1 = float("%.1f" % voltage)
    write_to_ramdisk("llv1", str(lp1voltage1))
    voltage = float(mbusclient.readvalue(lp1_02))
    lp1voltage2 = float("%.1f" % voltage)
    write_to_ramdisk("llv2", str(lp1voltage2))
    voltage = float(mbusclient.readvalue(lp1_04))
    lp1voltage3 = float("%.1f" % voltage)
    write_to_ramdisk("llv3", str(lp1voltage3))
    
    lp1lla1 = float(mbusclient.readvalue(lp1_06))
    lp1lla1 = float("%.1f" % lp1lla1)
    write_to_ramdisk("lla1", str(lp1lla1))
    lp1lla2 = float(mbusclient.readvalue(lp1_08))
    lp1lla2 = float("%.1f" % lp1lla2)
    write_to_ramdisk("lla2", str(lp1lla2))
    lp1lla3 = float(mbusclient.readvalue(lp1_0A))
    lp1lla3 = float("%.1f" % lp1lla3)
    write_to_ramdisk("lla3", str(lp1lla3))
    
    lp1llkwh = float(mbusclient.readvalue(lp1_156))
    lp1llkwh = float("%.3f" % lp1llkwh)
    write_to_ramdisk("llkwh", str(lp1llkwh))
    
    hz = float(mbusclient.readvalue(lp1_46))
    hz = float("%.2f" % hz)
    write_to_ramdisk("llhz", str(hz))
    
    try:
        if lp1lla1 > 3:
            lp1countphasesinuse = 1
        if lp1lla2 > 3:
            lp1countphasesinuse = 2
        if lp1lla3 > 3:
            lp1countphasesinuse = 3
    except Exception:
        lp1countphasesinuse = 1

        
    try:

        if G_isss_mode == "duo":
            try:
                time.sleep(0.1)
                lp2llw1 = mbusclient.readvalue(lp2_0C)
                lp2llw1 = int(lp2llw1)
                lp2llw2 = mbusclient.readvalue(lp2_0E)
                lp2llw2 = int(lp2llw2)
                lp2llw3 = mbusclient.readvalue(lp2_10)
                lp2llw3 = int(lp2llw3)
                lp2llg = lp2llw1 + lp2llw2 + lp2llw3
                if lp2llg < 10:
                    lp2llg = 0
                write_to_ramdisk("llaktuells1", str(lp2llg))
                voltage = float(mbusclient.readvalue(lp2_00))
                lp2voltage1 = float("%.1f" % voltage)
                write_to_ramdisk("llvs11", str(lp2voltage1))
                voltage = float(mbusclient.readvalue(lp2_02))
                lp2voltage2 = float("%.1f" % voltage)
                write_to_ramdisk("llvs12", str(lp2voltage2))
                voltage = float(mbusclient.readvalue(lp2_04))
                lp2voltage3 = float("%.1f" % voltage)
                write_to_ramdisk("llvs13", str(lp2voltage3))
                lp2lla1 = float(mbusclient.readvalue(lp2_06))
                lp2lla1 = float("%.1f" % lp2lla1)
                write_to_ramdisk("llas11", str(lp2lla1))
                lp2lla2 = float(mbusclient.readvalue(lp2_08))
                lp2lla2 = float("%.1f" % lp2lla2)
                write_to_ramdisk("llas12", str(lp2lla2))
                lp2lla3 = float(mbusclient.readvalue(lp2_0A))
                lp2lla3 = float("%.1f" % lp2lla3)
                write_to_ramdisk("llas13", str(lp2lla3))
                lp2llkwh = float(mbusclient.readvalue(lp2_156))
                lp2llkwh = float("%.3f" % lp2llkwh)
                write_to_ramdisk("llkwhs1", str(lp2llkwh))
                try:
                    if lp2lla1 > 3:
                        lp2countphasesinuse = 1
                    if lp2lla2 > 3:
                        lp2countphasesinuse = 2
                    if lp2lla3 > 3:
                        lp2countphasesinuse = 3
                except Exception:
                    lp2countphasesinuse = 1
                try:
                    time.sleep(0.1)
                    lp2ll = mbusclient.readvalue(evse2_1000)
                except Exception:
                    lp2ll = 0
                try:
                    time.sleep(0.1)
                    lp2var = mbusclient.readvalue(evse2_1002)
                    DeviceValues.update({'lp2readerror': str(0)})
                except Exception:
                    DeviceValues.update({'lp2readerror': str(int(DeviceValues['lp2readerror']) + 1)})
                    log_debug(2, "Fehler!", traceback.format_exc())
                    lp2var = 5
                if (lp2var == 5 and int(DeviceValues['lp2readerror']) > MaxEvseError):
                    log_debug(2, "Anhaltender Fehler beim Auslesen der EVSE von lp2! ("
                              + str(DeviceValues['lp2readerror']) + ")")
                    log_debug(2, "Plugstat und Chargestat werden zurückgesetzt.")
                    Values.update({'lp2plugstat': 0})
                    Values.update({'lp2chargestat': 0})
                elif lp2var == 1:
                    Values.update({'lp2plugstat': 0})
                    Values.update({'lp2chargestat': 0})
                elif lp2var == 2:
                    Values.update({'lp2plugstat': 1})
                    Values.update({'lp2chargestat': 0})
                elif (lp2var == 3 and lp2ll > 0):
                    Values.update({'lp2plugstat': 1})
                    Values.update({'lp2chargestat': 1})
                elif (lp2var == 3 and lp2ll == 0):
                    Values.update({'lp2plugstat': 1})
                    Values.update({'lp2chargestat': 0})
                write_to_ramdisk("plugstats1", str(Values["lp2plugstat"]))
                write_to_ramdisk("chargestats1", str(Values["lp2chargestat"]))
                Values.update({'lp2evsell': lp2ll})
                log_debug(0, "EVSE lp2plugstat: " + str(lp2var) + " EVSE lp2LL: " + str(lp2ll))
            except Exception:
                pass

        try:
            time.sleep(0.1)
            lp1ll = mbusclient.readvalue(evse1_1000)
            evsefailure = 0
        except Exception:
            lp1ll = 0
            evsefailure = 1
        try:
            time.sleep(0.1)
            lp1var = mbusclient.readvalue(evse1_1002)
            evsefailure = 0
            DeviceValues.update({'lp1readerror': str(0)})
        except Exception:
            DeviceValues.update({'lp1readerror': str(int(DeviceValues['lp1readerror']) + 1)})
            log_debug(2, "Fehler!", traceback.format_exc())
            lp1var = 5
            evsefailure = 1
        if (lp1var == 5 and int(DeviceValues['lp1readerror']) > MaxEvseError):
            log_debug(2, "Anhaltender Fehler beim Auslesen der EVSE von lp1! ("
                      + str(DeviceValues['lp1readerror']) + ")")
            log_debug(2, "Plugstat und Chargestat werden zurückgesetzt.")
            Values.update({'lp1plugstat': 0})
            Values.update({'lp1chargestat': 0})
        elif lp1var == 1:
            Values.update({'lp1plugstat': 0})
            Values.update({'lp1chargestat': 0})
        elif lp1var == 2:
            Values.update({'lp1plugstat': 1})
            Values.update({'lp1chargestat': 0})
        elif (lp1var == 3 and lp1ll > 0):
            Values.update({'lp1plugstat': 1})
            Values.update({'lp1chargestat': 1})
        elif (lp1var == 3 and lp1ll == 0):
            Values.update({'lp1plugstat': 1})
            Values.update({'lp1chargestat': 0})
        write_to_ramdisk("plugstat", str(Values["lp1plugstat"]))
        write_to_ramdisk("chargestat", str(Values["lp1chargestat"]))
        Values.update({'lp1evsell': lp1ll})
        log_debug(0, "EVSE lp1plugstat: " + str(lp1var) + " EVSE lp1LL: " + str(lp1ll))
        try:
            rfidtag = read_from_ramdisk("readtag")
        except Exception:
            pass
            
        log_debug( 2 , '######## '+str(G_isss) )    
        if G_isss == 1:
        # check for parent openWB
        try:
            parentWB = read_from_ramdisk("parentWB")
            parentWB = parentWB.strip() 
            parentCPlp1 = read_from_ramdisk("parentCPlp1").strip()
            # parentCPlp1 = str(int(re.sub(r'\D', '', read_from_ramdisk("parentCPlp1"))))
            parentCPlp2 = '0'
                if G_isss_mode == "duo":
                parentCPlp2 = read_from_ramdisk("parentCPlp2").strip()
        except Exception:
            log_debug(2, "Failed to get infos about parent wb! Setting default values.")
            parentWB = str("0")
            parentCPlp1 = str("0")
            parentCPlp2 = str("0")

        log_debug(2, "parentWB:[" + parentWB + '] parentCPlp1:[' + parentCPlp1 + '] parentCPlp2:[' + parentCPlp2 + ']')
        else:
            parentWB = str("0")
            parentCPlp1 = str("0")
            parentCPlp2 = str("0")

        if parentWB != "0":
            remoteclient = mqtt.Client("openWB-isss-bulkpublisher-" + str(os.getpid()))
            remoteclient.connect(str(parentWB))
            remoteclient.loop(timeout=2.0)
        mclient = mqtt.Client("openWB-isss-bulkpublisher-" + str(os.getpid()))
        mclient.connect("localhost")
        mclient.loop(timeout=2.0)
        for key in DeviceValues:
            if "lp1watt" in key:
                if DeviceValues[str(key)] != str(lp1llg):
                    mclient.publish("openWB/lp/1/W", payload=str(lp1llg), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1watt': str(lp1llg)})
                if parentWB != "0":
                    # 1.9
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/W", payload=str(lp1llg), qos=0, retain=True)
                    # 2.0
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/power", payload=str(lp1llg), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)
            if "lp1voltage1" in key:
                if DeviceValues[str(key)] != str(lp1voltage1):
                    mclient.publish("openWB/lp/1/VPhase1", payload=str(lp1voltage1), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1voltage1': str(lp1voltage1)})
                if parentWB != "0":
                    # 1.9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/Vphase1", payload=str(lp1voltage1), qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/voltages", payload="["
                                         + str(lp1voltage1) + "," + str(lp1voltage2) + "," + str(lp1voltage3) + "]",
                                         qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)
            if "lp1voltage2" in key:
                if DeviceValues[str(key)] != str(lp1voltage2):
                    mclient.publish("openWB/lp/1/VPhase2", payload=str(lp1voltage2), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1voltage2': str(lp1voltage2)})
            if "lp1voltage3" in key:
                if DeviceValues[str(key)] != str(lp1voltage3):
                    mclient.publish("openWB/lp/1/VPhase3", payload=str(lp1voltage3), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1voltage3': str(lp1voltage3)})
            if "lp1lla1" in key:
                if DeviceValues[str(key)] != str(lp1lla1):
                    mclient.publish("openWB/lp/1/APhase1", payload=str(lp1lla1), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1lla1': str(lp1lla1)})
                if parentWB != "0":
                    # 1.9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/Aphase1", payload=str(lp1lla1), qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/currents",
                                         payload="[" + str(lp1lla1) + "," + str(lp1lla2) + "," + str(lp1lla3) + "]",
                                         qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if "lp1lla2" in key:
                if DeviceValues[str(key)] != str(lp1lla2):
                    mclient.publish("openWB/lp/1/APhase2", payload=str(lp1lla2), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1lla2': str(lp1lla2)})
                if parentWB != "0":
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/Aphase2", payload=str(lp1lla2), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if "lp1lla3" in key:
                if DeviceValues[str(key)] != str(lp1lla3):
                    mclient.publish("openWB/lp/1/APhase3", payload=str(lp1lla3), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1lla3': str(lp1lla3)})
                if parentWB != "0":
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/Aphase3", payload=str(lp1lla3), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if "lp1countphasesinuse" in key:
                if DeviceValues[str(key)] != str(lp1countphasesinuse):
                    mclient.publish("openWB/lp/1/countPhasesInUse", payload=str(lp1countphasesinuse),
                                    qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1countphasesinuse': str(lp1countphasesinuse)})
                if parentWB != "0":
                    # 1.9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/countPhasesInUse", payload=str(lp1countphasesinuse), qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/phases_in_use", payload=str(lp1countphasesinuse), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)
            if "lp1llkwh" in key:
                if DeviceValues[str(key)] != str(lp1llkwh):
                    mclient.publish("openWB/lp/1/kWhCounter", payload=str(lp1llkwh), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1llkwh': str(lp1llkwh)})
                if parentWB != "0":
                    # 1.9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/kWhCounter", payload=str(lp1llkwh), qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/imported", payload=str(lp1llkwh * 1000), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if "lp1plugstat" in key:
                if DeviceValues[str(key)] != Values["lp1plugstat"]:
                    mclient.publish("openWB/lp/1/boolPlugStat", payload=Values["lp1plugstat"], qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    if int(Values["lp1plugstat"]) == "1":
                        write_to_ramdisk("pluggedin", str(Values["lp1plugstat"]))
                    DeviceValues.update({'lp1plugstat': Values["lp1plugstat"]})
                if parentWB != "0":
                    # 1,9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/boolPlugStat", payload=Values["lp1plugstat"], qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/plug_state", payload=Values["lp1plugstat"], qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if "lp1chargestat" in key:
                if DeviceValues[str(key)] != Values["lp1chargestat"]:
                    mclient.publish("openWB/lp/1/boolChargeStat", payload=Values["lp1chargestat"], qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'lp1chargestat': Values["lp1chargestat"]})
                if parentWB != "0":
                    # 1.9 
                    remoteclient.publish("openWB/lp/" + parentCPlp1 + "/boolChargeStat", payload=Values["lp1chargestat"], qos=0, retain=True)
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/charge_state", payload=Values["lp1chargestat"], qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)
            if "rfidtag" in key:
                if DeviceValues[str(key)] != str(rfidtag):
                    mclient.publish("openWB/lp/1/LastScannedRfidTag", payload=str(rfidtag), qos=0, retain=True)
                    mclient.loop(timeout=2.0)
                    DeviceValues.update({'rfidtag': str(rfidtag)})
                if parentWB != "0":
                    if rfidtag == '0\n':
                        rfidtag = None  # default value for 2.0 is None, not "0"
                    # 2.0 
                    remoteclient.publish("openWB/set/chargepoint/" + parentCPlp1 + "/get/rfid", payload=json.dumps(rfidtag), qos=0, retain=True)
                    remoteclient.loop(timeout=2.0)

            if G_isss_mode == "duo":
                if "lp2countphasesinuse" in key:
                    if DeviceValues[str(key)] != str(lp2countphasesinuse):
                        mclient.publish("openWB/lp/2/countPhasesInUse", payload=str(lp2countphasesinuse), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2countphasesinuse': str(lp2countphasesinuse)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/countPhasesInUse", payload=str(lp2countphasesinuse), qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/phases_in_use", payload=str(lp2countphasesinuse), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)
                if "lp2watt" in key:
                    if DeviceValues[str(key)] != str(lp2llg):
                        mclient.publish("openWB/lp/2/W", payload=str(lp2llg), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2watt': str(lp2llg)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/W", payload=str(lp2llg), qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/power", payload=str(lp2llg), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)
                if "lp2voltage1" in key:
                    if DeviceValues[str(key)] != str(lp2voltage1):
                        mclient.publish("openWB/lp/2/VPhase1", payload=str(lp2voltage1), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2voltage1': str(lp2voltage1)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Vphase1", payload=str(lp2voltage1), qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/voltages",
                                             payload="[" + str(lp2voltage1) + "," + str(lp2voltage2) + "," + str(lp2voltage3) + "]",
                                             qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)
                if "lp2voltage2" in key:
                    if DeviceValues[str(key)] != str(lp2voltage2):
                        mclient.publish("openWB/lp/2/VPhase2", payload=str(lp2voltage2), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2voltage2': str(lp2voltage2)})
                    if parentWB != "0":
                        # 1.9
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Vphase2", payload=str(lp2voltage2), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2voltage3" in key:
                    if DeviceValues[str(key)] != str(lp2voltage3):
                        mclient.publish("openWB/lp/2/VPhase3", payload=str(lp2voltage3), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2voltage3': str(lp2voltage3)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Vphase3", payload=str(lp2voltage3), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2lla1" in key:
                    if DeviceValues[str(key)] != str(lp2lla1):
                        mclient.publish("openWB/lp/2/APhase1", payload=str(lp2lla1), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2lla1': str(lp2lla1)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Aphase1", payload=str(lp2lla1), qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/currents",
                                             payload="[" + str(lp2lla1) + "," + str(lp2lla2) + "," + str(lp2lla3) + "]",
                                             qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2lla2" in key:
                    if DeviceValues[str(key)] != str(lp2lla2):
                        mclient.publish("openWB/lp/2/APhase2", payload=str(lp2lla2), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2lla2': str(lp2lla2)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Aphase2", payload=str(lp2lla2), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2lla3" in key:
                    if DeviceValues[str(key)] != str(lp2lla3):
                        mclient.publish("openWB/lp/2/APhase3", payload=str(lp2lla3), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2lla3': str(lp2lla3)})
                    if parentWB != "0":
                        #  1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/Aphase3", payload=str(lp2lla3), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2llkwh" in key:
                    if DeviceValues[str(key)] != str(lp2llkwh):
                        mclient.publish("openWB/lp/2/kWhCounter", payload=str(lp2llkwh), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2llkwh': str(lp2llkwh)})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/kWhCounter", payload=str(lp2llkwh), qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/imported", payload=str(lp2llkwh * 1000), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)
                if "lp2plugstat" in key:
                    if DeviceValues[str(key)] != Values["lp2plugstat"]:
                        mclient.publish("openWB/lp/2/boolPlugStat", payload=Values["lp2plugstat"], qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2plugstat': Values["lp2plugstat"]})
                        if (int(Values["lp2plugstat"]) == "1"):
                            write_to_ramdisk("pluggedin", str(Values["lp2plugstat"]))
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/boolPlugStat", payload=Values["lp2plugstat"], qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/plug_state", payload=Values["lp2plugstat"], qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "lp2chargestat" in key:
                    if DeviceValues[str(key)] != Values["lp2chargestat"]:
                        mclient.publish("openWB/lp/2/boolChargeStat", payload=Values["lp2chargestat"],
                                        qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'lp2chargestat': Values["lp2chargestat"]})
                    if parentWB != "0":
                        # 1.9 
                        remoteclient.publish("openWB/lp/" + parentCPlp2 + "/boolChargeStat", payload=Values["lp2chargestat"], qos=0, retain=True)
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/charge_state", payload=Values["lp2chargestat"], qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)

                if "rfidtag" in key:
                    if DeviceValues[str(key)] != str(rfidtag):
                        mclient.publish("openWB/lp/2/LastScannedRfidTag", payload=str(rfidtag), qos=0, retain=True)
                        mclient.loop(timeout=2.0)
                        DeviceValues.update({'rfidtag': str(rfidtag)})
                    if parentWB != "0":
                        if rfidtag == '0\n':
                            rfidtag = None  # default value for 2.0 is None, not "0"
                        # 2.0 
                        remoteclient.publish("openWB/set/chargepoint/" + parentCPlp2 + "/get/rfid", payload=json.dumps(rfidtag), qos=0, retain=True)
                        remoteclient.loop(timeout=2.0)
        mclient.disconnect()
        if parentWB != "0":
            remoteclient.disconnect()
    except Exception:
        G_metercounter = G_metercounter + 1
        if G_metercounter > 5:
            log_debug(2, "Get meter Fehler!", traceback.format_exc())


# control of socket lock
# GPIO 23: control direction of lock motor
# GPIO 26: power to lock motor
def set_socket_actuator(action: str):
    global actcooldown
    global actcooldowntimestamp

    if actcooldown < 10:
        if action == "auf":
            GPIO.output(23, GPIO.LOW)
            GPIO.output(26, GPIO.HIGH)
            time.sleep(2)
            GPIO.output(26, GPIO.LOW)
            log_debug(1, "Aktor auf")
        if action == "zu":
            GPIO.output(23, GPIO.HIGH)
            GPIO.output(26, GPIO.HIGH)
            time.sleep(3)
            GPIO.output(26, GPIO.LOW)
            log_debug(1, "Aktor zu")
    else:
        log_debug(2, "Cooldown für Aktor aktiv.")
        if actcooldowntimestamp < 50:
            actcooldowntimestamp = int(time.time())
            log_debug(1, "Beginne 5 Minuten Cooldown für Aktor")
            write_to_ramdisk("lastregelungaktiv",
                             "Cooldown für Aktor der Verriegelung erforderlich. Steckt der Stecker richtig?")
    actcooldown = actcooldown + 1


# get actual socket lock state
def get_socket_state() -> int:
    actorstat_tmp = GPIO.input(19)
    if actorstat_tmp == GPIO.LOW:
        return 1
    else:
        return 0


# get all values to control our chargepoints
def load_control_values():
    global actorstat
    global lp1solla
    global u1p3pstat
    global u1p3plp2stat
    global u1p3ptmpstat
    global u1p3plp2tmpstat
    global evsefailure
#    global lp2installed
    global G_isss_mode
    global G_isss
    global heartbeat
    global actcooldown
    global actcooldowntimestamp
    global lp1evsehres
    global lp2evsehres

    try:
        if lp1evsehres == 0:
            lp1solla = int(float(read_from_ramdisk("llsoll")))
        else:
            lp1solla = int(float(read_from_ramdisk("llsoll")) * 100)
    except (FileNotFoundError, ValueError):
        log_debug(2, "Error reading configured current! Using default '0'.")
        lp1solla = 0
        
    if G_isss == 1:        
    try:
        heartbeat = int(read_from_ramdisk("heartbeat"))
        if heartbeat > 80:
            lp1solla = 0
            log_debug(2, "Heartbeat Fehler seit " + str(heartbeat) + "Sekunden keine Verbindung, Stoppe Ladung.")
    except (FileNotFoundError, ValueError):
        log_debug(2, "Error reading heartbeat! Using default '0'.")
        heartbeat = 0
                
    log_debug(0, "LL Soll: " + str(lp1solla) )
    if G_socket_configured:
        log_debug(0, "ActorStatus: " + str(actorstat))
        actorstat = get_socket_state()
        log_debug(1, "in Buchse " + str(evsefailure) + " lp1plugstat:" + str(Values["lp1plugstat"]))
        if actcooldowntimestamp > 50:
            tst = actcooldowntimestamp + 300
            if tst < int(time.time()):
                actcooldowntimestamp = 0
                actcooldown = 0
                log_debug(1, "Cooldown für Aktor zurückgesetzt")
            else:
                timeleft = tst - int(time.time())
                log_debug(1, str(timeleft) + " Sekunden Cooldown für Aktor verbleiben.")

        if evsefailure == 0:
            log_debug(1, "need to control actor? actorstat=" + str(actorstat)
                      + " plugstat=" + str(Values["lp1plugstat"]))
            if Values["lp1plugstat"] == 1:
                if actorstat == 0:
                    set_socket_actuator("zu")
            if Values["lp1plugstat"] == 0:
                if actorstat == 1:
                    writelp1evse(0)
                    set_socket_actuator("auf")
            if actorstat == 1:
                if Values["lp1evsell"] != lp1solla and Values["lp1plugstat"] == 1:
                    writelp1evse(lp1solla)
            else:
                if Values["lp1evsell"] != 0:
                    writelp1evse(0)
    else:
        if Values["lp1evsell"] != lp1solla:
            writelp1evse(lp1solla)
    if G_isss_mode == "duo":
        try:
            if lp2evsehres == 0:
                lp2solla = int(float(read_from_ramdisk("llsolls1")))
            else:
                lp2solla = int(float(read_from_ramdisk("llsolls1")) * 100)
        except (FileNotFoundError, ValueError):
            log_debug(2, "Error reading configured current for cp 2! Using default '0'.")
            lp2solla = 0
        log_debug(0, "LL lp2 Soll: " + str(lp2solla))
        if Values["lp2evsell"] != lp2solla:
            writelp2evse(lp2solla)
    try:
        u1p3ptmpstat = int(read_from_ramdisk("u1p3pstat"))
    except (FileNotFoundError, ValueError):
        log_debug(2, "Error reading used phases! Using default '3'.")
        u1p3ptmpstat = 3
    try:
        u1p3pstat
    except Exception:
        u1p3pstat = 3
    u1p3pstat = switch_phases_cp1(u1p3ptmpstat, u1p3pstat)
    writelp1evse(lp1solla)
    if G_isss_mode == "duo":
        try:
            u1p3plp2tmpstat = int(read_from_ramdisk("u1p3plp2stat"))
        except (FileNotFoundError, ValueError):
            log_debug(2, "Error reading used phases for cp 2! Using default '3'.")
            u1p3plp2tmpstat = 3
        try:
            u1p3plp2stat
        except Exception:
            u1p3plp2stat = 3
        if u1p3plp2stat != u1p3plp2tmpstat:
            log_debug(1, "Umschaltung erfolgt auf " + str(u1p3plp2tmpstat) + " Phasen an Lp2")
            writelp2evse(0)
            time.sleep(1)
            u1p3plp2stat = switch_phases_cp2(u1p3plp2tmpstat, u1p3plp2stat)
            writelp2evse(lp2solla)


def __switch_phases(gpio_cp: int, gpio_relay: int):
    GPIO.output(gpio_cp, GPIO.HIGH)  # CP on
    GPIO.output(gpio_relay, GPIO.HIGH)  # 3 on/off
    time.sleep(2)
    GPIO.output(gpio_relay, GPIO.LOW)  # 3 on/off
    time.sleep(5)
    GPIO.output(gpio_cp, GPIO.LOW)  # CP off
    time.sleep(1)


def switch_phases_cp1(new_phases: int, old_phases: int) -> int:
    if (new_phases != old_phases):
        log_debug(1, "switching phases on cp1: old=" + str(old_phases) + " new=" + str(new_phases))
        gpio_cp = 22
        if (new_phases == 1):
            gpio_relay = 29
        else:
            gpio_relay = 37
        __switch_phases(gpio_cp, gpio_relay)
    else:
        log_debug(0, "no need to switch phases on cp1: old=" + str(old_phases) + " new=" + str(new_phases))
    return new_phases


def switch_phases_cp2(new_phases: int, old_phases: int) -> int:
    if (new_phases != old_phases):
        log_debug(1, "switching phases on cp2: old=" + str(old_phases) + " new=" + str(new_phases))
        gpio_cp = 15
        if (new_phases == 1):
            gpio_relay = 11
        else:
            gpio_relay = 13
        __switch_phases(gpio_cp, gpio_relay)
    else:
        log_debug(0, "no need to switch phases on cp2: old=" + str(old_phases) + " new=" + str(new_phases))
    return new_phases


def writelp1evse(lla):
    if lp1evsehres == 1:
        mpp = G_pp * 100
        if lla > mpp:
            lla = mpp
    else:
        if lla > G_pp:
            lla = G_pp
    try:
        log_debug(1, "Write to EVSE lp1 " + str(lla))
        mbusclient.write_registers(1000, lla, unit=1)
        mclient.publish("openSim/evse1/1000", str(lla), qos=0, retain=True)
    except Exception:
        log_debug(2, "FAILED Write to EVSE lp1 " + str(lla), traceback.format_exc())


def writelp2evse(lla):
    try:
        log_debug(1, "Write to EVSE lp2 " + str(lla))
        mbusclient.write_registers(1000, lla, unit=2)
        mclient.publish("openSim/evse2/1000", str(lla), qos=0, retain=True)
    except Exception:
        log_debug(2, "FAILED Write to EVSE lp2 " + str(lla), traceback.format_exc())


# check for "openWB Buchse"
def NC_check_for_socket() -> Tuple[bool, int]:
    try:
        with open('/home/pi/ppbuchse', 'r') as value:
            pp_value = int(value.read())
            socket_is_configured = True
    except (FileNotFoundError, ValueError):
        pp_value = 32
        socket_is_configured = False
    log_debug(1, "check for socket: " + str(socket_is_configured) + " " + str(pp_value))
    return [socket_is_configured, pp_value]


# guess USB/modbus device name
def detect_modbus_usb_port() -> str:
    try:
        with open("/dev/ttyUSB0"):
            return "/dev/ttyUSB0"
    except FileNotFoundError:
        return "/dev/serial0"


log_debug(1, "###### main start #######")

G_isss = int(sys.argv[1])  # 1 wenn "nur ladepunkt" als mit parent.pflic5 + heartbeat
G_isss_mode = sys.argv[2]
G_isss_32 = int(sys.argv[3])
log_debug(1, "main start with isss:" + str(G_isss) + " " + str(G_isss_mode) + " " + str(G_isss_32))

MaxEvseError = 5
actorstat = 0
evsefailure = 0

lp1evsehres = 0
lp2evsehres = 0
lp1solla = 0
u1p3pstat = None
u1p3plp2stat = None
u1p3ptmpstat = 3
u1p3plp2tmpstat = 3
rfidtag = 0
lp1countphasesinuse = 1
lp2countphasesinuse = 2
heartbeat = 0
actcooldown = 0
actcooldowntimestamp = 0

log_debug(1, "init gpio")
init_gpio()
log_debug(1, "init values")
init_values()

log_debug(1, "sock")
G_socket_configured = int( G_isss_mode == "socket")
G_pp = G_isss_32

log_debug(1, "seradd")
seradd = detect_modbus_usb_port()

# connect to broker and subscribe to set topics
def on_connect(client, userdata, flags, rc):
    #subscribe to all set topics
    #client.subscribe("openWB/#", 2)
    mclient.subscribe("openWB/set/isss/#", 2)
    mclient.subscribe("openSim/#", 2)

# handle each set topic
def on_message(client, userdata, msg):
    # log all messages before any error forces this process to die
    if (len(msg.payload.decode("utf-8")) >= 1):
        payload=msg.payload.decode("utf-8")
        #lock.acquire()
        log_debug(2,"MClient.Topic: [%s] Message: [%s]" % (msg.topic, payload ) )
        t = msg.topic.replace("openSim/","")
        mbusclient.writevalue(t, payload)

# ReInit-Loop
mainloops=0
while True:
    mainloops=20
    log_debug( 2, "##############################################");
    log_debug( 2, "######## Topic ##############################");
    log_debug( 2, "connect modbus device");
    
    mclient = mqtt.Client("openWB-isss-subscripter-" + str(os.getpid()))
    mclient.on_connect = on_connect
    mclient.on_message = on_message
    mclient.connect("localhost", 1883)
    mclient.loop_start()
      
    mbusclient = ModbusSerialClient(method="rtu", port=seradd, baudrate=9600, stopbits=1, bytesize=8, timeout=1)
    with mbusclient:
    log_debug(1, "modbusclient createt.")
    # start our control loop
        while mainloops>0:
            log_debug(1, "Main Loop..." + str(mainloops))
            mclient.publish("openSim/ticker", str(mainloops), qos=0, retain=True)
        read_meter()
            load_control_values()
        time.sleep(1)
            mclient.loop()
            mainloops = mainloops - 1
        mbusclient.close()
        mclient.loop_stop() 
        mclient.disconnect()
    log_debug(2, "mainloops abgelaufen, reinit")            
# ##### END ####