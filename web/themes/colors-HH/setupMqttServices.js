/**
 * Functions to provide services for MQTT
 *
 * @author Kevin Wieland
 * @author Michael Ortenstein
 */

// these topics will be subscribed
// index 1 represents flag if value was received, needed for preloader progress bar
// if flags are preset with 1 they are not counted on reload and page will show even if topic was not received
var topicsToSubscribe = [
	// Status Konfiguration Ladepunkt
	["openWB/lp/1/boolChargePointConfigured", 0],
	["openWB/lp/2/boolChargePointConfigured", 0],
	["openWB/lp/3/boolChargePointConfigured", 0],
	// hook Konfiguration
	["openWB/hook/1/boolHookConfigured", 1],
	["openWB/hook/2/boolHookConfigured", 1],
	["openWB/hook/3/boolHookConfigured", 1],
	// verbraucher Konfiguration
	["openWB/Verbraucher/1/Configured", 0],
	["openWB/Verbraucher/1/Name", 0],
	["openWB/Verbraucher/1/Watt", 1],
	["openWB/Verbraucher/2/Configured", 0],
	["openWB/Verbraucher/2/Name", 0],
	["openWB/Verbraucher/2/Watt", 1],
	// housebattery Konfiguration
	["openWB/housebattery/boolHouseBatteryConfigured", 0],
	// SmartHome Konfiguration
	["openWB/config/get/SmartHome/Devices/1/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/2/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/3/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/4/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/5/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/6/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/7/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/8/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/9/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/1/device_name", 1],
	["openWB/config/get/SmartHome/Devices/2/device_name", 1],
	["openWB/config/get/SmartHome/Devices/3/device_name", 1],
	["openWB/config/get/SmartHome/Devices/4/device_name", 1],
	["openWB/config/get/SmartHome/Devices/5/device_name", 1],
	["openWB/config/get/SmartHome/Devices/6/device_name", 1],
	["openWB/config/get/SmartHome/Devices/7/device_name", 1],
	["openWB/config/get/SmartHome/Devices/8/device_name", 1],
	["openWB/config/get/SmartHome/Devices/9/device_name", 1],
	["openWB/config/get/SmartHome/Devices/1/mode", 1],
	["openWB/config/get/SmartHome/Devices/2/mode", 1],
	["openWB/config/get/SmartHome/Devices/3/mode", 1],
	["openWB/config/get/SmartHome/Devices/4/mode", 1],
	["openWB/config/get/SmartHome/Devices/5/mode", 1],
	["openWB/config/get/SmartHome/Devices/6/mode", 1],
	["openWB/config/get/SmartHome/Devices/7/mode", 1],
	["openWB/config/get/SmartHome/Devices/8/mode", 1],
	["openWB/config/get/SmartHome/Devices/9/mode", 1],
	["openWB/config/get/SmartHome/Devices/1/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/2/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/3/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/4/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/5/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/6/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/7/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/8/device_homeConsumtion", 1],
	["openWB/config/get/SmartHome/Devices/9/device_homeConsumtion", 1],

	["openWB/config/get/pv/priorityModeEVBattery", 1],
	["openWB/config/get/pv/minCurrentMinPv", 1],
	["openWB/config/get/pv/nurpv70dynact", 1],
	
		// Config Vars Sofort current
	["openWB/config/get/sofort/lp/1/current", 1],
	["openWB/config/get/sofort/lp/2/current", 1],
	["openWB/config/get/sofort/lp/3/current", 1],
	["openWB/config/get/sofort/lp/1/chargeLimitation", 1],
	["openWB/config/get/sofort/lp/2/chargeLimitation", 1],
	["openWB/config/get/sofort/lp/3/chargeLimitation", 1],
	["openWB/config/get/sofort/lp/1/energyToCharge", 1],
	["openWB/config/get/sofort/lp/2/energyToCharge", 1],
	["openWB/config/get/sofort/lp/3/energyToCharge", 1],
	["openWB/config/get/sofort/lp/1/socToChargeTo", 1],
	["openWB/config/get/sofort/lp/2/socToChargeTo", 1],

	// etprovider topics
	["openWB/global/ETProvider/modulePath", 1],
	["openWB/global/awattar/boolAwattarEnabled", 0],
	["openWB/global/awattar/MaxPriceForCharging", 1],
	["openWB/global/awattar/ActualPriceForCharging", 1],
	["openWB/global/awattar/pricelist", 1],
	// graph topics
	//
	["openWB/graph/boolDisplayLp1", 1],
	["openWB/graph/boolDisplayLp2", 1],
	["openWB/graph/boolDisplayLp3", 1],
	["openWB/graph/boolDisplayHouseConsumption", 1],
	["openWB/graph/boolDisplayLoad1", 1],
	["openWB/graph/boolDisplayLoad2", 1],
	["openWB/graph/boolDisplayLp1Soc", 1],
	["openWB/graph/boolDisplayLp2Soc", 1],
	["openWB/graph/boolDisplayLpAll", 1],
	["openWB/graph/boolDisplaySpeicherSoc", 1],
	["openWB/graph/boolDisplaySpeicher", 1],
	["openWB/graph/boolDisplayEvu", 1],
	["openWB/graph/boolDisplayLegend", 1],
	["openWB/graph/boolDisplayLiveGraph", 1],
	["openWB/graph/boolDisplayPv", 1],
	["openWB/graph/boolDisplayShD1", 1],
	["openWB/graph/boolDisplayShD2", 1],
	["openWB/graph/boolDisplayShD3", 1],
	["openWB/graph/boolDisplayShD4", 1],
	["openWB/graph/boolDisplayShD5", 1],
	["openWB/graph/boolDisplayShD6", 1],
	["openWB/graph/boolDisplayShD7", 1],
	["openWB/graph/boolDisplayShD8", 1],
	["openWB/graph/boolDisplayShD9", 1],

	// global topics
	["openWB/global/cplp1_inwork", 1],
	["openWB/global/u1p3p_inwork", 1],
	["openWB/global/u1p3p_state", 1],
	["openWB/global/WHouseConsumption", 1],
	["openWB/global/ChargeMode", 0],
	["openWB/global/WAllChargePoints", 1],
	["openWB/global/strLastmanagementActive", 1],
	["openWB/global/strLaderegler", 0],
	["openWB/global/strBatSupport", 0],
	["openWB/global/rfidConfigured", 1],
	["openWB/global/urlforlink", 1],				// urlforlink=http://192.168.208.64/openWB/web/index.php

	// pv topics
	["openWB/pv/W", 1],
	["openWB/pv/bool70PVDynStatus", 1],
	
	// evu topics
	["openWB/evu/W", 1],
	// lp topics
	["openWB/lp/1/%Soc", 1],
	["openWB/lp/1/socRange", 1],
	["openWB/lp/1/socTime", 1],
	["openWB/lp/2/%Soc", 1],
	["openWB/lp/2/socRange", 1],
	["openWB/lp/2/socTime", 1],
	// geladene kWh seit anstecken des EV
	["openWB/lp/1/kWhChargedSincePlugged", 1],
	["openWB/lp/2/kWhChargedSincePlugged", 1],
	["openWB/lp/3/kWhChargedSincePlugged", 1],
	// geladene kWh seit Reset Lademengenbegrenzung
	["openWB/lp/1/kWhActualCharged", 1],
	["openWB/lp/2/kWhActualCharged", 1],
	["openWB/lp/3/kWhActualCharged", 1],
	// Durchschnittsverbrauch
	["openWB/lp/1/energyConsumptionPer100km", 1],
	["openWB/lp/2/energyConsumptionPer100km", 1],
	["openWB/lp/3/energyConsumptionPer100km", 1],
	// Ladeleistung am LP
	["openWB/lp/1/W", 1],
	["openWB/lp/2/W", 1],
	["openWB/lp/3/W", 1],
	// Anzahl genutzter Phasen während Ladung am LP
	["openWB/lp/1/countPhasesInUse", 1],
	["openWB/lp/2/countPhasesInUse", 1],
	["openWB/lp/3/countPhasesInUse", 1],
	// Status Stecker
	["openWB/lp/1/boolPlugStat", 1],
	["openWB/lp/2/boolPlugStat", 1],
	["openWB/lp/3/boolPlugStat", 1],
	// Status Laden
	["openWB/lp/1/boolChargeStat", 1],
	["openWB/lp/2/boolChargeStat", 1],
	["openWB/lp/3/boolChargeStat", 1],
	// Status Konfiguration SoC
	["openWB/lp/1/boolSocConfigured", 1],
	["openWB/lp/2/boolSocConfigured", 1],
	// manual SoC
	["openWB/lp/1/boolSocManual", 1],
	["openWB/lp/2/boolSocManual", 1],
	// Status Nachtladen
	["openWB/lp/1/boolChargeAtNight", 1],
	["openWB/lp/2/boolChargeAtNight", 1],
	// eingestellter Ladestrom
	["openWB/lp/1/AConfigured", 1],
	["openWB/lp/2/AConfigured", 1],
	["openWB/lp/3/AConfigured", 1],
	// Restzeit
	["openWB/lp/1/TimeRemaining", 1],
	["openWB/lp/2/TimeRemaining", 1],
	["openWB/lp/3/TimeRemaining", 1],

	["openWB/lp/1/boolDirectChargeMode_none_kwh_soc", 1],
	["openWB/lp/2/boolDirectChargeMode_none_kwh_soc", 1],
	["openWB/lp/3/boolDirectChargeMode_none_kwh_soc", 1],
	//
	["openWB/lp/1/ChargePointEnabled", 1],
	["openWB/lp/2/ChargePointEnabled", 1],
	["openWB/lp/3/ChargePointEnabled", 1],
	// Name LP
	["openWB/lp/1/strChargePointName", 1],
	["openWB/lp/2/strChargePointName", 1],
	["openWB/lp/3/strChargePointName", 1],
	// Status Autolock konfiguriert
//	["openWB/lp/1/AutolockConfigured", 1],
//	["openWB/lp/2/AutolockConfigured", 1],
//	["openWB/lp/3/AutolockConfigured", 1],
	// Status Autolock
//	["openWB/lp/1/AutolockStatus", 1],
//	["openWB/lp/2/AutolockStatus", 1],
//	["openWB/lp/3/AutolockStatus", 1],
	["openWB/lp/1/ADirectModeAmps", 1],
	["openWB/lp/2/ADirectModeAmps", 1],
	["openWB/lp/3/ADirectModeAmps", 1],
	// Zielladen
	["openWB/lp/1/boolFinishAtTimeChargeActive", 1],
	// housebattery values
	["openWB/housebattery/W", 1],
	["openWB/housebattery/%Soc", 1],
	["openWB/housebattery/soctarget", 1],
	["openWB/housebattery/iskalib", 1],
	["openWB/housebattery/enable_priceloading", 0],
    ["openWB/housebattery/loadWatt", 1],
    ["openWB/housebattery/load_minutes", 1],
	["openWB/housebattery/discharge_max", 1],
	// Daily Yields
	["openWB/housebattery/DailyYieldImportKwh", 1],
	["openWB/housebattery/DailyYieldExportKwh", 1],
	["openWB/global/DailyYieldHausverbrauchKwh", 1],
	["openWB/global/DailyYieldAllChargePointsKwh", 1],
	["openWB/evu/DailyYieldImportKwh", 1],
	["openWB/evu/DailyYieldExportKwh", 1],
	["openWB/pv/DailyYieldKwh", 1],
	["openWB/Verbraucher/1/DailyYieldImportkWh", 1],
	["openWB/Verbraucher/2/DailyYieldImportkWh", 1],
	["openWB/SmartHome/Devices/1/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/2/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/3/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/4/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/5/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/6/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/7/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/8/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/9/DailyYieldKwh", 1],

	// hook status
	["openWB/hook/1/boolHookStatus", 1],
	["openWB/hook/2/boolHookStatus", 1],
	["openWB/hook/3/boolHookStatus", 1],

	["openWB/SmartHome/Status/wattnichtHaus", 1],
	
	// Smart Home Devices, only configured is definitely set, other values only set if configured, assume they are there!
	["openWB/SmartHome/Devices/1/Watt", 1],
	["openWB/SmartHome/Devices/1/TemperatureSensor0", 1],
	["openWB/SmartHome/Devices/1/TemperatureSensor1", 1],
	["openWB/SmartHome/Devices/1/TemperatureSensor2", 1],
	["openWB/SmartHome/Devices/2/Watt", 1],
	["openWB/SmartHome/Devices/2/TemperatureSensor0", 1],
	["openWB/SmartHome/Devices/2/TemperatureSensor1", 1],
	["openWB/SmartHome/Devices/2/TemperatureSensor2", 1],
	["openWB/SmartHome/Devices/3/Watt", 1],
	["openWB/SmartHome/Devices/4/Watt", 1],
	["openWB/SmartHome/Devices/5/Watt", 1],
	["openWB/SmartHome/Devices/6/Watt", 1],
	["openWB/SmartHome/Devices/7/Watt", 1],
	["openWB/SmartHome/Devices/8/Watt", 1],
	["openWB/SmartHome/Devices/9/Watt", 1],
	["openWB/SmartHome/Devices/1/RelayStatus", 1],
	["openWB/SmartHome/Devices/2/RelayStatus", 1],
	["openWB/SmartHome/Devices/3/RelayStatus", 1],
	["openWB/SmartHome/Devices/4/RelayStatus", 1],
	["openWB/SmartHome/Devices/5/RelayStatus", 1],
	["openWB/SmartHome/Devices/6/RelayStatus", 1],
	["openWB/SmartHome/Devices/7/RelayStatus", 1],
	["openWB/SmartHome/Devices/8/RelayStatus", 1],
	["openWB/SmartHome/Devices/9/RelayStatus", 1],
	["openWB/SmartHome/Devices/1/Status", 1],
	["openWB/SmartHome/Devices/2/Status", 1],
	["openWB/SmartHome/Devices/3/Status", 1],
	["openWB/SmartHome/Devices/4/Status", 1],
	["openWB/SmartHome/Devices/5/Status", 1],
	["openWB/SmartHome/Devices/6/Status", 1],
	["openWB/SmartHome/Devices/7/Status", 1],
	["openWB/SmartHome/Devices/8/Status", 1],
	["openWB/SmartHome/Devices/9/Status", 1],
	["openWB/SmartHome/Devices/1/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/2/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/3/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/4/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/5/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/6/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/7/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/8/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/9/RunningTimeToday", 1],

	// system topics
	["openWB/system/Timestamp", 0],
	["openWB/system/debug", 0],	
	["openWB/system/Uptime", 0],
	["openWB/system/devicename", 0],
    ["openWB/system/regelneeds", 0]

];


