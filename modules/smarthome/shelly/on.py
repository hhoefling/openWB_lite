#!/usr/bin/python3
import sys
import os
import time
import json
import getopt
import socket
import struct
import codecs
import binascii
import urllib.request
from datetime import datetime, timezone
LOGLEVELDEBUG = 0
LOGLEVELINFO = 1
LOGLEVELERROR = 2
basePath = '/var/www/html/openWB'
loglevel = LOGLEVELDEBUG


def logDebug(level, msg):
    if (int(level) >= int(loglevel)):
        local_time = datetime.now(timezone.utc).astimezone()
        file = open(basePath+'/ramdisk/smarthome.log', 'a',encoding='utf8')
        if (int(level) == 0):
            file.write(local_time.strftime(format = "%Y-%m-%d %H:%M:%S") + '0: ' + str(msg)+ '\n')
        if (int(level) == 1):
            file.write(local_time.strftime(format = "%Y-%m-%d %H:%M:%S") + '1: ' + str(msg)+ '\n')
        if (int(level) == 2):
            file.write(local_time.strftime(format = "%Y-%m-%d %H:%M:%S") + '2: ' + str(msg)+ '\n')
        file.close()
        
        
named_tuple = time.localtime() # getstruct_time
time_string = time.strftime("%m/%d/%Y, %H:%M:%S shelly on.py", named_tuple)
devicenumber=str(sys.argv[1])
ipadr=str(sys.argv[2])
uberschuss=int(sys.argv[3])
logDebug(LOGLEVELDEBUG,'Shelly ' + str(devicenumber) + ' ' + str(ipadr) +' turn ON 111111111111111')
urllib.request.urlopen("http://"+str(ipadr)+"/relay/0?turn=on", timeout=3)