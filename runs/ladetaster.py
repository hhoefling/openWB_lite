import time
# run with  sudo -u pi bash -c "python3 runs/ladetaster.py &"
try:
    import RPi.GPIO as GPIO
except ModuleNotFoundError:
    exit("Module RPi.GPIO missing! Maybe we are on supported hardware?")

basePath = "/var/www/html/openWB"
ramdiskPath = basePath + "/ramdisk"
logFilename = ramdiskPath + "/ladestatus.log"

loglevel = 1


# handling of all logging statements
def log_debug(level: int, msg: str) -> None:
    if level >= loglevel:
        with open(logFilename, 'a') as log_file:
            log_file.write(time.ctime() + ': ' + msg + '\n')


# write value to file in ramdisk
def write_to_ramdisk(filename: str, content: str) -> None:
    with open(ramdiskPath + "/" + filename, "w") as file:
        file.write(content)


GPIO.setmode(GPIO.BCM)   # GPIO statt PinNr

GPIO.setup(12, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Sofortladen
GPIO.setup(16, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Min+PV
GPIO.setup(6, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # NURPV
GPIO.setup(13, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # AUS
GPIO.setup(21, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # STANDBY
try:
    while True:
        button1_state = GPIO.input(12)
        button2_state = GPIO.input(16)
        button3_state = GPIO.input(6)
        button4_state = GPIO.input(13)
        button5_state = GPIO.input(21)
        time.sleep(0.2)
        if button1_state is False:
            write_to_ramdisk("lademodus", "0")
            log_debug(2, "Lademodus geaendert durch Taster auf SofortLaden")
        if button2_state is False:
            write_to_ramdisk("lademodus", "1")
            log_debug(2, "Lademodus geaendert durch Taster auf Min und PV")
        if button3_state is False:
            write_to_ramdisk("lademodus", "2")
            log_debug(2, "Lademodus geaendert durch Taster auf NurPV")
        if button4_state is False:
            write_to_ramdisk("lademodus", "3")
            log_debug(2, "Lademodus geaendert durch Taster auf Stop")
        if button5_state is False:
            write_to_ramdisk("lademodus", "4")
            log_debug(2, "Lademodus geaendert durch Taster auf Standby")
        time.sleep(0.2)
except:
    GPIO.cleanup()