var lastlivesubcribted=false;
var livesubcribted=false;
var daysubcribted=false;
var monthubcribted=false;



// holds number of topics flagged 1 initially
var countTopicsNotForPreloader = topicsToSubscribe.filter(row => row[1] === 1).length;

var retries = 0;
var topics = 0;

//Connect Options
if ( typeof MOSQSERVER === 'undefined' )
{
     MOSQSERVER =location.hostname;
	 MOSQPORTSSL=443
	 MOSQPORT=9001
	 usern='';
	 passwd='';
	 iscloud=false;
}	 
var isSSL = location.protocol == 'https:'
var port = isSSL ? MOSQPORTSSL : MOSQPORT;

console.log('MOSQSERVER', MOSQSERVER);
console.log('usern:', usern);
console.log('port:', port);
console.log('iscloud',iscloud);
console.log('isSSL',isSSL);

var options = {
 	ports: [ port ],
	hosts: [ MOSQSERVER ],
	userName: usern,
	password: passwd,
	timeout: 5,
	useSSL: isSSL,
	//Gets Called if the connection has sucessfully been established
	onSuccess: function () {
		retries = 0;
		topicsToSubscribe.forEach((topic) => {
			clientsubscribe(topic[0], {qos: 0});
		});
		if (wbdata.graphMode == 'day') {
			subscribeDayGraph(new Date());
		} else {	// live
			subscribeLiveGraphSegments();
			subscribeGraphUpdates();
		}
		if( iscloud )
		{
			console.log('send 1 to openWB/set/graph/RequestLLiveGraph');
			publish("1",  "openWB/set/graph/RequestLLiveGraph");
		}	
		console.log('countTopicsNotForPreloader', countTopicsNotForPreloader , ' von ', topics);
	},
	//Gets Called if the connection could not be established
	onFailure: function (message) {
		setTimeout(function() { client.connect(options); }, 5000);
	}
};

