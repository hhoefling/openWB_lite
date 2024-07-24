/**
 * set of topics that have to be subscribed for the error reporting page
 *
 * @author Kevin Wieland
 * @author Michael Ortenstein
 */

// line[0] = topic
// line[1] = load counter (if needed)

var topicsToSubscribe = [
	["openWB/system/devicename", 0],
	["openWB/system/debug", 0],
	["openWB/config/get/global/dataProtectionAcknoledged", 0]
];
