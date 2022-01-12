#!/bin/bash
#
# Running with sudo
# Truncate Logfile to max 128KB each
# Truncate only if bigger, let the file untouched if less. 
#
if [ -f /var/www/html/openWB/ramdisk/debuguser ]; then
	timestamp=`date +"%Y-%m-%d %H:%M:%S"`
	echo "$timestamp cleanup.sh: Skipping logfile cleanup as senddebug.sh is collecting data." >> /var/www/html/openWB/ramdisk/openwb.log
else
	# find /var/www/html/openWB/ramdisk/ -name "*.log" -type f -exec /var/www/html/openWB/runs/cleanupf.sh {} \;
	for f in /var/www/html/openWB/ramdisk/*.log ; do
 	   logfilesize=$(stat --format=%s "$f")
	   if  (( $logfilesize > (120*1024) )) ; then
         lines=$(wc -l <"$f" )
         lines=$(( $lines / 2 ))   # truncate to half size
         echo "$(tail -$lines $f)" > $f
         echo "$timestamp truncate $lines" >>$f
         echo "Logfile $f bigger than 120Kb, truncate it to $lines lines"
         chown pi:pi $f
         chmod a+rw $f
         ls -l $f
      fi
	done
fi
