#!/bin/bash

export TS_MAXFINISHED=10
export TS_SAVELIST=/var/www/html/openWB/runs/tasker/tsp.dump
# export  TS_ENV='pwd;set;mount'.
tsp -K
tsp

ps -elf | grep tsp
