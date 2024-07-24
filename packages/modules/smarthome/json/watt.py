#!/usr/bin/python3
import sys
import json
import jq
import subprocess 
import urllib.request
from urllib.parse import urlparse, parse_qs, parse_qsl
import logging
from smarthome.smartlog import initlog, initMainlog


devicenumber = int(sys.argv[1])

initMainlog()
mlog = logging.getLogger('smarthome.json.watt')

initlog("json", devicenumber)
log = logging.getLogger("json.watt")


# Abfrage-URL, die die .json Antwort liefert. Z.B.
# "http://192.168.0.150/solar_api/v1/GetMeterRealtimeData.cgi?Scope=Device&DeviceID=1"
# "python3:///var/www/html/openWB/modules/verbraucher/sdm120json.py ttyUSB0 9"
jsonurl = str(sys.argv[2])
jsonpower = str(sys.argv[3])  # json Key in dem der aktuelle Leistungswert steht, z.B. ".Body.Data.PowerReal_P_Sum"
jsonpowerc = str(sys.argv[4]) # json Key in dem der summierte Verbrauch steht, z.B. ".Body.Data.EnergyReal_WAC_Sum_Consumed"

log.info('watt with:' + str(jsonurl) )

pr = urlparse(jsonurl)
# log.info( pr )

if( pr.scheme=='python3'):
	url='python3 ' + pr.path
	# log.info('exec:' + url) 
	result = subprocess.run(url, shell=True, capture_output=True, text=True)
	answer = result.stdout
	if( len(result.stderr) ):
		log.error(result.stderr)
	# log.info(answer)
	answer = json.loads(str(answer))
	try:
		power=answer['power']
	except Exception:
		power = 0
	try:
		powerc=answer['powerc']
	except Exception:
		powerc = 0
else:
	answer = json.loads(str(urllib.request.urlopen(jsonurl, timeout=3).read().decode("utf-8")))
	try:
		power = jq.compile(jsonpower).input(answer).first()
		power = int(abs(power))
	except Exception:
		power = 0
	try:
		powerc = jq.compile(jsonpowerc).input(answer).first()
		powerc = int(abs(powerc))
	except Exception:
		powerc = 0

fn = '/var/www/html/openWB/ramdisk/smarthome_device_ret' + str(devicenumber)
f1 = open(fn, 'w')
answer = '{"power":' + str(power) + ',"powerc":' + str(powerc) + '}'
json.dump(answer, f1)
f1.close()
log.info(answer + ' saved')
