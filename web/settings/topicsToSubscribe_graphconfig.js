/**
 * set of topics that has to be subscribed for the graph settings
 *
 * @author Kevin Wieland
 * @author Michael Ortenstein
 */

 // line[0] = topic
 // line[1] = load counter (if needed)

var topicsToSubscribe = [
	["openWB/system/devicename", 0],
	["openWB/system/debug", 0],
	["openWB/graph/boolDisplayHouseConsumption", 0],
	["openWB/graph/boolDisplayShD1", 0],
	["openWB/graph/boolDisplayShD2", 0],
	["openWB/graph/boolDisplayShD3", 0],
	["openWB/graph/boolDisplayShD4", 0],
	["openWB/graph/boolDisplayShD5", 0],
	["openWB/graph/boolDisplayShD6", 0],
	["openWB/graph/boolDisplayShD7", 0],
	["openWB/graph/boolDisplayShD8", 0],
	["openWB/graph/boolDisplayShD9", 0],
	["openWB/graph/boolDisplayLoad1", 0],
	["openWB/graph/boolDisplayLoad2", 0],
	["openWB/graph/boolDisplayLp1Soc", 0],
	["openWB/graph/boolDisplayLp2Soc", 0],
	["openWB/graph/boolDisplayLp1", 0],
	["openWB/graph/boolDisplayLp2", 0],
	["openWB/graph/boolDisplayLp3", 0],
	["openWB/graph/boolDisplayLpAll", 0],
	["openWB/graph/boolDisplaySpeicherSoc", 0],
	["openWB/graph/boolDisplaySpeicher", 0],
	["openWB/graph/boolDisplayEvu", 0],
	["openWB/graph/boolDisplayLegend", 0],
	["openWB/graph/boolDisplayLiveGraph", 0],
	["openWB/graph/boolDisplayPv", 0],
	["openWB/housebattery/boolHouseBatteryConfigured", 0],
	["openWB/pv/1/boolPVConfigured", 0],
	["openWB/pv/2/boolPVConfigured", 0],
	["openWB/Verbraucher/1/Configured", 0],
	["openWB/Verbraucher/2/Configured", 0],
	["openWB/system/ConfiguredChargePoints", 0],
	["openWB/lp/1/boolChargePointConfigured", 0],
	["openWB/lp/2/boolChargePointConfigured", 0],
	["openWB/lp/3/boolChargePointConfigured", 0],
	["openWB/lp/1/boolSocConfigured", 0],
	["openWB/lp/2/boolSocConfigured", 0],
	["openWB/config/get/SmartHome/Devices/1/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/2/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/3/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/4/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/5/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/6/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/7/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/8/device_configured", 0],
	["openWB/config/get/SmartHome/Devices/9/device_configured", 0]
	
];
