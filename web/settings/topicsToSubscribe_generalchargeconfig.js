/**
 * set of topics that has to be subscribed for the general charge settings
 *
 * @author Kevin Wieland
 * @author Michael Ortenstein
 */

// line[0] = topic
// line[1] = load counter (if needed)

var topicsToSubscribe = [
	["openWB/system/devicename", 0],
	["openWB/system/debuglevel", 0],
	["openWB/config/get/global/maxEVSECurrentAllowed", 0],
	["openWB/config/get/global/minEVSECurrentAllowed", 0]	
];
