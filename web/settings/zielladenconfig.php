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

		?>
		<script>
		  var debugold=<?php echo $debugold;?>;
		  console.log('openWB debug aus openwb.conf:',debugold);
		</script>		

		<div id="nav"></div> <!-- placeholder for navbar -->

		<div role="main" class="container" style="margin-top:20px">
			<h1>Zielladen Einstellungen (Beta)</h1>
			<form action="./settings/saveconfig.php" method="POST">

				<!-- Zielladen -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Zielladen (Beta)
					</div>
					<div class="card-body">
						<div class="form-group">
							<div class="form-row vaRow mb-1">
								<label class="col-md-4 col-form-label">Ladepunkt 1</label>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($zielladenaktivlp1old == 0) echo " active" ?>">
										<input type="radio" name="zielladenaktivlp1" id="zielladenaktivlp1Off" value="0"<?php if($zielladenaktivlp1old == 0) echo " checked=\"checked\"" ?>>Aus
									</label>
									<label class="btn btn-outline-info<?php if($zielladenaktivlp1old == 1) echo " active" ?>">
										<input type="radio" name="zielladenaktivlp1" id="zielladenaktivlp1On" value="1"<?php if($zielladenaktivlp1old == 1) echo " checked=\"checked\"" ?>>An
									</label>
								</div>
							   <div class="d_label">zielladenaktivlp1</div>				
							</div>
							<div id="zielladenaktivlp1div" class="disabled">
								<div class="card-text alert alert-info">
									Gewünschten SoC, Ziel Uhrzeit sowie Ladegeschwindigkeit einstellen. Sicherstellen das die Akkugröße wie auch die richtige Anzahl der Phasen konfiguriert sind.
								</div>
								<div class="form-row mb-1">
									<label for="zielladensoclp1" class="col-md-4 col-form-label">Ziel-SoC</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="zielladensoclp1" class="col-2 col-form-label valueLabel" suffix="%"><?php echo $zielladensoclp1old; ?> %</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="zielladensoclp1" id="zielladensoclp1" min="0" max="100" step="1" value="<?php echo $zielladensoclp1old; ?>">
											</div>
										</div>
							         <span class="d_label">zielladensoclp1</span>				
										<span class="form-text small">Der SoC Wert auf den geladen werden soll.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="zielladenuhrzeitlp1" class="col-md-4 col-form-label">Ziel-Zeitpunkt</label>
									<div class="col">
										<input class="form-control" type="text" pattern="20[0-9]{2}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31)) (0[0-9]|1[0-9]|2[0-3])(:[0-5][0-9])" name="zielladenuhrzeitlp1" id="zielladenuhrzeitlp1" value="<?php echo $zielladenuhrzeitlp1old; ?>">
							         <span class="d_label">zielladenuhrzeitlp1</span>				
										<span class="form-text small">Gültige Werte YYYY-MM-DD HH:MM, z.B. 2018-12-16 06:15. Ende der gewünschten Ladezeit. Das Datum muss exakt in diesem Format mit Leerzeichen zwischen Monat und Stunde eingegeben werden.</span>
										<!--
											test datetime input (not supported by all Browsers)
											value format: YYY-MM-DDTHH:MM needs to be handled before passing to config file!
										<input class="form-control" type="datetime-local" name="zielladenuhrzeitlp1_test" id="zielladenuhrzeitlp1_test" value="<?php echo str_replace( ' ', 'T', $zielladenuhrzeitlp1old ); ?>">
										-->
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="zielladenalp1" class="col-md-4 col-form-label">Stromstärke</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="zielladenalp1" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $zielladenalp1old; ?> A</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="zielladenalp1" id="zielladenalp1" min="6" max="32" step="1" value="<?php echo $zielladenalp1old; ?>">
											</div>
										</div>
							         <span class="d_label">zielladenalp1</span>				
										<span class="form-text small">Ampere mit denen geladen werden soll um den Ziel SoC zu erreichen.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Anzahl genutzter Phasen</label>
									<div class="col">
										<div class="btn-group btn-group-toggle btn-block" data-toggle="buttons">
											<label class="btn btn-outline-info<?php if($zielladenaktivlp1old == 1) echo " active" ?>">
												<input type="radio" name="zielladenphasenlp1" id="zielladenphasenlp11" value="1"<?php if($zielladenphasenlp1old == 1) echo " checked=\"checked\"" ?>>1
											</label>
											<label class="btn btn-outline-info<?php if($zielladenaktivlp1old == 2) echo " active" ?>">
												<input type="radio" name="zielladenphasenlp1" id="zielladenphasenlp12" value="2"<?php if($zielladenphasenlp1old == 2) echo " checked=\"checked\"" ?>>2
											</label>
											<label class="btn btn-outline-info<?php if($zielladenaktivlp1old == 3) echo " active" ?>">
												<input type="radio" name="zielladenphasenlp1" id="zielladenphasenlp13" value="3"<?php if($zielladenphasenlp1old == 3) echo " checked=\"checked\"" ?>>3
											</label>
										</div>
							         <span class="d_label">zielladenphasenlp1</span>				
										<span class="form-text small">Achtung wenn mehr als eine Phase genutzt wird, muss für Standby auf 3-Phasig stehen.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="zielladenmaxalp1" class="col-md-4 col-form-label">maximale Stromstärke</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="zielladenmaxalp1" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $zielladenmaxalp1old; ?> A</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="zielladenmaxalp1" id="zielladenmaxalp1" min="6" max="32" step="1" value="<?php echo $zielladenmaxalp1old; ?>">
											</div>
										</div>
							         <span class="d_label">zielladenmaxalp1</span>				
										<span class="form-text small">Ampere mit denen geladen werden kann, um den Ziel SoC zu erreichen. Orientiert an der Leistung der Hausinstallation, oder der des zu ladenden Autos.</span>
									</div>
								</div>								
							</div>
						</div>
					</div>
					<script>
						$(function() {
							function visibility_zielladenaktivlp1() {
								if($('#zielladenaktivlp1Off').prop("checked")) {
									hideSection('#zielladenaktivlp1div');
								} else {
									showSection('#zielladenaktivlp1div');
								}
							}

							$('input[type=radio][name=zielladenaktivlp1]').change(function(){
								visibility_zielladenaktivlp1();
							});

							visibility_zielladenaktivlp1();
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
				<small>Sie befinden sich hier: Einstellungen/Laden/Zielladen</small>
			</div>
		</footer>


		<script>

			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav").replaceWith(data);
					// disable navbar entry for current page
					$('#navZielladen').addClass('disabled');
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
