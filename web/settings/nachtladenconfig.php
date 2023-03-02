<!DOCTYPE html>
<html lang="de">

	<head>
		<base href="/openWB/web/">

		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>openWB Einstellungen</title>
		<meta name="description" content="Control your charge" />
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
		<!-- Bootstrap Selectpicker-->
		<link rel="stylesheet" type="text/css" href="css/bootstrap-selectpicker/bootstrap-select.min.css">

		<link rel="stylesheet" type="text/css" href="fonts/font-awesome-5.8.2/css/all.css">
		<!-- include settings-style -->
		<link rel="stylesheet" type="text/css" href="css/settings_style.css">

		<!-- important scripts to be loaded -->
		<script src="js/jquery-3.6.0.min.js"></script>
		<script src="js/bootstrap-4.4.1/bootstrap.bundle.min.js"></script>
		<script src="js/bootstrap-selectpicker/bootstrap-select.min.js"></script>
		<!-- load helper functions -->
		<script src = "settings/helperFunctions.js?ver=20210329" ></script>
	</head>

	<body>
		<?php
			$lines = file($_SERVER['DOCUMENT_ROOT'] . '/openWB/openwb.conf');
			foreach($lines as $line) {
				list($key, $value) = explode("=", $line, 2);
				${$key."old"} = trim( $value, " '\t\n\r\0\x0B" ); // remove all garbage and single quotes
			}
         //echo "<pre>"; print_r($GLOBALS); echo "</pre>";
		?>
        <script>
          var debugold=<?php echo $debugold;?>;
          var devicename='<?php echo $devicenameold;?>';
          console.log('openWB debug aus openwb.conf:',debugold);
        </script>        

		<div id="nav"></div> <!-- placeholder for navbar -->

		<div role="main" class="container" style="margin-top:20px">
     	   <h1>Einstellungen für Nachtlademodus und das Morgenladen</h1>
			<form action="./settings/saveconfig.php" method="POST">

				<!-- Nachtlademodus -->
				<div class="card border-info">
					<div class="card-header bg-info">
						Nachtlademodus
					</div>
					<div class="card-body">
						<div class="form-group">
							<div class="form-row vaRow mb-1">
								<div class="col">
									Aktivierung je Lademodus
								</div>
							</div>
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Sofort</label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($nlakt_sofortold == 0) echo " active" ?>">
										<input type="radio" name="nlakt_sofort" id="nlakt_sofortOff" value="0"<?php if($nlakt_sofortold == 0) echo " checked=\"checked\"" ?>>Aus
									</label>
									<label class="btn btn-outline-info<?php if($nlakt_sofortold == 1) echo " active" ?>">
										<input type="radio" name="nlakt_sofort" id="nlakt_sofortOn" value="1"<?php if($nlakt_sofortold == 1) echo " checked=\"checked\"" ?>>An
									</label>
	             				<span class="d_label">nlakt_sofort</span>				
								</div>
							</div>
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Min+PV</label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($nlakt_minpvold == 0) echo " active" ?>">
										<input type="radio" name="nlakt_minpv" id="nlakt_minpvOff" value="0"<?php if($nlakt_minpvold == 0) echo " checked=\"checked\"" ?>>Aus
									</label>
									<label class="btn btn-outline-info<?php if($nlakt_minpvold == 1) echo " active" ?>">
										<input type="radio" name="nlakt_minpv" id="nlakt_minpvOn" value="1"<?php if($nlakt_minpvold == 1) echo " checked=\"checked\"" ?>>An
									</label>
	             				<span class="d_label">nlakt_minpv</span>				
								</div>
							</div>
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Nur PV</label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($nlakt_nurpvold == 0) echo " active" ?>">
										<input type="radio" name="nlakt_nurpv" id="nlakt_nurpvOff" value="0"<?php if($nlakt_nurpvold == 0) echo " checked=\"checked\"" ?>>Aus
									</label>
									<label class="btn btn-outline-info<?php if($nlakt_nurpvold == 1) echo " active" ?>">
										<input type="radio" name="nlakt_nurpv" id="nlakt_nurpvOn" value="1"<?php if($nlakt_nurpvold == 1) echo " checked=\"checked\"" ?>>An
									</label>
	             				<span class="d_label">nlakt_nurpv</span>				
								</div>
							</div>
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Standby</label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($nlakt_standbyold == 0) echo " active" ?>">
										<input type="radio" name="nlakt_standby" id="nlakt_standbyOff" value="0"<?php if($nlakt_standbyold == 0) echo " checked=\"checked\"" ?>>Aus
									</label>
									<label class="btn btn-outline-info<?php if($nlakt_standbyold == 1) echo " active" ?>">
										<input type="radio" name="nlakt_standby" id="nlakt_standbyOn" value="1"<?php if($nlakt_standbyold == 1) echo " checked=\"checked\"" ?>>An
									</label>
	             				<span class="d_label">nlakt_standby</span>				
								</div>
							</div>
						</div>
						<hr class="border-info">
						<div class="form-group">
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Ladepunkt 1 <?php echo $nachtladenold ?></label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($nachtladenold == 0) echo " active" ?>">
										<input type="radio" name="nachtladen" id="nachtladenOff" value="0"<?php if($nachtladenold == 0) echo " checked=\"checked\"" ?>> Aus 
									</label>
									<label class="btn btn-outline-info<?php if($nachtladenold == 1) echo " active" ?>">
										<input type="radio" name="nachtladen" id="nachtladenOn" value="1"<?php if($nachtladenold == 1) echo " checked=\"checked\"" ?>> An 
									</label>
									<span class="d_label">nachtladen</span>				
								</div>
							</div>
							<div id="nachtladenan" class="hide">
								<div class="form-row mb-1">
									<div class="col">
										Nachtladen
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="nachtll" class="col-md-4 col-form-label">Stromstärke in A</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="nachtll" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $nachtllold; ?> A</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="nachtll" id="nachtll" min="6" max="32" step="1" value="<?php echo $nachtllold; ?>">
											</div>
										</div>
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										Zeitspanne
									</div>
									<div class="col">
										<div class="form-row">
											<div class="col-sm-6">
												<div class="input-group">
													<div class="input-group-prepend">
														<div class="input-group-text">
															Anfang
														</div>
													</div>
													<select name="nachtladenabuhr" id="nachtladenabuhr" class="form-control">
														<option <?php if($nachtladenabuhrold == 17) echo "selected" ?> value="17">17:00</option>
														<option <?php if($nachtladenabuhrold == 18) echo "selected" ?> value="18">18:00</option>
														<option <?php if($nachtladenabuhrold == 19) echo "selected" ?> value="19">19:00</option>
														<option <?php if($nachtladenabuhrold == 20) echo "selected" ?> value="20">20:00</option>
														<option <?php if($nachtladenabuhrold == 21) echo "selected" ?> value="21">21:00</option>
														<option <?php if($nachtladenabuhrold == 22) echo "selected" ?> value="22">22:00</option>
														<option <?php if($nachtladenabuhrold == 23) echo "selected" ?> value="23">23:00</option>
														<option <?php if($nachtladenabuhrold == 0) echo "selected" ?> value="0">0:00</option>
														<option <?php if($nachtladenabuhrold == 1) echo "selected" ?> value="1">1:00</option>
														<option <?php if($nachtladenabuhrold == 2) echo "selected" ?> value="2">2:00</option>
														<option <?php if($nachtladenabuhrold == 3) echo "selected" ?> value="3">3:00</option>
														<option <?php if($nachtladenabuhrold == 4) echo "selected" ?> value="4">4:00</option>
													</select>
												</div>
											</div>
											<div class="col-sm-6">
												<div class="input-group">
													<div class="input-group-prepend">
														<div class="input-group-text">
															Ende
														</div>
													</div>
													<select name="nachtladenbisuhr" id="nachtladenbisuhr" class="form-control">
														<option <?php if($nachtladenbisuhrold == 20) echo "selected" ?> value="20">20:00</option>
														<option <?php if($nachtladenbisuhrold == 21) echo "selected" ?> value="21">21:00</option>
														<option <?php if($nachtladenbisuhrold == 22) echo "selected" ?> value="22">22:00</option>
														<option <?php if($nachtladenbisuhrold == 23) echo "selected" ?> value="23">23:00</option>
														<option <?php if($nachtladenbisuhrold == 0) echo "selected" ?> value="0">0:00</option>
														<option <?php if($nachtladenbisuhrold == 1) echo "selected" ?> value="1">1:00</option>
														<option <?php if($nachtladenbisuhrold == 2) echo "selected" ?> value="2">2:00</option>
														<option <?php if($nachtladenbisuhrold == 3) echo "selected" ?> value="3">3:00</option>
														<option <?php if($nachtladenbisuhrold == 4) echo "selected" ?> value="4">4:00</option>
														<option <?php if($nachtladenbisuhrold == 5) echo "selected" ?> value="5">5:00</option>
														<option <?php if($nachtladenbisuhrold == 6) echo "selected" ?> value="6">6:00</option>
														<option <?php if($nachtladenbisuhrold == 7) echo "selected" ?> value="7">7:00</option>
														<option <?php if($nachtladenbisuhrold == 8) echo "selected" ?> value="8">8:00</option>
														<option <?php if($nachtladenbisuhrold == 9) echo "selected" ?> value="9">9:00</option>
													</select>
												</div>
											</div>
										</div>
										<span class="form-text small">Zeitspanne, in der nachts geladen werden soll.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="nachtsoc" class="col-md-4 col-form-label">SoC Sonntag bis Donnerstag</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="nachtsoc" class="col-2 col-form-label valueLabel" suffix="%"><?php echo $nachtsocold; ?> %</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="nachtsoc" id="nachtsoc" min="5" max="100" step="1" value="<?php echo $nachtsocold; ?>">
											</div>
										</div>
										<span class="form-text small">Wenn SoC Modul vorhanden wird Nachts bis xx% SoC geladen in dem angegebenen Zeitfenster. Das SoC Fenster is von von Sonntag Abend bis Freitag Morgen aktiv.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="nachtsoc1" class="col-md-4 col-form-label">SoC Freitag bis Sonntag</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="nachtsoc1" class="col-2 col-form-label valueLabel" suffix="%"><?php echo $nachtsoc1old; ?> %</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="nachtsoc1" id="nachtsoc1" min="5" max="100" step="1" value="<?php echo $nachtsoc1old; ?>">
											</div>
										</div>
										<span class="form-text small">Wenn SoC Modul vorhanden wird Nachts bis xx% SoC geladen in dem angegebenen Zeitfenster. Das SoC Fenster is von von Freitag Morgen bis Sonntag Abend aktiv.</span>
									</div>
								</div>
                        
                        
                        <!--   -->
								<hr class="border-info">
								<div class="form-row mb-1">
									<div class="col">
										Morgensladen
									</div>
								</div>
								<?php
									function generateTimeOptions($hourStart, $minuteStart, $hourStop, $minuteStop, $minuteStep, $selectedValue) {
										$minutesOfDayStop = $hourStop * 60 + $minuteStop;
										for($minutesOfDay = $hourStart * 60 + $minuteStart; $minutesOfDay <= $minutesOfDayStop; $minutesOfDay += $minuteStep) {
											$formattedTime = sprintf('%02d:%02d', (int)($minutesOfDay / 60), $minutesOfDay  % 60);
											echo '<option value="', $formattedTime, '"', $formattedTime == $selectedValue ? ' selected' : '', '>', $formattedTime, "</option>\n";
										}
									}
									function generateMorningChargeDayOptions($dayName, $dayShortcut) {
										// mollp1 = "MOrgens Laden LadePunkt 1"
										$prefix = "mollp1$dayShortcut"
								?>
								<div class="form-row mb-1">
									<div class="col">
										<?php echo $dayName; ?>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="<?php echo $prefix; ?>ll" class="col-md-4 col-form-label">Stromstärke in A</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="<?php echo $prefix; ?>ll" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $GLOBALS["${prefix}llold"]; ?> A</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="<?php echo $prefix; ?>ll" id="<?php echo $prefix; ?>ll" min="6" max="32" step="1" value="<?php echo $GLOBALS["${prefix}llold"]; ?>">
											</div>
										</div>
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										Zeitspanne
									</div>
									<div class="col">
										<div class="form-row">
											<div class="col-sm-6">
												<div class="input-group">
													<div class="input-group-prepend">
														<div class="input-group-text">
															Anfang
														</div>
													</div>
													<select name="<?php echo $prefix; ?>ab" id="<?php echo $prefix; ?>ab" class="form-control">
														<?php generateTimeOptions(3, 0, 10, 45, 15, $GLOBALS["${prefix}abold"]); ?>
													</select>
												</div>
											</div>
											<div class="col-sm-6">
												<div class="input-group">
													<div class="input-group-prepend">
														<div class="input-group-text">
															Ende
														</div>
													</div>
													<select name="<?php echo $prefix; ?>bis" id="<?php echo $prefix; ?>bis" class="form-control">
														<?php generateTimeOptions(3, 0, 11, 0, 15, $GLOBALS["${prefix}bisold"]); ?>
													</select>
												</div>
											</div>
										</div>
										<span class="form-text small">Zeitspanne, in der am <?php echo $dayName; ?> morgens geladen werden soll.</span>
									</div>
								</div>
								<?php
									}
									generateMorningChargeDayOptions('Montag', 'mo');
									generateMorningChargeDayOptions('Dienstag', 'di');
									generateMorningChargeDayOptions('Mittwoch', 'mi');
									generateMorningChargeDayOptions('Donnerstag', 'do');
									generateMorningChargeDayOptions('Freitag', 'fr');
									generateMorningChargeDayOptions('Samstag', 'sa');
									generateMorningChargeDayOptions('Sonntag', 'so');
								?>
							</div>
						</div>

						<div id="nachtladenlp2div" class="hide">
							<hr class="border-info">
							<div class="form-group">
								<div class="form-row vaRow mb-1">
									<label class="col-md-4 col-form-label">Ladepunkt 2</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($nachtladens1old == 0) echo " active" ?>">
											<input type="radio" name="nachtladens1" id="nachtladens1Off" value="0"<?php if($nachtladens1old == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-outline-info<?php if($nachtladens1old == 1) echo " active" ?>">
											<input type="radio" name="nachtladens1" id="nachtladens1On" value="1"<?php if($nachtladens1old == 1) echo " checked=\"checked\"" ?>>An
										</label>
									</div>
								</div>
								<div id="nachtladenans1" class="hide">
									<div class="form-row mb-1">
										<div class="col">
											Nachtladen
										</div>
									</div>
									<div class="form-row mb-1">
										<label for="nachtlls1" class="col-md-4 col-form-label">Stromstärke in A</label>
										<div class="col-md-8">
											<div class="form-row vaRow mb-1">
												<label for="nachtlls1" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $nachtlls1old; ?> A</label>
												<div class="col-10">
													<input type="range" class="form-control-range rangeInput" name="nachtlls1" id="nachtlls1" min="6" max="32" step="1" value="<?php echo $nachtlls1old; ?>">
												</div>
											</div>
										</div>
									</div>
									<div class="form-row mb-1">
										<div class="col-md-4">
											Zeitspanne
										</div>
										<div class="col">
											<div class="form-row">
												<div class="col-sm-6">
													<div class="input-group">
														<div class="input-group-prepend">
															<div class="input-group-text">
																Anfang
															</div>
														</div>
														<select name="nachtladenabuhrs1" id="nachtladenabuhrs1" class="form-control">
															<option <?php if($nachtladenabuhrs1old == 17) echo "selected" ?> value="17">17:00</option>
															<option <?php if($nachtladenabuhrs1old == 18) echo "selected" ?> value="18">18:00</option>
															<option <?php if($nachtladenabuhrs1old == 19) echo "selected" ?> value="19">19:00</option>
															<option <?php if($nachtladenabuhrs1old == 20) echo "selected" ?> value="20">20:00</option>
															<option <?php if($nachtladenabuhrs1old == 21) echo "selected" ?> value="21">21:00</option>
															<option <?php if($nachtladenabuhrs1old == 22) echo "selected" ?> value="22">22:00</option>
															<option <?php if($nachtladenabuhrs1old == 23) echo "selected" ?> value="23">23:00</option>
															<option <?php if($nachtladenabuhrs1old == 0)  echo "selected" ?> value="0">0:00</option>
															<option <?php if($nachtladenabuhrs1old == 1)  echo "selected" ?> value="1">1:00</option>
															<option <?php if($nachtladenabuhrs1old == 2)  echo "selected" ?> value="2">2:00</option>
															<option <?php if($nachtladenabuhrs1old == 3)  echo "selected" ?> value="3">3:00</option>
															<option <?php if($nachtladenabuhrs1old == 4)  echo "selected" ?> value="4">4:00</option>
														</select>
													</div>
												</div>
												<div class="col-sm-6">
													<div class="input-group">
														<div class="input-group-prepend">
															<div class="input-group-text">
																Ende
															</div>
														</div>
														<select name="nachtladenbisuhrs1" id="nachtladenbisuhrs1" class="form-control">
															<option <?php if($nachtladenbisuhrs1old == 20) echo "selected" ?> value="20">20:00</option>
															<option <?php if($nachtladenbisuhrs1old == 21) echo "selected" ?> value="21">21:00</option>
															<option <?php if($nachtladenbisuhrs1old == 22) echo "selected" ?> value="22">22:00</option>
															<option <?php if($nachtladenbisuhrs1old == 23) echo "selected" ?> value="23">23:00</option>
															<option <?php if($nachtladenbisuhrs1old == 0) echo "selected" ?> value="0">0:00</option>
															<option <?php if($nachtladenbisuhrs1old == 1) echo "selected" ?> value="1">1:00</option>
															<option <?php if($nachtladenbisuhrs1old == 2) echo "selected" ?> value="2">2:00</option>
															<option <?php if($nachtladenbisuhrs1old == 3) echo "selected" ?> value="3">3:00</option>
															<option <?php if($nachtladenbisuhrs1old == 4) echo "selected" ?> value="4">4:00</option>
															<option <?php if($nachtladenbisuhrs1old == 5) echo "selected" ?> value="5">5:00</option>
															<option <?php if($nachtladenbisuhrs1old == 6) echo "selected" ?> value="6">6:00</option>
															<option <?php if($nachtladenbisuhrs1old == 7) echo "selected" ?> value="7">7:00</option>
															<option <?php if($nachtladenbisuhrs1old == 8) echo "selected" ?> value="8">8:00</option>
															<option <?php if($nachtladenbisuhrs1old == 9) echo "selected" ?> value="9">9:00</option>
														</select>
													</div>
												</div>
											</div>
											<span class="form-text small">Zeitspanne, in der nachts geladen werden soll.</span>
										</div>
									</div>
									<div class="form-row mb-1">
										<label for="nachtsocs1" class="col-md-4 col-form-label">SoC Sonntag bis Donnerstag</label>
										<div class="col-md-8">
											<div class="form-row vaRow mb-1">
												<label for="nachtsocs1" class="col-2 col-form-label valueLabel" suffix="%"><?php echo $nachtsocs1old; ?> %</label>
												<div class="col-10">
													<input type="range" class="form-control-range rangeInput" name="nachtsocs1" id="nachtsocs1" min="5" max="100" step="1" value="<?php echo $nachtsocs1old; ?>">
												</div>
											</div>
											<span class="form-text small">Wenn SoC Modul vorhanden wird Nachts bis xx% SoC geladen in dem angegebenen Zeitfenster. Das SoC Fenster is von von Sonntag Abend bis Freitag Morgen aktiv.</span>
										</div>
									</div>
									<div class="form-row mb-1">
										<label for="nachtsoc1s1" class="col-md-4 col-form-label">SoC Freitag bis Sonntag</label>
										<div class="col-md-8">
											<div class="form-row vaRow mb-1">
												<label for="nachtsoc1s1" class="col-2 col-form-label valueLabel" suffix="%"><?php echo $nachtsoc1s1old; ?> %</label>
												<div class="col-10">
													<input type="range" class="form-control-range rangeInput" name="nachtsoc1s1" id="nachtsoc1s1" min="5" max="100" step="1" value="<?php echo $nachtsoc1s1old; ?>">
												</div>
											</div>
											<span class="form-text small">Wenn SoC Modul vorhanden wird Nachts bis xx% SoC geladen in dem angegebenen Zeitfenster. Das SoC Fenster is von von Freitag Morgen bis Sonntag Abend aktiv.</span>
										</div>
									</div>
									<hr class="border-info">
									<div class="form-row mb-1">
										<div class="col">
											Morgensladen
										</div>
									</div>
									<div class="form-row mb-1">
										<label for="nacht2lls1" class="col-md-4 col-form-label">Stromstärke in A</label>
										<div class="col-md-8">
											<div class="form-row vaRow mb-1">
												<label for="nacht2lls1" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $nacht2lls1old; ?> A</label>
												<div class="col-10">
													<input type="range" class="form-control-range rangeInput" name="nacht2lls1" id="nacht2lls1" min="6" max="32" step="1" value="<?php echo $nacht2lls1old; ?>">
												</div>
											</div>
										</div>
									</div>
									<div class="form-row mb-1">
										<div class="col-md-4">
											Zeitspanne
										</div>
										<div class="col">
											<div class="form-row">
												<div class="col-sm-6">
													<div class="input-group">
														<div class="input-group-prepend">
															<div class="input-group-text">
																Anfang
															</div>
														</div>
														<select name="nachtladen2abuhrs1" id="nachtladen2abuhrs1" class="form-control">
															<option <?php if($nachtladen2abuhrs1old == 3) echo "selected" ?> value="3">03:00</option>
															<option <?php if($nachtladen2abuhrs1old == 4) echo "selected" ?> value="4">04:00</option>
															<option <?php if($nachtladen2abuhrs1old == 5) echo "selected" ?> value="5">05:00</option>
															<option <?php if($nachtladen2abuhrs1old == 6) echo "selected" ?> value="6">06:00</option>
															<option <?php if($nachtladen2abuhrs1old == 7) echo "selected" ?> value="7">07:00</option>
															<option <?php if($nachtladen2abuhrs1old == 8) echo "selected" ?> value="8">08:00</option>
															<option <?php if($nachtladen2abuhrs1old == 9) echo "selected" ?> value="9">09:00</option>
														</select>
													</div>
												</div>
												<div class="col-sm-6">
													<div class="input-group">
														<div class="input-group-prepend">
															<div class="input-group-text">
																Ende
															</div>
														</div>
														<select name="nachtladen2bisuhrs1" id="nachtladen2bisuhrs1" class="form-control">
															<option <?php if($nachtladen2bisuhrs1old == 4) echo "selected" ?> value="4">04:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 5) echo "selected" ?> value="5">05:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 6) echo "selected" ?> value="6">06:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 7) echo "selected" ?> value="7">07:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 8) echo "selected" ?> value="8">08:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 9) echo "selected" ?> value="9">09:00</option>
															<option <?php if($nachtladen2bisuhrs1old == 10) echo "selected" ?> value="10">10:00</option>
														</select>
													</div>
												</div>
											</div>
											<span class="form-text small">Zeitspanne, in der morgens geladen werden soll.</span>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<script>
						$(function() {
							function visibility_nachtladen() {
								if($('#nachtladenOff').prop("checked")) {
									hideSection('#nachtladenan');
								} else {
									showSection('#nachtladenan');
								}
							}

							function visibility_nachtladens1() {
								if($('#nachtladens1Off').prop("checked")) {
									hideSection('#nachtladenans1');
								} else {
									showSection('#nachtladenans1');
								}
							}

							$('input[type=radio][name=nachtladen]').change(function(){
								visibility_nachtladen();
							});

							$('input[type=radio][name=nachtladens1]').change(function(){
								visibility_nachtladens1();
							});

							visibility_nachtladen();
							visibility_nachtladens1()
						});
					</script>
               
					<script>
						$(function() {
							var lp2akt = <?php echo $lastmanagementold ?>;
							if(lp2akt == '0') {
								hideSection('#nachtladenlp2div');
							} else {
								showSection('#nachtladenlp2div');
							}
						});
					</script>


				</div>

				<div class="form-row text-center">
					<div class="col">
						<button type="submit" class="btn btn-success">Speichern</button>
					</div>
				</div>
			</form>
		</div>

		<footer class="footer bg-dark text-light font-small">
			<div class="container text-center">
				<small>Sie befinden sich hier: Ladeeinstellungen/Nachtladen</small>
			</div>
		</footer>


		<script>

			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav").replaceWith(data);
					// disable navbar entry for current page
					$('#navNachtladen').addClass('disabled');
                    $('.devicename').text(devicename);
				}
			);

			$(document).ready(function(){

				$('.rangeInput').on('input', function() {
					// show slider value in label of class valueLabel
					updateLabel($(this).attr('id'));
				});

			});  // end document ready

		</script>

	</body>
</html>
