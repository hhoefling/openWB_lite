#!/bin/bash

# Check ob Filesystem ok ist.
# V-0.1 H.Hoefling

# Step1 , Test on SD Karte beschreibbar
# result=0 Ok
# result=1 Schrheibtest fehlgeshclagen -> Karte ist Read-Only 
# result=... weitere Tests

fn="/tmp/sdstatus"

if touch "$fn" >/dev/null 2>&1 ; then
  rm "$fn"
  result=0
else 
  result=1
fi
echo $result

    
