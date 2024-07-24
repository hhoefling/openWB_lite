#!/usr/bin/python
import sys
import os
import time
import getopt
import socket
#import ConfigParser
import struct
import binascii
from pymodbus.client.sync import ModbusTcpClient

ipaddress = str(sys.argv[1])
start = int(sys.argv[2])
length = int(sys.argv[3])
slaveid = int(sys.argv[4])
dtyp= str(sys.argv[5])
func = str(sys.argv[6])
named_tuple = time.localtime() # get struct_time
time_string = time.strftime("%m/%d/%Y, %H:%M:%S opentrace", named_tuple) 
client = ModbusTcpClient(ipaddress, port=502)
if func ==  "3":
	resp= client.read_input_registers(start,length, unit=slaveid )
else:
	resp= client.read_holding_registers(start,length, unit=slaveid)

print("<pre>\r\n")
print ('%s resp:  %s ' % (time_string, resp.registers) )

i= 0
while i < length:
   if( dtyp == 'f' ):
   
        a = int(resp.registers[1])
        b = int(resp.registers[0])
        struct.unpack('!f', bytes.fromhex('{0:04x}'.format(a) + '{0:04x}'.format(b)))
          
        value1 = resp.registers[1]
        value2 = resp.registers[0]
        all = format(value1, '04x') + format(value2, '04x')
        final = int(struct.unpack('>i', all.decode('hex'))[0])   
        print ('%s start %6d  + %3d inhalt %s /> ' % (time_string,start,i, str(final) ))
   
        all = format(resp.registers[1], '04x') + format(resp.registers[0], '04x')
        ff = float(struct.unpack('>i', all.decode('hex'))[0])
        ff = float("%.1f" % ff) / 10
        print ('%s start %6d  + %3d inhalt %s /> ' % (time_string,start,i, str(ff) ))
        i = i + 2
   else:        
        print ('%s start %6d  + %3d inhalt %6d %#4X <br/> ' % (time_string,start,i,resp.registers [i],resp.registers [i]
        ))
        i = i + 1
   
print ( "</pre> " )   
