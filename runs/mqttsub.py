#!/usr/bin/python3
import configparser
import fileinput
import re
import subprocess
import sys
import threading
import time
from datetime import datetime
from json import loads as json_loads
from json.decoder import JSONDecodeError
# import os
from pathlib import Path

import paho.mqtt.client as mqtt
# from subprocess import run


global inaction
inaction = 0
openwbconffile = "/var/www/html/openWB/openwb.conf"
config = configparser.ConfigParser()
shconfigfile = '/var/www/html/openWB/smarthome.ini'
config.read(shconfigfile)
numberOfSupportedDevices = 9    # limit number of smarthome devices
numberOfSupportedLP = 3     # limit number of LP devices, lite=3 openWB=8
lock = threading.Lock()
# RAMDISK_PATH = Path(__file__).resolve().parents[1] / "ramdisk"

#
# ############################################
#
def dolog(msg):
    timestamp = datetime.now().strftime(format="%Y-%m-%d %H:%M:%S")
    file = open('/var/www/html/openWB/ramdisk/mqtt.log', 'a')
    file.write("%s %s \n" % (timestamp, msg))
    file.close()

#
# ############################################
#
class Ramdisk:
    def __init__(self, rambase):
        self.rambase = rambase
        dolog("ramdisk %s" % (rambase))

    def write(self, name, val, debug=False):
        fn = self.rambase + '/' + name
        with open(fn, 'w') as f:
            f.write(str(val))
        if True or debug:
            dolog("  write ramdisk %s = [%s]" % (fn, val))
        return True

    def readint(self, name, defval='0', debug=False):
        fn = self.rambase + '/' + name
        try:
            with open(fn, 'r') as f:
                val = f.read().rstrip("\n")
        except Exception:
            val = defval
            dolog("ramdisk.readint %s  not found used default [%s]" % (fn, val))
            return int(val)
        if debug:
            dolog("read ramdiskI %s = [%s]" % (fn, val))
        return int(val)

    def readfloat(self, name, defval='0.0', debug=False):
        fn = self.rambase + '/' + name
        try:
            with open(fn, 'r') as f:
                val = f.read().rstrip("\n")
        except Exception:
            val = defval
            dolog("ramdisk.readfloat %s  not found used default [%s]" % (fn, val))
        else:
            if debug:
                dolog("read ramdiskF %s = [%s]" % (fn, val))
        return float(val)

    def readstr(self, name, defval='', debug=False):
        fn = self.rambase + '/' + name
        try:
            with open(fn, 'r') as f:
                val = f.read().rstrip("\n")
        except Exception:
            val = defval
            dolog("ramdisk.readstr %s  not found used default [%s]" % (fn, val))
        else:
            if debug:
                dolog("read ramdiskS %s = [%s]" % (fn, val))
        return str(val)


#
# ############################################
#
def writetoconfig(configpart, section, key, value):
    config.read(configpart)
    try:
        config.set(section, key, value)
        dolog('  set %s [%s] to [%s]' % (configpart, key, value)) 
    except Exception:
        config.add_section(section)
        config.set(section, key, value)
    with open(configpart, 'w') as f:
        config.write(f)
    try:
        ramdisk.write('reread' + str(section), '1')
    except Exception as e:
        print(str(e))


#
# ############################################
#
def replaceinconfig(changeval, newval):
    sendcommand = ["/var/www/html/openWB/runs/replaceinconfig.sh", changeval, newval]
    subprocess.run(sendcommand)
    dolog("  replaceinconfig.sh %s [%s]" % (changeval, newval))

#
# ############################################
#
def xsubprocess(xcommand):
    subprocess.run(xcommand)
    dolog("  subprocess run [%s]" % (xcommand))

#
# ############################################
#
def replaceAll(changeval, newval):
    global inaction
    if (inaction == 0):
        inaction = 1
        for line in fileinput.input(openwbconffile, inplace=1):
            if line.startswith(changeval):
                line = changeval + newval + "\n"
                dolog("  replaceAll line [%s]" % (line))
            # sys.stdout.write(line)
        time.sleep(0.1)
        inaction = 0

#
# ############################################
#
def getConfigValue(key):
    for line in fileinput.input(openwbconffile):
        if line.startswith(str(key + "=")):
            return line.split("=", 1)[1]
    return

#
# ############################################
#
def getserial():
    # Extract serial from cpuinfo file
    with open('/proc/cpuinfo', 'r') as f:
        for line in f:
            if line[0:6] == 'Serial':
                return line[10:26]
        return "0000000000000000"


#
# ############################################
#
def publish(client, topic, payload):
   dolog("  sendmqtt [%s] = [%s]" % ( topic,payload))
   client.publish(topic, payload, qos=0, retain=True)



dolog("mqttsub starting...\n")


for i in range(1,(numberOfSupportedDevices + 1)):
    try:
        confvar = config.get('smarthomedevices', 'device_configured_' + str(i))
    except Exception:
        try:
            config.set('smarthomedevices', 'device_configured_' + str(i), str(0))
        except Exception:
            config.add_section('smarthomedevices')
            config.set('smarthomedevices', 'device_configured_' + str(i), str(0))
with open(shconfigfile, 'w') as f:
    config.write(f)


#############################################


mqtt_broker_ip = "localhost"
client = mqtt.Client("openWB-mqttsub-" + getserial())

ipallowed = '^[0-9.]+$'
nameallowed = '^[a-zA-Z ]+$'
namenumballowed = '^[0-9a-zA-Z ]+$'
emailallowed = r'^([\w\.]+)([\w]+)@(\w{2,})\.(\w{2,})$'

ramdisk = Ramdisk('/var/www/html/openWB/ramdisk')

# dolog("int [%s] " %  ramdisk.readint('int'))
# dolog("int [%s] nf" %  ramdisk.readint('intx'))
# dolog("int [%s] nf" %  ramdisk.readint('intx',0))
# dolog("float [%s] " %  ramdisk.readfloat('float'))
# dolog("float [%s] " %  ramdisk.readfloat('float2'))
# dolog("float [%s] nf" %  ramdisk.readfloat('float3',0.0))
# dolog("str [%s] " %  ramdisk.readstr('str'))
# dolog("str [%s] " %  ramdisk.readstr('str', 'a'))
# dolog("str [%s] nf" %  ramdisk.readstr('str3', 'none'))


#
# ############################################
#
# connect to broker and subscribe to set topics
def on_connect(client, userdata, flags, rc):
    # subscribe to all set topics
    # client.subscribe("openWB/#", 2)
    client.subscribe("openWB/set/#", 2)
    client.subscribe("openWB/config/set/#", 2)

