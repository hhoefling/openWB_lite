/**
 * Functions to provide services for MQTT
 *
 * @author Kevin Wieland
 * @author Michael Ortenstein
 */
 
 
console.log('usern:', usern, passwd);
console.log('iscloud',iscloud)

// bei clound
// function requestlivegraph() {
//        publish("1",  "openWB/set/graph/RequestLLiveGraph");
// }

var dbdeb;

var timeOfLastMqttMessage = 0;

// these topics will be subscribed
// index 1 represents flag if value was received, needed for preloader progress bar
// if flags are preset with 1 they are not counted on reload and page will show even if topic was not received

var topicsToSubscribeLocal = [
	["openWB/graph/lastlivevalues", 1],
	["openWB/graph/1alllivevalues", 1],
	["openWB/graph/2alllivevalues", 1],
	["openWB/graph/3alllivevalues", 1],
	["openWB/graph/4alllivevalues", 1],
	["openWB/graph/5alllivevalues", 1],
	["openWB/graph/6alllivevalues", 1],
	["openWB/graph/7alllivevalues", 1],
	["openWB/graph/8alllivevalues", 1],
	["openWB/graph/9alllivevalues", 1],
	["openWB/graph/10alllivevalues", 1],
	["openWB/graph/11alllivevalues", 1],
	["openWB/graph/12alllivevalues", 1],
	["openWB/graph/13alllivevalues", 1],
	["openWB/graph/14alllivevalues", 1],
	["openWB/graph/15alllivevalues", 1],
	["openWB/graph/16alllivevalues", 1],
];


