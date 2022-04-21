#!/usr/bin/python3

from subprocess import run
import os
import sys
import subprocess
import time
import fileinput
from datetime import datetime
import configparser
import re
import threading
import platform
import paho.mqtt.client as mqtt




############################################
def getserial():
############################################
    # Extract serial from cpuinfo file
    with open('/proc/cpuinfo','r') as f:
        for line in f:
            if line[0:6] == 'Serial':
                return line[10:26]
        return "0000000000000000"


############################################
def creation_date(path_to_file):
############################################
    """
    Try to get the date that a file was created, falling back to when it was
    last modified if that isn't possible.
    See http://stackoverflow.com/a/39501288/1709587 for explanation.
    """
    if platform.system() == 'Windows':
        return os.path.getctime(path_to_file)
    else:
        stat = os.stat(path_to_file)
        try:
            return stat.st_birthtime
        except AttributeError:
            # We're probably on Linux. No easy way to get creation dates here,
            # so we'll settle for when its content was last modified.
            return stat.st_mtime
            




############################################
class Configfile:
############################################
	lastread = ""
	clines = []
	cf=""

	def __init__(self,fn):
		self.cf=fn
		print('Configfile:', self.cf)
		
	
	def read(self):
		f=open(self.cf,"r")
		self.clines=f.readlines()
		f.close()
		self.lastread = creation_date(self.cf)
		print(len(self.clines) , ' Lines read at ', self.lastread )

	def readval(self,key):
		for line in self.clines:
			if line.startswith(str(key+"=")):
				return (line.split("=", 1)[1]).strip()
		return

	def haschanged(self):
		self.new=creation_date(self.cf)
		if self.lastread !=self.new:
			print('File is old, read new')
			return True
		#print('CFile not changed', self.new, ' ' , self.lastread)
		return False


############################################
############################################
############################################

print('los gehts.')

innerloop=True
outerloop=True
modules=[]
C = Configfile('/var/www/html/openWB/openwb.conf')


def getmodules():
	global modules 
	# check if any module is mqtt
	print(  'ev:' , C.readval('evsecon'))
	modules=[]
	if C.readval('evsecon') == 'mqttevse':
		modules.append('ev1')
	if C.readval('ladeleistungmodul') == 'mqttll':
		modules.append('evll1')
	if C.readval('socmodul') == 'soc_mqtt':
		modules.append('evsoc1')

	if C.readval('lastmanagement') == "1":
		if C.readval('evsecons1') == 'mqttevse':
			modules.append('ev2')
		if C.readval('ladeleistungs1modul') == 'mqttlllp2':
			modules.append('evll2')
		if C.readval('socmodul') == 'soc_mqtts1':
			modules.append('evsoc2')

	if C.readval('wattbezugmodul') == 'bezug_mqtt':
		modules.append('evu')  
	if C.readval('pvwattmodul') == 'wr_mqtt':
		modules.append('pv')   
	if C.readval('speichermodul') == 'speicher_mqtt':
		modules.append('bat')  


