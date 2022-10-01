#!/bin/bash
# called as pi from upload.php

# OPENWBBASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OPENWBBASEDIR=/var/www/html/openWB
SOURCEFILE="/var/www/html/openWB/web/tools/upload/backup.tar.gz"
WORKINGDIR="/home/pi/openwb_restore"
LOGF=/var/www/html/openWB/web/tools/upload/restore.log

SELF=`basename $0`
function log()
{
 timestamp=`date +"%Y-%m-%d %H:%M:%S: "`
 echo $timestamp $SELF "$*" 
}

echo "" >$LOGF
sudo chown pi:www-data $LOGF
sudo chmod 0775 $LOGF

(
log "Restore of backup started..."
log "****************************************"
log "Step 1a: setting flag 'update in progress' and wait for control loop to finish"
echo 1 > "$OPENWBBASEDIR/ramdisk/updateinprogress"
# Wait for regulation loop(s) and cron jobs to end, but with timeout in case a script hangs
pgrep -f "$OPENWBBASEDIR/(regel\\.sh|runs/cron5min\\.sh|runs/cronnightly\\.sh)$" | \
	timeout 15 xargs -n1 -I'{}' tail -f --pid="{}" /dev/null
log "****************************************"

log "Step 1b: creating working directory \"$WORKINGDIR\""
log "****************************************"
mkdir -p "$WORKINGDIR"
log "****************************************"
log "Step 2: extracting archive to working dir \"$WORKINGDIR\"..."
log "****************************************"
if ! sudo tar -vxf "$SOURCEFILE" -C "$WORKINGDIR"; then
	log "something went wrong! aborting restore"
	echo "Wiederherstellung fehlgeschlagen! Bitte Protokolldateien pr?fen." >"$RAMDISKDIR/lastregelungaktiv"
	echo 0 > "$OPENWBBASEDIR/ramdisk/updateinprogress"
	exit 1
fi
log "****************************************"
log "Step 3: replacing old files..."
log "****************************************"
#  mv -v -f "${WORKINGDIR}${OPENWBBASEDIR}/." "${OPENWBBASEDIR}/"
sudo cp -v -R -p "${WORKINGDIR}/var/www/html/openWB" /var/www/html/
log "****************************************"
log "Step 4: restoring mosquitto db..."
log "****************************************"
sudo systemctl stop mosquitto.service
sleep 2
# sudo mv -v -f "${WORKINGDIR}${MOSQUITTODIR}/mosquitto.db" "$MOSQUITTODIR/mosquitto.db"
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
) >>$LOGF 2>&1


