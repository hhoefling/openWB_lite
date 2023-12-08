#!/usr/bin/python3
import sys
import os
import time

def read(fn): 
    f = open('/var/www/html/openWB/ramdisk/' + fn, 'r')
    result = float(f.read())
    f.close()
    print("read %s -> %s" % (str(fn), str(result)) ) 
    return result

def write(fn, val): 
    f = open('/var/www/html/openWB/ramdisk/' + fn, 'w')
    f.write(str(val))
    f.close()
    print("write %s <- %s" % (str(fn), str(val)) ) 
    
watt2 = int(sys.argv[1])
prefix = str(sys.argv[2])
import_filename = str(sys.argv[3])
export_filename = str(sys.argv[4])

# emulate import  export
seconds2 = time.time()
watt1 = 0
seconds1 = 0.0
if os.path.isfile('/var/www/html/openWB/ramdisk/' + prefix + 'sec0'):
    seconds1 = float(read(prefix + 'sec0'))
    watt1 = int(float(read(prefix + 'wh0')))
    wattposh = int(float(read(prefix + 'watt0pos')))
    wattnegh = int(float(read(prefix + 'watt0neg')))

    seconds2s = "%22.6f" % seconds2
    write(prefix + 'sec0', str(seconds2s))
    write(prefix + 'wh0', str(watt2))
    
    seconds1 = seconds1 + 1
    deltasec = seconds2 - seconds1
    deltasectrun = int(deltasec * 1000) / 1000
    stepsize = int((watt2 - watt1) / deltasec)
    while seconds1 <= seconds2:
        print( " secound:%s %s delta:%s %s step:%s" % ( seconds1, seconds2, deltasec, deltasectrun, stepsize ) )
        if watt1 < 0:
            wattnegh = wattnegh + watt1
        else:
            wattposh = wattposh + watt1
        watt1 = watt1 + stepsize
        if stepsize < 0:
            watt1 = max(watt1, watt2)
        else:
            watt1 = min(watt1, watt2)
        seconds1 = seconds1 + 1
    rest = deltasec - deltasectrun
    seconds1 = seconds1 - 1 + rest
    if rest > 0:
        watt1 = int(watt1 * rest)
        if watt1 < 0:
            wattnegh = wattnegh + watt1
        else:
            wattposh = wattposh + watt1
    wattposkh = wattposh / 3600
    wattnegkh = (wattnegh * -1) / 3600
    write(prefix + 'watt0pos', str(wattposh))
    write(prefix + 'watt0neg', str(wattnegh))
    write(import_filename, str(wattposkh))
    write(export_filename, str(wattnegkh))
else:
    seconds2s = "%22.6f" % seconds2
    write(prefix + 'sec0', str(seconds2s))
    write(prefix + 'wh0', str(watt2))
