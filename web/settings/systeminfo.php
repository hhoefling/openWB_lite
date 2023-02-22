<!DOCTYPE html>
<html lang="de">

	<head>
		<base href="/openWB/web/">

		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>openWB Systeminfo</title>
		<meta name="author" content="Michael Ortenstein" />
		<!-- Favicons (created with http://realfavicongenerator.net/)-->
		<link rel="apple-touch-icon" sizes="57x57" href="img/favicons/apple-touch-icon-57x57.png">
		<link rel="apple-touch-icon" sizes="60x60" href="img/favicons/apple-touch-icon-60x60.png">
		<link rel="icon" type="image/png" href="img/favicons/favicon-32x32.png" sizes="32x32">
		<link rel="icon" type="image/png" href="img/favicons/favicon-16x16.png" sizes="16x16">
		<link rel="manifest" href="manifest.json">
		<link rel="shortcut icon" href="img/favicons/favicon.ico">
		<meta name="msapplication-TileColor" content="#00a8ff">
		<meta name="msapplication-config" content="img/favicons/browserconfig.xml">
		<meta name="theme-color" content="#ffffff">

		<!-- Bootstrap -->
		<link rel="stylesheet" type="text/css" href="css/bootstrap-4.4.1/bootstrap.min.css">
		<!-- Normalize -->
		<link rel="stylesheet" type="text/css" href="css/normalize-8.0.1.css">
		<!-- include settings-style -->
		<link rel="stylesheet" type="text/css" href="css/settings_style.css">

		<!-- important scripts to be loaded -->
		<script src="js/jquery-3.6.0.min.js"></script>
		<script src="js/bootstrap-4.4.1/bootstrap.bundle.min.js"></script>
		<!-- load helper functions -->
		<script src = "settings/helperFunctions.js?ver=20210329" ></script>
	</head>

	<body>

		<?php

			// read selected releasetrain from config file
			$lines = file($_SERVER['DOCUMENT_ROOT'] . '/openWB/openwb.conf');
			foreach($lines as $line) {
				if(strpos($line, "releasetrain=") !== false) {
					list(, $releasetrain) = explode("=", $line);
				}
				else if(strpos($line, "devicename=") !== false) {
					list(, $devicename) = explode("=", $line);
				}			}
			$releasetrain = trim($releasetrain);

			if ( $releasetrain == "" ) {
				// if no releasetrain set, set stable
				$releasetrain="stable";
			}
			if ( $releasetrain == "stable17" ) {
				// if no releasetrain set, set stable
				$releasetrain="stable";
			}
			
		?>

		<div id="nav-placeholder"></div>
		<div role="main" class="container" style="margin-top:20px">
			<h1>Systeminfo</h1>

			<div class="card border-secondary">
				<div class="card-header bg-secondary">
					Software
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col">
							Kernel: <?php echo exec('uname -ors'); echo " (", exec('/var/www/html/openWB/runs/distro.sh'), ")"; ?><br>
							<?php echo exec('python3 -V'); ?><br>
							openWB Version: <span id="installedVersionSpan" data-version=""></span>
						</div>
					</div>
				</div>
			</div>


			<div class="card border-secondary">
				<div class="card-header bg-secondary">
					Hardware
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col">

							Board: <span id="board">--</span><br>
							CPU: <?php echo exec('cat /proc/cpuinfo | grep -m 1 "model name" | sed "s/^.*: //"'); ?><br>
							CPU-Kerne: <?php echo exec('cat /proc/cpuinfo | grep -E "processor\s*:" | wc -l'); ?><br>
						</div>
					</div>
				</div>
			</div>

			<div class="card border-secondary">
				<div class="card-header bg-secondary">
					System
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col">
							<p>
								Systemzeit: <span id="systemtime">--</span><br>
								Letzter Systemstart: <span id="lastreboot">--</span><br>
								System-Laufzeit: <span id="uptime">--</span><br>
							</p>
							<p>
								CPU-Frequenz: <span id="cpufreq">--</span>MHz<br>
								CPU-Temperatur: <span id="cputemp">--</span>°C<br>
								CPU-Last: <meter id="cpu" high=85 min=0 max=100 value=0></meter> <span id="cpuuse">--</span>% <br>
								Durchschnittslast: <span id="loadaverage">--</span>
							</p>
							<p>
								RAM: <span id="memtot">--</span>MB
								<meter id="memMeter" min=0 max=0 value=0></meter> (<span id='memused'>--</span>MB genutzt)
							</p>
							<p>
                                Root Filesystem: <span id="disktot">--</span>, davon <span id="diskfree">--</span> verfügbar / <meter id="disk" high=65 min=0 max=100 value=0></meter> <span id="diskusedprz">--</span>% belegt 
								auf: <span id="rootdev">--</span> <br> 
                                TMP Filesystem: <span id="tmptot">--</span>, davon <span id="tmpfree">--</span> verfügbar / <meter id="tmp" high=65 min=0 max=100 value=0></meter> <span id="tmpusedprz">--</span>% belegt
								<br>
								Status: <span id="sdstatus">--</span>
							</p>
							IP-Adresse LAN: <span id="iplan">--</span><br>
							IP-Adresse WLAN: <span id="ipwifi">--</span>
							<div class="hide" id="wifidata">
								<ul>
									<li><span id="wifissid">--</span></li>
									<li><span id="wifimode">--</span></li>
									<li><span id="wifiqualy">--</span></li>
									<li><span id="wifibitrate">--</span></li>
									<li><span id="wifipower">--</span></li>
									<li><span id="wifirx">--</span></li>
									<li><span id="wifitx">--</span>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
			
	        <div class="card border-secondary">
				<div class="card-header bg-secondary">
					Netzwerk
				</div>
				<div class="card-body" style="padding:0.25em;">
					<div class="row">
						<div class="col">
							<p><pre style="font-size:0.7em;"><?php 
											$lines=[];
											exec('sudo netstat -nap | egrep "VERBUNDEN|ESTABLISHED|LISTEN" | grep tcp ', $lines);
											echo implode('<br>',$lines);
                                       ?>		
                            	</pre>
							</p>
						</div>
					</div>
				</div>
				<div class="card-header bg-secondary">
					Processe
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col">
							<p><pre style="font-size:0.7em;"><?php 
											$lines=[];
											exec('sudo ps -efl | grep -E "openWB|runs|tsp" | grep -v grep | grep -v sudo ', $lines);
                                            $lines[]="";
											echo implode('<br>',$lines);
                                       ?>
								</pre>
							</p>
						</div>
					</div>
				</div>

				<div class="card-header bg-secondary">
					Regelschleife
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col">
							<?php 
											$lines=[];
											exec('/var/www/html/openWB/statregel.sh -t', $lines);
											echo implode('',$lines);
                                  ?>
						</div>
					</div>
				</div>

			</div>


		</div>  <!-- container -->

		<footer class="footer bg-dark text-light font-small">
			<div class="container text-center">
				<small>Sie befinden sich hier: System/Systeminfo</small>
			</div>
		</footer>

		<script>

			// load navbar, be careful: it loads asynchronous
			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav-placeholder").replaceWith(data);
					$('#navSystemInfo').addClass('disabled');
				}
			);

			$(document).ready(function(){

                $('.devicename').text("<?php echo trim($devicename); ?>");

				function getVersion(dataURL) {
					// read dataURL filecontent = releasetrain version and return it
					return $.get({
						url: dataURL,
						cache: false
					});
				}

				$.get({
					url: '/openWB/web/version',
					cache: false
				})
				.done(function(result) {
					$('#installedVersionSpan').prepend(result);
					$('#installedVersionSpan').data('version', result);
				});

				if( '<?php echo $releasetrain ?>' == 'master' ) {
					$.get({
						url: '/openWB/web/lastcommit',
						cache: false
					})
					.done(function(result) {
						$('#installedVersionSpan').append(' ('+result+')');
					});
				}

				function updatesysteminfo() {
					function addTimePart(timePart, timePartUnit, extension) {
						if (timePart > 0) {
							var result = timePart + ' ' + timePartUnit;
							if (timePart > 1) result += extension;
							return result + ', ';
						} else return '';
					}

					$.getJSON('tools/programmloggerinfo.php', function(data){
						json = eval(data);
						$('#board').text(json.board);
						$('#cpu').val(json.cpuuse);
						$('#cpuuse').text(json.cpuuse);
						$('#cputemp').text((json.cputemp/1000).toFixed(2));
						$('#cpufreq').text((json.cpufreq/1000));
						$('#memtot').text(json.memtot);
						$('#memused').text(json.memuse);
						if (json.rootdev == 'mmcblk0p2') 
						   {	$('#rootdev').text('SD Karte');	} 
					   else
						   { $('#rootdev').text(json.rootdev); }
						$('#disktot').text(json.disktot);
						$('#diskuse').text(json.diskuse);
						$('#diskfree').text(json.diskfree);
						$('#diskusedprz').text(json.diskusedprz);
						$('#disk').val(json.diskusedprz);
						$('#tmptot').text(json.tmptot);
						$('#tmpuse').text(json.tmpuse);
						$('#tmpfree').text(json.tmpfree);
						$('#tmpusedprz').text(json.tmpusedprz);
						$('#tmp').val(json.tmpusedprz);
						if (json.sdstatus == "0" )
						   $('#sdstatus').text('RW-Test: Ok, Karte beschreibbar.');
						else if (json.sdstatus == "1" ) 
						   $('#sdstatus').html('RW-Test: <span style="background-color:red;">&nbsp;Fail, Karte im Read-Only Mode, Bitte austauschen.&nbsp;</span>' );
						else
						   $('#sdstatus').text('RW-Test: Abfrage fehlerhaft');

						$('#memMeter').attr({'max': json.memtot, 'high': (json.memtot*0.85)});
						$('#memMeter').val(json.memuse);
						if (json.ethaddr != '') {
							$('#iplan').text( json.ethaddr   + ( (json.ethaddr2=='')? '' :' ,  ' ) + json.ethaddr2 );
						} else {
							$('#iplan').text('--');
						}
						if (json.wlanaddr != '') {
							$('#wifidata').show();
							$('#ipwifi').text( json.wlanaddr + ( (json.wlanaddr2=='')? '' :' ,  ' )  + json.wlanaddr2 );
							$('#wifiqualy').text(json.wlanqualy);
							$('#wifissid').text(json.wlanssid);
							$('#wifimode').text(json.wlanmode);
							$('#wifibitrate').text(json.wlanbitrate);
							$('#wifipower').text(json.wlanpower);
							$('#wifirx').text(json.wlanrx);
							$('#wifitx').text(json.wlantx);
						} else {
							$('#wifidata').hide();
							$('#ipwifi').text('--');
						}

						const options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', timeZoneName: 'short' };
						var systemTimeDate = new Date(json.systime * 1000);  // json comes in Unix-time without milliseconds
						var formattedSystemTime = systemTimeDate.toLocaleDateString(undefined, options);
						$('#systemtime').text(formattedSystemTime);
						var lastRebootTimeDate = new Date(json.lastreboot * 1000);  // json comes in Unix-time without milliseconds
						var formattedLastRebootTime = lastRebootTimeDate.toLocaleDateString(undefined, options);
						$('#lastreboot').text(formattedLastRebootTime);

						var upTimeUnix = json.systime - json.lastreboot;
						var weeksUp = Math.floor(upTimeUnix / 604800);
						upTimeUnix -= weeksUp * 604800;
						var daysUp = Math.floor(upTimeUnix / 86400);
						upTimeUnix -= daysUp * 86400;
						var hoursUp = Math.floor(upTimeUnix / 3600) % 24;
						upTimeUnix -= hoursUp * 3600;
						var minutesUp = Math.floor(upTimeUnix / 60) % 60;
						upTimeUnix -= minutesUp * 60;
						var secondsUp = upTimeUnix % 60;
						var formattedUpTime = addTimePart(weeksUp, 'Woche', 'n') + addTimePart(daysUp, 'Tag', 'e');
						formattedUpTime = formattedUpTime + addTimePart(hoursUp, 'Stunde', 'n') + addTimePart(minutesUp, 'Minute', 'n') + addTimePart(secondsUp, 'Sekunde', 'n');
						formattedUpTime = formattedUpTime.substr(0, formattedUpTime.length-2);
						$('#uptime').text(formattedUpTime);

						var pattern = 'load average:';
						var loadAverage = json.uptime.substr(json.uptime.indexOf(pattern) + pattern.length, json.uptime.length);
						$('#loadaverage').text(loadAverage);

					})
				}

				updatesysteminfo();
				setInterval(updatesysteminfo, 2000);

			});

		</script>

	</body>
</html>