var clientuid = Math.random().toString(36).replace(/[^a-z]+/g, "").substr(0, 5);
console.log('mqtt client ' , MOSQSERVER, port, clientuid); 
var client = new Messaging.Client(MOSQSERVER, port, clientuid);

$(document).ready(function () {
	client.connect(options);
	timeOfLastMqttMessage = Date.now();
});

//Gets  called if the websocket/mqtt connection gets disconnected for any reason
client.onConnectionLost = function (responseObject) {
	client.connect(options);
};
//Gets called whenever you receive a message
client.onMessageArrived = function (message) {
    mqttmsg = message.destinationName;
	//console.log('topic ', mqttmsg, message.payloadString);
	if( typeof usern !== 'undefined' && usern>'' )
	{
		mqttmsg  = mqttmsg.replace(usern+'/'  , '');
		//console.log('topic now ', mqttmsg, message.payloadString);
	}	
	handlevar(mqttmsg, message.payloadString);
};


function subscribeLiveGraphSegments() {
	if(livesubcribted)
	{
		console.log('##### subscribeLiveGraphSegements, allredy done skip')
	} else
	{
		console.log('SubScribeLiveGraphSegements');
		for (var segments = 1; segments < 17; segments++) {
			if(iscloud ) topic = "openWB/system/" + segments + "alllivevalues";
 				    else topic = "openWB/graph/" + segments + "alllivevalues";
			
			clientsubscribe(topic, { qos: 0 });
		}
		livesubcribted=true;
	}
	if( iscloud) {
		console.log('send 1 to openWB/set/graph/RequestLLiveGraph');
		publish("1",  "openWB/set/graph/RequestLLiveGraph");
	}
}

