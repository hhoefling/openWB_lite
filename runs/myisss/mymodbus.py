
import struct
from myisss.mylog import log_debug

# #####################################################


# Konst sdm32 Modbus 105
lp1_00 = "lp1/0x00"     # SDM72 Volt Phase1
lp1_02 = "lp1/0x02"     # SDM72 Volt Phase2
lp1_04 = "lp1/0x04"     # SDM72 Volt Phase3
lp1_06 = "lp1/0x06"     # SDM72 Ampere Phase1
lp1_08 = "lp1/0x08"     # SDM72 Ampere Phase2
lp1_0A = "lp1/0x0A"     # SDM72 Ampere Phase3
lp1_0C = "lp1/0x0C"     # SDM72 Power(W) Phase1
lp1_0E = "lp1/0x0E"     # SDM72 Power(W) Phase2
lp1_10 = "lp1/0x10"     # SDM72 Power(W) Phase3
lp1_46 = "lp1/0x46"     # SDM72 Freqenz
lp1_156 = "lp1/0x156"   # SDM72 total Energy kwh
# Konst sdm32 Modbus 106
lp2_00 = "lp2/0x00"
lp2_02 = "lp2/0x02"
lp2_04 = "lp2/0x04"
lp2_06 = "lp2/0x06"
lp2_08 = "lp2/0x08"
lp2_0A = "lp2/0x0A"
lp2_0C = "lp2/0x0C"
lp2_0E = "lp2/0x0E"
lp2_10 = "lp2/0x10"
lp2_156 = "lp2/0x156"
# Konst EVSE Modbus 1
evse1_1000 = "evse1/1000"     # evse current A 
evse1_1002 = "evse1/1002"     # evse Vehicle statzs 0=ready 2=present 3=charging 4=charg with vent 5=failure
# Konst EVSE Modbus 2
evse2_1000 = "evse2/1000"
evse2_1002 = "evse2/1002"

    
modbusvalues = {}  
# wird aus openWBSim/lp1/x ausgelesen
modbusvalues[lp1_0C] = 0
modbusvalues[lp1_0E] = 0
modbusvalues[lp1_10] = 0
modbusvalues[lp1_00] = 221
modbusvalues[lp1_02] = 222
modbusvalues[lp1_04] = 223
modbusvalues[lp1_06] = 0
modbusvalues[lp1_08] = 0
modbusvalues[lp1_0A] = 0
modbusvalues[lp1_156] = 2333.0
modbusvalues[lp1_46] = 50.2

# wird aus openWBSim/lp2/x ausgelesen
modbusvalues[lp2_0C] = 0
modbusvalues[lp2_0E] = 0
modbusvalues[lp2_10] = 0
modbusvalues[lp2_00] = 241
modbusvalues[lp2_02] = 242
modbusvalues[lp2_04] = 243
modbusvalues[lp2_06] = 0
modbusvalues[lp2_08] = 0
modbusvalues[lp2_0A] = 0
modbusvalues[lp2_156] = 2222.0


modbusvalues[evse1_1000] = 0
modbusvalues[evse1_1002] = 0
modbusvalues[evse2_1000] = 0
modbusvalues[evse2_1002] = 0


class respond:
    def __init__(self, values):
        self.registers = values
        log_debug(2, "self.registers " + str(self.registers))


class ModbusSerialClient:

    def __init__(self, method, port, baudrate, stopbits, bytesize, timeout):
        log_debug(2, "ModbusSerialClient.__init__")
        return

    def __enter__(self):
        log_debug(2, "ModbusSerialClient.__enter__")
        pass

    def __exit__(self, p2, p3, p4):
        log_debug(2, "ModbusSerialClient.__exit__")
        pass

    def close(self):
        log_debug(2, "ModbusSerialClient.close")
        pass

# Simulation via mqtt
    def readvalue(self, valname):
        val = modbusvalues[valname]
        log_debug(2, "get modbusvalues[" + str(valname) + "] as [" + str(val) +  "]" )
        return val  
# Simulation via mqtt
    def writevalue(self, valname: str, val: str):
        modbusvalues[valname] = val
        log_debug(2, "set modbusvalues[" + str(valname) + "] to  [" + str(val) +  "]" )


