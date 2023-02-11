


import sys
import time
import traceback


basePath = "/var/www/html/openWB"
ramdiskPath = basePath + "/ramdisk"
logFilename = ramdiskPath + "/isss.log"


# handling of all logging statements
def log_debug(level: int, msg: str, traceback_str: str = None) -> None:
    if level <= loglevel:
        msg = msg + ' ' + sys.argv[0]
        with open(logFilename, 'a') as log_file:
            log_file.write(time.ctime() + ': ' + msg + '\n')
            if traceback_str is not None:
                log_file.write(traceback_str + '\n')


# write value to file in ramdisk
def write_to_ramdisk(filename: str, content: str) -> None:
    with open(ramdiskPath + "/" + filename, "w") as file:
        file.write(content)


# read value from file in ramdisk
def read_from_ramdisk(filename: str) -> str:
    try:
        with open(ramdiskPath + "/" + filename, 'r') as file:
            return file.read()
    except FileNotFoundError:
        log_debug(2, "Error reading file '" + filename + "' from ramdisk!", traceback.format_exc())
        return ""


loglevel = 2
try:
    loglevel = int(read_from_ramdisk("lpdaemonloglevel"))
except (FileNotFoundError, ValueError):
    pass
