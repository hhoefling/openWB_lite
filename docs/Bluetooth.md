## Bluethooth auf meinem 3B+ will nicht (buster) ##

Meine Versuche dies zu beheben:

Zuerst mal "clean"
```
sudo apt-get remove bluetooth bluez blueman
sudo apt-get autoclean
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoclean
sudo reboot
```

nach dem Reboot dann
```
sudo apt-get install bluetooth bluez blueman
sudo apt-get install bluez bluez-firmware
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
sudo usermod -G bluetooth -a pi
sudo cat /etc/group | grep bluetooth

sudo reboot
```
nochmal reboot, dann:
```
sudo systemctl status bluetooth
 bluetooth.service - Bluetooth service
   Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2024-02-01 10:05:33 CET; 3min 6s ago
     Docs: man:bluetoothd(8)
 Main PID: 544 (bluetoothd)
   Status: "Running"
    Tasks: 1 (limit: 2059)
   CGroup: /system.slice/bluetooth.service
           └─544 /usr/lib/bluetooth/bluetoothd
Feb 01 10:05:33 pi67 systemd[1]: Starting Bluetooth service...
Feb 01 10:05:33 pi67 bluetoothd[544]: Bluetooth daemon 5.50
Feb 01 10:05:33 pi67 systemd[1]: Started Bluetooth service.
Feb 01 10:05:33 pi67 bluetoothd[544]: Starting SDP server
Feb 01 10:05:33 pi67 bluetoothd[544]: Bluetooth management interface 1.18 initialized
Feb 01 10:05:33 pi67 bluetoothd[544]: Sap driver initialization failed.
Feb 01 10:05:33 pi67 bluetoothd[544]: sap-server: Operation not permitted (1)
Feb 01 10:05:33 pi67 bluetoothd[544]: Failed to set privacy: Rejected (0x0b)
Feb 01 10:05:47 pi67 bluetoothd[544]: Endpoint registered: sender=:1.28 path=/MediaEndpoint/A2DPSource
Feb 01 10:05:47 pi67 bluetoothd[544]: Endpoint registered: sender=:1.28 path=/MediaEndpoint/A2DPSink

```