function unsubscribeLiveGraphSegments() {
	if(livesubcribted)
	{
		console.log('unSubScribeLiveGraphSegements');
		for (var segments = 1; segments < 17; segments++) {
			if(iscloud ) topic = "openWB/system/" + segments + "alllivevalues";
 				    else topic = "openWB/graph/" + segments + "alllivevalues";
			clientunsubscribe(topic);
		}
		livesubcribted=false;
	} else
	 	console.log('##### unSubScribeLiveGraphSegments not subscribted, skip');
}

function subscribeGraphUpdates() {
	if( lastlivesubcribted )
	{
		console.log('##### subscribeGraphUpdates, allredy done skip')
	} else
	{
		console.log('SubScribeGraphUpdate');
		if(iscloud ) topic = "openWB/system/lastlivevalues";
 			    else topic = "openWB/graph/lastlivevalues";
		clientsubscribe(topic, { qos: 0 });
		lastlivesubcribted=true;
	}
}

function unsubscribeGraphUpdates() {
	if( lastlivesubcribted )
	 {
	 	console.log('unSubScribeGraphUpdate');
		if(iscloud ) topic = "openWB/system/lastlivevalues";
			else 	 topic = "openWB/graph/lastlivevalues";
 	 	clientunsubscribe(topic);
		lastlivesubcribted=false;
	 } else
	 	console.log('##### unSubScribeGraphUpdate not subscribted, skip');
	 
}

