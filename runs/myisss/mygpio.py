
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

    def setwarnings(self, arg) -> None:
        log_debug(2, "GPIO.Setwarnning")
        pass

    def setmode(self, mode) -> None:
        if mode == 0:
           log_debug(2, "GPIO.Setmode: BCM (GPIO Nummern)")
        elif mode == 1:
           log_debug(2, "GPIO.Setmode: BOARD (pin Nummern)")
        else:
           log_debug(2, "GPIO.Setmode: "+str(mode) )
        pass

    def setup(self, nr: int, mode: int, pull_up_down: int = 0) -> None:
        log_debug(2, "GPIO.Setup " + str(nr) + " " + str(mode))
        pass

    def input(self, nr: int) -> str:
        log_debug(2, "GPIO.input " + str(nr) + " ->0")
        return 0

    def output(self, nr: int, val: int) -> None:
        log_debug(2, "GPIO.output " + str(nr) + " = " + str(val))
        pass
######################################################


GPIO = CGPIO()
log_debug(2, "GPIO global Instance created")
