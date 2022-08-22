#!/bin/bash


SELF=`basename $0`
function log()
{
 timestamp=`date +"%Y-%m-%d %H:%M:%S: "`
 echo $timestamp $SELF "$*" >>/var/www/html/openWB/web/tools/upload/restore.log
}

SOURCEFILE="/var/www/html/openWB/web/tools/upload/backup.tar.gz"
WORKINGDIR="/home/pi/openwb_restore"

(
log "Restore of backup started..."
log "****************************************"
log "Step 1: creating working directory \"$WORKINGDIR\""
log "****************************************"
mkdir -p "$WORKINGDIR"
log "****************************************"
log "Step 2: extracting archive to working dir \"$WORKINGDIR\"..."
log "****************************************"
sudo tar -vxf "$SOURCEFILE" -C "$WORKINGDIR"
log "****************************************"
log "Step 3: replacing old files..."
log "****************************************"
cp -v -R -p "${WORKINGDIR}/var/www/html/openWB/." /var/www/html/openWB/
log "****************************************"
log "Step 4: restoring mosquitto db..."
log "****************************************"
sudo systemctl stop mosquitto.service
sleep 2
sudo cp -v -p "$WORKINGDIR/var/lib/mosquitto/mosquitto.db" "/var/lib/mosquitto/mosquitto.db"
sudo systemctl start mosquitto.service
log "****************************************"
log "Step 5: cleanup after restore..."
log "****************************************"
sudo rm "$SOURCEFILE"
sudo rm -R "$WORKINGDIR"
log "****************************************"
log "End: Restore finished."
log "****************************************"
) >>/var/www/html/openWB/web/tools/upload/restore.log 2>&1


