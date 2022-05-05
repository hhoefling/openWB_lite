
cd /home/pi/puller
kip=$(ps aux |grep '[s]marthomehandler.py' | awk '{print $2}')
echo "now kill $kip"
kill $kip
python3 /var/www/html/openWB/runs/smarthomehandler.py &
ps -elf |grep smart


