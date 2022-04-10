#!/bin/bash

wattbezug=0

openwbDebugLog MAIN  0 "wattbezug: ${wattbezug} Module not supportet"
openwbModulePublishState "EVU" 2 "Module: <bezug_discovergy> aktuell nicht unterstützt"

echo $wattbezug

