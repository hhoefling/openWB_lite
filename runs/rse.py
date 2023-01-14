import time

basePath = "/var/www/html/openWB"
ramdiskPath = basePath + "/ramdisk"
logFilename = ramdiskPath + "/openWB.log"

try:
    import RPi.GPIO as GPIO
except ModuleNotFoundError:
    exit("Module RPi.GPIO missing! Maybe we are not running on supported hardware?")


# write value to file in ramdisk
def write_to_ramdisk(filename: str, content: str) -> None:
    with open(ramdiskPath + "/" + filename, "w") as file:
        file.write(content)



# GPIOnr Nicht pins
GPIO.setmode(GPIO.BCM)
state = 0
state1 = 0
GPIO.setup(8, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(9, GPIO.IN, pull_up_down=GPIO.PUD_UP)

try:
    while True:
        button1_state = GPIO.input(8)
        button2_state = GPIO.input(9)

        time.sleep(10.2)

        if button1_state is False:
            if state == 0:
                write_to_ramdisk("rsestatus", "1")
                state = 1
        if button1_state is True:
            if state == 1:
                write_to_ramdisk("rsestatus", "0")
                state = 0
        if button2_state is False:
            if state1 == 0:
                write_to_ramdisk("rse2status", "1")
                state1 = 1
        if button2_state is True:
            if state1 == 1:
                write_to_ramdisk("rse2status", "0")
                state1 = 0

except:
    GPIO.cleanup()