srcsolltokens=[]
def getsolltokens():
	global srcsolltokens
	srcsolltokens=[]
	srcsolltokens.append(['openWB/system/Timestamp',	'openWB/system/Timestamp'] ) 
	if 'ev1' in modules:
		srcsolltokens.append(['openWB/lp/1/boolPlugStat',	'openWB/set/lp/1/plugStat'] ) 
		srcsolltokens.append(['openWB/lp/1/boolChargeStat',	'openWB/set/lp/1/chargeStat'] ) 
	if 'ev2' in modules:
		srcsolltokens.append(['openWB/lp/2/boolPlugStat',	'openWB/set/lp/2/plugStat'] ) 
		srcsolltokens.append(['openWB/lp/2/boolChargeStat',	'openWB/set/lp/2/chargeStat'] ) 
	if 'evll1' in modules:
		srcsolltokens.append(['openWB/lp/1/ChargePointEnabled', 'openWB/set/lp/1/ChargePointEnabled'] ) 
		srcsolltokens.append(['openWB/lp/1/W', 			'openWB/set/lp/1/W'] ) 
		srcsolltokens.append(['openWB/lp/1/kWhCounter',	'openWB/set/lp/1/kWhCounter'] ) 
		srcsolltokens.append(['openWB/lp/1/VPhase1',   	'openWB/set/lp/1/VPhase1'] ) 
		srcsolltokens.append(['openWB/lp/1/VPhase2',   	'openWB/set/lp/1/VPhase2'] ) 
		srcsolltokens.append(['openWB/lp/1/VPhase3',   	'openWB/set/lp/1/VPhase3'] ) 
		srcsolltokens.append(['openWB/lp/1/APhase1',   	'openWB/set/lp/1/APhase1'] ) 
		srcsolltokens.append(['openWB/lp/1/APhase2',   	'openWB/set/lp/1/APhase2'] ) 
		srcsolltokens.append(['openWB/lp/1/APhase3',   	'openWB/set/lp/1/APhase3'] )
		srcsolltokens.append(['openWB/lp/1/HzFrequenz',	'openWB/set/lp/1/HzFrequenz'] )
	if 'evll2' in modules:
		srcsolltokens.append(['openWB/lp/2/ChargePointEnabled', 'openWB/set/lp/2/ChargePointEnabled'] ) 
		srcsolltokens.append(['openWB/lp/2/W', 			'openWB/set/lp/2/W'] ) 
		srcsolltokens.append(['openWB/lp/2/kWhCounter',	'openWB/set/lp/2/kWhCounter'] ) 
		srcsolltokens.append(['openWB/lp/2/VPhase1',   	'openWB/set/lp/2/VPhase1'] ) 
		srcsolltokens.append(['openWB/lp/2/VPhase2',   	'openWB/set/lp/2/VPhase2'] ) 
		srcsolltokens.append(['openWB/lp/2/VPhase3',   	'openWB/set/lp/2/VPhase3'] ) 
		srcsolltokens.append(['openWB/lp/2/APhase1',   	'openWB/set/lp/2/APhase1'] ) 
		srcsolltokens.append(['openWB/lp/2/APhase2',   	'openWB/set/lp/2/APhase2'] ) 
		srcsolltokens.append(['openWB/lp/2/APhase3',   	'openWB/set/lp/2/APhase3'] )
	if 'evu' in modules:
		srcsolltokens.append(['openWB/evu/W', 	   	  'openWB/set/evu/W'] ) 
		srcsolltokens.append(['openWB/evu/VPhase1',   'openWB/set/evu/VPhase1'] ) 
		srcsolltokens.append(['openWB/evu/VPhase2',   'openWB/set/evu/VPhase2'] ) 
		srcsolltokens.append(['openWB/evu/VPhase3',   'openWB/set/evu/VPhase3'] ) 
		srcsolltokens.append(['openWB/evu/APhase1',   'openWB/set/evu/APhase1'] ) 
		srcsolltokens.append(['openWB/evu/APhase2',   'openWB/set/evu/APhase2'] ) 
		srcsolltokens.append(['openWB/evu/APhase3',   'openWB/set/evu/APhase3'] )
		srcsolltokens.append(['openWB/evu/Hz',        'openWB/set/evu/HzFrequenz'] )
		srcsolltokens.append(['openWB/evu/WhImported','openWB/set/evu/WhImported'] )
		srcsolltokens.append(['openWB/evu/WhExported','openWB/set/evu/WhExported'] )
	if 'pv' in modules:
		srcsolltokens.append(['openWB/pv/W',  'openWB/set/pv/W'])
		srcsolltokens.append(['openWB/pv/WhCounter',  'openWB/set/pv/WhCounter'])
		srcsolltokens.append(['openWB/pv/1/WhCounter',  'openWB/set/pv/1/WhCounter'])
		srcsolltokens.append(['openWB/pv/DailyYieldKwh',  'openWB/pv/DailyYieldKwh'])
		srcsolltokens.append(['openWB/pv/MonthlyYieldKwh',  'openWB/pv/MonthlyYieldKwh'])
		srcsolltokens.append(['openWB/pv/YearlyYieldKwh',  'openWB/pv/YearlyYieldKwh'])
	if 'bat' in modules:
		srcsolltokens.append(['openWB/housebattery/WhImported', 'openWB/set/houseBattery/WhImported'])
		srcsolltokens.append(['openWB/housebattery/WhExported', 'openWB/set/houseBattery/WhExported'])
		srcsolltokens.append(['openWB/housebattery/%Soc',       'openWB/set/houseBattery/%Soc'])
		srcsolltokens.append(['openWB/housebattery/soctarget',  'openWB/housebattery/soctarget'])
		srcsolltokens.append(['openWB/housebattery/faultState', 'openWB/set/houseBattery/faultState'])
		srcsolltokens.append(['openWB/housebattery/faultStr',   'openWB/set/houseBattery/faultStr'])
		srcsolltokens.append(['openWB/housebattery/W',          'openWB/set/houseBattery/W'])
	if 'evsoc1' in modules:
		srcsolltokens.append(['openWB/lp/1/%Soc', 		  'openWB/set/lp/1/%Soc'] )
		srcsolltokens.append(['openWB/lp/1/socKM', 		  'openWB/set/lp/1/socKM'] )
	if 'evsoc2' in modules:
		srcsolltokens.append(['openWB/lp/2/%Soc', 		  'openWB/set/lp/2/%Soc'] )
		srcsolltokens.append(['openWB/lp/2/socKM', 		  'openWB/set/lp/2/socKM'] )