var topicsToSubscribeCloud = [
	["openWB/system/lastlivevalues", 1],
	["openWB/system/1alllivevalues", 1],
	["openWB/system/2alllivevalues", 1],
	["openWB/system/3alllivevalues", 1],
	["openWB/system/4alllivevalues", 1],
	["openWB/system/5alllivevalues", 1],
	["openWB/system/6alllivevalues", 1],
	["openWB/system/7alllivevalues", 1],
	["openWB/system/8alllivevalues", 1],
	["openWB/system/9alllivevalues", 1],
	["openWB/system/10alllivevalues", 1],
	["openWB/system/11alllivevalues", 1],
	["openWB/system/12alllivevalues", 1],
	["openWB/system/13alllivevalues", 1],
	["openWB/system/14alllivevalues", 1],
	["openWB/system/15alllivevalues", 1],
	["openWB/system/16alllivevalues", 1]
];


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
	["openWB/Verbraucher/1/Name", 1],
	["openWB/Verbraucher/1/Watt", 1],
	["openWB/Verbraucher/1/DailyYieldImportkWh", 1],
	["openWB/Verbraucher/2/Configured", 0],
	["openWB/Verbraucher/2/Name", 1],
	["openWB/Verbraucher/2/Watt", 1],
	["openWB/Verbraucher/2/DailyYieldImportkWh", 1],
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

	// etprovider topics
	["openWB/global/ETProvider/modulePath", 1],
	["openWB/global/awattar/boolAwattarEnabled", 0],
	["openWB/global/awattar/MaxPriceForCharging", 1],
	["openWB/global/awattar/ActualPriceForCharging", 1],
	["openWB/global/awattar/pricelist", 1],

	// graph topics.   Speicher , nur auf dem Webssrver-mqtt. kommt nicht aus dem Haus
	["openWB/graph/boolDisplayLp1", 0],
	["openWB/graph/boolDisplayLp2", 0],
	["openWB/graph/boolDisplayLp3", 0],
	["openWB/graph/boolDisplayHouseConsumption", 0],
	["openWB/graph/boolDisplayLoad1", 0],
	["openWB/graph/boolDisplayLoad2", 0],
	["openWB/graph/boolDisplayLp1Soc", 0],
	["openWB/graph/boolDisplayLp2Soc", 0],
	["openWB/graph/boolDisplayLpAll", 0],
	["openWB/graph/boolDisplaySpeicherSoc", 0],
	["openWB/graph/boolDisplaySpeicher", 0],
	["openWB/graph/boolDisplayEvu", 0],
	["openWB/graph/boolDisplayLegend", 0],
	["openWB/graph/boolDisplayPv", 0],
	["openWB/graph/boolDisplayShD1", 0],
	["openWB/graph/boolDisplayShD2", 0],
	["openWB/graph/boolDisplayShD3", 0],
	["openWB/graph/boolDisplayShD4", 0],
	["openWB/graph/boolDisplayShD5", 0],
	["openWB/graph/boolDisplayShD6", 0],
	["openWB/graph/boolDisplayShD7", 0],
	["openWB/graph/boolDisplayShD8", 0],
	["openWB/graph/boolDisplayShD9", 0],

	// global topics
	["openWB/global/WHouseConsumption", 1],
	["openWB/global/ChargeMode", 1],
	["openWB/global/WAllChargePoints", 1],
	["openWB/global/strLastmanagementActive", 1],
	["openWB/config/get/pv/priorityModeEVBattery", 1],
	["openWB/config/get/pv/minCurrentMinPv", 1],
	// system topics
	["openWB/system/Timestamp", 1],
	["openWB/system/debug", 1],	
	["openWB/system/devicename", 1],	
	["openWB/system/Version", 1],	
	
	// pv topics
	["openWB/pv/W", 1],
	["openWB/pv/DailyYieldKwh", 1],
	// evu topics
	["openWB/evu/W", 1],
	// lp topics
	["openWB/lp/1/%Soc", 1],
	["openWB/lp/2/%Soc", 1],
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
	["openWB/lp/1/ADirectModeAmps", 1],
	["openWB/lp/2/ADirectModeAmps", 1],
	["openWB/lp/3/ADirectModeAmps", 1],
	// Zielladen
	["openWB/lp/1/boolFinishAtTimeChargeActive", 1],
	// FaultState
	["openWB/lp/+/faultState", 1],
	// housebattery values
	["openWB/housebattery/W", 1],
	["openWB/housebattery/%Soc", 1],
	// Daily Yields
	["openWB/housebattery/DailyYieldImportKwh", 1],
	["openWB/housebattery/DailyYieldExportKwh", 1],
	["openWB/global/DailyYieldHausverbrauchKwh", 1],
	["openWB/global/DailyYieldAllChargePointsKwh", 1],
	["openWB/evu/DailyYieldImportKwh", 1],
	["openWB/evu/DailyYieldExportKwh", 1],

	// hook status
	["openWB/hook/1/boolHookStatus", 1],
	["openWB/hook/2/boolHookStatus", 1],
	["openWB/hook/3/boolHookStatus", 1],

	// Smart Home Devices, only configured is definitely set, other values only set if configured, assume they are there!
	["openWB/SmartHome/Devices/1/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/2/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/3/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/4/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/5/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/6/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/7/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/8/DailyYieldKwh", 1],
	["openWB/SmartHome/Devices/9/DailyYieldKwh", 1],
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
	["openWB/SmartHome/Devices/1/Status", 1],
	["openWB/SmartHome/Devices/2/Status", 1],
	["openWB/SmartHome/Devices/3/Status", 1],
	["openWB/SmartHome/Devices/4/Status", 1],
	["openWB/SmartHome/Devices/5/Status", 1],
	["openWB/SmartHome/Devices/6/Status", 1],
	["openWB/SmartHome/Devices/7/Status", 1],
	["openWB/SmartHome/Devices/8/Status", 1],
	["openWB/SmartHome/Devices/9/Status", 1],
	["openWB/SmartHome/Devices/1/RelayStatus", 1],
	["openWB/SmartHome/Devices/2/RelayStatus", 1],
	["openWB/SmartHome/Devices/3/RelayStatus", 1],
	["openWB/SmartHome/Devices/4/RelayStatus", 1],
	["openWB/SmartHome/Devices/5/RelayStatus", 1],
	["openWB/SmartHome/Devices/6/RelayStatus", 1],
	["openWB/SmartHome/Devices/7/RelayStatus", 1],
	["openWB/SmartHome/Devices/8/RelayStatus", 1],
	["openWB/SmartHome/Devices/9/RelayStatus", 1],
	
	["openWB/config/get/SmartHome/Devices/1/mode", 1],
	["openWB/config/get/SmartHome/Devices/2/mode", 1],
	["openWB/config/get/SmartHome/Devices/3/mode", 1],
	["openWB/config/get/SmartHome/Devices/4/mode", 1],
	["openWB/config/get/SmartHome/Devices/5/mode", 1],
	["openWB/config/get/SmartHome/Devices/6/mode", 1],
	["openWB/config/get/SmartHome/Devices/7/mode", 1],
	["openWB/config/get/SmartHome/Devices/8/mode", 1],
	["openWB/config/get/SmartHome/Devices/9/mode", 1],
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

	["openWB/SmartHome/Devices/1/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/2/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/3/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/4/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/5/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/6/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/7/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/8/RunningTimeToday", 1],
	["openWB/SmartHome/Devices/9/RunningTimeToday", 1],
	["openWB/pv/bool70PVDynStatus", 1],
	["openWB/config/get/pv/nurpv70dynact", 1]
];