#
# ############################################
#
#  openWB/config/set/SmartHome/xxxxx 
def process_configSetSmarthome(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_configSetSmarthome Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/config/set/SmartHome/maxBatteryPower"):
        if (0 <= int(payload) <= 30000):
            ramdisk.write('smarthomehandlermaxbatterypower', payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/SmartHome/smartmq"):
        if (0 <= int(payload) <= 1):
            ramdisk.write('smartmq', payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/SmartHome/logLevel"):
        if (int(payload) >= 0 and int(payload) <= 2):
            ramdisk.write('smarthomehandlerloglevel', payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

#
# ############################################
#
#  openWB/config/set/SmartHome/Device/[0-9]/xxx 
def process_configSetSmarthomeDevice(client, msg):
    payload = msg.payload.decode("utf-8")
    m = re.match(r".*/Devices[s]*/(\d+)/.*", msg.topic)
    if m:
        devicenumb = int(m[1])
        # dolog("process_configSetSmarthomeDevice Topic: [%s] Message: [%s] dev[%s]" % (msg.topic, payload, devicenumb))
        if msg.topic.endswith('device_configured'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_configured_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_canSwitch'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_canSwitch_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_differentMeasurement'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_differentMeasurement_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_chan'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 6):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_chan_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_nxdacxxtype'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 2):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_nxdacxxtype_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measchan'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 6):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measchan_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_ip'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 6 and bool(re.match(ipallowed, payload))):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_ip_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_pbip'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 6 and bool(re.match(ipallowed, payload))):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_pbip_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureip'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 6 and bool(re.match(ipallowed, payload))):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureip_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_name'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 3 <= len(str(payload)) <= 12 and bool(re.match(nameallowed, payload))):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_name_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_temperatur_configured'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 3):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_temperatur_configured_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_einschaltschwelle'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and -100000 <= int(payload) <= 100000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_einschaltschwelle_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_deactivateper'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_deactivateper_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_deactivateWhileEvCharging'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 2):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_deactivateWhileEvCharging_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_ausschaltschwelle'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and -100000 <= int(payload) <= 100000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_ausschaltschwelle_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_ausschaltverzoegerung'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 10000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_ausschaltverzoegerung_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_einschaltverzoegerung'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_einschaltverzoegerung_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_updatesec'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 180):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_updatesec_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureid'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 1 <= int(payload) <= 255):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureid_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureid'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 1 <= int(payload) <= 255):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureid_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_speichersocbeforestart'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_speichersocbeforestart_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_speichersocbeforestop'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_speichersocbeforestop_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_maxeinschaltdauer'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_maxeinschaltdauer_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_mineinschaltdauer'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 100000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_mineinschaltdauer_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_einschalturl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_einschalturl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_ausschalturl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_ausschalturl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_leistungurl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_leistungurl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_stateurl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_stateurl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureurl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureurl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measurejsonurl'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measurejsonurl_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measurejsonpower'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measurejsonpower_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_username'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_username_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_password'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_password_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_actor'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_actor_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureavmusername'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureavmusername_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureavmpassword'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureavmpassword_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureavmactor'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureavmactor_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_acthorpower'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 18000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_acthorpower_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_finishTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_finishtime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_onTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_ontime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_offTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_offtime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_onuntilTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_onuntilTime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_startTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_startTime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_endTime'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and re.search(r'^([01]{0,1}\d|2[0-3]):[0-5]\d$', payload)):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_endTime_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_homeConsumtion'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_homeConsumtion_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_setauto'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_setauto_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_measurePortSdm'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 9999):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measurePortSdm_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_dacport'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 9999):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_dacport_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_startupDetection'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_startupdetection_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_standbyPower'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_standbypower_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_nonewatt'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 10000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_nonewatt_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_idmnav'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 1 <= int(payload) <= 2):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_idmnav_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_nxdacxxueb'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 32000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_nxdacxxueb_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_standbyDuration'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 86400):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_standbyduration_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_startupMulDetection'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_startupMulDetection_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_measuresmaage'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measuresmaage_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_measuresmaage'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1000):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measuresmaage_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_measuresmaser'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measuresmaser_' + str(devicenumb), payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
            else:
                dolog("invalid payload for topic '" + msg.topic + "': " + str(payload))
        elif msg.topic.endswith('device_manual_control'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                publish(client, msg.topic.replace('set/','get/'), payload)
                ramdisk.write('smarthome_device_manual_control_' + str(devicenumb), payload)
        elif msg.topic.endswith('device_measurejsoncounter'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measurejsoncounter_' + str(devicenumb), payload)
                ramdisk.write('smarthome_device_manual_control_' + str(devicenumb), payload)
        elif msg.topic.endswith('/mode'):
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and 0 <= int(payload) <= 1):
                publish(client, msg.topic.replace('set/','get/'), payload)
                ramdisk.write('smarthome_device_manual_' + str(devicenumb), payload)
        elif msg.topic.endswith('device_pbtype'):
            validDeviceTypespb = ['none', 'shellypb']
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 2):
                    try:
                        # just check vor payload in list, deviceTypeIndex is not used
                        deviceTypeIndex = validDeviceTypespb.index(payload)
                    except ValueError:
                        pass
                    else:
                        writetoconfig(shconfigfile, 'smarthomedevices', 'device_pbtype_' + str(devicenumb), payload)
                        publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_type'):
            validDeviceTypes = ['none', 'shelly', 'tasmota', 'acthor', 'lambda', 'elwa', 'idm', 'vampair', 'stiebel', 
                                'http', 'avm', 'mystrom', 'viessmann', 'mqtt', 'NXDACXX', 'ratiotherm', 'pyt']    # 'pyt' is deprecated and will be removed!
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 2):
                    try:
                        # just check vor payload in list, deviceTypeIndex is not used
                        deviceTypeIndex = validDeviceTypes.index(payload)
                    except ValueError:
                        pass
                    else:
                        writetoconfig(shconfigfile, 'smarthomedevices', 'device_type_' + str(devicenumb), payload)
                        publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureType'):
            validDeviceMeasureTypes = ['shelly', 'tasmota', 'http', 'mystrom', 'sdm630', 'lovato', 'we514', 'fronius', 'json', 'avm', 'mqtt', 'sdm120', 'smaem']   # 'pyt' is deprecated and will be removed!
            if (1 <= int(devicenumb) <= numberOfSupportedDevices and len(str(payload)) > 2):
                    try:
                        #  just check vor payload in list, deviceMeasureTypeIndex is not used
                        deviceMeasureTypeIndex = validDeviceMeasureTypes.index(payload)
                    except ValueError:
                        pass
                    else:
                        writetoconfig(shconfigfile, 'smarthomedevices', 'device_measuretype_' + str(devicenumb), payload)
                        publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('device_measureurlc'):
                if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                    if (payload == "none"):
                        # print("received message 'none'")
                        publish(client, msg.topic.replace('set/','get/'), "" )
                    else:
                        publish(client, msg.topic.replace('set/','get/'), payload)
                writetoconfig(shconfigfile, 'smarthomedevices', 'device_measureurlc_' + str(devicenumb), payload)
        elif msg.topic.endswith('device_acthortype'):
                validDeviceTypes = ['M1', 'M3', '9s', '9s18']
                if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                    try:
                        # just check vor payload in list, deviceTypeIndex is not used
                        deviceTypeIndex = validDeviceTypes.index(payload)
                    except ValueError:
                        pass
                    else:
                        publish(client, msg.topic.replace('set/','get/'), payload)
                        writetoconfig(shconfigfile, 'smarthomedevices', 'device_acthortype_' + str(devicenumb), payload)
        elif msg.topic.endswith('device_lambdaueb'):
                validTypes = ['UP', 'UN', 'UZ']
                if (1 <= int(devicenumb) <= numberOfSupportedDevices):
                    try:
                        # just check for payload in list, TypeIndex is not used
                        TypeIndex = validTypes.index(payload)
                    except ValueError:
                        pass
                    else:
                        writetoconfig(shconfigfile, 'smarthomedevices', 'device_lambdaueb_' + str(devicenumb), payload)
                        publish(client, msg.topic.replace('set/','get/'), payload)
        else:
            dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



