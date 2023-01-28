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
			<h1>Allgemeine Einstellungen</h1>
			<form action="./settings/saveconfig.php" method="POST">


				<!-- Übergreifendes -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						<div class="form-group mb-0">
							<div class="form-row mb-1">
								<label for="devicename" class="col-md-4 col-form-label">Gerätename</label>
								<div class="col">
									<input type="text" name="devicename" id="devicename" value="<?php echo $devicenameold; ?>" placeholder="OpenWB" aria-describedby="devicenameHelpBlock" class="form-control" required="required" pattern="^[\w\d\s\t-,\.\#\+]{0,32}$">
									<span id="devicenameHelpBlock" class="form-text small">
									Der Gerätename wird auf einigen Display-Themen zur Unterscheidung der Ladestationen angezeigt.<br>
									Der Name darf bis zu 32 Zeichen lang sein und aus Buchstaben/Zahlen bestehen
									</span>
								</div>
							</div>
						</div>
					</div>
				</div>



				<!-- Übergreifendes -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						<div class="form-group mb-0">
							<div class="form-row vaRow mb-0">
								<div class="col-4">openWB ist nur ein Ladepunkt</div>
								<div class="col">
									<div class="btn-group btn-group-toggle btn-block" data-toggle="buttons">
										<label class="btn btn-sm btn-outline-info<?php if($isssold == 0) echo " active" ?>">
											<input type="radio" name="isss" id="isssOff" value="0"<?php if($isssold == 0) echo " checked=\"checked\"" ?>>Nein
										</label>
										<label class="btn btn-sm btn-outline-info<?php if($isssold == 1) echo " active" ?>">
											<input type="radio" name="isss" id="isssOn" value="1"<?php if($isssold == 1) echo " checked=\"checked\"" ?>>Ja
										</label>
									</div>
								</div>
							</div>
						</div>
					</div>
					<span class="d_label">&nbsp;isss   </span>				
					<div class="card-body">
						<div class="card-text alert alert-info">
							Wird hier Ja gewählt ist diese openWB nur ein Ladepunkt und übernimmt keine eigene Regelung.
							Hier ist Ja zu wählen wenn, bereits eine openWB vorhanden ist und diese nur ein weiterer Ladepunkt der vorhandenen openWB sein soll.<br />
							Es ist sicherzustellen, dass auf dieser openWB die Modulkonfiguration des <span class="text-danger">ersten Ladepunktes</span>
							korrekt ist und alle weiteren Ladepunkte <span class="text-danger">deaktiviert</span> sind. Handelt es sich hier um eine
							<span class="text-danger">DUO</span>, so ist auch der <span class="text-danger">zweite Ladepunkt</span> zu aktivieren.<br />
							<span class="text-danger">Alle weiteren in dieser openWB getätigten Einstellungen werden NICHT beachtet.</span>
							An der Haupt openWB wird als Ladepunkt "externe openWB" gewählt und die IP Adresse eingetragen.
						</div>
						<div id="isssdiv" class="disabled">
							<div class="form-group">
								<div class="form-row mb-1">
									<label for="ssdisplay" class="col-md-4 col-form-label">Display-Theme</label>
									<div class="col">
										<select name="ssdisplay" id="ssdisplay" class="form-control">
											<option <?php if($ssdisplayold == 0) echo "selected" ?> value="0">Normal</option>
											<option <?php if($ssdisplayold == 1) echo "selected" ?> value="1">Display der übergeordneten openWB</option>
										</select>
									</div>
								</div>
							  	<span class="d_label">openWB.conf&nbsp;ssdisplay   </span>				
							</div>
						</div>
					</div>
					<script>
						$(function() {
							function visibility_isss() {
								if($('#isssOff').prop("checked")) {
									hideSection('#isssdiv');
								} else {
									showSection('#isssdiv');
								}
							}

							$('input[type=radio][name=isss]').change(function(){
								visibility_isss();
							});

							visibility_isss();
						});
					</script>
				</div>

				<!-- electricity tariff providers -->
