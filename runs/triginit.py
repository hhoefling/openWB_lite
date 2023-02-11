#!/usr/bin/env python3
#coding: utf8
#
# Up atreboot.sh
# Hardware ebene
#

import time
try:
    import RPi.GPIO as GPIO
except ModuleNotFoundError:
    from myisss.mylog import log_debug
    from myisss.mygpio import GPIO
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--duration", type=float, default=2.0, help="duration in seconds (float), defaults to 2.0")
parser.add_argument("-v", "--verbose", action="store_true", help="verbose debug output")
args = parser.parse_args()

if(args.verbose):
    print("Wartezeit vor und nach 1p/3p Umschaltung: %fs" % (args.duration))


# BCM-Nummerierung verwenden
# GPIO.setmode(GPIO.BCM)
	
# setup GPIOs
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(22, GPIO.OUT)
GPIO.setup(37, GPIO.OUT)
GPIO.setup(29, GPIO.OUT)
GPIO.setup(15, GPIO.OUT)
GPIO.setup(13, GPIO.OUT)
GPIO.setup(11, GPIO.OUT)

# block CP
GPIO.output(22, GPIO.HIGH)
GPIO.output(15, GPIO.HIGH)
time.sleep(float(args.duration))

# init phases PIN37=GPIO26,  PIN29=GPIO5,  PIN13 GPIO27,   PIN11=GPIO17
GPIO.output(37, GPIO.LOW)
GPIO.output(29, GPIO.LOW)
GPIO.output(13, GPIO.LOW)
GPIO.output(11, GPIO.LOW)
time.sleep(float(args.duration))

# enable CP  PIN22=GPIO25  PIN15=GPIO22
GPIO.output(22, GPIO.LOW)
GPIO.output(15, GPIO.LOW)

# Socket: power to lock motor PIN26=GPIO7
GPIO.setup(26, GPIO.OUT)
# set pin to low to prevent the motor from burning out
GPIO.output(26, GPIO.LOW)

