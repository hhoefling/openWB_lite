<?php

$arch =exec('uname -m');


$uptime = exec('uptime');
$systime = exec("date +%s");
$lastreboot = exec("cat /proc/stat | grep btime | awk '{print $2}'");
$cpuuse = exec("ps aux|awk 'NR > 0 { s +=$3 }; END {print \"cpu %\",s}' | awk '{ print $3 }'");


if($arch=="x86_64")
{
	$board='Intel/AMD Maschine'; 
	$cputemp = 44440;
	$cpufreq = 1111000;
	$wlanaddr = '';
	$ethaddr2 = '';
	$wlanaddr2 = '';
	$wlanqualy ='';
	$wlanbitrate = '';
	$wlanrx = '';
	$wlantx = '';
	$wlanpower = '';
	$wlanmode = '';
	$wlanssid = '';
}
else
{   // arch=arm71
	$board = exec('cat /sys/firmware/devicetree/base/model');
	$cputemp = exec("cat /sys/class/thermal/thermal_zone0/temp");	
	$cpufreq = exec("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
	$wlanaddr = exec("ifconfig wlan0 |grep 'inet ' |awk '{print $2}'");
	$ethaddr2 = exec("ifconfig eth0:0 |grep 'inet ' |awk '{print $2}'");
	$wlanaddr2 = exec("ifconfig wlan0:0 |grep 'inet ' |awk '{print $2}'");
	$wlanqualy = exec("iwconfig wlan0 |grep 'Link'");
	$wlanbitrate = exec("iwconfig wlan0 |grep 'Bit'");
	$wlanrx = exec("iwconfig wlan0 |grep 'Rx'");
	$wlantx = exec("iwconfig wlan0 |grep 'Tx'");
	$wlanpower = exec("iwconfig wlan0 |grep 'Power'");
	$wlanmode = exec("iwconfig wlan0 |grep 'Mode'");
	$wlanssid = exec("iwconfig wlan0 |grep 'ESSID'|awk '{print $4}'");
}
$memtot = exec("free -m | grep 'Mem' | awk '{print $2}'");
$memuse = exec("free -m| grep 'Mem' | awk '{print $3}'");
$memfree = exec("free -m| grep 'Mem' | awk '{print $7}'");
$disktot = exec("df -h | grep \"/$\" | awk '{print $2}'");
$diskuse = exec("df -h | grep \"/$\" | awk '{print $3}'");
$diskfree = exec("df -h | grep \"/$\" | awk '{print $4}'");
$diskusedprz=exec("df -h | grep \"/$\" | awk '{print $5}'");
$tmptot=exec("df -h | grep  ramdisk | awk '{print $2}'");
$tmpfree=exec("df -h | grep  ramdisk | awk '{print $4}'");
$tmpusedprz=exec("df -h | grep  ramdisk | awk '{print $5}'");

$ethaddr = exec("ifconfig eth0 |grep 'inet ' |awk '{print $2}'");

$arr = array(
	'board' => trim($board),
	'arch' => trim($arch),
	'uptime' => trim($uptime),
	'systime' => trim($systime),
	'lastreboot' => trim($lastreboot),
	'cpuuse' => trim($cpuuse),
	'cputemp' => trim($cputemp),
	'cpufreq' => trim($cpufreq),
	'memtot' => trim($memtot),
	'memuse' => trim($memuse),
	'memfree' => trim($memfree),
	'disktot' => trim($disktot),                                
	'diskuse' => trim($diskuse),
	'diskfree' => trim($diskfree),	
	'diskusedprz' => str_replace('%','',trim($diskusedprz)),
	'tmptot' => trim($tmptot),
	'tmpfree' => trim($tmpfree),
	'tmpusedprz' => str_replace('%','',trim($tmpusedprz)),
	'ethaddr' => $ethaddr,
	'wlanaddr' => $wlanaddr,
	'ethaddr2' => $ethaddr2,
	'wlanaddr2' => $wlanaddr2,
	'wlanqualy' => $wlanqualy,
	'wlanbitrate' => $wlanbitrate,
	'wlanmode' => $wlanmode,
	'wlanssid' => $wlanssid,
	'wlanpower' => $wlanpower,
	'wlanrx' => $wlanrx,
	'wlantx' => $wlantx
);

header("Content-type: application/json");
echo json_encode($arr);
?>