<?php
 if ( True )
 {
?> 				
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						<div class="form-group mb-0">
							<div class="form-row vaRow mb-0">
								<div class="col-4">Stromanbieter</div>
								<div class="col">
									<div class="btn-group btn-group-toggle btn-block" data-toggle="buttons">
										<label class="btn btn-sm btn-outline-info<?php if($etprovideraktivold == 0) echo " active" ?>">
											<input type="radio" name="etprovideraktiv" id="etprovideraktivOff" value="0"<?php if($etprovideraktivold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-sm btn-outline-info<?php if($etprovideraktivold == 1) echo " active" ?>">
											<input type="radio" name="etprovideraktiv" id="etprovideraktivOn" value="1"<?php if($etprovideraktivold == 1) echo " checked=\"checked\"" ?>>An
										</label>
									</div>
								</div>
							</div>
						</div>
					</div>
					<span class="d_label"> etprovideraktiv  </span>				
					<div class="card-body">
						<div class="card-text alert alert-info">
							Ermöglicht Laden nach Strompreis. Hierfür wird ein unterstützter Anbieter benötigt. Die Funktion ist nur im Modus Sofortladen aktiv!
						</div>
						<div class="form-group mb-0" id="etproviderondiv">
							<div class="form-row mb-1">
								<label for="etprovider" class="col-md-4 col-form-label">Anbieter</label>
								<div class="col">
									<select name="etprovider" id="etprovider" class="form-control">
										<option <?php if($etproviderold == "et_awattar") echo "selected" ?> value="et_awattar">aWATTar Hourly</option>
										<option <?php if($etproviderold == "et_awattarcap") echo "selected" ?> value="et_awattarcap">aWATTar Hourly-CAP</option>
										<option <?php if($etproviderold == "et_tibber") echo "selected" ?> value="et_tibber">Tibber</option>
									</select>
								</div>
							</div>
						   <div class="d_label">openWB/global/ETProvider/modulePath etprovider </div>				
							<div id="awattardiv" class="disabled">
								<div class="form-group">
									<div class="form-row mb-1">
										<label for="awattarlocation" class="col-md-4 col-form-label">Land</label>
										<div class="col">
											<select name="awattarlocation" id="awattarlocation" class="form-control">
												<option <?php if($awattarlocationold == "de") echo "selected" ?> value="de">Deutschland</option>
												<option <?php if($awattarlocationold == "at") echo "selected" ?> value="at">Österreich</option>
											</select>
										</div>
									</div>
						         <div class="d_label">awattarlocation</div>				
								</div>
							</div>
							<div id="tibberdiv" class="hide">
								<script src = "../modules/et_tibber/tibber.js?ver=20210128" ></script>
								<div class="card-text alert alert-primary">
									<p>
										Ihren persönlichen Tibber-Token erhalten Sie über die <a href="https://developer.tibber.com/explorer" target="_blank">Tibber-Developer-Seite</a>.
									</p>
									<p>
										Behandeln Sie Ihren Token wie ein Passwort, da sich darüber auch persönliche Daten aus Ihrem Tibber-Account abfragen lassen! Die Home-ID können Sie (wenn bekannt)
										in das Eingabefeld selbst eintragen oder <b>nach Eingabe Ihres Token</b> durch Klick auf den Button von der openWB ermitteln lassen. Unerlaubte Zeichen werden aus dem Token und der Home-ID automatisch gelöscht.
									</p>
									<p>
										Bei einer fehlerhaften Tibber-Abfrage wird der Strompreis von der openWB bis zur nächsten erfolgreichen Abfrage mit 99.99ct/kWh festgelegt.
									</p>
									Bitte verifizieren Sie die Eingabe, bevor Sie die Einstellungen speichern.
								</div>
								<div class="form-group">
									<div class="form-row mb-1">
										<label for="tibbertoken" class="col-md-4 col-form-label">Tibber-Token</label>
										<div class="col">
											<input class="form-control" type="text" name="tibbertoken" id="tibbertoken" value="<?php echo $tibbertokenold; ?>">
										</div>
									</div>
									<div class="d_label">tibbertoken</div>				
									<div class="form-row mb-1">
										<label for="tibberhomeid" class="col-md-4 col-form-label">Home-ID</label>
										<div class="col">
											<input class="form-control" type="text" name="tibberhomeid" id="tibberhomeid" value="<?php echo $tibberhomeidold; ?>">
										</div>
									</div>
									<div class="d_label">tibberhomeid</div>				
								</div>
								<div class="row justify-content-center">
									<button id="getTibberHomeIdBtn" type="button" class="btn btn-primary m-2">Home-ID ermitteln</button>
									<button id="verifyTibberBtn" type="button" class="btn btn-secondary m-2">Tibber-Daten verifizieren</button>
								</div>
								<script>
									$(document).ready(function(){

										$('#tibberHomesDropdown').selectpicker();

										$('#tibbertoken').change(function(){
											// after change of token check if no invalid chars were entered
											var currentVal = $(this).val();
											// !Attention! Until now there are only characters 0-9 a-Z A-Z _ and - in token.
											// Function may be needed to be adjusted in future
											newVal = currentVal.trim().replace(/[^\w-]/gi,'');
											$(this).val(newVal);
										});

										$('#tibberhomeid').change(function(){
											// after change of token check if no invalid chars were entered
											var currentVal = $(this).val();
											// !Attention! Until now there are only characters 0-9 a-Z A-Z _ and - in in homeID.
											// Function may be needed to be adjusted in future
											newVal = currentVal.trim().replace(/[^\w-]/gi,'');
											$(this).val(newVal);
										});

										$('#tibberhomeIdModalOkBtn').click(function(){
											$('#tibberhomeid').val($('#tibberHomesDropdown option:selected').val());
										});

										$('#getTibberHomeIdBtn').click(function(){
											const tibberQuery = '{ "query": "{viewer {homes{id address{address1 address2 address3 postalCode city}}}}" }';
											readTibberAPI($('#tibbertoken').val(), tibberQuery)
												.then((queryData) => {
													var homes = queryData.data.viewer.homes;
													// clear selectpicker
													$('#tibberHomesDropdown').empty();
													// and fill with received address(es)
													$(homes).each(function() {
														var homeID = this.id;
														var addressStr = this.address.address1;
														if ( this.address.address2 !== null ) {
															addressStr = addressStr + ', ' + this.address.address2;
														}
														if ( this.address.address3 !== null ) {
															addressStr = addressStr + ', ' + this.address.address3;
														}
														addressStr = addressStr + ', ' + this.address.postalCode + ' ' + this.address.city;
														$('#tibberHomesDropdown').append('<option value="' + homeID + '">' + addressStr + '</option>');
    												});
													$('#tibberhomeIdModal').find('.modal-header').removeClass('bg-danger');
													$('#tibberhomeIdModal').find('.modal-header').addClass('bg-success');
													$('#tibberhomeIdModalOkBtn').show();
													$('#tibberModalHomeIdErrorDiv').hide();
													$('#tibberModalSelectHomeIdDiv').show();
													// order of the following selectpicker commands is crucial for correct functionality!!
													// make sure formerly hidden element is now enabled,
													$('#tibberHomesDropdown').attr('disabled',false);
													$('#tibberHomesDropdown').selectpicker('refresh');
													// set the selectpicker to the first option
													$('#tibberHomesDropdown').selectpicker('val', $('#tibberHomesDropdown option:first').val());
													// show modal with unhidden div
													$('#tibberhomeIdModal').modal("show");
												})
												.catch((error) => {
													$('#tibberhomeIdModal').find('.modal-header').removeClass('bg-success');
													$('#tibberhomeIdModal').find('.modal-header').addClass('bg-danger');
													$('#tibberhomeIdModalOkBtn').hide();
													$('#tibberModalHomeIdErrorDiv').find('span').text(error);
													//$('#tibberErrorText').text(error);
													$('#tibberModalHomeIdErrorDiv').show();
													$('#tibberModalSelectHomeIdDiv').hide();
													$('#tibberhomeid').val('');
													$('#tibberhomeIdModal').modal("show");
								  				})
										});

										$('#verifyTibberBtn').click(function(){
											const tibberQuery = '{ "query": "{viewer {name home(id:\\"' + $('#tibberhomeid').val() + '\\") {address {address1}}}}" }';
											readTibberAPI($('#tibbertoken').val(), tibberQuery)
												.then((queryData) => {
													$('#tibberVerifyModal').find('.modal-header').removeClass('bg-danger');
													$('#tibberVerifyModal').find('.modal-header').addClass('bg-success');
													$('#tibberVerifyOkBtn').show();
													$('#tibberVerifyModal').find('.btn-danger').hide();
													$('#tibberModalVerifyErrorDiv').hide();
													$('#tibberModalVerifySuccessDiv').show();
													var name = queryData.data.viewer.name;
													$('#tibberModalVerifySuccessDiv').find('span').text(name);
													$('#tibberVerifyModal').modal("show");
												})
												.catch((error) => {
													$('#tibberVerifyModal').find('.modal-header').removeClass('bg-success');
													$('#tibberVerifyModal').find('.modal-header').addClass('bg-danger');
													$('#tibberVerifyOkBtn').hide();
													$('#tibberVerifyModal').find('.btn-danger').show();
													$('#tibberModalVerifyErrorDiv').find('span').text(error);
													$('#tibberModalVerifyErrorDiv').show();
													$('#tibberModalVerifySuccessDiv').hide();
													$('#tibberhomeid').val('');
													$('#tibberVerifyModal').modal("show");
												})
										});

									});  // end document ready
								</script>

								<!-- modal Tibber-homeID-window -->
								<div class="modal fade" id="tibberhomeIdModal">
									<div class="modal-dialog">
										<div class="modal-content">

											<!-- modal header -->
											<div class="modal-header">
												<h4 class="modal-title">Tibber Home-ID ermitteln</h4>
											</div>

											<!-- modal body -->
											<div class="modal-body">
												<div id="tibberModalHomeIdErrorDiv" class="row justify-content-center hide">
													<div class="col">
														<p>
															<span></span>
														</p>
														Home-ID-Ermittlung fehlgeschlagen.
													</div>
												</div>

												<div id="tibberModalSelectHomeIdDiv" class="row justify-content-center hide">
													<div class="col">
														<div class="form-group">
														<label for="tibberHomesDropdown">Bitte wählen Sie eine Adresse:</label>
														<select class="form-control selectpicker" id="tibberHomesDropdown">
														</select>
													  </div>
													</div>
												</div>

											</div>

											<!-- modal footer -->
											<div class="modal-footer d-flex justify-content-center">
												<button type="button" class="btn btn-success" data-dismiss="modal" id="tibberhomeIdModalOkBtn">Home-ID übernehmen</button>
												<button type="button" class="btn btn-danger" data-dismiss="modal">Abbruch</button>
											</div>

										</div>
									</div>
								</div>  <!-- end modal Tibber-homeID-window -->

								<!-- modal Tibber-verify-data-window -->
								<div class="modal fade" id="tibberVerifyModal">
									<div class="modal-dialog">
										<div class="modal-content">

											<!-- modal header -->
											<div class="modal-header">
												<h4 class="modal-title">Tibber-Daten verifizieren</h4>
											</div>

											<!-- modal body -->
											<div class="modal-body">
												<div id="tibberModalVerifyErrorDiv" class="row justify-content-center hide">
													<div class="col">
														<p>
															<span></span>
														</p>
														Verifizierung der Tibber-Daten fehlgeschlagen.
													</div>
												</div>

												<div id="tibberModalVerifySuccessDiv" class="row justify-content-center hide">
													<div class="col">
														<p>
															Verifizierung der Tibber-Daten erfolgreich!
														</p>
														Registrierter Account-Inhaber: <span></span>
													</div>
												</div>
											</div>

											<!-- modal footer -->
											<div class="modal-footer d-flex justify-content-center">
												<button type="button" class="btn btn-success" data-dismiss="modal" id="tibberVerifyOkBtn">OK</button>
												<button type="button" class="btn btn-danger" data-dismiss="modal">Abbruch</button>
											</div>

										</div>
									</div>
								</div>  <!-- end modal Tibber-verify-data-window -->

							</div>
						</div>
					</div>

					<script>
						$(function() {
							function visibility_electricityprovider() {
								if($('#etprovideraktivOff').prop("checked")) {
									hideSection('#etproviderondiv');
								} else {
									showSection('#etproviderondiv');
								}
							}

							function visibility_electricitytariff() {
								hideSection('#awattardiv');
								hideSection('#tibberdiv');
								switch ($('#etprovider').val()) {
									case 'et_awattar':
										showSection('#awattardiv');
									break;
									case 'et_tibber':
										showSection('#tibberdiv');
									break;
								}
							}

							$('#etprovider').change(function(){
								visibility_electricitytariff();
							});

							$('input[type=radio][name=etprovideraktiv]').change(function(){
								visibility_electricityprovider();
							});

							visibility_electricitytariff();
							visibility_electricityprovider();
						});
					</script>
				</div>
<?php
 }
 else
 {
?>
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Stromanbieter nicht verfügbar.
					</div>
				</div>
<?php 
 }
?> 				
				<!-- Sperren nach Abstecken -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Ladepunkte sperren nach Abstecken
					</div>
					<div class="card-body">
						<div class="card-text alert alert-info">
							Nachdem der Stecker gezogen wird, wird der entsprechende Ladepunkt gesperrt. Ein manuelles aktivieren des Ladepunktes ist erforderlich. Nach aktivieren bleibt der Ladepunkt solange aktiv bis ein Stecker eingesteckt und wieder abgezogen wird. Ist unabhängig davon ob geladen wird.
						</div>
						<div class="form-group">
							<div class="form-row vaRow mb-1">
								<div class="col-md-4">
									Ladepunkt 1
								</div>
								<div class="btn-group btn-group-toggle col" data-toggle="buttons">
									<label class="btn btn-outline-info<?php if($stopchargeafterdisclp1old == 0) echo " active" ?>">
										<input type="radio" name="stopchargeafterdisclp1" id="stopchargeafterdisclp1Off" value="0"<?php if($stopchargeafterdisclp1old == 0) echo " checked=\"checked\"" ?>>Nein
									</label>
									<label class="btn btn-outline-info<?php if($stopchargeafterdisclp1old == 1) echo " active" ?>">
										<input type="radio" name="stopchargeafterdisclp1" id="stopchargeafterdisclp1On" value="1"<?php if($stopchargeafterdisclp1old == 1) echo " checked=\"checked\"" ?>>Ja
									</label>
								</div>
							   <div class="d_label">stopchargeafterdisclp1</div>				
							</div>
							<div id="lp2aktdiv" class="disabled">
								<div class="form-row vaRow mb-1">
									<div class="col-md-4">
										Ladepunkt 2
									</div>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($stopchargeafterdisclp2old == 0) echo " active" ?>">
											<input type="radio" name="stopchargeafterdisclp2" id="stopchargeafterdisclp2Off" value="0"<?php if($stopchargeafterdisclp2old == 0) echo " checked=\"checked\"" ?>>Nein
										</label>
										<label class="btn btn-outline-info<?php if($stopchargeafterdisclp2old == 1) echo " active" ?>">
											<input type="radio" name="stopchargeafterdisclp2" id="stopchargeafterdisclp2On" value="1"<?php if($stopchargeafterdisclp2old == 1) echo " checked=\"checked\"" ?>>Ja
										</label>
									</div>
							      <div class="d_label">stopchargeafterdisclp2</div>				
								</div>
							</div>
							<div id="lp3aktdiv" class="disabled">
								<div class="form-row vaRow mb-1">
									<div class="col-md-4">
										Ladepunkt 3
									</div>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($stopchargeafterdisclp3old == 0) echo " active" ?>">
											<input type="radio" name="stopchargeafterdisclp3" id="stopchargeafterdisclp3Off" value="0"<?php if($stopchargeafterdisclp3old == 0) echo " checked=\"checked\"" ?>>Nein
										</label>
										<label class="btn btn-outline-info<?php if($stopchargeafterdisclp3old == 1) echo " active" ?>">
											<input type="radio" name="stopchargeafterdisclp3" id="stopchargeafterdisclp3On" value="1"<?php if($stopchargeafterdisclp3old == 1) echo " checked=\"checked\"" ?>>Ja
										</label>
									</div>
						    	   <span class="d_label">stopchargeafterdisclp3</span>			
								</div>
							</div>
						</div>
					</div>
					<script>
						$(function() {
							var lp2akt = <?php echo $lastmanagementold ?>;
							var lp3akt = <?php echo $lastmanagements2old ?>;

							if(lp2akt == '0') {
								hideSection('#lp2aktdiv');
								hideSection('#loadsharingdiv');
								//showSection('#loadsharingoffdiv');
								hideSection('#durchslp2div');
							} else {
								showSection('#lp2aktdiv');
								showSection('#loadsharingdiv');
								//hideSection('#loadsharingoffdiv');
								showSection('#durchslp2div');
							}
							if(lp3akt == '0') {
								hideSection('#lp3aktdiv');
								hideSection('#durchslp3div');
							} else {
								showSection('#lp3aktdiv');
								showSection('#durchslp3div');
							}
						});
					</script>
				</div>

				<!-- EV Daten -->
				<div class="card border-primary">
					<div class="card-header bg-primary">
						EV Daten
					</div>
					<div class="card-body">
						<div id="durchslp1div">
							<div class="form-group">
								<div class="form-row mb-1">
									<div class="col">
										Ladepunkt 1
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="durchslp1" class="col-md-4 col-form-label">Durchschnittsverbrauch in kWh/100km</label>
									<div class="col">
										<input class="form-control" type="number" min="1" step="0.1" name="durchslp1" id="durchslp1" value="<?php echo $durchslp1old ?>">
							         <span class="d_label">durchslp1</span>				
										<span class="form-text small">Gültige Werte xx.xx, z.B. 14.5. Dient zur Berechnung der geladenen Strecke.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="akkuglp1" class="col-md-4 col-form-label">Akkugröße in kWh</label>
									<div class="col">
										<input class="form-control" type="number" min="1" step="1" name="akkuglp1" id="akkuglp1" value="<?php echo $akkuglp1old ?>">
							         <span class="d_label">akkuglp1</span>				
										<span class="form-text small">Gültige Werte xx, z.B. 41. Dient zur Berechnung der benötigten Ladezeit.</span>
									</div>
								</div>
							</div>
						</div>
						<div id="durchslp2div" class="disabled">
							<hr class="border-primary">
							<div class="form-group mb-1">
								<div class="form-row mb-1">
									<div class="col">
										Ladepunkt 2
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="durchslp2" class="col-md-4 col-form-label">Durchschnittsverbrauch in kWh/100km</label>
									<div class="col">
										<input class="form-control" type="number" min="1" step=".1" name="durchslp2" id="durchslp2" value="<?php echo $durchslp2old ?>">
							         <span class="d_label">durchslp2</span>				
										<span class="form-text small">Gültige Werte xx.xx, z.B. 14.5. Dient zur Berechnung der geladenen Strecke.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="akkuglp2" class="col-md-4 col-form-label">Akkugröße in kWh</label>
									<div class="col">
										<input class="form-control" type="number" min="1" step="1" name="akkuglp2" id="akkuglp2" value="<?php echo $akkuglp2old ?>">
							         <span class="d_label">akkuglp2</span>				
										<span class="form-text small">Gültige Werte xx, z.B. 41. Dient zur Berechnung der benötigten Ladezeit.</span>
									</div>
								</div>
							</div>
						</div>
						<div id="durchslp3div" class="disabled">
							<hr class="border-primary">
							<div class="form-group">
								<div class="form-row mb-1">
									<div class="col">
										Ladepunkt 3
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="durchslp3" class="col-md-4 col-form-label">Durchschnittsverbrauch in kWh/100km</label>
									<div class="col">
										<input class="form-control" type="number" min="1" step=".1" name="durchslp3" id="durchslp3" value="<?php echo $durchslp3old ?>">
							         <span class="d_label">durchslp3</span>				
										<span class="form-text small">Gültige Werte xx.xx, z.B. 14.5. Dient zur Berechnung der geladenen Strecke.</span>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Automatische Phasenumschaltung -->
				<div class="card border-success">
					<div class="card-header bg-success">
						<div class="form-group mb-0">
							<div class="form-row vaRow mb-0">
								<div class="col-4">Automatische Phasenumschaltung</div>
								<div class="col">
									<div class="btn-group btn-group-toggle btn-block" data-toggle="buttons">
										<label class="btn btn-sm btn-outline-info<?php if($u1p3paktivold == 0) echo " active" ?>">
											<input type="radio" name="u1p3paktiv" id="u1p3paktivOff" value="0"<?php if($u1p3paktivold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-sm btn-outline-info<?php if($u1p3paktivold == 1) echo " active" ?>">
											<input type="radio" name="u1p3paktiv" id="u1p3paktivOn" value="1"<?php if($u1p3paktivold == 1) echo " checked=\"checked\"" ?>>An
										</label>
									</div>
								</div>
							</div>
						</div>
					</div>
					<span class="d_label">u1p3paktiv</span>				
					<div class="card-body">
						<div class="card-text alert alert-info">
							Automatisierte Umschaltung von 1- und 3-phasiger Ladung. Nur aktivieren, wenn diese Option in der OpenWB verbaut ist. Je nach gekaufter Hardwareoption gültig für alle Ladepunkte!
						</div>
						<div id="u1p3pan" class="disabled">
							<div class="form-group">
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Sofort Laden</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($u1p3psofortold == 1) echo " active" ?>">
											<input type="radio" name="u1p3psofort" id="u1p3psofort1" value="1"<?php if($u1p3psofortold == 1) echo " checked=\"checked\"" ?>>einphasig
										</label>
										<label class="btn btn-outline-info<?php if($u1p3psofortold == 3) echo " active" ?>">
											<input type="radio" name="u1p3psofort" id="u1p3psofort3" value="3"<?php if($u1p3psofortold == 3) echo " checked=\"checked\"" ?>>dreiphasig
										</label>
									</div>
								   <span class="d_label">u1p3psofort</span>				
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Standby</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($u1p3pstandbyold == 1) echo " active" ?>">
											<input type="radio" name="u1p3pstandby" id="u1p3pstandby1" value="1"<?php if($u1p3pstandbyold == 1) echo " checked=\"checked\"" ?>>einphasig
										</label>
										<label class="btn btn-outline-info<?php if($u1p3pstandbyold == 3) echo " active" ?>">
											<input type="radio" name="u1p3pstandby" id="u1p3pstandby3" value="3"<?php if($u1p3pstandbyold == 3) echo " checked=\"checked\"" ?>>dreiphasig
										</label>
									</div>
								   <span class="d_label">u1p3pstandby</span>				
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Nachtladen</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($u1p3pnlold == 1) echo " active" ?>">
											<input type="radio" name="u1p3pnl" id="u1p3pnl1" value="1"<?php if($u1p3pnlold == 1) echo " checked=\"checked\"" ?>>einphasig
										</label>
										<label class="btn btn-outline-info<?php if($u1p3pnlold == 3) echo " active" ?>">
											<input type="radio" name="u1p3pnl" id="u1p3pnl3" value="3"<?php if($u1p3pnlold == 3) echo " checked=\"checked\"" ?>>dreiphasig
										</label>
									</div>
								   <span class="d_label">u1p3pnl</span>				
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Min + PV Laden</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($u1p3pminundpvold == 1) echo " active" ?>">
											<input type="radio" name="u1p3pminundpv" id="u1p3pminundpv1" value="1"<?php if($u1p3pminundpvold == 1) echo " checked=\"checked\"" ?>>einphasig
										</label>
										<label class="btn btn-outline-info<?php if($u1p3pminundpvold == 3) echo " active" ?>">
											<input type="radio" name="u1p3pminundpv" id="u1p3pminundpv3" value="3"<?php if($u1p3pminundpvold == 3) echo " checked=\"checked\"" ?>>dreiphasig
										</label>
										<label class="btn btn-outline-info<?php if($u1p3pminundpvold == 4) echo " active" ?>">
											<input type="radio" name="u1p3pminundpv" id="u1p3pminundpv4" value="4"<?php if($u1p3pminundpvold == 4) echo " checked=\"checked\"" ?>>Automatikmodus
										</label>
									</div>
								   <span class="d_label">u1p3pminundpv</span>				
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Nur PV Laden</label>
									<div class="col">
										<div class="btn-group btn-group-toggle btn-block" data-toggle="buttons">
											<label class="btn btn-outline-info<?php if($u1p3pnurpvold == 1) echo " active" ?>">
												<input type="radio" name="u1p3pnurpv" id="u1p3pnurpv1" value="1"<?php if($u1p3pnurpvold == 1) echo " checked=\"checked\"" ?>>einphasig
											</label>
											<label class="btn btn-outline-info<?php if($u1p3pnurpvold == 3) echo " active" ?>">
												<input type="radio" name="u1p3pnurpv" id="u1p3pnurpv3" value="3"<?php if($u1p3pnurpvold == 3) echo " checked=\"checked\"" ?>>dreiphasig
											</label>
											<label class="btn btn-outline-info<?php if($u1p3pnurpvold == 4) echo " active" ?>">
												<input type="radio" name="u1p3pnurpv" id="u1p3pnurpv4" value="4"<?php if($u1p3pnurpvold == 4) echo " checked=\"checked\"" ?>>Automatikmodus
											</label>
   								   <span class="d_label">u1p3pnurpv</span>				
										</div>
									</div>
								</div>
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Schaltzeiten Automatikmodus</label>
									<div class="col">
										<div class="form-row vaRow mb-1">
											<label for="u1p3schaltparam" class="col-2 col-form-label valueLabel" suffix="Min"><?php echo $u1p3schaltparamold; ?> Min</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="u1p3schaltparam" id="u1p3schaltparam" min="1" max="15" step="1" value="<?php echo $u1p3schaltparamold; ?>">
											</div>
										</div>
   								   <span class="d_label">u1p3schaltparam</span>				
										<span class="form-text small">Im Automatikmodus wird die PV Ladung einphasig begonnen. Um zu viele Schaltungen zu vermeiden wird Anhand dieses Wertes definiert wann die Umschaltung erfolgen soll. Ist für durchgehend x Minuten die Maximalstromstärke erreicht, wird auf dreiphasige Ladung umgestellt. Ist die Ladung nur für ein Intervall unterhalb der Maximalstromstärke, beginnt der Counter für die Umschaltung erneut. Ist die Ladung im dreiphasigen Modus für 16 - x Minuten bei der Minimalstromstärke, wird wieder auf einphasige Ladung gewechselt. Standardmäßig ist dieser Wert bei 8 min, sprich nach 8 min Maximalstromstärke wird auf 3 Phasige Ladung umgestellt und nach 16 - 8 = 8 min bei Minimalstromstärke wird wieder auf einphasige Ladung gewechselt.</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<label for="u1p3ppause" class="col-md-4 col-form-label">Pause vor und nach der Umschaltung</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="u1p3ppause" class="col-2 col-form-label valueLabel" suffix="Sek"><?php echo $u1p3ppauseold; ?> Sek</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="u1p3ppause" id="u1p3ppause" min="2" max="150" step="1" value="<?php echo $u1p3ppauseold; ?>">
											</div>
										</div>
   								   <span class="d_label">u1p3ppause</span>				
										<span class="form-text small">
											Die Standardeinstellung ist 2 Sekunden. Falls ein Fahrzeug den Ladevorgang nach einer Umschaltung nicht zuverlässig startet, kann dieser Wert erhöht werden.
											<span class="text-danger">Achtung: experimentelle Einstellung!</span>
										</span>
									</div>
								</div>
							</div>
							<hr class="border-success">
							<div class="form-group">
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Schieflastbeachtung</label>
									<div class="btn-group btn-group-toggle col" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($schieflastaktivold == 0) echo " active" ?>">
											<input type="radio" name="schieflastaktiv" id="schieflastaktivOff" value="0"<?php if($schieflastaktivold == 0) echo " checked=\"checked\"" ?>>Nein
										</label>
										<label class="btn btn-outline-info<?php if($schieflastaktivold == 1) echo " active" ?>">
											<input type="radio" name="schieflastaktiv" id="schieflastaktivOn" value="1"<?php if($schieflastaktivold == 1) echo " checked=\"checked\"" ?>>Ja
										</label>
									</div>
								</div>
   							<span class="d_label">schieflastaktiv</span>				
								<div class="form-row mb-1 disabled" id="schieflastan">
									<label for="schieflastmaxa" class="col-md-4 col-form-label">Schieflastbegrenzung</label>
									<div class="col-md-8">
										<div class="form-row vaRow mb-1">
											<label for="schieflastmaxa" class="col-2 col-form-label valueLabel" suffix="A"><?php echo $schieflastmaxaold; ?> A</label>
											<div class="col-10">
												<input type="range" class="form-control-range rangeInput" name="schieflastmaxa" id="schieflastmaxa" min="10" max="32" step="1" value="<?php echo $schieflastmaxaold; ?>">
											</div>
										</div>
            						<span class="d_label">schieflastmaxa</span>				
										<span class="form-text small">Gibt an mit wieviel Ampere maximal geladen wird wenn die automatische Umschaltung aktiv ist und mit einer Phase lädt.</span>
									</div>
								</div>
							</div>
						</div>
					</div>
					<script>
						$(function() {
							function visibility_u1p3paktiv() {
								if($('#u1p3paktivOff').prop("checked")) {
									hideSection('#u1p3pan');
								} else {
									showSection('#u1p3pan');
									visibility_schieflastaktiv();
								}
							}

							function visibility_schieflastaktiv() {
								if($('#schieflastaktivOff').prop("checked")) {
									hideSection('#schieflastan');
								} else {
									showSection('#schieflastan');
								}
							}

							$('input[type=radio][name=u1p3paktiv]').change(function(){
								visibility_u1p3paktiv();
							});

							$('input[type=radio][name=schieflastaktiv]').change(function(){
								visibility_schieflastaktiv();
							});

							visibility_u1p3paktiv();
						});
					</script>
				</div>


				<!-- EVU basiertes Lastmanagement -->
				<div class="card border-warning">
					<div class="card-header bg-warning">
						EVU basiertes Lastmanagement
					</div>
					<div class="card-body">
						<div class="form-group">
							<div class="form-row mb-1">
								<div class="col-md-4">
									maximale Stromstärken in A
								</div>
								<div class="col">
									<div class="form-row">
										<div class="col-sm-4">
											<div class="input-group">
												<div class="input-group-prepend">
													<div class="input-group-text">
														Phase 1
													</div>
												</div>
												<input type="number" min="7" step="1" name="lastmaxap1" id="lastmaxap1" class="form-control" value="<?php echo $lastmaxap1old ?>">
											</div>
										</div>
										<div class="col-sm-4">
											<div class="input-group">
												<div class="input-group-prepend">
													<div class="input-group-text">
														Phase 2
													</div>
												</div>
												<input type="number" min="7" step="1" name="lastmaxap2" id="lastmaxap2" class="form-control" value="<?php echo $lastmaxap2old ?>">
											</div>
										</div>
										<div class="col-sm-4">
											<div class="input-group">
												<div class="input-group-prepend">
													<div class="input-group-text">
														Phase 3
													</div>
												</div>
												<input type="number" min="7" step="1" name="lastmaxap3" id="lastmaxap3" class="form-control" value="<?php echo $lastmaxap3old ?>">
											</div>
										</div>
									</div>
	             				<span class="d_label">lastmaxap1 lastmaxap2 lastmaxap3 </span>				
									<span class="form-text small">Gültige Werte: ganze Zahl größer 7. Definiert die maximal erlaubte Stromstärke der einzelnen Phasen des <b>Hausanschlusses</b> im Sofort Laden Modus, sofern das EVU Modul die Werte je Phase zur Verfügung stellt. Hiermit ist nicht der Anschluss der openWB gemeint! Übliche Werte für ein EFH/MFH sind im Bereich 35 bis 63A.</span>
								</div>
							</div>
							<div class="form-row mb-1">
								<label for="lastmmaxw" class="col-md-4 col-form-label">maximaler Bezug in W</label>
								<div class="col">
									<input class="form-control" type="number" min="2000" max="1000000" step="1000" name="lastmmaxw" id="lastmmaxw" value="<?php echo $lastmmaxwold ?>">
	             				<span class="d_label">lastmmaxw </span>				
									<span class="form-text small">Gültige Werte: 2000-1000000W in ganzen 1000W-Schritten. Definiert die maximal erlaubten bezogenen Watt des Hausanschlusses im Sofort Laden Modus, sofern die Bezugsleistung bekannt ist.</span>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Loadsharing -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						Loadsharing
					</div>
					<div class="card-body">
						<div id="loadsharingoffdiv" class="card-text alert alert-info ">
							Diese Einstellungen sind nur verfügbar, wenn mindestens zwei Ladepunkte konfiguriert sind.
						</div>
						<div id="loadsharingdiv" class="disabled">
							<div class="form-group">
								<div class="form-row mb-1">
									<label class="col-md-4 col-form-label">Loadsharing für Ladepunkte 1 und 2</label>
									<div class="col">
										<div class="btn-group btn-block btn-group-toggle" data-toggle="buttons">
											<label class="btn btn-outline-info<?php if($loadsharinglp12old == 0) echo " active" ?>">
												<input type="radio" name="loadsharinglp12" id="loadsharinglp12Off" value="0"<?php if($loadsharinglp12old == 0) echo " checked=\"checked\"" ?>>Deaktiviert
											</label>
											<label class="btn btn-outline-info<?php if($loadsharinglp12old == 1) echo " active" ?>">
												<input type="radio" name="loadsharinglp12" id="loadsharinglp12On" value="1"<?php if($loadsharinglp12old == 1) echo " checked=\"checked\"" ?>>Aktiviert
											</label>
										</div>
             					   <span class="d_label">loadsharinglp12 </span>				
										<span class="form-text small">
											Wenn Ladepunkt 1 und 2 sich eine Zuleitung teilen, diese Option aktivieren. Sie stellt in jedem Lademodus sicher, dass nicht mehr als 16 bzw. 32A je Phase in der Summe von Ladepunkt 1 und 2 genutzt werden.
											<span class="text-danger">Bei der OpenWB Duo muss diese Option aktiviert werden!</span>
										</span>
									</div>
								</div>
								<div id="loadsharinglp12div" class="disabled">
									<div class="form-row mb-2">
										<label class="col-md-4 col-form-label">Maximaler Strom</label>
										<div class="col">
											<div class="btn-group btn-block btn-group-toggle" data-toggle="buttons">
												<label class="btn btn-outline-info<?php if($loadsharingalp12old == 16) echo " active" ?>">
													<input type="radio" name="loadsharingalp12" id="loadsharingalp1216" value="16"<?php if($loadsharingalp12old == 16) echo " checked=\"checked\"" ?>>16 Ampere
												</label>
												<label class="btn btn-outline-info<?php if($loadsharingalp12old == 32) echo " active" ?>">
													<input type="radio" name="loadsharingalp12" id="loadsharingalp1232" value="32"<?php if($loadsharingalp12old == 32) echo " checked=\"checked\"" ?>>32 Ampere
												</label>
											</div>
	             					   <span class="d_label">loadsharingalp12 </span>				
										</div>
									</div>
									<div class="alert alert-warning">
										<p class="text-danger">Der richtige Anschluss ist zu gewährleisten.</p>
										<div class="row">
											<div class="col-md-4">Ladepunkt 1:</div>
											<div class="col">
												<ul>
													<li>Zuleitung Phase 1 = Phase 1</li>
													<li>Zuleitung Phase 2 = Phase 2</li>
													<li>Zuleitung Phase 3 = Phase 3</li>
												</ul>
											</div>
										</div>
										<div class="row">
											<div class="col-md-4">Ladepunkt 2:</div>
											<div class="col">
												<ul>
													<li>Zuleitung Phase 1 = <span class="text-danger">Phase 2</span></li>
													<li>Zuleitung Phase 2 = <span class="text-danger">Phase 3</span></li>
													<li>Zuleitung Phase 3 = <span class="text-danger">Phase 1</span></li>
												</ul>
											</div>
										</div>
										<p>Durch das Drehen der Phasen ist sichergestellt, dass 2 einphasige Autos mit voller Geschwindigkeit laden können.</p>
									</div>
								</div>
							</div>
						</div>
					</div>
					<script>
						$(function() {
							function visibility_loadsharinglp12() {
								if($('#loadsharinglp12Off').prop("checked")) {
									hideSection('#loadsharinglp12div');
								} else {
									showSection('#loadsharinglp12div');
								}
							}

							$('input[type=radio][name=loadsharinglp12]').change(function(){
								visibility_loadsharinglp12();
							});

							visibility_loadsharinglp12();
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
				<small>Sie befinden sich hier: Einstellungen/Allgemein</small>
			</div>
		</footer>


		<script>

			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav").replaceWith(data);
					// disable navbar entry for current page
					$('#navAllgemein').addClass('disabled');
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
