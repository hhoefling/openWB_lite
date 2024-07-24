<?php
function  getdateurl($dir,$file)
	{
 			$fn=sprintf('%s/%s', $dir,$file);
			$ftime=filemtime("./$file");
			return sprintf('%s?w=%d' , $fn,$ftime);
	
 	}
?>
<!DOCTYPE html>
<html lang="de">

	<head>
		<base href="/openWB/web/">

		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>openWB Einstellungen</title>
		<meta name="description" content="Control your charge" />
		<meta name="keywords" content="html template, css, free, one page, gym, fitness, web design" />
		<meta name="author" content="Kevin Wieland, Michael Ortenstein" />
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
		<link rel="stylesheet" type="text/css" href="fonts/font-awesome-5.8.2/css/all.css">
		<!-- include settings-style -->
		<link rel="stylesheet" type="text/css" href="css/settings_style.css">

		<!-- important scripts to be loaded -->
		<script src="js/jquery-3.6.0.min.js"></script>
		<script src="js/bootstrap-4.4.1/bootstrap.bundle.min.js"></script>
		<!-- load helper functions -->
		<script src = "<?php echo getdateurl('settings','helperFunctions.js');?>"></script>
		
		<script>
		 function setDefaults(target)
		 {
		  //console.log('setdefaults for ', target);
		  $('input', $(target)).each(function () 
		  		{
	    			// console.log($(this)); //log every element found to console output
					if($(this).attr("data-default"))
					 {
					  console.log('---def', this.id, this.name, this.value , $(this).data('default')  );
					  var defval=$(this).data('default');
					  var deftyp=$(this).data('typ');
					  console.log(defval, deftyp);
				      if( $(this).val()==''  )
                      {
					     $(this).val( defval );
                      } else console.log('value set', this.value )
					 } 				
			   }
		   );
		 }

		</script>
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
          var devicename='<?php echo $devicenameold;?>';
		  console.log('openWB Debug:',debugold);
		</script>

		<div id="nav"></div> <!-- placeholder for navbar -->

		<div role="main" class="container" style="margin-top:20px">
			<h1>Events und Benachrichtigungen</h1>
            <span class="d_label">alles Daten aus openWB.conf</span> 
			<form action="./settings/saveconfig.php" method="POST">
				<!-- Benachrichtigungen mit Pushover -->
				<div class="card border-secondary">
					<div class="card-header bg-secondary">
						<div class="form-group mb-0">
							<div class="form-row vaRow mb-0">
								<div class="col-4">Benachrichtigungen mit Pushover</div>
								<div class="col">
									<div class="btn-group btn-block btn-group-toggle" data-toggle="buttons">
										<label class="btn btn-sm btn-outline-info<?php if($pushbenachrichtigungold == 0) echo " active" ?>">
											<input type="radio" name="pushbenachrichtigung" id="pushbenachrichtigungOff" value="0"<?php if($pushbenachrichtigungold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-sm btn-outline-info<?php if($pushbenachrichtigungold == 1) echo " active" ?>">
											<input type="radio" name="pushbenachrichtigung" id="pushbenachrichtigungOn" value="1"<?php if($pushbenachrichtigungold == 1) echo " checked=\"checked\"" ?>>An
										</label>
  							            <span class="d_label"> pushbenachrichtigung</span>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="card-body">
						<div class="card-text alert alert-info">
							<p>Zur Nutzung von Pushover muss ein Konto auf Pushover.net bestehen. Zudem muss im Pushover-Nutzerkonto eine Applikation openWB eingerichtet werden, um den benötigten API-Token/Key zu erhalten.</p>
							Wenn Pushover eingeschaltet ist, werden die Zählerstände aller konfigurierten Ladepunkte immer zum 1. des Monats gepusht.
						</div>
						<div id="pushban" class="disabled">
							<div class="form-group">
								<div class="form-row mb-1">
									<label for="pushoveruser" class="col-md-4 col-form-label">Pushover User Key</label>
									<div class="col">
										<div class="input-group">
											<div class="input-group-prepend">
												<div class="input-group-text">
													<i class="fa fa-user"></i>
												</div>
											</div>
											<input type="text" data-default="username"  name="pushoveruser" id="pushoveruser" value="<?php echo $pushoveruserold ?>" placeholder="User Token" class="form-control">
										</div>
										<span class="d_label"> pushoveruser</span>
									</div>
								</div>
								<div class="form-row">
									<label for="pushovertoken" class="col-md-4 col-form-label">Pushover API-Token/Key</label>
									<div class="col">
										<div class="input-group">
											<div class="input-group-prepend">
												<div class="input-group-text">
													<i class="fa fa-lock"></i>
												</div>
											</div>
											<input type="text" name="pushovertoken" id="pushovertoken" value="<?php echo $pushovertokenold ?>" placeholder="App Token" class="form-control">
										</div>
										<span class="d_label"> pushovertoken</span>
									</div>
								</div>
							</div>
							<hr class="border-secondary">
							<div class="form-group">
								<div class="form-row">
									<div class="col">
										Benachrichtigungen
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										<label class="col-form-label">Beim Starten der Ladung</label>
									</div>
									<div class="btn-group btn-group-toggle col-md-8" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($pushbstartlold == 0) echo " active" ?>">
											<input type="radio" name="pushbstartl" id="pushbstartlOff" value="0"<?php if($pushbstartlold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-outline-info<?php if($pushbstartlold == 1) echo " active" ?>">
											<input type="radio" name="pushbstartl" id="pushbstartlOn" value="1"<?php if($pushbstartlold == 1) echo " checked=\"checked\"" ?>>An
										</label>
										<span class="d_label"> pushbstartlOn</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										<label class="col-form-label">Beim Stoppen der Ladung</label>
									</div>
									<div class="btn-group btn-group-toggle col-md-8" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($pushbstoplold == 0) echo " active" ?>">
											<input type="radio" name="pushbstopl" id="pushbstoplOff" value="0"<?php if($pushbstoplold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-outline-info<?php if($pushbstoplold == 1) echo " active" ?>">
											<input type="radio" name="pushbstopl" id="pushbstoplOn" value="1"<?php if($pushbstoplold == 1) echo " checked=\"checked\"" ?>>An
										</label>
										<span class="d_label"> pushbstoplOn</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										<label class="col-form-label">Beim Einstecken des Fahrzeugs</label>
									</div>
									<div class="btn-group btn-group-toggle col-md-8" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($pushbplugold == 0) echo " active" ?>">
											<input type="radio" name="pushbplug" id="pushbplugOff" value="0"<?php if($pushbplugold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-outline-info<?php if($pushbplugold == 1) echo " active" ?>">
											<input type="radio" name="pushbplug" id="pushbplugOn" value="1"<?php if($pushbplugold == 1) echo " checked=\"checked\"" ?>>An
										</label>
										<span class="d_label"> pushbplugOn</span>
									</div>
								</div>
								<div class="form-row mb-1">
									<div class="col-md-4">
										<label class="col-form-label">Bei Triggern von Smart Home Aktionen</label>
									</div>
									<div class="btn-group btn-group-toggle col-md-8" data-toggle="buttons">
										<label class="btn btn-outline-info<?php if($pushbsmarthomeold == 0) echo " active" ?>">
											<input type="radio" name="pushbsmarthome" id="pushbsmarthomeOff" value="0"<?php if($pushbsmarthomeold == 0) echo " checked=\"checked\"" ?>>Aus
										</label>
										<label class="btn btn-outline-info<?php if($pushbsmarthomeold == 1) echo " active" ?>">
											<input type="radio" name="pushbsmarthome" id="pushbsmarthomeOn" value="1"<?php if($pushbsmarthomeold == 1) echo " checked=\"checked\"" ?>>An
										</label>
										<span class="d_label"> pushbsmarthomeOn</span>
									</div>
								</div>
							</div>
						</div>
					</div>
					<script>
						function visibility_pushbenachrichtigung() {
							if($('#pushbenachrichtigungOff').prop("checked")) {
								hideSection('#pushban');
							} else {
								showSection('#pushban');
								setDefaults('#pushban');
							}
						}

						$(document).ready(function(){
							$('input[type=radio][name=pushbenachrichtigung]').change(function(){
								visibility_pushbenachrichtigung();
							});

							visibility_pushbenachrichtigung();
						});
					</script>
				</div>

				<div class="form-row text-center">
					<div class="col">
						<button id="saveSettingsBtn" type="submit" class="btn btn-success">Speichern</button>
					</div>
				</div>
			</form>
		</div>  <!-- container -->

		<footer class="footer bg-dark text-light font-small">
			<div class="container text-center">
				<small>Sie befinden sich hier: Events</small>
			</div>
		</footer>

		<script>
			$('.rangeInput').on('input', function() {
				// show slider value in label of class valueLabel
				updateLabel($(this).attr('id'));
			});

			$.get(
				{ url: "settings/navbar.html", cache: false },
				function(data){
					$("#nav").replaceWith(data);
					// disable navbar entry for current page
					$('#navEvent').addClass('disabled');
                   $('.devicename').text(devicename);
				}
				
			);
		</script>

	</body>
</html>
