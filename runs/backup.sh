#!/bin/bash

FILENAME=${1:-/var/www/html/openWB/web/backup/backup.tar.gz}
DEBUG=${2:-0}

SELF=`basename $0`
function log()
{
 timestamp=`date +"%Y-%m-%d %H:%M:%S: "`
 if ((  DEBUG > 0 )) ; then
   echo "$timestamp $*"
 fi   
 echo $timestamp $SELF "$*" >>/var/log/openWB.log
}


log "Sicherung gestartet"

# if ((  DEBUG > 0 )) ; then
#   log "Parameter: $*"
# fi
 
# remove old backup files
log "Entferne alte Sicherungen"
sudo rm /var/www/html/openWB/web/backup/*

log "Sichere MQTT Daten"
# tell mosquitto to store all retained topics in db now
for pid in $(pidof "mosquitto"); do
	log "Sende SIGUSR1 zu Mosquitto pid: '$pid' "
	sudo kill -s SIGUSR1 "$pid"
done

# give mosquitto some time to finish
sleep 0.5

# create backup file
log "Erzeuge Sicherung in:"
log "$FILENAME"
sudo tar --exclude=/var/www/html/openWB/web/backup --exclude=/var/www/html/openWB/.git -czf "$FILENAME" /var/www/html/openWB/ /var/lib/mosquitto/
sudo chown pi:www-data "$FILENAME"
sudo chmod 664 "$FILENAME"

log "Sicherung beended"
exit 0

OPENWBBASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKUPDIR="$OPENWBBASEDIR/web/backup"
. "$OPENWBBASEDIR/helperFunctions.sh"

backup() {
	openwbDebugLog MAIN 0 "creating new backup: $FILENAME"
	# remove old backup files
	openwbDebugLog MAIN 1 "deleting old backup files if present"
	rm "$BACKUPDIR/"*
	BACKUPFILE="$BACKUPDIR/$FILENAME"

	# tell mosquitto to store all retained topics in db now
	for pid in $(pidof "mosquitto"); do
		openwbDebugLog MAIN 1 "sending 'SIGUSR1' to mosquitto on pid '$pid'"
		sudo kill -s SIGUSR1 "$pid"
	done
	# give mosquitto some time to finish
	sleep 0.2

	# create backup file
	openwbDebugLog MAIN 1 "creating new backup file: $BACKUPFILE"
	sudo tar --exclude="$OPENWBBASEDIR/web/backup" --exclude="$OPENWBBASEDIR/.git" -czf "$BACKUPFILE" "$OPENWBBASEDIR/" "/var/lib/mosquitto/"
	openwbDebugLog MAIN 1 "setting permissions of new backup file"
	sudo chown pi:www-data "$BACKUPFILE"
	sudo chmod 664 "$BACKUPFILE"

	openwbDebugLog MAIN 0 "backup finished"
}

useExtendedFilename=$1
if ((useExtendedFilename == 1)); then
	FILENAME="openWB_backup_$(date +"%Y-%m-%d_%H:%M:%S").tar.gz"
else
	FILENAME="backup.tar.gz"
fi

openwbRunLoggingOutput backup "$FILENAME"
# return our filename for further processing
echo "$FILENAME"