# unit 201 = B23 , unit 105 = sdm,    1 = esve

    def read_input_registers(self, reg: int, cnt: int, unit: int):
        log_debug(2, "read_input_registers " + str(reg) + " cnt:" + str(cnt) + "unit=" + str(unit))
        if( unit == 1 ):         # evse 1
            if (reg == 1000):
                resp = modbusvalues[evse1_1000] 
            elif (reg == 1002):
                resp = modbusvalues[evse1_1002]
        elif( unit == 2 ):         # evse 1
            if (reg == 1000):
                resp = modbusvalues[evse2_1000]
            elif (reg == 1002):
                resp = modbusvalues[evse2_1002]
        elif ( unit == 105 ):                 
        if (reg == 0):
                resp = modbusvalues[lp1_00]
            elif (reg == 2):
                resp = modbusvalues[lp1_02]
            elif (reg == 4):
                resp = modbusvalues[lp1_04]
            elif (reg == 6):
                resp = modbusvalues[lp1_06]
            elif (reg == 8):
                resp = modbusvalues[lp1_08]
            elif (reg == 0x0A):
                resp = modbusvalues[lp1_0A]
            elif (reg == 0x0C):
                resp = modbusvalues[lp1_0C]
            elif (reg == 0x0E):
                resp = modbusvalues[lp1_0E]
            elif (reg == 0x10):
                resp = modbusvalues[lp1_10]
            elif (reg == 0x46):
                resp = modbusvalues[lp1_46]
            elif (reg == 0x156):
                resp = modbusvalues[lp1_156]
            else: 
                log_debug(0, "Read_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
                resp=0
        elif ( unit == 106 ):                 
        if (reg == 0):
                resp = modbusvalues[lp2_00]
            elif (reg == 2):
                resp = modbusvalues[lp2_02]
            elif (reg == 4):
                resp = modbusvalues[lp2_04]
            elif (reg == 6):
                resp = modbusvalues[lp2_06]
            elif (reg == 8):
                resp = modbusvalues[lp2_08]
            elif (reg == 0x0A):
                resp = modbusvalues[lp2_0A]
            elif (reg == 0x0C):
                resp = modbusvalues[lp2_0C]
            elif (reg == 0x0E):
                resp = modbusvalues[lp2_0E]
            elif (reg == 0x10):
                resp = modbusvalues[lp2_10]
            elif (reg == 0x156):
                resp = modbusvalues[lp2_156]
            else: 
                log_debug(0, "Read_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
                resp = 0
        else:
            log_debug(0, "Readt_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
            resp = 0 
        log_debug(2, "-->" + str(resp))
            return resp

    def read_holding_registers(self, reg: int, cnt: int, unit: int):
        log_debug(2, "read_holding_registers " + hex(reg) + " cnt:" + str(cnt) + "unit=" + str(unit))
        if( unit == 1 ):         # evse 1
        if (reg == 1000):
                resp = modbusvalues[evse1_1000]
        elif (reg == 1002):
                resp = modbusvalues[evse1_1002]
        elif( unit == 2 ):         # evse 1
        if (reg == 1000):
                resp = modbusvalues[evse2_1000]
        elif (reg == 1002):
                resp = modbusvalues[evse2_1002]
        elif ( unit == 105 ):                 
            if (reg == 0):
                resp = modbusvalues[lp1_00]
            elif (reg == 2):
                resp = modbusvalues[lp1_02]
            elif (reg == 4):
                resp = modbusvalues[lp1_04]
            elif (reg == 6):
                resp = modbusvalues[lp1_06]
            elif (reg == 8):
                resp = modbusvalues[lp1_08]
            elif (reg == 0x0A):
                resp = modbusvalues[lp1_0A]
            elif (reg == 0x0C):
                resp = modbusvalues[lp1_0C]
            elif (reg == 0x0E):
                resp = modbusvalues[lp1_0E]
            elif (reg == 0x10):
                resp = modbusvalues[lp1_10]
            elif (reg == 0x46):
                resp = modbusvalues[lp1_46]
            elif (reg == 0x156):
                resp = modbusvalues[lp1_156]
        else:
                log_debug(0, "Read_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
                resp=0
        elif ( unit == 106 ):                 
            if (reg == 0):
                resp = modbusvalues[lp2_00]
            elif (reg == 2):
                resp = modbusvalues[lp2_02]
            elif (reg == 4):
                resp = modbusvalues[lp2_04]
            elif (reg == 6):
                resp = modbusvalues[lp2_06]
            elif (reg == 8):
                resp = modbusvalues[lp2_08]
            elif (reg == 0x0A):
                resp = modbusvalues[lp2_0A]
            elif (reg == 0x0C):
                resp = modbusvalues[lp2_0C]
            elif (reg == 0x0E):
                resp = modbusvalues[lp2_0E]
            elif (reg == 0x10):
                resp = modbusvalues[lp2_10]
            elif (reg == 0x156):
                resp = modbusvalues[lp2_156]
        else:
                log_debug(0, "Read_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
                resp=0
        else:
            log_debug(0, "Read_registers unknown:" + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
            resp=0
        log_debug("-->" + str(resp))
        return resp

    def write_registers(self, reg: int, val: int, unit: int = 1) -> None:
        log_debug(2, "write_registers " + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
        if( unit == 1 ):         # evse 1
            if ( reg == 1000):
                modbusvalues[evse1_1000]=val                              
        if( unit == 2 ):         # evse 1
            if ( reg == 1000):
                modbusvalues[evse2_1000]=val                              
        pass
