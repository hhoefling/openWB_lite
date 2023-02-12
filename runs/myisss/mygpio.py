
from myisss.mylog import log_debug


######################################################

class CGPIO:
    BCM = 0
    BOARD = 1
    OUT = 1
    IN = 2
    PUD_UP = 3
    LOW = 0
    HIGH = 1

    amode = 0

    def __init__(self):
        self.amode = 0
        pass

    def name(self, nr:int) -> str:
        if self.amode == 0:
            switch={    # GPIO
            4: 'P07 G04 Led3',
            5: 'P29 G05 LP1 U1P3--',
            6: 'P31 G06 INP T3',
            7: 'P26 G07 Socket LM',
            8: 'P24 G08 INP RSE',
            9: 'P21 G09 INP RSE',
            10: 'P19 G10 INP Socket LM State',
            11: 'P23 G11 Socket LM Dir',
            12: 'P32 G12 INP T1',
            13: 'P33 G13 INP T4',
            16: 'P36 G16 INP T2',
            21: 'P40 G21 INP T5',
            22: 'P15 G22 LP2 CP',
            23: 'P16 G23 Led2',
            24: 'P18 G24 Led1',
            25: 'P22 G25 LP1 CP',
            26: 'P37 G26 LP1 U1P3++',
            27: 'P13 G27 LP2 U1P3++'
            } 
            return switch.get(nr)
            pass
        if self.amode == 1:
            switch={
            7: 'P07 G04 Led3',
            11: 'P11 G17 LP2 U1P3--',
            13: 'P13 G27 LP2 U1P3++',
            15: 'P15 G22 LP2 CP',
            16: 'P16 G23 Led2',
            18: 'P18 G24 Led1',
            19: 'P19 G10 INP Socket LM State',
            21: 'P21 G09 INP RSE',
            22: 'P22 G25 LP1 CP',
            23: 'P23 G11 Socket LM Dir',
            24: 'P24 G08 INP RSE',
            26: 'P26 G07 Socket LM',
            29: 'P29 G05 LP1 U1P3--',
            31: 'P31 G06 INP T3',
            32: 'P32 G12 INP T1',
            33: 'P33 G13 INP T4',
            36: 'P36 G16 INP T2',
            37: 'P37 G26 LP1 U1P3++',
            40: 'P40 G21 INP T5'
            } 
            return switch.get(nr)
            pass
        pass

    def setwarnings(self, arg) -> None:
        log_debug(2, "GPIO.Setwarnning")
        pass

    def setmode(self, mode) -> None:
        if mode == 0:
           self.amode=0
           log_debug(2, "GPIO.Setmode:0 BCM (GPIO Nummern)")
        elif mode == 1:
           self.amode=1
           log_debug(2, "GPIO.Setmode:1 BOARD (pin Nummern)")
        else:
           self.amode=mode1
           log_debug(2, "GPIO.Setmode: "+str(mode) )
        pass

    def setup(self, nr: int, mode: int, pull_up_down: int = 0) -> None:
        log_debug(2, "GPIO.Setup Pin" + str(nr) + " "  + self.name(nr)+ " " + str(mode))
        pass

    def input(self, nr: int) -> str:
        s = self.name(nr)
        log_debug(2, "GPIO.input " + str(nr) + " " + str(s) + " ->0")
        return 0

    def output(self, nr: int, val: int) -> None:
        s = self.name(nr)
        log_debug(2, "GPIO.output " + str(nr) + " " + str(s) + " = " + str(val))
        pass
######################################################


GPIO = CGPIO()
log_debug(2, "GPIO global Instance created")
