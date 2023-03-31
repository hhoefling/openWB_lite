#!/usr/bin/python3
# coding: utf8

import time

try:
    import RPi.GPIO as GPIO
except ModuleNotFoundError:
    from myisss.mylog import log_debug
    from myisss.mygpio import GPIO

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--duration", type=int, default=4, help="duration in seconds, defaults to 4")
parser.add_argument("-v", "--verbose", action="store_true", help="verbose debug output")
args = parser.parse_args()

if (args.verbose):
    print("CP-Unterbrechung LP1: %ds" % (args.duration))

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(22, GPIO.OUT)

GPIO.output(22, GPIO.HIGH)
time.sleep(args.duration)
GPIO.output(22, GPIO.LOW)
