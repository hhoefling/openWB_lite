<?php
function  geturl($dir,$file)
	{
 			$fn=sprintf('./%s/%s', $dir, $file);
 			$ftime=filemtime($file);
 			return sprintf('%s?v=%d' , $fn,$ftime);
	}
?>


<!DOCTYPE html>
<html lang="de">
	<head>
		<base href="/openWB/web/">

		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>openWB Einstellungen</title>
		<meta name="author" content="Michael Ortenstein, Lutz Bender">
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

		<!-- important scripts to be loaded -->
		<script  src="js/jquery-3.6.0.min.js"></script>
		<script src="js/bootstrap-4.4.1/bootstrap.bundle.min.js"></script>

		<!-- Bootstrap -->
		<link rel="stylesheet" type="text/css" href="css/bootstrap-4.4.1/bootstrap.min.css">
		<!-- Normalize -->
		<link rel="stylesheet" type="text/css" href="css/normalize-8.0.1.css">
		<!-- Font Awesome, all styles -->
		<link href="fonts/font-awesome-5.8.2/css/all.css" rel="stylesheet">

		<!-- include settings-style -->
		<link rel="stylesheet" type="text/css" href="css/settings_style.css">
		<!-- load helper functions -->
		<script src = "<?php echo geturl('settings','helperFunctions.js');?>"></script>
			
	</head>
	<body>

		<div id="nav"></div> <!-- placeholder for navbar -->

		<div role="main" class="container" style="margin-top:20px">
			<form id="myForm">
				<h1>Graph-Einstellungen</h1>

				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Allgemeine Optionen
					</div>
					<div class="card-body">
						<div class="form-row mb-1">
							<label class="col-md-4 col-form-label">Graph Anzeige</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLiveGraph" name="boolDisplayLiveGraph" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLiveGraph" id="boolDisplayLiveGraphOff" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLiveGraph" id="boolDisplayLiveGraphOn" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1">
							<label class="col-md-4 col-form-label">Legende</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLegend" name="boolDisplayLegend" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLegend" id="boolDisplayLegendOff" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLegend" id="boolDisplayLegendOn" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<hr class="border-secondary">
						<div class="form-row mb-1">
							<label class="col-md-4 col-form-label">EVU Bezug/Einspeisung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayEvu" name="boolDisplayEvu" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayEvu" id="boolDisplayEvuOff" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayEvu" id="boolDisplayEvuOn" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1">
							<label class="col-md-4 col-form-label">Hausverbrauch</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayHouseConsumption" name="boolDisplayHouseConsumption" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayHouseConsumption" id="boolDisplayHouseConsumptionOff" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayHouseConsumption" id="boolDisplayHouseConsumptionOn" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1 pvoptions">
							<label class="col-md-4 col-form-label">PV Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayPv" name="boolDisplayPv" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayPv" id="boolDisplayPvOff" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayPv" id="boolDisplayPvOn" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
					</div> <!-- end card body Allgemeine Optionen -->
				</div>

				<div class="card border-primary">
					<div class="card-header bg-primary">
						Ladepunkte
					</div>
					<div class="card-body">
						<div class="alllpoptions xdisabled">
							<div class="form-row mb-1">
								<label class="col-md-4 col-form-label">Summe aller Ladepunktleistungen</label>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLpAll" name="boolDisplayLpAll" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLpAll" id="boolDisplayLpAllOff" data-option="0" value="0">Aus
										</label>
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLpAll" id="boolDisplayLpAllOn" data-option="1" value="1">An
										</label>
									</div>
								</div>
							</div>
							<hr class="border-primary">
						</div>
						<div class="form-row mb-1 lp1options xdisabled">
							<label class="col-md-4 col-form-label">Ladepunkt 1 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLp1" name="boolDisplayLp1" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp1" id="boolDisplayLp1Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp1" id="boolDisplayLp1On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1 lp2options xdisabled">
							<label class="col-md-4 col-form-label">Ladepunkt 2 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLp2" name="boolDisplayLp2" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp2" id="boolDisplayLp2Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp2" id="boolDisplayLp2On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1 lp3options xdisabled">
							<label class="col-md-4 col-form-label">Ladepunkt 3 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLp3" name="boolDisplayLp3" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp3" id="boolDisplayLp3Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLp3" id="boolDisplayLp3On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="soclpoptions">
							<hr class="border-primary">
							<div class="form-row mb-1 soclp1options xdisabled">
								<label class="col-md-4 col-form-label">Ladepunkt 1 SoC</label>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLp1Soc" name="boolDisplayLp1Soc" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLp1Soc" id="boolDisplayLp1SocOff" data-option="0" value="0">Aus
										</label>
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLp1Soc" id="boolDisplayLp1SocOn" data-option="1" value="1">An
										</label>
									</div>
								</div>
							</div>
							<div class="form-row mb-1 soclp2options xdisabled">
								<label class="col-md-4 col-form-label">Ladepunkt 2 SoC</label>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLp2Soc" name="boolDisplayLp2Soc" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLp2Soc" id="boolDisplayLp2SocOff" data-option="0" value="0">Aus
										</label>
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplayLp2Soc" id="boolDisplayLp2SocOn" data-option="1" value="1">An
										</label>
									</div>
								</div>
							</div>
						</div>
					</div> <!-- end card body Ladepunkte -->
				</div>

				<div class="card border-warning">
					<div class="card-header bg-warning">
						Speicher
					</div>
					<div class="card-body">
						<div class="card-text alert alert-info nohousebattery">
							Diese Optionen sind nur verfügbar, wenn ein Speicher konfiguriert wurde.
						</div>
						<div class="housebatteryoptions xdisabled">
							<div class="form-row mb-1">
								<label class="col-md-4 col-form-label">(Ent-)Lade-Leistung</label>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" id="boolDisplaySpeicher" name="boolDisplaySpeicher" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplaySpeicher" id="boolDisplaySpeicherOff" data-option="0" value="0">Aus
										</label>
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplaySpeicher" id="boolDisplaySpeicherOn" data-option="1" value="1">An
										</label>
									</div>
								</div>
							</div>
							<div class="form-row mb-1">
								<label class="col-md-4 col-form-label">SoC</label>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" id="boolDisplaySpeicherSoc" name="boolDisplaySpeicherSoc" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplaySpeicherSoc" id="boolDisplaySpeicherSocOff" data-option="0" value="0">Aus
										</label>
										<label class="btn btn-outline-info btn-toggle">
											<input type="radio" name="boolDisplaySpeicherSoc" id="boolDisplaySpeicherSocOn" data-option="1" value="1">An
										</label>
									</div>
								</div>
							</div>
						</div>
					</div> <!-- end card body Speicher -->
				</div>

				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Verbraucher
					</div>
					<div class="card-body">
						<div class="card-text alert alert-info noverbraucher">
							Diese Optionen sind nur verfügbar, wenn ein Verbraucher konfiguriert wurde.
						</div>
						<div class="form-row mb-1 verbraucher1options xdisabled">
							<label class="col-md-4 col-form-label">Verbraucher 1 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLoad1" name="boolDisplayLoad1" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLoad1" id="boolDisplayLoad1Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLoad1" id="boolDisplayLoad1On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1 verbraucher2options xdisabled">
							<label class="col-md-4 col-form-label">Verbraucher 2 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayLoad2" name="boolDisplayLoad2" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLoad2" id="boolDisplayLoad2Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayLoad2" id="boolDisplayLoad2On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
					</div> <!-- end card body Verbraucher -->
				</div>


				<div class="card border-secondary">
					<div class="card-header bg-info">
						Smart-Home 2 Geräte
					</div>
					<div class="card-body">
						<div class="card-text alert alert-info nosmarthome">
							Diese Optionen sind nur verfügbar, wenn Smarthome Geräte verwendet werden.
						</div>
						<div class="form-row mb-1 smarthome1options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 1 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD1" name="boolDisplayShD1" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD1" id="boolDisplayShD1Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD1" id="boolDisplayShD1On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>
						<div class="form-row mb-1 smarthome2options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 2 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD2" name="boolDisplayShD2" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD2" id="boolDisplayShD2Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD2" id="boolDisplayShD2On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome3options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 3 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD3" name="boolDisplayShD3" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD3" id="boolDisplayShD3Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD3" id="boolDisplayShD3On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome4options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 4 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD4" name="boolDisplayShD4" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD4" id="boolDisplayShD4Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD4" id="boolDisplayShD4On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome5options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 5 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD5" name="boolDisplayShD5" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD5" id="boolDisplayShD5Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD5" id="boolDisplayShD5On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome6options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 6 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD6" name="boolDisplayShD6" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD6" id="boolDisplayShD6Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD6" id="boolDisplayShD6On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome7options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 7 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD7" name="boolDisplayShD7" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD7" id="boolDisplayShD7Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD7" id="boolDisplayShD7On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome8options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 8 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD8" name="boolDisplayShD8" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD8" id="boolDisplayShD8Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD8" id="boolDisplayShD8On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

						<div class="form-row mb-1 smarthome9options xdisabled">
							<label class="col-md-4 col-form-label">Smarthome 9 Leistung</label>
							<div class="col">
								<div class="btn-group btn-block btn-group-toggle" id="boolDisplayShD9" name="boolDisplayShD9" data-toggle="buttons" data-default="0" data-topicprefix="openWB/graph/">
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD9" id="boolDisplayShD9Off" data-option="0" value="0">Aus
									</label>
									<label class="btn btn-outline-info btn-toggle">
										<input type="radio" name="boolDisplayShD9" id="boolDisplayShD9On" data-option="1" value="1">An
									</label>
								</div>
							</div>
						</div>

					</div> <!-- end card body Smarthome -->
				</div>


			</form>
		</div> <!-- end main container -->

		<footer class="footer bg-dark text-light font-small">
			<div class="container text-center">
				<small>Sie befinden sich hier: Erscheinungsbild/Graph</small>
			</div>
		</footer>

		<!-- load mqtt library -->
		<script src = "js/mqttws31.js" ></script>
		<!-- load topics -->
		<script src = "<?php echo geturl('settings','topicsToSubscribe_graphconfig.js');?>"></script>
		<!-- load service -->
		<script src = "<?php echo geturl('settings','setupMqttServices.js');?>"></script>
		<!-- load mqtt handler-->
		<script src = "<?php echo geturl('settings','processAllMqttMsg.js');?>"></script>

		<script>

			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav").replaceWith(data);
					// disable navbar entry for current page
					$('#navGraphSettings').addClass('disabled');
				}
			);

			var pv1 = 0;
			var pv2 = 0;
			// callback vom MQTT
			function visibiltycheck(elementId, mqttpayload) {
				// PV
				if ( ( elementId == "boolPVConfiguredPv1") || ( elementId == "boolPVConfiguredPv2") ) {
					if ( elementId == "boolPVConfiguredPv1" ) {
						pv1 = mqttpayload;
					} else {
						pv2 = mqttpayload;
					}

					if ( (pv1 + pv2) > 0 ) {
						showSection('.pvoptions');
					} else {
						hideSection('.pvoptions');
					}
				}
				// House Battery
				if ( elementId == "boolHouseBatteryConfigured") {
					if ( mqttpayload == 0 ) {
						hideSection('.housebatteryoptions');
						showSection('.nohousebattery');
						publish("0", "openWB/graph/boolDisplaySpeicher");
						publish("0", "openWB/graph/boolDisplaySpeicherSoc");
					} else {
						showSection('.housebatteryoptions');
						hideSection('.nohousebattery');
					}
				}
				// Chargepoint SoC
				if ( elementId == "boolSocConfiguredLp1") {
					if ( mqttpayload == 0 ) {
						hideSection('.soclp1options');
						publish("0", "openWB/graph/boolDisplayLp1Soc");
					} else {
						showSection('.soclpoptions');
						showSection('.soclp1options');
					}
				}
				if ( elementId == "boolSocConfiguredLp2") {
					if ( mqttpayload == 0 ) {
						hideSection('.soclp2options');
						publish("0", "openWB/graph/boolDisplayLp2Soc");
					} else {
						showSection('.soclpoptions');
						showSection('.soclp2options');
					}
				}
				// Chargepoints
				if ( elementId == "ConfiguredChargePoints") {
					if ( mqttpayload < 2 ) {
						hideSection('.alllpoptions');
						publish("0", "openWB/graph/boolDisplayLpAll");
					} else {
						showSection('.alllpoptions');
					}
				}
				if ( elementId == "boolChargePointConfiguredLp1") {
					if ( mqttpayload == 0 ) {
						hideSection('.lp1options');
						publish("0", "openWB/graph/boolDisplayLp1");
					} else {
						showSection('.lp1options');
					}
				}
				if ( elementId == "boolChargePointConfiguredLp2") {
					if ( mqttpayload == 0 ) {
						hideSection('.lp2options');
						publish("0", "openWB/graph/boolDisplayLp2");
					} else {
						showSection('.lp2options');
					}
				}
				if ( elementId == "boolChargePointConfiguredLp3") {
					if ( mqttpayload == 0 ) {
						hideSection('.lp3options');
						publish("0", "openWB/graph/boolDisplayLp3");
					} else {
						showSection('.lp3options');
					}
				}
				// Verbraucher
				if ( elementId == "ConfiguredVerbraucher1") {
					if ( mqttpayload == 0 ) {
						hideSection('.verbraucher1options');
						publish("0", "openWB/graph/boolDisplayLoad1");
					} else {
						showSection('.verbraucher1options');
						hideSection('.noverbraucher');
					}
				}
				if ( elementId == "ConfiguredVerbraucher2") {
					if ( mqttpayload == 0 ) {
						hideSection('.verbraucher2options');
						publish("0", "openWB/graph/boolDisplayLoad2");
					} else {
						showSection('.verbraucher2options');
						hideSection('.noverbraucher');
					}
				}
				if ( elementId == "device_configuredDevices1") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome1options');
						publish("0", "openWB/graph/boolDisplayShD1");
					} else {
						showSection('.smarthome1options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices2") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome2options');
						publish("0", "openWB/graph/boolDisplayShD2");
					} else {
						showSection('.smarthome2options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices3") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome3options');
						publish("0", "openWB/graph/boolDisplayShD3");
					} else {
						showSection('.smarthome3options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices4") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome4options');
						publish("0", "openWB/graph/boolDisplayShD4");
					} else {
						showSection('.smarthome4options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices5") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome5options');
						publish("0", "openWB/graph/boolDisplayShD5");
					} else {
						showSection('.smarthome5options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices6") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome6options');
						publish("0", "openWB/graph/boolDisplayShD6");
					} else {
						showSection('.smarthome6options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices7") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome7options');
						publish("0", "openWB/graph/boolDisplayShD7");
					} else {
						showSection('.smarthome7options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices8") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome8options');
						publish("0", "openWB/graph/boolDisplayShD8");
					} else {
						showSection('.smarthome8options');
						hideSection('.nosmarthome');
					}
				}
				if ( elementId == "device_configuredDevices9") {
					if ( mqttpayload == 0 ) {
						hideSection('.smarthome9options');
						publish("0", "openWB/graph/boolDisplayShD9");
					} else {
						showSection('.smarthome9options');
						hideSection('.nosmarthome');
					}
				}
			}

			$(document).ready(function(){
				$('input[type=radio]').change(function(){
					me = $(this);
					value = me.val();
					topic = $('#'+me.attr("name")).attr("data-topicprefix")+me.attr("name");
					console.log("Value: "+value+" Topic: "+topic);
					publish(value, topic)
				})
			});

		</script>

	</body>

</html>
