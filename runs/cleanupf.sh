#!/bin/bash

# Truncate Logfile to max 256KB each
# Truncate only if bigger, let the file untouched if less.

f=$1
kb=${2:-256}

logfilesize=$(stat --format=%s "$f")
if  (( $logfilesize > (kb * 1024) )) ; then
    timestamp=`date +"%Y-%m-%d %H:%M:%S"`
    lines=$(wc -l <"$f" )
    lines=$(( $lines / 4 ))   # truncate to 1/4 size
    echo "$(tail -$lines $f)" > $f
    echo "$timestamp cleanupf.sh truncate tp $lines" >>$f
    echo "$timestamp cleanupf.sh Logfile $f bigger than $kb Kb, truncate it to $lines lines"
    chown pi:pi $f
    chmod a+rw $f
    #ls -l $f
fi



#echo "tail $1"
#ls $1 -l
#echo "$(tail -2000 $1)" > $1
