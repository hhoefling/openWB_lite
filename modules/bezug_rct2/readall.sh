#!/bin/bash
d="$(date +%y%m%d-%H%M)"
out=rct_$d
python3 rct_read.py --ip=192.168.208.63 -v | tee $out

echo "file:$out"