function subscribeDayGraph(date) {
	if( daysubcribted )
	{
		console.log('##### subscribeDayGraph, allredy done skip')
	} else
	{
		console.log('SubScribeDayGraph');
		// var today = new Date();
		var dd = String(date.getDate()).padStart(2, '0');
		var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = date.getFullYear();
		graphdate = yyyy + mm + dd;
		for (var segment = 1; segment < 13; segment++) {
			var topic = "openWB/system/DayGraphData" + segment;
			clientsubscribe(topic, { qos: 0 });
		}
		daysubcribted=true;
	}
	publish(graphdate, "openWB/set/graph/RequestDayGraph");
}

function unsubscribeDayGraph() {
	if( daysubcribted )
	 {
		console.log('unSubScribeDayGraph');
		for (var segment = 1; segment < 13; segment++) {
			var topic = "openWB/system/DayGraphData" + segment;
			clientunsubscribe(topic);
		}
		daysubcribted=false;
	} else 
		console.log('##### unSubScribeDayGraph not subscribted, skip');
	publish("0", "openWB/set/graph/RequestDayGraph");
}

function subscribeMonthGraph(date) {
	if( monthubcribted )
	{
		console.log('##### subscribeMonthGraph, allredy done skip')
	} else
	{
		console.log('SubScribeMonthGraphV1');
		var mm = String(date.month + 1).padStart(2, '0'); //January is 0!
		var yyyy = date.year;
		graphdate = yyyy + mm;
		for (var segment = 1; segment < 13; segment++) {
			var topic = "openWB/system/MonthGraphDatan" + segment;
			clientsubscribe(topic, { qos: 0 });
		}
		monthubcribted=true;
	}
	publish(graphdate, "openWB/set/graph/RequestMonthGraphv1");
}