def on_subdisconnect(client,userdata,rc):
	print("DisConnected result code "+str(rc))
	client.loop_stop()




pubclient=mqtt.Client(clean_session=True)
subclient=mqtt.Client(clean_session=True)


# connect to broker and subscribe to set topics
def on_subconnect(client, userdata, flags, rc):
	global srcsolltokens
	if rc == 0:
		print('connected')
	else:
		print('error on connect')
	for s in srcsolltokens:
		client.subscribe(s[0], 0)

def handled(src, dst):
    global pubclient,topic,payload
    if ( src in topic ):
       #print (time.ctime() + ': ' , topic, '=[', payload, '] -> handled ->',dst)
       print (time.ctime() + ': ' , topic, '=[', payload, '] -> handled')
       pubclient.publish(dst, payload, qos=0, retain=True)
       return True
    else:
       return False


# handle each set topic
def on_submessage(client, userdata, msg):
    # log all messages before any error forces this process to die
    global C, innerloop, pubclient,topic,payload
    topic=(str(msg.topic))
    payload=str(msg.payload.decode("utf-8"))
   # print ('['+topic+']=[', payload,']')
    
    if handled("Timestamp","openWB/system/Timestamp_master"):
       pubclient.loop(timeout=2.0)
       if C.haschanged():
          innerloop=False
    #
    #  LP1 Module
    #
    elif  handled("openWB/lp/1/boolPlugStat","openWB/set/lp/1/plugStat"):
       pubclient.loop(timeout=2.0)
    elif handled("openWB/lp/1/boolChargeStat","openWB/set/lp/1/chargeStat"):
       pubclient.loop(timeout=2.0)
    elif  handled("openWB/lp/2/boolPlugStat","openWB/set/lp/2/plugStat"):
       pubclient.loop(timeout=2.0)
    elif handled("openWB/lp/2/boolChargeStat","openWB/set/lp/2/chargeStat"):
       pubclient.loop(timeout=2.0)
    #
    # LP1 Ladeleistung
    #
    elif handled("openWB/lp/1/VPhase1","openWB/set/lp/1/VPhase1"):
       pubclient.loop(timeout=2.0)
    elif  handled("openWB/lp/1/VPhase2","openWB/set/lp/1/VPhase2"):
       pubclient.loop(timeout=2.0)
    elif  handled("openWB/lp/1/VPhase3","openWB/set/lp/1/VPhase3"):
       pubclient.loop(timeout=2.0)
    elif handled("openWB/lp/1/APhase1","openWB/set/lp/1/APhase1"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/APhase2" ,"openWB/set/lp/1/APhase2"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/APhase3" ,"openWB/set/lp/1/APhase3"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/W" ,"openWB/set/lp/1/W"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/kWhCounter" ,"openWB/set/lp/1/kWhCounter"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/ChargePointEnabled" ,"openWB/set/lp/1/ChargePointEnabled"):
       pubclient.loop(timeout=2.0)
    elif ( "openWB/lp/1/HzFrequenz" in msg.topic) and (float(msg.payload) >= 0 and float(msg.payload) <= 80):
          print (time.ctime() + ': ', topic, ' ', payload, ' -> publish to ramdisk')
          f = open('/var/www/html/openWB/ramdisk/llhz', 'w')
          f.write(msg.payload.decode("utf-8"))
          f.close()
    # LP12Ladeleistung
    #
    elif handled("openWB/lp/2/VPhase1","openWB/set/lp/2/VPhase1"):
       pubclient.loop(timeout=2.0)
    elif  handled("openWB/lp/2/VPhase2","openWB/set/lp/2/VPhase2"):
       pubclient.loop(timeout=2.0)
    elif  handled("openWB/lp/2/VPhase3","openWB/set/lp/2/VPhase3"):
       pubclient.loop(timeout=2.0)
    elif handled("openWB/lp/2/APhase1","openWB/set/lp/2/APhase1"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/APhase2" ,"openWB/set/lp/2/APhase2"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/APhase3" ,"openWB/set/lp/2/APhase3"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/W" ,"openWB/set/lp/2/W"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/kWhCounter" ,"openWB/set/lp/2/kWhCounter"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/ChargePointEnabled" ,"openWB/set/lp/2/ChargePointEnabled"):
       pubclient.loop(timeout=2.0)
    #
    # LP1/LP2  SOC
    #
    elif handled( "openWB/lp/1/%Soc"  ,"openWB/set/lp/1/%Soc"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/1/socKM" ,"openWB/set/lp/1/socKM"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/%Soc"  ,"openWB/set/lp/2/%Soc"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/lp/2/socKM" ,"openWB/set/lp/2/socKM"):
       pubclient.loop(timeout=2.0)
       
    #
    # Speicher
    #
    elif handled( "openWB/housebattery/WhImported" ,"openWB/set/houseBattery/WhImported" ):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/WhExported" ,"openWB/set/houseBattery/WhExported"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/%Soc" ,"openWB/set/houseBattery/%Soc"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/soctarget" ,"openWB/housebattery/soctarget"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/faultState" ,"openWB/set/houseBattery/faultState"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/faultStr" , "openWB/set/houseBattery/faultStr"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/housebattery/W" , "openWB/set/houseBattery/W"):
       pubclient.loop(timeout=2.0)
    #
    # PV Module
    # openWB/set/pv/1/W PV-Leistung in Watt, int, negativ
    # openWB/set/pv/1/WhCounter Erzeugte Energie in Wh, float, nur positiv 
    #
    #
    elif handled( "openWB/pv/WhCounter" ,"openWB/set/pv/WhCounter"):
       pubclient.publish("openWB/pv/WhCounter", payload, qos=0, retain=True)
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/pv/1/WhCounter","openWB/set/pv/1/WhCounter"):
       pubclient.loop(timeout=2.0)
    elif ( "openWB/pv/W" in msg.topic):
       if (float(msg.payload) >= -10000000 and float(msg.payload) <= 100000000):
         if (float(msg.payload) > 1):
             pvwatt=int(float(msg.payload.decode("utf-8"))) * -1
         else:
             pvwatt=int(float(msg.payload.decode("utf-8")))
         #pubclient.publish("openWB/pv/W", msg.payload.decode("utf-8"), qos=0, retain=True)
         pubclient.publish("openWB/set/pv/1/W",  str(pvwatt), qos=0, retain=True)
         pubclient.loop(timeout=2.0)
         print (time.ctime() + ': ', topic, ' ', payload, ' -> handled as:', str(pvwatt) )
         
    elif (topic == "openWB/pv/MonthlyYieldKwh"):
        if (float(msg.payload) >= 0 and float(msg.payload) <= 10000000000):
            f = open('/var/www/html/openWB/ramdisk/monthly_pvkwhk', 'w')
            f.write(str(payload))
            f.close()
            pubclient.publish(topic,  str(payload), qos=0, retain=True)
            pubclient.loop(timeout=2.0)
            print (time.ctime() + ': ', topic, ' ', payload, ' -> handled mqtt & Ramdisk' )
    elif (msg.topic == "openWB/pv/YearlyYieldKwh"):
        if (float(msg.payload) >= 0 and float(msg.payload) <= 10000000000):
            f = open('/var/www/html/openWB/ramdisk/yearly_pvkwhk', 'w')
            f.write(str(payload))
            f.close()
            pubclient.publish(topic,  str(payload), qos=0, retain=True)
            pubclient.loop(timeout=2.0)
            print (time.ctime() + ': ', topic, ' ', payload, ' -> handled mqtt & Ramdisk' )
    #
    # EVU  Module
    #
    elif handled( "openWB/evu/VPhase1","openWB/set/evu/VPhase1"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/VPhase2","openWB/set/evu/VPhase2"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/VPhase3" ,"openWB/set/evu/VPhase3"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/APhase1" ,"openWB/set/evu/APhase1"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/APhase2" ,"openWB/set/evu/APhase2"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/APhase3" ,"openWB/set/evu/APhase3"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/Hz" , "openWB/set/evu/HzFrequenz"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/WhImported" ,"openWB/set/evu/WhImported"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/WhExported","openWB/set/evu/WhExported"):
       pubclient.loop(timeout=2.0)
    elif handled( "openWB/evu/W","openWB/set/evu/W"):
       pubclient.loop(timeout=2.0)
    else:
        print (time.ctime() + ': ' , topic, '=[', payload, '] ***** not assigned')
    sys.stdout.flush()


subclient.on_connect = on_subconnect
subclient.on_message = on_submessage
subclient.on_disconnect = on_subdisconnect


def main():

	global innerloop
	global outerloop
	outerloop=True
	while outerloop:
		C.read()
		srcip=C.readval('mqtt_pullerip')
		print('src ip:' , srcip)
		getmodules()
		getsolltokens()
		print('activ mqtt modules:' , modules)
		#for s in srcsolltokens: 
		#	print('srcsolltokens:' , s)
		#
		print('outerloop open connections')
		subclient.connect(srcip, 1883, 60 )
		pubclient.connect('localhost', 1883, 60 )
		innerloop=True
		while innerloop==True:
			subclient.loop()
		print( "-----innerloop end-----------")
		subclient.disconnect()
		pubclient.disconnect()

if __name__ == "__main__":
    main()
    
exit()





