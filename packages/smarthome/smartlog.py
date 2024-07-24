import logging

bp = '/var/www/html/openWB'

def initlog(name: str, devicenumber: int) -> None:
    log = logging.getLogger(name)
    formatter = logging.Formatter('%(asctime)s %(name)-10s %(levelname)-8s ; %(message)s')
    log.setLevel(logging.DEBUG)
    fname = '/var/www/html/openWB/ramdisk/smarthome_device_'
    fname += str(devicenumber) + '_' + str(name) + '.log'
    fh = logging.FileHandler(fname, encoding='utf8')
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)
    log.addHandler(fh)

def initMainlog() -> None:
    global log
    log = logging.getLogger("smarthome") 
#    formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    formatter = logging.Formatter('%(asctime)s %(name)-25s %(levelname)-8s : %(message)s')
    log.setLevel(logging.DEBUG)
    fh = logging.FileHandler(bp+'/ramdisk/smarthome.log', encoding='utf8')
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)
    log.addHandler(fh)
