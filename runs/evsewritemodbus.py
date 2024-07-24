#!/usr/bin/python3
# nur von set_current
import sys
from pymodbus.client.sync import ModbusSerialClient

seradd = str(sys.argv[1])
evseid = int(sys.argv[2])
lla = int(sys.argv[3])

client = ModbusSerialClient(method = "rtu", port=seradd, baudrate=9600, stopbits=1, bytesize=8, timeout=1)
rq = client.write_registers(1000, lla, unit=evseid)