function unsubscribeMonthGraph() {
	if( monthubcribted )
	 {
		console.log('unSubScribeMonthGraphV1');
		for (var segment = 1; segment < 13; segment++) {
			var topic = "openWB/system/MonthGraphDatan" + segment;
			clientunsubscribe(topic);
		}
		monthubcribted=false;
	} else
		console.log('##### unSubScribeMonthGraph not subscribted, skip');
	publish("0", "openWB/set/graph/RequestMonthGraphv1");
}



function clientsubscribe(topic) 
{
	if( usern>'')
		{ 
				//console.log('Subscripe2 ', usern + '/' + topic)
				client.subscribe( usern + '/' + topic, {qos: 0});
		} else {
				//console.log('Subscripe2 ', topic)
				client.subscribe( topic, {qos: 0});
		};  

   topics++;
   //console.log('topcis:',topics+ '  subscribe:'+ topic)
}
function clientunsubscribe(topic) {
	if( iscloud && usern>'' )
		topic = usern + '/' + topic;
   client.unsubscribe(topic, { onFailure : function(x){ alert('Oh ha!');}  } );
   topics--;
   //console.log('topcis:',topics+'  unsubscribe '+topic)
   if( topics < 0 )
   {
     console.log('!!!!!!!!!!! topcs < 0 !!!!!!!!!!');
	 topics=0;
   }
}


//Creates a new Messaging.Message Object and sends it
function publish(payload, topic) {
	if( iscloud && usern>'' )
		topic = usern + '/' + topic;
	console.log('MQTT SEND ', topic, ' =  [', payload, ']');
	var message = new Messaging.Message(payload);
	message.destinationName = topic;
	message.qos = 2;
	message.retained = true;
	client.send(message);
//	var message = new Messaging.Message("local client uid: " + clientuid + " sent: " + topic);
//	message.destinationName = "openWB/set/system/topicSender";
//	message.qos = 2;
//	message.retained = true;
//	client.send(message);
}
