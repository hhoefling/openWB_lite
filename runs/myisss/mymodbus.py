
from myisss.mylog import log_debug

# #####################################################




class respond:
    def __init__(self, values):
        self.registers = values
        log_debug(2, "self.registers " + str(self.registers))


class ModbusSerialClient:

    def __init__(self):
        log_debug(2, "client.__init__")
        return

    def __enter__(self):
        log_debug(2, "client.__enter__")
        pass

    def __exit__(self, p2, p3, p4):
        log_debug(2, "client.__exit__")
        pass

# unit 201 = B23 , unit 105 = sdm,    1 = esve

    def read_input_registers(self, reg: int, cnt: int, unit: int):
        log_debug(2, "read_input_registers " + str(reg) + " cnt:" + str(cnt) + "unit=" + str(unit))
        if (reg == 0):
            resp = respond([231, 232])
            # log_debug(2, "-->" , str(resp.registers))
            return resp
        return respond([0, 0])

    def read_holding_registers(self, reg: int, cnt: int, unit: int):
        log_debug(2, "read_holding_registers " + hex(reg) + " cnt:" + str(cnt) + "unit=" + str(unit))
        if (reg == 1000):
            resp = respond([0])
        elif (reg == 1002):
            resp = respond([0])
        elif (reg == 0x5000):
            resp = respond([0, 0, 0, 0])
        elif (reg == 0x5B00):
            resp = respond([231, 232])
        elif (reg == 0x5B02):
            resp = respond([233, 234])
        elif (reg == 0x5B04):
            resp = respond([235, 236])
        elif (reg == 0x5B0C):
            resp = respond([0, 1])
        elif (reg == 0x5B0E):
            resp = respond([2, 3])
        elif (reg == 0x5B10):
            resp = respond([4, 5])
        else:
            resp = respond([0, 0])
        return resp

    def write_registers(self, reg: int, val: int, unit: int = 1) -> None:
        log_debug(2, "Wriet_registers " + hex(reg) + " cnt:" + "unit=" + str(unit) + " " + str(val))
        pass
