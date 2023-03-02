#!/bin/bash

# Truncate Logfile to max 1024KB each
# Truncate only if bigger, let the file untouched if less.
# runs from cleanup.sh as root

f=$1
kb=${2:-1024}

logfilesize=$(stat --format=%s "$f")
#echo  $logfilesize $kb 
if  (( $logfilesize > (kb * 1024) )) ; then
    timestamp=`date +"%Y-%m-%d %H:%M:%S"`
    linesges=$(wc -l <"$f" )
    lines=$(( $linesges / 4 ))   # truncate to 1/4 size
    echo "$(tail -$lines $f)" > $f
    echo "$timestamp cleanupf.sh truncate $linesges to $lines" >>$f
    echo "$timestamp cleanupf.sh Logfile $f bigger than $kb Kb, truncate $linesges to $lines lines"
    chown pi:pi $f
    chmod a+rw $f
    #ls -l $f
fi

