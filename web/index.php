<?php

require_once("includes/site_conf.inc");

$debug=$dbdeb;

/**
 * Support samesite cookie flag in both php 7.2 (current production) and php >= 7.3 (when we get there)
 * From: https://github.com/GoogleChromeLabs/samesite-examples/blob/master/php.md and https://stackoverflow.com/a/46971326/2308553 
 *
 * @see https://www.php.net/manual/en/function.setcookie.php
 *
 * @param string $name
 * @param string $value
 * @param int $expire
 * @param string $path
 * @param string $domain
 * @param bool $secure
 * @param bool $httponly
 * @param string $samesite
 * @return void
 */
function setCookieSameSite(
    string $name, string $value,
    int $expire, string $path, string $domain,
    bool $secure, bool $httponly, string $samesite = 'None'
) {
    if (PHP_VERSION_ID < 70300) {
        setcookie($name, $value, $expire, $path . '; samesite=' . $samesite, $domain, $secure, $httponly);
        return;
    }
    setcookie($name, $value, [
        'expires' => $expire,
        'path' => $path,
        'domain' => $domain,
        'samesite' => $samesite,
        'secure' => $secure,
        'httponly' => $httponly,
    ]);
}

function  getdateurl($dir,$file)
	{
 			$fn=sprintf('./%s/%s', $dir,$file);
			$ftime=filemtime("$dir/$file");
			return sprintf('%s?w=%d' , $fn,$ftime);
	
 	}


	$owbconf=[];
	// check if update.sh is still running
	$updateinprogress = file_get_contents($_SERVER['DOCUMENT_ROOT'] . '/openWB/ramdisk/updateinprogress');
	// check if atreboot.sh is still running
	$bootinprogress = file_get_contents($_SERVER['DOCUMENT_ROOT'] . '/openWB/ramdisk/bootinprogress');
	// if yes, show placeholder. If not, show theme
	if ( $bootinprogress == 1 or $updateinprogress == 1) {
		//atreboot.sh or update.sh still in progress, wait 5 seconds and retry
		include 'notready.html';
	} else {
		// load openwb.conf
		$lines = file($_SERVER['DOCUMENT_ROOT'] . '/openWB/openwb.conf');
		foreach($lines as $line) {
			list($key, $value) = explode("=", $line, 2);
			$owbconf[$key]=$value;
			// ${$key."old"} = trim( $value, " '\t\n\r\0\x0B" ); // remove all garbage and single quotes
		}
		unset($line);
		unset($key);
		unset($value);
		$debugold=$owbconf['debug'];
		$debug=$dbdeb;
		out('debug form owb.conf:'.$debugold);
		if($debugold>$debug)
			$debug=$debugold;
		out('debug now:'.$debug);

		// check for acknoledgement of dataprotection
		if ( $owbconf['datenschutzack'] == 0 && $owbconf['clouduser'] !== "leer") {
			// load dataprotection page
			include 'settings/datenschutz.html';
		} elseif ( !isset($owbconf['wizzarddone']) || ($owbconf['wizzarddone'] < 100) ) {
			// load wizzard page
			include 'settings/wizzard.php';
		} elseif ( $owbconf['isss'] == 1 ) {
			// load chargepoint only page
			include 'isss.html';
		} else 
		{
			// load normal UI
			// check if theme cookie exists and theme is installed
			// else set standard theme
			if ( !(isset($_COOKIE['openWBTheme'] ) === true) || !(is_dir('themes/'.$_COOKIE['openWBTheme']) === true) ) {
				$_COOKIE['openWBTheme'] = 'standard';
			}
			if (isset($_GET['theme'])) 
			{
	    		$th=trim($_GET['theme']);
				if (is_dir('themes/'.$th) === true)
				   $_COOKIE['openWBTheme'] =$th; 
		    }
			$theme = $_COOKIE['openWBTheme'];  // colors-hh oder colors

			// expand expiring-date to now + 2 years
			$expire = time()+(60*60*24*365*2);
			setCookieSameSite('openWBTheme', $_COOKIE['openWBTheme'], $expire, '/openWB/', '', false, false, 'Lax' );
			// following line is needed because until now the cookie-path was accidentally
			// set to /openWB/web/. So from now on path is /openWB/ to access cookie from all subdirectories
			// therefore delete old cookies by having them expire immediately
		    // setcookie('openWBTheme', '', time() - 3600, '/openWB/web');
			
			$file='themes/' . $_COOKIE['openWBTheme' ];
			if (file_exists(stream_resolve_include_path($file.'/theme.php') ) )
				include($file.'/theme.php');
			else
				include $file.'/theme.html';
		}
	}
?>
