#!/usr/bin/python
import sys
# import os
# import time
# import getopt
# import socket
# import ConfigParser
import struct
# import binascii
import json
from pymodbus.client.sync import ModbusSerialClient

#Args in var schreiben
seradd = '/dev/'+str(sys.argv[1])
sdmid = int(sys.argv[2])


client = ModbusSerialClient(method = "rtu", port=seradd, baudrate=9600, stopbits=1, bytesize=8, timeout=1)

resp = client.read_input_registers(0x000C,2, unit=sdmid)
watt = struct.unpack('>f',struct.pack('>HH',*resp.registers))
watt = int(watt[0])
# print(watt)

resp = client.read_input_registers(0x0048,2, unit=sdmid)
vwh = struct.unpack('>f',struct.pack('>HH',*resp.registers))
vwh4 = int(float(vwh[0]) * int(1000))
# print(vwh4)

client.close()

# print(json.dumps({'power': watt, 'powerc': vwh4}, indent=2))

print ('{ "power":%d, "powerc":%d }' % (watt, vwh4) ) 