#
# ############################################
#
#  openWB/config/set/display/xxx 
def process_configSetDisplay(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_configSetDisplay Topic: [%s] Message: [%s] " % (msg.topic, payload))
    if (msg.topic == "openWB/config/set/display/displayLight"):
        if (int(payload) >= 10 and int(payload) <= 250):
            replaceinconfig("displayLight=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
            xsubprocess(["/var/www/html/openWB/runs/displaybacklight.sh", payload])
    elif (msg.topic == "openWB/config/set/display/displaysleep"):
        if (int(payload) >= 10 and int(payload) <= 1800):
            replaceinconfig("displaysleep=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/display/displaypincode"):
        if (int(payload) >= 1000 and int(payload) <= 99999999):
            replaceinconfig("displaypincode=", payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))


#
# ############################################
#
# openWB/config/set/pv
# openWB/set/pv
def process_SetPv(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_SetPv Topic: [%s] Message: [%s]" % (msg.topic, payload))

    if (msg.topic == "openWB/config/set/pv/minFeedinPowerBeforeStart"):
        if (int(payload) >= -100000 and int(payload) <= 100000):
            replaceinconfig("mindestuberschuss=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/maxPowerConsumptionBeforeStop"):
        if (int(payload) >= -100000 and int(payload) <= 100000):
            replaceinconfig("abschaltuberschuss=", payload.decode("utf-8"))
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/stopDelay"):
        if (int(payload) >= 0 and int(payload) <= 10000):
            replaceinconfig("abschaltverzoegerung=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/startDelay"):
        if (int(payload) >= 0 and int(payload) <= 100000):
            replaceinconfig("einschaltverzoegerung=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/minCurrentMinPv"):
        if (int(payload) >= 6 and int(payload) <= 16):
            replaceinconfig("minimalampv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/maxSoc"):
        if (int(payload) >= 0 and int(payload) <= 100):
            replaceinconfig("stopchargepvpercentagelp1=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/2/maxSoc"):
        if (int(payload) >= 0 and int(payload) <= 100):
            replaceinconfig("stopchargepvpercentagelp2=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/socLimitation"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("stopchargepvatpercentlp1=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/2/socLimitation"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("stopchargepvatpercentlp2=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/minCurrent"):
        if (int(payload) >= 6 and int(payload) <= 16):
            replaceinconfig("minimalapv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/2/minCurrent"):
        if (int(payload) >= 6 and int(payload) <= 16):
            replaceinconfig("minimalalp2pv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/set/pv/1/faultState"):
        if (0 <= int(payload) <= 2):
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/set/pv/2/faultState"):
        if (0 <= int(payload) <= 2):
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/set/pv/1/faultStr"):
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/set/pv/2/faultStr"):
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/minSocAlwaysToChargeTo"):
        if (int(payload) >= 0 and int(payload) <= 80):
            replaceinconfig("minnurpvsoclp1=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/maxSocToChargeTo"):
        if (int(payload) >= 0 and int(payload) <= 101):
            replaceinconfig("maxnurpvsoclp1=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/lp/1/minSocAlwaysToChargeToCurrent"):
        if (int(payload) >= 6 and int(payload) <= 32):
            replaceinconfig("minnurpvsocll=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/chargeSubmode"):
        if (int(payload) >= 0 and int(payload) <= 2):
            replaceinconfig("pvbezugeinspeisung=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/regulationPoint"):
        if (int(payload) >= -300000 and int(payload) <= 300000):
            replaceinconfig("offsetpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/boolShowPriorityIconInTheme"):   # NC
        if (int(payload) >= 0 and int(payload) <= 1):   # NC
            replaceinconfig("speicherpvui=", payload)   # NC
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/minBatteryChargePowerAtEvPriority"):
        if (int(payload) >= 0 and int(payload) <= 90000):
            replaceinconfig("speichermaxwatt=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/minBatteryDischargeSocAtBattPriority"):
        if (int(payload) >= 0 and int(payload) <= 101):
            replaceinconfig("speichersocnurpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/batteryDischargePowerAtBattPriority"):
        if (int(payload) >= 0 and int(payload) <= 90000):
            replaceinconfig("speicherwattnurpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/batteryDischargePowerAtBattPriorityHybrid"):
        if (int(payload) >= 0 and int(payload) <= 100000):
            replaceinconfig("speicherwattnurpvhybrid=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/socStartChargeAtMinPv"):
        if (int(payload) >= 0 and int(payload) <= 101):
            replaceinconfig("speichersocminpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/socStopChargeAtMinPv"):
        if (int(payload) >= 0 and int(payload) <= 101):
            replaceinconfig("speichersochystminpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/boolAdaptiveCharging"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("adaptpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/adaptiveChargingFactor"):
        if (int(payload) >= 0 and int(payload) <= 100):
            replaceinconfig("adaptfaktor=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/nurpv70dynact"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("nurpv70dynact=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/nurpv70dynw"):
        if (int(payload) >= 2000 and int(payload) <= 50000):
            replaceinconfig("nurpv70dynw=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/pv/priorityModeEVBattery"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("speicherpveinbeziehen=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/set/pv/NurPV70Status"):
        if (int(payload) >= 0 and int(payload) <= 1):
            ramdisk.write('nurpv70dynstatus', payload)
            publish(client, msg.topic.replace('set/',''), payload)
    elif (msg.topic == "openWB/set/pv/1/kWhCounter"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
            pvkwhcounter = float(payload) * 1000
            ramdisk.write('pvkwh', str(pvkwhcounter))
    elif (msg.topic == "openWB/set/pv/WhCounter"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
            ramdisk.write('pvkwh', payload)
    elif (msg.topic == "openWB/set/pv/1/WhCounter"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
            ramdisk.write('pvkwh', payload)
    elif (msg.topic == "openWB/set/pv/1/W"):
        if (float(payload) >= -10000000 and float(payload) <= 100000000):
            if (float(payload) > 1):
                pvwatt = int(float(payload)) * -1
            else:
                pvwatt = int(float(payload))
            ramdisk.write('pvwatt', str(pvwatt))
    elif (msg.topic == "openWB/set/pv/2/kWhCounter"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
            pvkwhcounter = float(payload) * 1000
            ramdisk.write('pv2kwh', str(pvkwhcounter))
    elif (msg.topic == "openWB/set/pv/2/WhCounter"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
            ramdisk.write('pv2kwh', payload)
    elif (msg.topic == "openWB/set/pv/2/W"):
        if (float(payload) >= -10000000 and float(payload) <= 100000000):
            if (float(payload) > 1):
                pvwatt = int(float(payload)) * -1
            else:
                pvwatt = int(float(payload))
            ramdisk.write('pv2watt', str(pvwatt))
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

#
# ############################################
#
#  openWB/config/set/global/xxx 
def process_configSetGlobal(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_configSetGlobal Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/config/set/global/minEVSECurrentAllowed"):
        if (int(payload) >= 6 and int(payload) <= 32):
            replaceinconfig("minimalstromstaerke=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/global/maxEVSECurrentAllowed"):
        if (int(payload) >= 6 and int(payload) <= 32):
            replaceinconfig("maximalstromstaerke=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/global/dataProtectionAcknoledged"):
        if (int(payload) >= 0 and int(payload) <= 2):
            replaceinconfig("datenschutzack=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/global/rfidConfigured"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("rfidakt=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/global/lp/1/cpInterrupt"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("cpunterbrechunglp1=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/global/lp/2/cpInterrupt"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("cpunterbrechunglp2=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



#
# ############################################
#
#  openWB/config/set/u1p3p
def process_configsetu1p3p(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_configsetu1p3p Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/config/set/u1p3p/standbyPhases"):
        if (int(payload) >= 1 and int(payload) <= 3):
            replaceinconfig("u1p3pstandby=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/u1p3p/sofortPhases"):
        if (int(payload) >= 1 and int(payload) <= 3):
            replaceinconfig("u1p3psofort=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/u1p3p/nachtPhases"):
        if (int(payload) >= 1 and int(payload) <= 3):
            replaceinconfig("u1p3pnl=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/u1p3p/minundpvPhases"):
        if (int(payload) >= 1 and int(payload) <= 4):
            replaceinconfig("u1p3pminundpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/u1p3p/nurpvPhases"):
        if (int(payload) >= 1 and int(payload) <= 4):
            replaceinconfig("u1p3pnurpv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    elif (msg.topic == "openWB/config/set/u1p3p/isConfigured"):
        if (int(payload) >= 0 and int(payload) <= 1):
            replaceinconfig("u1p3paktiv=", payload)
            publish(client, msg.topic.replace('set/','get/'), payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



#
# ############################################
#
#  openWB/config/set/sofort/lp/[0-9]/xx
def process_configSetSofortLpNum(client, msg):
    payload = msg.payload.decode("utf-8")
    m = re.match(r".*/lp/(\d+)/.*", msg.topic)
    if m:
        devicenumb = int(m[1])
        # dolog("process_configSetSofortLpNum Topic: [%s] Message: [%s] dev[%s]" % (msg.topic, payload, devicenumb))
        if msg.topic.endswith('/current'):
            if (1 <= int(devicenumb) <= numberOfSupportedLP and 6 <= int(payload) <= 32):
                publish(client, msg.topic.replace('set/','get/'), payload)
                ramdisk.write('lp' + str(devicenumb) + 'sofortll', payload)
        elif msg.topic.endswith('energyToCharge'):
            if (1 <= devicenumb <= numberOfSupportedLP and 0 <= int(payload) <= 100):
                if (devicenumb == 1):
                    replaceinconfig("lademkwh=", payload)
                if (devicenumb == 2):
                    replaceinconfig("lademkwhs1=", payload)
                if (devicenumb == 3):
                    replaceinconfig("lademkwhs2=", payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        elif msg.topic.endswith('resetEnergyToCharge'):
            if (1 <= devicenumb <= numberOfSupportedLP and int(payload) == 1):
                if (devicenumb == 1):
                    ramdisk.write('aktgeladen', "0")
                    ramdisk.write('gelrlp1', "0")
                if (devicenumb == 2):
                    ramdisk.write('aktgeladens1', "0")
                    ramdisk.write('gelrlp2', "0")
                if (devicenumb == 3):
                    ramdisk.write('aktgeladens2', "0")
                    ramdisk.write('gelrlp3', "0")
#                if (devicenumb >= 4):
#                        f = open('/var/www/html/openWB/ramdisk/aktgeladenlp' + str(devicenumb), 'w')
#                        f.write("0")
#                        f.close()
#                        f = open('/var/www/html/openWB/ramdisk/gelrlp' + str(devicenumb), 'w')
#                        f.write("0")
#                        f.close()
        elif msg.topic.endswith('socToChargeTo'):
            if (1 <= devicenumb <= 2 and 0 <= int(payload) <= 100):
                publish(client, "openWB/config/get/sofort/lp/" + str(devicenumb) + "/socToChargeTo", payload)
                replaceinconfig( "sofortsoclp" + str(devicenumb) + "=", payload)
        elif msg.topic.endswith('etBasedCharging'):
            if (1 <= devicenumb <= 8 and 0 <= int(payload) <= 1):
                publish(client, "openWB/config/get/sofort/lp/" + str(devicenumb) + "/etBasedCharging", payload)
                xsubprocess(["/var/www/html/openWB/runs/replaceinconfig.sh", "lp" + str(devicenumb) + "etbasedcharging=", payload])
        elif msg.topic.endswith('chargeLimitation'):
            if (3 <= devicenumb <= numberOfSupportedLP and 0 <= int(payload) <= 1):
                replaceinconfig("msmoduslp" + str(devicenumb) + "=", payload)
                time.sleep(0.4)
                if (int(payload) == 1):
                    replaceinconfig("lademstatlp" + str(devicenumb) + "=", "1")
                    publish(client, "openWB/lp/" + str(devicenumb) + "/boolDirectModeChargekWh", payload)
                else:
                    replaceinconfig("lademstatlp" + str(devicenumb) + "=", "0")
                    publish(client, "openWB/lp/" + str(devicenumb) + "/boolDirectModeChargekWh", "0")
                publish(client, "openWB/config/get/sofort/lp/" + str(devicenumb) + "/chargeLimitation", payload)
        elif (msg.topic == "openWB/config/set/sofort/lp/1/chargeLimitation"):
            if (int(payload) >= 0 and int(payload) <= 2):
                replaceinconfig("msmoduslp1=", payload)
                if (payload == 1):
                    publish(client, "openWB/lp/1/boolDirectModeChargekWh", "1")
                else:
                    publish(client, "openWB/lp/1/boolDirectModeChargekWh", "0")
                if (int(payload) == 2):
                    publish(client, "openWB/lp/1/boolDirectChargeModeSoc", "1")
                else:
                    publish(client, "openWB/lp/1/boolDirectChargeModeSoc", "0")
                publish(client, "openWB/config/get/sofort/lp/1/chargeLimitation", payload)
        elif (msg.topic == "openWB/config/set/sofort/lp/2/chargeLimitation"):
            if (payload >= 0 and int(payload) <= 2):
                replaceinconfig("msmoduslp2=", payload)
                if (int(payload) == 1):
                    publish(client, "openWB/lp/2/boolDirectModeChargekWh", "1")
                else:
                    publish(client, "openWB/lp/2/boolDirectModeChargekWh", "0")
                if (int(payload) == 2):
                    publish(client, "openWB/lp/2/boolDirectChargeModeSoc", "1")
                else:
                    publish(client, "openWB/lp/2/boolDirectChargeModeSoc", "0")
                publish(client, "openWB/config/get/sofort/lp/2/chargeLimitation", payload)
        else:
            dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

#
# ############################################
#
#  openWB/set/system
def process_SetSystem(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_SetSystem Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/set/system/GetRemoteSupport"):
        if (5 <= len(payload) <= 50):
            ramdisk.write('remotetoken', payload)
            xsubprocess(["/var/www/html/openWB/runs/initremote.sh"])
    elif (msg.topic == "openWB/set/system/SimulateRFID"):
        if len(str(payload)) >= 1 and bool(re.match(namenumballowed, payload)):
            ramdisk.write('readtag', payload)
    elif (msg.topic == "openWB/set/system/PerformUpdate"):
        if (int(payload) == 1):
            publish(client, msg.topic, '0')
            setTopicCleared = True
            xsubprocess.run(["/var/www/html/openWB/runs/update.sh"])
    elif (msg.topic == "openWB/set/system/reloadDisplay"):
        dolog("******** process_SetSystem Topic: [%s] Message: [%s]" % (msg.topic, payload ))
        if ( int(payload) >= 0 and int(payload) <= 1 ):
            publish(client, msg.topic.replace('set/',''), payload)
            xsubprocess(["/var/www/html/openWB/runs/reloadDisplay.sh", payload])
    elif (msg.topic == "openWB/set/system/topicSender"):
        pass
    # elif (msg.topic == "openWB/config/set/releaseTrain"):
    elif (msg.topic == "openWB/set/system/releaseTrain"):
        if (payload == "stable17" or payload == "master" or payload == "beta" or payload.startswith("yc/")):
            replaceinconfig("releasetrain=", payload)
            # client.publish("openWB/system/releaseTrain", payload, qos=0, retain=True)
            publish(client, msg.topic.replace('set/',''), payload)
    elif (msg.topic == "openWB/set/system/debug/RequestDebugInfo"):
        if (int(payload) == 1):
            xsubprocess(["/var/www/html/openWB/runs/sendmqttdebug.sh"])
            setTopicCleared = True
    elif (msg.topic == "openWB/set/system/SendDebug"):
        if ( 20 <= len(payload) <= 1000 ):
            try:            # { "message": "asdasdasd", "email": "info@xx.de" }
                json_payload = json_loads(str(payload))
            except JSONDecodeError:
                file = open('/var/www/html/openWB/ramdisk/mqtt.log', 'a')
                file.write("payload is not valid JSON, fallback to simple text\n")
                file.close()
                payload = payload.rpartition('email: ')
                json_payload = { "message": payload[0], "email": payload[2] }
            finally:
                if (re.match(emailallowed, json_payload["email"])):
                    f = open('/var/www/html/openWB/ramdisk/debuguser', 'w')
                    f.write("%s\n%s\n" % (json_payload["message"], json_payload["email"]))
                    f.close()
                    f = open('/var/www/html/openWB/ramdisk/debugemail', 'w')
                    f.write(json_payload["email"] + "\n")
                    f.close()
                else:
                    file = open('/var/www/html/openWB/ramdisk/mqtt.log', 'a')
                    file.write("payload does not contain a valid email: '%s'\n" % (str(json_payload["email"])))
                    file.close()
                client.publish("openWB/set/system/SendDebug", "0", qos=0, retain=True)
                setTopicCleared = True
                subprocess.run("/var/www/html/openWB/runs/senddebuginit.sh")
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

#
# ############################################
#
#  openWB/set/isss
def process_SetIsss(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_SetIsss Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/set/isss/ClearRfid"):
        if (int(payload) > 0 and int(payload) <= 1):
            ramdisk.write('readtag', "0")
    elif (msg.topic == "openWB/set/isss/Current"):
        if (float(payload) >= 0 and float(payload) <= 32):
            ramdisk.write('llsoll', payload)
    elif (msg.topic == "openWB/set/isss/Lp2Current"):
        if (float(payload) >= 0 and float(payload) <= 32):
            ramdisk.write('llsolls1', payload)
    elif (msg.topic == "openWB/set/isss/U1p3p"):
        if (int(payload) >= 0 and int(payload) <= 5):
            ramdisk.write('u1p3pstat', payload)
    elif (msg.topic == "openWB/set/isss/U1p3pLp2"):
        if (int(payload) >= 0 and int(payload) <= 5):
            ramdisk.write('u1p3plp2stat', payload)
    elif (msg.topic == "openWB/set/isss/Cpulp1"):
        if (int(payload) >= 0 and int(payload) <= 5):
            ramdisk.write('extcpulp1', payload)
    elif (msg.topic == "openWB/set/isss/heartbeat"):
        if (int(payload) >= -1 and int(payload) <= 5):
            ramdisk.write('heartbeat', payload)
    elif (msg.topic == "openWB/set/isss/parentWB"):
        ramdisk.write('parentWB', payload)
        publish(client, "openWB/system/parentWB", payload)
    elif (msg.topic == "openWB/set/isss/parentCPlp1"):
        publish(client, "openWB/system/parentCPlp1", payload)
        ramdisk.write('parentCPlp1', payload)
    elif (msg.topic == "openWB/set/isss/parentCPlp2"):
        publish(client, "openWB/system/parentCPlp2", payload)
        ramdisk.write('parentCPlp2', payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



#
# ############################################
#
#  openWB/set/graph
def process_SetGraph(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_SetGraph Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/set/graph/LiveGraphDuration"):
        if (int(payload) >= 20 and int(payload) <= 120):
            replaceinconfig("livegraph=", payload)
    elif (msg.topic == "openWB/set/graph/RequestLiveGraph"):      # NC, maybe from cloud?
        if (int(payload) == 1):
            xsubprocess(["/var/www/html/openWB/runs/sendlivegraphdata.sh"])
        else:
            publish(client, "openWB/system/LiveGraphData", "empty")
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestLLiveGraph"):
        if (int(payload) == 1):
            xsubprocess(["/var/www/html/openWB/runs/sendllivegraphdata.sh"])
        else:
            client.publish("openWB/system/1alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/2alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/3alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/4alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/5alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/6alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/7alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/8alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/9alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/10alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/11alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/12alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/13alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/14alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/15alllivevalues", "empty", qos=0, retain=True)
            client.publish("openWB/system/16alllivevalues", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestDayGraph"):
        if (int(payload) >= 1 and int(payload) <= 20501231):
            xsubprocess(["/var/www/html/openWB/runs/senddaygraphdata.sh", payload])
        else:
            client.publish("openWB/system/DayGraphData1", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData2", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData3", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData4", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData5", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData6", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData7", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData8", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData9", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData10", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData11", "empty", qos=0, retain=True)
            client.publish("openWB/system/DayGraphData12", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestMonthGraph"):
        if (int(payload) >= 1 and int(payload) <= 205012):
            xsubprocess(["/var/www/html/openWB/runs/sendmonthgraphdata.sh", payload])
        else:
            client.publish("openWB/system/MonthGraphData1", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData2", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData3", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData4", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData5", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData6", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData7", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData8", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData9", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData10", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData11", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphData12", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestMonthGraphv1"):
        if (int(payload) >= 1 and int(payload) <= 205012):
            xsubprocess(["/var/www/html/openWB/runs/sendmonthgraphdatav1.sh", payload])
        else:
            client.publish("openWB/system/MonthGraphDatan1", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan2", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan3", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan4", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan5", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan6", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan7", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan8", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan9", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan10", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan11", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthGraphDatan12", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestYearGraph"):
        if (int(payload) >= 1 and int(payload) <= 2050):
            xsubprocess(["/var/www/html/openWB/runs/sendyeargraphdata.sh", payload])
        else:
            client.publish("openWB/system/YearGraphData1", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData2", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData3", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData4", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData5", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData6", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData7", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData8", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData9", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData10", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData11", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphData12", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestYearGraphv1"):
        if (int(payload) >= 1 and int(payload) <= 2050):
            xsubprocess(["/var/www/html/openWB/runs/sendyeargraphdatav1.sh", payload])
        else:
            client.publish("openWB/system/YearGraphDatan1", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan2", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan3", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan4", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan5", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan6", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan7", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan8", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan9", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan10", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan11", "empty", qos=0, retain=True)
            client.publish("openWB/system/YearGraphDatan12", "empty", qos=0, retain=True)
            setTopicCleared = True
    elif (msg.topic == "openWB/set/graph/RequestMonthLadelog"):
        if (int(payload) >= 1 and int(payload) <= 205012):
            xsubprocess(["/var/www/html/openWB/runs/sendladelog.sh", payload])
        else:
            client.publish("openWB/system/MonthLadelogData1", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData2", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData3", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData4", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData5", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData6", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData7", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData8", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData9", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData10", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData11", "empty", qos=0, retain=True)
            client.publish("openWB/system/MonthLadelogData12", "empty", qos=0, retain=True)
            setTopicCleared = True
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))


#
# ############################################
#
#  openWB/set/evu
def process_SetEvu(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_SetEvu Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/set/evu/W"):
        if (float(payload) >= -100000 and float(payload) <= 100000):
                    ramdisk.write('wattbezug', payload)
    elif (msg.topic == "openWB/set/evu/APhase1"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('bezuga1', payload)
    elif (msg.topic == "openWB/set/evu/APhase2"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('bezuga2', payload)
    elif (msg.topic == "openWB/set/evu/APhase3"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('bezuga3', payload)
    elif (msg.topic == "openWB/set/evu/VPhase1"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('evuv1', payload)
    elif (msg.topic == "openWB/set/evu/VPhase2"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('evuv2', payload)
    elif (msg.topic == "openWB/set/evu/VPhase3"):
        if (float(payload) >= -1000 and float(payload) <= 1000):
                    ramdisk.write('evuv3', payload)
    elif (msg.topic == "openWB/set/evu/HzFrequenz"):
        if (float(payload) >= 0 and float(payload) <= 80):
                    ramdisk.write('evuhz', payload)
    elif (msg.topic == "openWB/set/evu/WhImported"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
                    ramdisk.write('bezugkwh', payload)
    elif (msg.topic == "openWB/set/evu/WhExported"):
        if (float(payload) >= 0 and float(payload) <= 10000000000):
                    ramdisk.write('einspeisungkwh', payload)
    elif (msg.topic == "openWB/set/evu/faultState"):
        if (int(payload) >= 0 and int(payload) <= 9):
            publish(client, msg.topic.replace('set/',''), payload)
    elif (msg.topic == "openWB/set/evu/faultStr"):
        publish(client, msg.topic.replace('set/',''), payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

#
# ############################################
#
#  openWB/set  # der ganze rest
def process_Set(client, msg):
    payload = msg.payload.decode("utf-8")
    # dolog("process_Set Topic: [%s] Message: [%s]" % (msg.topic, payload))
    if (msg.topic == "openWB/set/hook/HookControl"):
        if (int(payload) >= 0 and int(payload) <= 30):
            hookmsg = payload
            hooknmb = hookmsg[1:2]
            hookact = hookmsg[0:1]
            xsubprocess(["/var/www/html/openWB/runs/hookcontrol.sh", hookmsg])
            publish(client, "openWB/hook/" + hooknmb + "/BoolHookStatus", hookact)
    elif (msg.topic == "openWB/set/RenewMQTT"):
        if (int(payload) == 1):
            publish(client, "openWB/set/RenewMQTT", "0")
            ramdisk.write('renewmqtt', "1")
            setTopicCleared = True
    elif (msg.topic == "openWB/set/ChargeMode"):
        if (int(payload) >= 0 and int(payload) <= 4):
            ramdisk.write('lademodus', payload)
            publish(client, "openWB/global/ChargeMode", payload)
    elif (msg.topic == "openWB/set/awattar/MaxPriceForCharging"):
        if (float(payload) >= -50.0 and float(payload) <= 95.0):
            ramdisk.write('etprovidermaxprice', payload)
    elif (msg.topic == "openWB/set/houseBattery/W"):
        if (float(payload) >= -30000 and float(payload) <= 30000):
            ramdisk.write('speicherleistung', payload)
    elif (msg.topic == "openWB/set/houseBattery/WhImported"):
        if (float(payload) >= 0 and float(payload) <= 9000000):
            ramdisk.write('speicherikwh', payload)
    elif (msg.topic == "openWB/set/houseBattery/WhExported"):
        if (float(payload) >= 0 and float(payload) <= 9000000):
            ramdisk.write('speicherekwh', payload)
    elif (msg.topic == "openWB/set/houseBattery/%Soc"):
        if (float(payload) >= 0 and float(payload) <= 100):
            ramdisk.write('speichersoc', payload)
    elif (msg.topic == "openWB/set/houseBattery/faultState"):
        if (int(payload) >= 0 and int(payload) <= 2):
            publish(client, "openWB/housebattery/faultState", payload)
    elif (msg.topic == "openWB/set/houseBattery/faultStr"):
        publish(client, "openWB/housebattery/faultStr", payload)
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



#
# ############################################
#
#  openWB/config/set/lp/[0-9]/xxx 
def process_configSetLpNum(client, msg):
    payload = msg.payload.decode("utf-8")
    m = re.match(r".*/lp/(\d+)/.*", msg.topic)
    if m:
        devicenumb = int(m[1])
        # dolog("process_configSetLpNum Topic: [%s] Message: [%s] dev[%s]" % (msg.topic, payload, devicenumb))
        if msg.topic.endswith('stopchargeafterdisc'):
            if (1 <= int(devicenumb) <= numberOfSupportedLP and 0 <= int(payload) <= 1):
                replaceinconfig( "stopchargeafterdisclp" + str(devicenumb) + "=", payload)
                publish(client, msg.topic.replace('set/','get/'), payload)
        else:
            dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))


#
# ############################################
#
#  openWB/set/lp/[0-9]/xxx 
def process_SetLpNum(client, msg):
    payload = msg.payload.decode("utf-8")
    m = re.match(r".*/lp/(\d+)/.*", msg.topic)
    if m:
        devicenumb = int(m[1])
        # dolog("process_SetLpNum Topic: [%s] Message: [%s] dev[%s]" % (msg.topic, payload, devicenumb))
        if msg.topic.endswith('ChargePointEnabled'):
            if (1 <= int(devicenumb) <= numberOfSupportedLP and 0 <= int(payload) <= 1):
                ramdisk.write('lp' + str(devicenumb) + 'enabled', payload)
                publish(client, msg.topic.replace('set/',''), payload)
        elif (msg.topic == "openWB/set/lp/1/%Soc"):
            if (float(payload) >= 0 and float(payload) <= 100):
                ramdisk.write('soc', payload)
        elif (msg.topic == "openWB/set/lp/2/%Soc"):
            if (float(payload) >= 0 and float(payload) <= 100):
                ramdisk.write('soc1', payload)
        elif (msg.topic == "openWB/set/lp/1/DirectChargeSubMode"):
            if (int(payload) == 0):
                replaceAll("lademstat=", payload)
                replaceAll("sofortsocstatlp1=", payload)
            if (int(payload) == 1):
                replaceAll("lademstat=", payload)
                replaceAll("sofortsocstatlp1=", "0")
            if (int(payload) == 2):
                replaceAll("lademstat=", "0")
                replaceAll("sofortsocstatlp1=", "1")
        elif (msg.topic == "openWB/set/lp/2/DirectChargeSubMode"):
            if (int(payload) == 0):
                replaceAll("lademstats1=", payload)
                replaceAll("sofortsocstatlp2=", payload)
            if (int(payload) == 1):
                replaceAll("lademstats1=", payload)
                replaceAll("sofortsocstatlp2=", "0")
            if (int(payload) == 2):
                replaceAll("lademstats1=", "0")
                replaceAll("sofortsocstatlp2=", "1")
        elif (msg.topic == "openWB/set/lp/3/DirectChargeSubMode"):
            if (int(payload) == 0):
                replaceAll("lademstats2=", payload)
                # replaceAll("sofortsocstatlp3=", payload)
            if (int(payload) == 1):
                replaceAll("lademstats2=", payload)
                # replaceAll("sofortsocstatlp3=", "0")
            # if (int(payload) == 2):
            #    replaceAll("lademstats2=", "0")
            #    replaceAll("sofortsocstatlp3=", "1")
        elif (msg.topic == "openWB/set/lp/1/AutolockStatus"):
            if (int(payload) >= 0 and int(payload) <= 3):
                ramdisk.write('autolockstatuslp1', payload)
                    #  values used for AutolockStatus flag:
                    #  0 = standby
                    #  1 = waiting for autolock
                    #  2 = autolock performed
                    #  3 = auto-unlock performed
                    # warum im mqtt nur bei lp1 und nicht bei lp2,3++
                publish(client, "openWB/lp/1/AutolockStatus", payload)
        elif (msg.topic == "openWB/set/lp/2/AutolockStatus"):
            if (int(payload) >= 0 and int(payload) <= 3):
                ramdisk.write('autolockstatuslp2', payload)
                publish(client, "openWB/lp/2/AutolockStatus", payload)
        elif (msg.topic == "openWB/set/lp/3/AutolockStatus"):
            if (int(payload) >= 0 and int(payload) <= 3):
                ramdisk.write('autolockstatuslp3', payload)
                publish(client, "openWB/lp/3/AutolockStatus", payload)
        elif msg.topic.endswith('ChargePointEnabled'):
            if (1 <= devicenumb <= numberOfSupportedLP and 0 <= int(payload) <= 1):  # 8
                ramdisk.write('lp' + str(devicenumb) + 'enabled', payload)
                publish(client, msg.topic.replace('set/',''), payload)
        elif msg.topic.endswith('ForceSoCUpdate'):
            if (1 <= int(devicenumb) <= 2 and int(payload) == 1):
                if (devicenumb == 1):
                    ramdisk.write('soctimer', "20005")
                elif (devicenumb == 2):
                    ramdisk.write('soctimer1', "20005")
        elif msg.topic.endswith('/manualSoc'):
            soc = int(payload)
            if 1 <= devicenumb <= 2 and 0 <= soc <= 100:
                if devicenumb == 1:
                    ramdisk.write('manual_soc_lp1', soc)
                    ramdisk.write('soc', soc)
                    ramdisk.write('manual_soc_meter_lp1', str(ramdisk.readfloat('llkwh')))
                    publish(client, "openWB/lp/1/manualSoc", soc)
                    publish(client, "openWB/lp/1/%Soc", soc)
                if devicenumb == 2:
                    ramdisk.write('manual_soc_lp2', soc)
                    ramdisk.write('soc1', soc)
                    ramdisk.write('manual_soc_meter_lp2', str(ramdisk.readfloat('llkwhs1')))
                    publish(client, "openWB/lp/2/manualSoc", soc)
                    publish(client, "openWB/lp/2/%Soc", soc)
        elif msg.topic.endswith('/faultState'):
                if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= int(payload) <= 2)):
                    publish(client, msg.topic.replace('set/',''), payload)
        elif msg.topic.endswith('/faultStr'):
                if (1 <= devicenumb <= numberOfSupportedLP):
                    publish(client, msg.topic.replace('set/',''), payload)
        elif msg.topic.endswith('socFaultState'):
                if ((1 <= devicenumb <= 2) and (0 <= int(payload) <= 2)):
                    publish(client, msg.topic.replace('set/',''), payload)
        elif msg.topic.endswith('socFaultStr'):
                if (1 <= devicenumb <= 2):
                    publish(client, msg.topic.replace('set/',''), payload)
        elif msg.topic.endswith('/socKM'):
                if (1 <= devicenumb <= numberOfSupportedLP):
                    publish(client, msg.topic.replace('set/',''), payload)
                    ramdisk.write('soc' + str(devicenumb) + 'KM', payload)
        elif msg.topic.endswith('socRange'):
                if (1 <= devicenumb <= numberOfSupportedLP):
                    publish(client, msg.topic.replace('set/',''), payload)
                    ramdisk.write('soc' + str(devicenumb) + 'Range', payload)
        elif msg.topic.endswith('/plugStat'):
                if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= int(payload) <= 1)):
                    if (devicenumb == 1):
                        ramdisk.write("plugstat", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("plugstats1", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("plugstatlp3", payload)
        elif msg.topic.endswith('/chargeStat'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= int(payload) <= 1)):
                    if (devicenumb == 1):
                        ramdisk.write("chargestat", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("chargestats1", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("chargestatlp3", payload)
        elif msg.topic.endswith('/W'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= int(payload) <= 100000)):
                    if (devicenumb == 1):
                        ramdisk.write("llaktuell", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llaktuells1", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llaktuells2", payload)
        elif msg.topic.endswith('/kWhCounter'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 10000000000)):
                    if (devicenumb == 1):
                        ramdisk.write("llkwh", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llkwhs1", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llkwhs2", payload)
        elif msg.topic.endswith('/VPhase1'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 300)):
                    if (devicenumb == 1):
                        ramdisk.write("llv1", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llv11", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llv21", payload)
        elif msg.topic.endswith('/VPhase2'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 300)):
                    if (devicenumb == 1):
                        ramdisk.write("llv2", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llvs12", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llvs22", payload)
        elif msg.topic.endswith('/VPhase3'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 300)):
                    if (devicenumb == 1):
                        ramdisk.write("llv3", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llvs13", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llvs23", payload)
        elif msg.topic.endswith('/APhase1'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 3000)):
                    if (devicenumb == 1):
                        ramdisk.write("lla1", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llas11", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llas21", payload)
        elif msg.topic.endswith('/APhase2'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 3000)):
                    if (devicenumb == 1):
                        ramdisk.write("lla2", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llas12", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llaas22", payload)
        elif msg.topic.endswith('/APhase3'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 3000)):
                    if (devicenumb == 1):
                        ramdisk.write("lla3", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llas13", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llas23", payload)
        elif msg.topic.endswith('/HzFrequenz'):
            if ((1 <= devicenumb <= numberOfSupportedLP) and (0 <= float(payload) <= 80)):
                    if (devicenumb == 1):
                        ramdisk.write("llhz", payload)
                    elif (devicenumb == 2):
                        ramdisk.write("llhzs1", payload)
                    elif (devicenumb == 3):
                        ramdisk.write("llhzs2", payload)
        else:
            dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))
    else:
        dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))



# 
# ##########################################################
# 
# handle each set topic
def on_message(client, userdata, msg):
    global numberOfSupportedDevices
    # log all messages before any error forces this process to die
    if (len(msg.payload.decode("utf-8")) >= 1):
        lock.acquire()
        try:
            setTopicCleared = False
            payload = msg.payload.decode("utf-8")
            # dolog("Topic: [%s] Message: [%s]" % (msg.topic, payload))
            
            if msg.topic.startswith(  'openWB/config/set/SmartHome/Device'):   # ok
                process_configSetSmarthomeDevice(client, msg)
            elif msg.topic.startswith('openWB/config/set/SmartHome'):  # ok
                process_configSetSmarthome(client, msg)
            elif msg.topic.startswith('openWB/config/set/lp'):
                process_configSetLpNum(client,  msg)
            elif msg.topic.startswith('openWB/config/set/sofort/lp'):
                process_configSetSofortLpNum(client,  msg)
            elif msg.topic.startswith('openWB/config/set/display'):  # ok
                process_configSetDisplay(client,  msg)
            elif msg.topic.startswith('openWB/config/set/u1p3p'):   # ok
                process_u1p3p(client,  msg)
            elif msg.topic.startswith('openWB/config/set/global'):  # ok
                process_configSetGlobal(client,  msg)
            elif msg.topic.startswith('openWB/config/set/pv'):  # ok
                process_SetPv(client,  msg)
            elif msg.topic.startswith('openWB/set/lp'):
                process_SetLpNum(client, msg)
            elif msg.topic.startswith('openWB/set/pv'):         # ok
                process_SetPv(client,  msg)
            elif msg.topic.startswith('openWB/set/system'):        # Pk
                process_SetSystem(client,  msg)
            elif msg.topic.startswith('openWB/set/isss'):          # Ok
                process_SetIsss(client,  msg)
            elif msg.topic.startswith('openWB/set/graph'):      # ok
                process_SetGraph(client,  msg)
            elif msg.topic.startswith('openWB/set/evu'):            # Ok
                process_SetEvu(client,  msg)
            elif msg.topic.startswith('openWB/set'):
                process_Set(client,  msg)
            else:
                dolog("WARNING Topic: [%s] Message: [%s] not matched" % (msg.topic, payload))

            # clear all set topics if not already done
            if (not(setTopicCleared)):
                # dolog('AutoClean (2): ' + str(msg.topic))
                client.publish(msg.topic, "", qos=2, retain=True)

        finally:
            lock.release()


client.on_connect = on_connect
client.on_message = on_message

client.connect(mqtt_broker_ip, 1883)
client.loop_forever()
client.disconnect()

# "openWB/set/pv/1/kWhCounter " --> 'pvkwh'
# "openWB/set/pv/1/WhCounter"     > 'pvkwh'
# "openWB/set/pv/1/W"             > 'pvwatt'
# "openWB/set/pv/2/kWhCounter"    > 'pvkwh'
# "openWB/set/pv/2/WhCounter"     > 'pv2kwh'
# "openWB/set/pv/2/W"             > 'pv2watt'
# openWB/set/system/topicSender