// holds number of topics flagged 1 initially
var countTopicsNotForPreloader = topicsToSubscribe.filter(row => row[1] === 1).length;

function subscribe1(topic)
{
	if( usern>'')
		{ 
			  //console.log('Subscripe2 ', usern + '/' + topic)
				client.subscribe( usern + '/' + topic, {qos: 0});
		} else {
				//  console.log('Subscripe2 ', topic)
				client.subscribe( topic, {qos: 0});
		};  
}

var retries = 0;
var isSSL = location.protocol == 'https:'
var port = isSSL ? 443 : 9001;

//Connect Options
if ( typeof MOSQSERVER === 'undefined' )
{
     MOSQSERVER =location.hostname;
	 usern='';
	 passwd='';
	 iscloud=false;
}	 
console.log('MOSQSERVER', MOSQSERVER);
console.log('usern:', usern);
console.log('port:', port);
console.log('iscloud',iscloud);

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
		topicsToSubscribe.forEach((topic) => { 	subscribe1(topic[0], {qos: 0}); });
	if( iscloud )
		{
		  topicsToSubscribeCloud.forEach((topic) => { subscribe1(topic[0]); });
		  publish("1",  "openWB/set/graph/RequestLLiveGraph");
		}
	else 
		{
		  topicsToSubscribeLocal.forEach((topic) => { subscribe1(topic[0]); });
		}
	// bei cloud requestlivegraph();
	timeOfLastMqttMessage = Date.now();			
	},
	//Gets Called if the connection could not be established
	onFailure: function (message) {
		setTimeout(function() { client.connect(options); }, 5000);
	}
};

var clientuid = Math.random().toString(36).replace(/[^a-z]+/g, "").substr(0, 5);
console.log('mqtt client ' , MOSQSERVER, port, clientuid); 
var client = new Messaging.Client(MOSQSERVER, port, clientuid);

$(document).ready(function(){
	client.connect(options);
	timeOfLastMqttMessage = Date.now();
});

//Gets  called if the websocket/mqtt connection gets disconnected for any reason
client.onConnectionLost = function (responseObject) {
	client.connect(options);
};
//Gets called whenever you receive a message
client.onMessageArrived = function (message) {
	handlevar(message.destinationName, message.payloadString);
};

//Creates a new Messaging.Message Object and sends it
function publish(payload, topic) {
	if( iscloud && usern>'' )
		topic = usern + '/' + topic;
	console.log('MQTT publish('+topic+')='+ payload);
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
