<?php
// heist html, wird aber von index.php geincluded

function  xgeturl($file)
{
 global $theme;
 $fn=sprintf('themes/%s/%s', $theme,$file);
 $ftime=filemtime($fn);
 return sprintf('%s?v=%d' , $fn,$ftime);

}


function makedebugreihe()
{
 global $dbdebs,$dbdeb,$debug;
 
 echo <<<END
	<!-- debug reihe  -->
	<div id="altclicker" class="container-fluid py-0 pb-2">
	  <div class="row py-0 px-0">
		<div class="rounded shadow wb-widget col-md p-2 m-1 ">
			<div id="accordion" class="accordion">
				<div class="card mb-0">
					<div class="card-header bg-secondary collapsed" data-toggle="collapse" data-target="#debugOne">
						<a class="card-title">Debug </a>
					</div>
					<div id="debugOne" class="card-body collapse" data-parent="#accordion" style="background-color: white" >
						<pre id="debugdiv" style="font-size:0.7rem;">

END;
					foreach( $dbdebs as $s)
						echo "DEB:$s\n";
					if( $debug > 3) { 
						echo "---- Globals---\n";
						$dbdebs="striped";	
				 		print_r($GLOBALS);
					}
echo <<<END
						</pre>
					</div>
				</div>
			</div>
		</div>
  	  </div>
	</div>
	<!-- debug reihe  -->
END;
}

function makerctclicker()
{
 global $iscloud;
 if( $iscloud )
   return;

echo <<<END
		if (Math.floor(wbdata.batterydischarge_max)>0)   // rct vorhanden, sonst default -1
			$("#rctbatmenu").addClass("hide");

// RCT Detailsmode start
			$('#lade1hclick').click(function (event) {
			    event.preventDefault()
				console.log('lade1hclick', event);
				publish("59", "openWB/set/houseBattery/loadbat");
			});
			$('#lade2hclick').click(function (event) {
			    event.preventDefault()
				console.log('lade2hclick', event);
				publish("119", "openWB/set/houseBattery/loadbat");
			});
			$('#resetwattclick').click(function (event) {
			    event.preventDefault()
				console.log('resetwattclick', event);
				publish("resetwatt", "openWB/set/houseBattery/reset_rct");
			});
			$('#resetcurrentclick').click(function (event) {
			    event.preventDefault()
				console.log('resetcurrentclick', event);
				publish("resetcurrent", "openWB/set/houseBattery/reset_rct");
			});
			$('#setcurrentclick').click(function (event) {
			    event.preventDefault()
				console.log('setcurrentclick', event);
				publish("180", "openWB/set/houseBattery/aktivateDrainmode");
			});
// RCT Detailsmode end

END;
}

function makebatmenu()
{
 global $iscloud;
 if( $iscloud )
   return;

echo <<<END
				<div class="col-2 px-0" style="text-align: right;" id="rctbatmenu">
					<div class="dropdown">
						<button class="btn btn-outline-secondary btn-sm dropdown-toggle" type="button" data-toggle="dropdown">
							<span class="fa fa-bars fa-sm"></span>
						</button>
						<div class="dropdown-menu dropdown-menu-right colormenu">
							<a class="dropdown-item" id="lade1hclick" href="#"><span class="fa fa-battery-quarter px-0"></span> 1 Stunde Laden</a>
							<a class="dropdown-item" id="lade2hclick" href="#"><span class="fa fa-battery-half px-0"></span> 2 Stunden Laden</a>
							<a class="dropdown-item" id="resetwattclick" href="#"><span class="fa fa-battery-half px-1"></span> <span class="fa fa-undo px-0"></span> Zurücksetzen</a>
							<a class="dropdown-item" id="setcurrentclick" href="#"><span class="fa fa-ban px-1"></span></span> Endladeschutz 2 Std</a>
							<a class="dropdown-item" id="resetcurrentclick" href="#"><span class="fa fa-ban px-1"></span> <span class="fa fa-undo  px-0"></span> Zurücksetzen</a>
						</div>
					</div>
				</div>

END;

}

?>
<!DOCTYPE html>
<html lang="de" class="theme-hh">
 
<head>
	<title>openWB</title>
	<meta charset="UTF-8">
	<meta name="viewport"
		content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
	<meta name="apple-mobile-web-app-title" content="openWB-PWA">
	<meta name="apple-mobile-web-app-status-bar-style" content="default">
	<link rel="apple-touch-startup-image" href="/openWB/web/img/favicons/splash1125x2436w.png" />
	<link rel="apple-touch-startup-image"
		media="(device-width: 375px) and (device-height: 812px) and (-webkit-device-pixel-ratio: 3)"
		href="img/favicons/splash1125x2436w.png">
	<meta name="apple-mobile-web-app-title" content="openWB">
    <meta name="mobile-web-app-capable" content="yes" />

	<meta name="description" content="openWB-d">
	<meta name="keywords" content="openWB-k">
	<meta name="author" content="Michael Ortenstein">
	<link rel="apple-touch-icon" sizes="72x72" href="img/favicons/apple-icon-72x72.png">
	<link rel="apple-touch-icon" sizes="76x76" href="img/favicons/apple-icon-76x76.png">
	<link rel="apple-touch-icon" sizes="114x114" href="img/favicons/apple-icon-114x114.png">
	<link rel="apple-touch-icon" sizes="120x120" href="img/favicons/apple-icon-120x120.png">
	<link rel="apple-touch-icon" sizes="144x144" href="img/favicons/apple-icon-144x144.png">
	<link rel="apple-touch-icon" sizes="152x152" href="img/favicons/apple-icon-152x152.png">
	<link rel="apple-touch-icon" sizes="180x180" href="img/favicons/apple-icon-180x180.png">
    <link rel="icon" type="image/png" sizes="16x16" href="img/favicons/favicon-16x16.png">
	<link rel="icon" type="image/png" sizes="32x32" href="img/favicons/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="96x96" href="img/favicons/favicon-96x96.png">
    <link rel="icon" type="image/png" sizes="192x192" href="img/favicons/android-icon-192x192.png">
	<meta name="msapplication-TileColor" content="#ffffff">
	<meta name="msapplication-TileImage" content="/ms-icon-144x144.png">
	<link rel="apple-touch-icon" sizes="57x57" href="img/favicons/apple-touch-icon-57x57.png">
	<link rel="apple-touch-icon" sizes="60x60" href="img/favicons/apple-touch-icon-60x60.png">
	<link rel="manifest" href="manifest.json">
	<link rel="manifest" href="./manifest.json">
	<link rel="shortcut icon" href="img/favicons/favicon.ico">
	<!-- link rel="apple-touch-startup-image" href="img/loader.gif"> -->
	<meta name="msapplication-config" content="img/favicons/browserconfig.xml">
	<meta name="theme-color" content="#ffffff">

	<!-- Bootstrap -->
	<link rel="stylesheet" type="text/css" href="css/bootstrap-4.4.1/bootstrap.css?v=1235">
	<!-- Normalize -->
	<link rel="stylesheet" type="text/css" href="css/normalize-8.0.1.css">
	<!-- Font Awesome, all styles -->
	<link rel="stylesheet" type="text/css" href="fonts/font-awesome-5.8.2/css/all.css">
	<!-- local css due to async loading of theme css -->
	<style>
		#preloader {
			background-color: var(--color-bg);
			position: fixed;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 999999;
		}

		#preloader-inner {
			margin-top: 150px;
			text-align: center;
		}

		#preloader-image {
			max-width: 300px;
			filter: var(--invertLogo)
		}

		#preloader-info {
			color: grey;
		}

		#thegraph>div {
			height: 350px;
		}
	</style>
	<!-- important scripts to be loaded -->
	<script src="js/jquery-3.6.0.min.js"></script>
	<script src="js/bootstrap-4.4.1/bootstrap.bundle.min.js"></script>

	<script>
		function getCookie(cname) {
			var name = cname + '=';
			var decodedCookie = decodeURIComponent(document.cookie);
			var ca = decodedCookie.split(';');
			for (var i = 0; i < ca.length; i++) {
				var c = ca[i];
				while (c.charAt(0) == ' ') {
					c = c.substring(1);
				}
				if (c.indexOf(name) == 0) {
					val=c.substring(name.length, c.length);
					console.log('theme.php getCookie '+cname+'='+val); 
					return val;
				}
			}
			return '';
		}
		var themeCookie = getCookie('openWBTheme');
		
		function setCookie(name, value, days) {
			var expires = '';
			if ( days ) {
				var date = new Date();
				date.setDate(date.getDate() + days);
				expires = '; expires=' + date.toUTCString();
			}
		    document.cookie = name + "=" + (value || '')  + expires + "; path=/openWB/;SameSite=Lax";
			console.log('setCookie '+name+'='+value);
		}


		// include special Theme style
	 	$('head').append('<link rel="stylesheet" href="<?php echo xgeturl('style.css');?>">');
		
		<?php
			echo "\r\t\t console.log('php.debug',  $debug)";
		?>
		
		var debugmode=<?php echo $debug;?>;
		var debugold=<?php echo $debug;?>;
		console.log('js.debugold', debugold, ' js.debugmode:',debugmode);
		tmp=getCookie('debugmode');
		if ( tmp>'')
		{ 
			debugmode=tmp;	// override
			console.log('js-debugmode from cookie:[debugmode]',debugmode);
		} else console.log('Cookie js.debugmode not set'); 
		console.log('js window.debugmode' + window.debugmode)

	</script>
	<script src="<?php echo xgeturl('js/d3.v6.min.js');?>"></script>
	<script src="<?php echo xgeturl('powerdata.js');?>"></script>
	<script src="<?php echo xgeturl('powermeter.js');?>"></script>
	<script src="<?php echo xgeturl('yieldmeter.js');?>"></script>
	<script src="<?php echo xgeturl('powergraph.js');?>"></script>
	<script src="<?php echo xgeturl('chargePointList.js');?>"></script>
	<script src="<?php echo xgeturl('smartHomeList.js');?>"></script>
	<script src="<?php echo xgeturl('batteryList.js');?>"></script>
	<script src="<?php echo xgeturl('pricechart.js');?>"></script>

<?php

// out('owbconf' . print_r($owbconf,true)); 				
 //$iscloud=true;

$iscl=($iscloud) ? 'true' : 'false';
out('iscl:' . $iscl);
echo <<<END
    <script>
    function validate()
     {
        console.log('validate..');
        usern='$_CURRENT_USER->username';
        passwd='$_CURRENT_USER->passwd';
        dbdeb=$dbdeb;
        iscloud=$iscl;
		MOSQSERVER='$MOSQSERVER';
		MOSQPORT=$MOSQPORT;
		MOSQPORTSSL=$MOSQPORTSSL;
		PROJECT='$PROJECT';
        theme='$theme';
    }
    validate();
    </script>

END;

?>

</head>

<body>
	<!-- Preloader with Progress Bar -->
	<!-- style instead of css due to async loading of theme css -->
	<!--  display:none statt hide   -->
	<div id="preloader">
		<div id="preloader-inner">
			<div class="row">
				<div class="mx-auto d-block justify-content-center">
					<img id="preloader-image" src="img/favicons/preloader-image-transparent.png" alt="openWB">
				</div>
			</div>
			<div id="preloader-info" class="row justify-content-center mt-2">
				<div class="col-10 col-sm-6">
					Bitte Geduld, während die Seite aufgebaut wird.
					<br><span class="devicename">openWB</span>&nbsp;Theme <?php echo $theme; ?>
				</div>
			</div>
			<div class="row justify-content-center mt-2">
				<div class="col-10 col-sm-6">
					<div class="progress active">
						<div class="progress-bar progress-bar-success progress-bar-striped progress-bar-animated" id="preloaderbar"
							role="progressbar">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Landing Page -->
	<div id="nav-placeholder">
	</div>
	
	<!-- main page  -->
	<div id="altclicker" class="container-fluid">


		<!-- Kopfzeile -->
		<div class="row py-1 verySmallTextSize" style="color: var(--color-fg)">
			<div id="date" class="col-2 text-left" style="padding-right: 5px; padding-left: 5px;" >
				&nbsp;
			</div>
			<div class="col-2 text-left" >
             <meter id="uptimem" min="0" low="0.05" high="1.5" max="2.0" value="0.1" style="width:70%" ></meter>
  			 <span id="uptime">	&nbsp; </span>
			</div>
			<div class="col-4 text-center">
				<button type="button" class="btnfcss btn-secondary cursor-pointer regularTextSize" id="chargeModeSelectBtn">
					<span id="chargeModeSelectBtnText">Lademodus</span>
					<span id="priorityEvBattery">
						<span class="fas fa-car" id="priorityEvBatteryIcon">&nbsp;</span>
					</span>
				</button>
		
			</div>
            <div class="col-2 text-left"  >
             <meter id="need" min="0" xlow="5" high="8" max="12" value="0" style="width:80%" ></meter>
			 <span id="needs">	&nbsp; </span>
			</div>
			<div id="time" class="col-2 text-right" style="padding-right: 5px; padding-left: 5px;" >
				&nbsp;needs
			</div>
		</div>  <!-- end kopf row -->
		<!-- Kopfzeile Ende -->




		<div class="row py-0 d-flex justify-content-center">
			<!-- Obere reihe mit drei elementen -->
			<!-- Aktuelle Leistung (powermeter) -->

			<div class="col-lg-4 p-1 m-0 main-window">
				<div class="rounded shadow wb-widget m-0 p-2">
					<div class="d-flex justify-content-between">
							<h3>Aktuelle Leistung</h3>
						<div class="col-4 m-0 p-0" style="text-align: right;">
							<div class="dropdown">
								<button class="btn btn-outline-secondary btn-sm dropdown-toggle" type="button" data-toggle="dropdown">
									<span class="fa fa-bars fa-sm"></span>
								</button>
								<div class="dropdown-menu dropdown-menu-right colormenu">
									<a class="dropdown-item" href="#" onclick="switchTheme()"><span class="fa fa-adjust px-0"></span>
										<span  id="mediacss">Hintergrund ändern </span></a>
									<a class="dropdown-item" href="#" onclick="toggleGrid()"><span class="fa fa-th px-0"></span> Graph:
										Raster an/aus</a>
									<a class="dropdown-item" href="#" onclick="switchDisplay()"><span
											class="fa fa-chart-area px-0"></span> Fixe Bögen an/aus</a>
									<a class="dropdown-item hide" id="meterResetButton" href="#" onclick="resetButtonClicked()"><span
											class="fa fa-undo"></span> Bögen reset</a>
									<a class="dropdown-item" href="#" onclick="switchDecimalPlaces()"><span
											class="fa fa-sliders-h px-0"></span> Dezimalstellen kW & kWh ändern</a>
									<a class="dropdown-item" href="#" onclick="switchSmartHomeColors()"><span
											class="fa fa-palette px-0"></span> Farbschema Smart-Home-Geräte ändern</a>
									<a class="dropdown-item" href="#" onclick="toggleSmartHomeSummary()"><span
											class="fa fa-palette px-0"></span> Smarthome-Zusammenfassung an/aus </a>
								</div>
							</div>

						</div>
					</div>
					<div class=" wb-subwidget">
						<figure id="powermeter" class="mb-0"></figure>
				</div>
			</div>
						</div>
			<!-- Graph - Live, Tag (powergraph) -->
			<div class="col-lg-4 m-0 p-1 main-window">
				<div class="rounded shadow wb-widget m-0 p-2">
					<div class="d-flex justify-content-between">
						<h3 class="mt-0" id="graphheading">Leistung / Ladestand</h3>
						<div class="col-4 p-0 m-0" style="text-align: right;">
							<button class="btn btn-outline-secondary btn-sm " id="graphChangeButton"><span
									class="fa fa-sort px-0"></span></button>
							<button class="btn btn-outline-secondary btn-sm " id="graphLeftButton"><span
									class="fa fa-chevron-circle-left px-0"></span></button>
							<button class="btn btn-outline-secondary btn-sm " id="graphRightButton"><span
									class="fa fa-chevron-circle-right px-0"></span></button>
						</div>
					</div>
					<div class="p-0 wb-subwidget">
						<figure id="powergraph" class="mb-0"></figure>
				</div>
			</div>
						</div>
			<!-- Energie heute (yieldmeter) -->
			<div class="col-lg-4 p-1 m-0 main-window">
				<div class="wb-widget p-2 m-0 rounded shadow">
					<div class="d-flex justify-content-between">
						<h3 id="energyheading" class="mt-0">Energie heute</h3>

						<div class="col-4 p-0 m-0" style="text-align: right;">
							<button class="btn btn-outline-secondary btn-sm " id="calendarButton"><span
									class="fa fa-calendar-alt px-0"></span></button>
							<button class="btn btn-outline-secondary btn-sm " id="energyLeftButton"><span
									class="fa fa-chevron-circle-left px-0"></span></button>
							<button class="btn btn-outline-secondary btn-sm " id="energyRightButton"><span
									class="fa fa-chevron-circle-right px-0"></span></button>
						</div>
					</div>
					<div class="p-0 wb-subwidget">
						<figure id="energymeter" class="mb-0"></figure>
				</div>
			</div>
		</div>
		</div> <!-- end obere row -->

		<!-- zweite reihe  -->
	 <div class="row py-0 px-0">
			<!-- Ladepunkte (chargePointList) -->
			<div class="rounded shadow wb-widget col-md p-2 m-1 ">
				<h3 class="mt-0"><span class="fas fa-charging-station" style="color: var(--color-charging)">&nbsp;</span>Ladepunkte
				<small><small id="LadereglerTxt"> notext </small></small></h3>
				<div class="pb-2 wb-subwidget">
					<div style="text-align:center;">
						<span id="lastregelungaktiv" class="regularTextSize text-red animate-alertPulsation"></span>
					</div>
					<div id="socSelector"></div>
					<div id="chargePointTable"></div>
				</div>
			</div>

			<!-- Speicher (batteryList) -->
			<div class="rounded shadow wb-widget col-md p-2 m-1" id="batteryWidget">
				<div class="container-fluid">
					<div class="row">
						<div class="col-10 px-0">
							<h3><span class="fas fa-car-battery" style="color: var(--color-battery)">&nbsp;</span>Speicher
							<small><small id="BatSupportTxt"> notext </small></small></h3>
						</div>
						<?php makebatmenu(); ?>
						<div class="wb-subwidget pb-2 " style="width:100%;">
							<div id="batteryStatus"></div>
						</div>
				
					</div>			
				</div>
			</div>

			<!-- Smart Home (smartHomeList) -->
			<div class="rounded shadow wb-widget col-md p-2 m-1" id="smartHomeWidget">
				<h3><span class="fas fa-plug" style="color: var(--color-devices)">&nbsp;</span>Geräte</h3>
				<div class="wb-subwidget pb-2 ">
					<div id="smartHomeTable"></div>
				</div>
			</div>
 
			<!-- Preisbasiertes Laden -->
 
			<div class="rounded shadow wb-widget col-md-4 p-2 m-1 priceConfiguration" id="priceConfigWidget">
				<h3 class="mt-0"><span class="fas fa-chart-line" style="color: var(--color-charging)">&nbsp;</span>Preis - Verlauf</h3>
				<div class="pb-2 wb-subwidget">
					<div class="row p-0 m-0 ">
						<div class="col-12 pricechartColumn p-0 m-0">
							<figure id="priceChart"></figure>
						</div>
					</div>
					<div class="container-fluid m-0 p-0 priceSelectWidget" >
			       	   <h3 class="mt-0"><span class="fas fa-chart-line" style="color: var(--color-charging)">&nbsp;</span>Preisbasiertes Laden</h3>


						<div class="row vaRow m-0 p-0">
							<div class="col-2 m-0 p-0">
								<button type="button" class="btn btn-secondary priceLess"><i class="fa fa-minus-square"></i></button>
							</div>
							<div class="col-8">
								<input type="range" class="form-control-range maxPriceInput" id="maxPrice" min="-15" max="55"
									step="0.1" value="0" data-initialized="0">
							</div>
							<div class="col-2 m-0 p-0 text-right">
								<button type="button" class="btn btn-secondary priceMore"><i class="fa fa-plus-square"></i></button>
							</div>
						</div>
						<div class="form-row vaRow p-0 m-0">
							<div class="col m-0 p-0 tablecell maxPrice">
								<label for="maxPrice" class=" col-form-label p-0 m-0 ">Max. Preis: </label>
								<label for="maxPrice" class=" labelMaxPrice col-form-label p-0 m-0" data-suffix="ct"></label>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- Ladepunkt Konfig -->
			<div class="rounded shadow wb-widget col-md p-2 m-1 hide" id="chargePointConfigWidget">
				<h3 class="mt-0"><span class="fas fa-cog" style="color: var(--color-charging)">&nbsp;</span>Einstellungen Ladepunkte</h3>
				<div class="pb-2 wb-subwidget">
					<!-- depending on charge mode show options -->
					<form id="minundpvladenEinstellungen" class="hide">
						<div class="row justify-content-center">
							<h3 class="font-weight-bold text-center text-lightgrey">Minimal Stromstärke</h3>
						</div>

						<div class="form-row form-group mb-1 vaRow regularTextSize" data-lp="1">
							<label for="minCurrentMinPv" class="col-3 col-form-label text-right"></label>
							<div class="col">
								<input type="range" class="form-control-range rangeInput" id="minCurrentMinPv" min="6" max="16" step="1"
									value="6" data-initialized="0" data-topicprefix="openWB/config/get/pv/">
							</div>
							<label for="minCurrentMinPv" class="col-3 col-form-label valueLabel" suffix="A"></label>
						</div>
					</form>

					<form id="sofortladenEinstellungen" class="hide">
							<div class="row justify-content-center">
								<h4 class="text-center">Sofortladen Stromstärke</h4>
							</div>

							<div class="form-row form-group mb-1 vaRow regularTextSize" data-lp="1">
								<label for="lp/1/current" class="col-3 col-form-label text-right">
									<span class="nameLp">LP1</span>:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/1/current" min="6" max="32" step="1"
										value="6" data-initialized="0" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/1/current" class="col-3 col-form-label valueLabel" suffix="A"></label>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-lp="2">
								<label for="lp/2/current" class="col-3 col-form-label text-right">
									<span class="nameLp">LP2</span>:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/2/current" min="6" max="32" step="1"
										value="6" data-initialized="0" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/2/current" class="col-3 col-form-label valueLabel" suffix="A"></label>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-lp="3">
								<label for="lp/3/current" class="col-3 col-form-label text-right">
									<span class="nameLp">LP3</span>:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/3/current" min="6" max="32" step="1"
										value="6" data-initialized="0" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/3/current" class="col-3 col-form-label valueLabel" suffix="A"></label>
							</div>
						</div>

						<div class="chargeLimitation" data-lp="1">
							<div class="row justify-content-center">
								<h4 class="text-center">Lademengenbegrenzung <span class="nameLp"></span></h4>
							</div>
							<div class="form-row vaRow form-group mt-1 justify-content-center" data-lp="1">
								<div class="col btn-group btn-group-toggle" id="lp/1/chargeLimitation" data-toggle="buttons"
									data-topicprefix="openWB/config/get/sofort/">
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/1/chargeLimitation" data-option="0"> keine
									</label>
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/1/chargeLimitation" data-option="1"> Energiemenge
									</label>
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/1/chargeLimitation" data-option="2"> EV-SoC
									</label>
								</div>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-option="1">
								<label for="lp/1/energyToCharge" class="col-3 col-form-label text-right">Energie:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/1/energyToCharge" min="2" max="100"
										step="2" value="2" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/1/energyToCharge" class="col-3 col-form-label valueLabel" suffix="kWh"></label>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-option="2">
								<label for="lp/1/socToChargeTo" class="col-3 col-form-label text-right">SoC:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/1/socToChargeTo" min="5" max="100"
										step="5" value="5" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/1/socToChargeTo" class="col-3 col-form-label valueLabel" suffix="%"></label>
							</div>
							<div class="form-row mt-2 justify-content-center regularTextSize" data-option="1">
								<div class="col col-sm-6">
									<span class="progress-label">Fortschritt: </span>
									<span class="restzeitLp pull-right"></span>
									<div class="progress active limitation-progress">
										<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
											data-actualCharged="0">
										</div>
									</div>
								</div>
								<input class="btn btn-sm btn-primary regularTextSize ml-2" type="button" id="lp/1/resetEnergyToCharge"
									value="Reset" data-topicprefix="openWB/config/get/sofort/">
							</div>
						</div>

						<div class="chargeLimitation" data-lp="2">
							<div class="row justify-content-center">
								<h4 class="text-center">Lademengenbegrenzung <span class="nameLp"></span></h4>
							</div>
							<div class="form-row vaRow form-group mt-1 justify-content-center" data-lp="2">
								<div class="col btn-group btn-group-toggle" id="lp/2/chargeLimitation" data-toggle="buttons"
									data-topicprefix="openWB/config/get/sofort/">
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/2/chargeLimitation" data-option="0"> keine
									</label>
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/2/chargeLimitation" data-option="1"> Energiemenge
									</label>
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/2/chargeLimitation" data-option="2"> EV-SoC
									</label>
								</div>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-option="1">
								<label for="lp/2/energyToCharge" class="col-3 col-form-label text-right">Energie:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/2/energyToCharge" min="2" max="100"
										step="2" value="2" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/2/energyToCharge" class="col-3 col-form-label valueLabel" suffix="kWh"></label>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-option="2">
								<label for="lp/2/socToChargeTo" class="col-3 col-form-label text-right">SoC:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/2/socToChargeTo" min="5" max="100"
										step="5" value="5" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/2/socToChargeTo" class="col-3 col-form-label valueLabel" suffix="%"></label>
							</div>
							<div class="form-row mt-2 justify-content-center regularTextSize" data-option="1">
								<div class="col col-sm-6">
									<span class="progress-label">Fortschritt: </span>
									<span class="restzeitLp pull-right"></span>
									<div class="progress active limitation-progress">
										<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
											data-actualCharged="0">
										</div>
									</div>
								</div>
								<input class="btn btn-sm btn-primary regularTextSize ml-2" type="button" id="lp/2/resetEnergyToCharge"
									value="Reset" data-topicprefix="openWB/config/get/sofort/">
							</div>
						</div>

						<div class="chargeLimitation" data-lp="3">
							<div class="row justify-content-center">
								<h4 class="text-center">Lademengenbegrenzung <span class="nameLp"></span></h4>
							</div>
							<div class="form-row vaRow form-group mt-1 justify-content-center" data-lp="3">
								<div class="col btn-group btn-group-toggle" id="lp/3/chargeLimitation" data-toggle="buttons"
									data-topicprefix="openWB/config/get/sofort/">
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/3/chargeLimitation" data-option="0"> keine
									</label>
									<label class="btn btn-sm btn-outline-info btn-toggle regularTextSize">
										<input type="radio" name="lp/3/chargeLimitation" data-option="1"> Energiemenge
									</label>
								</div>
							</div>
							<div class="form-row form-group mb-1 vaRow regularTextSize" data-option="1">
								<label for="lp/3/energyToCharge" class="col-3 col-form-label text-right">Energie:</label>
								<div class="col">
									<input type="range" class="form-control-range rangeInput" id="lp/3/energyToCharge" min="2" max="100"
										step="2" value="2" data-topicprefix="openWB/config/get/sofort/">
								</div>
								<label for="lp/3/energyToCharge" class="col-3 col-form-label valueLabel" suffix="kWh"></label>
							</div>
							<div class="form-row mt-2 justify-content-center regularTextSize" data-option="1">
								<div class="col col-sm-6">
									<span class="progress-label">Fortschritt: </span>
									<span class="restzeitLp pull-right"></span>
									<div class="progress active limitation-progress">
										<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
											data-actualCharged="0">
										</div>
									</div>
								</div>
								<input class="btn btn-sm btn-primary regularTextSize ml-2" type="button" id="lp/3/resetEnergyToCharge"
									value="Reset" data-topicprefix="openWB/config/get/sofort/">
							</div>
						</div>
					</form>
				</div> 	<!-- Ladepunkt Konfig -->
		</div> 	<!-- zweite reihe  -->

	</div> <!-- main page  -->

	<!-- ENDE COLOR THEME -->


		<!-- modal chargemode-select-window -->
		<div class="modal fade" id="chargeModeModal">
			<div class="modal-dialog">
				<div class="modal-content">

					<!-- modal header -->
					<div class="modal-header bg-success">
						<h4 class="modal-title">Lademodus-Auswahl</h4>
					</div>

					<!-- modal body -->
					<div class="modal-body">
						<div class="row justify-content-center">
							<div class="col-sm-5 py-1">
								<button id="chargeModeSofortBtn" type="button" class="chargeModeBtn btn btn-lg btn-block btn-secondary"
									data-dismiss="modal" chargeMode="0">Sofort</button>
							</div>
						</div>
						<div class="row justify-content-center">
							<div class="col-sm-5 order-first order-sm-last py-1">
								<button id="chargeModePVBtn" type="button" class="chargeModeBtn btn btn-lg btn-block btn-secondary"
									data-dismiss="modal" chargeMode="2">PV</button>
							</div>
						</div>
						<div class="row justify-content-center">
							<div class="col-sm-5 py-1">
								<button id="chargeModeMinPVBtn" type="button" class="chargeModeBtn btn btn-lg btn-block btn-secondary"
									data-dismiss="modal" chargeMode="1">Min + PV</button>
							</div>
						</div>
						<div class="row justify-content-center">
							<div class="col-sm-5 py-1">
								<button id="chargeModeStdbyBtn" type="button" class="chargeModeBtn btn btn-lg btn-block btn-secondary"
									data-dismiss="modal" chargeMode="4">Standby</button>
							</div>
						</div>
						<div class="row justify-content-center">
							<div class="col-sm-5 py-1">
								<button id="chargeModeStopBtn" type="button" class="chargeModeBtn btn btn-lg btn-block btn-secondary"
									data-dismiss="modal" chargeMode="3">Stop</button>
							</div>
						</div>
						<span id='priorityModeBtns'>
							<hr>
							<div class="row">
								<div class="col text-center text-grey">
									Vorrang im Lademodus PV-Laden:
								</div>
							</div>
							<div class="row justify-content-center">
								<div class="col-sm-5 py-1">
									<button id="evPriorityBtn" type="button" class="priorityModeBtn btn btn-lg btn-block btn-secondary"
										data-dismiss="modal" priority="1">
										EV <span class="fas fa-car">&nbsp;</span>
									</button>
								</div>
							</div>
							<div class="row justify-content-center">
								<div class="col-sm-5 py-1">
									<button id="batteryPriorityBtn" type="button"
										class="priorityModeBtn btn btn-lg btn-block btn-secondary" data-dismiss="modal" priority="0">
										Speicher <span class="fas fa-car-battery">&nbsp;</span>
									</button>
								</div>
							</div>
						</span>
						<span id='70ModeBtn'>
							<hr>

							<div class="row">
								<div class="col text-center text-grey">
									70% beachten im Lademodus PV-Laden:
								</div>
							</div>
							<div class="row justify-content-center">
								<div class="col-sm-5 py-1">
									<button id="70PvBtn" type="button" class=" 70PvBtn btn btn-lg btn-block btn-secondary"
										data-dismiss="modal">
										70 % beachten
									</button>
								</div>
							</div>
						</span>
						<!-- RFID Code entry -->
						<span id="codeEntry" class="hide">
							<hr>
							<div class="row">
								<div class="col justify-content-center text-grey">
									<input type="text" class="form-control" id="codeInput" placeholder="RFID-Code (1-3 Ziffern)">
								</div>
							</div>
							<div class="row  mt-2">
								<div class="col justify-content-end" style="text-align: end;">
									<button type="button" class="btn btn-success" id="codeEnterButton">Eingabe</button>
								</div>
							</div>
						</span>
					</div>
				</div> <!-- /modal body -->

				<!-- no modal footer -->
			</div>
		</div>
	</div>


	<!-- some scripts -->
	<script>

		// load navbar, be careful: it loads asynchronous
		$.get(
			{ url: "themes/navbar.html", cache: false },
			function (data) {
				$("#nav-placeholder").replaceWith(data);
			}
		);
 if ( debugold>0)	//
   {
    console.log("Bind altclicker ");
    $('#altclicker').bind('click', function(event){
    console.log('date clicked')
     if(  event.ctrlKey   &&  event.shiftKey)
     {
        console.log('shift-Ctrl pressed set debugmode=3' )
		event.preventDefault();
		debugmode=3
		setCookie('debugmode', 3, 30);		// Mode 3 für 30 Tage
		alert( "Set Debug mode to 3");
        this.click(event);
     }
     else if(event.ctrlKey || event.shiftKey)
     {
       console.log('shift or cntrl pressd set debugmode=2' )
	    debugmode=2
	    setCookie('debugmode', 2, 30);		// Mode 4 für 30 Tage
	    alert( "Set Debug mode to 2");
	  this.click(event);
     }	  
     else if(event.altKey)
     {
      console.log('alt pressd set debugmode=4' )
	    debugmode=4
	    setCookie('debugmode', 4, 30);		// Mode 4 für 30 Tage
	    alert( "Set Debug mode to 4");
	  this.click(event);
     }	  
    });
  }
 


		var timeOfLastMqttMessage = 0;  // holds timestamp of last received message
		var landingpageShown = false;  // holds flag for landing page being shown

		function chargeLimitationOptionsShowHide(btnGrp, option) {
			// show/hide all option-parameters in form-rows for selected option
			var parent = btnGrp.closest('.chargeLimitation[data-lp]');  // get parent div element for charge limitation options
			$(parent).find('.form-row[data-option*=' + option + ']').show();  // now show option elements for selected option
			$(parent).find('.form-row[data-option]').not('[data-option*=' + option + ']').hide();  // hide all other option elements
		}

		function processPreloader(mqttTopic) {
			// sets flag for topic received in topic-array
			// and updates the preloader progress bar
			if (!landingpageShown) {
				var countTopicsReceived = 0;
				for (var index = 0; index < topicsToSubscribe.length; index++) {
					if (topicsToSubscribe[index][0] == mqttTopic && topicsToSubscribe[index][1] == 0) {
						// topic found in array
						topicsToSubscribe[index][1] = 1;  // mark topic as received
					};
					if (topicsToSubscribe[index][1] > 0) {
						countTopicsReceived++;
					}
				};
				
	var d = new Date();
	let h = (d.getHours());
	let m = (d.getMinutes());
	let s = (d.getSeconds());
	let ms =(d.getMilliseconds());
	let time = h + ":" + m + ":" + s + ":" + ms;	

				
				// countTopicsToBeReceived holds all topics flagged 1 and not only those for preloader
				countTopicsReceived = countTopicsReceived - countTopicsNotForPreloader;
				var countTopicsToBeReceived = topicsToSubscribe.length - countTopicsNotForPreloader;
				var percentageReceived = (countTopicsReceived / countTopicsToBeReceived * 100).toFixed(0);
				console.log( time + ' Preloader:'+ mqttTopic + ' '+countTopicsReceived + ' '+percentageReceived);

				var timeBetweenTwoMessages = Date.now() - timeOfLastMqttMessage;
				if (timeBetweenTwoMessages > 3000) {
					// latest after 3 sec without new messages
					percentageReceived = 100;
					// debug output
					topicsToSubscribe.forEach((item, i) => {
						if (item[1] == 0) {
							console.log('not received: ' + item[0]);
						}
					});

				}
				timeOfLastMqttMessage = Date.now();
				$("#preloaderbar").width(percentageReceived + "%");
				$("#preloaderbar").text(percentageReceived + " %");
				if (percentageReceived == 100) {
					landingpageShown = true;
					setTimeout(function () {
						// delay a little bit
						$("#preloader").fadeOut(600);
					}, 500);
				}
			}
		}

		var delayUserInput = (function () {
			// sets a timeout on call and resets timeout if called again for same id before timeout fires
			var timeoutHandles = {};
			return function (id, callback, ms) {
				if (timeoutHandles[id]) {
					clearTimeout(timeoutHandles[id]);
				};
				timeoutHandles[id] = setTimeout(function () {
					delete timeoutHandles[id];
					callback(id);
				}, ms);
			};
		})();

		$(document).ready(function () {
			console.log('------------ $(document).ready ------------------' )
			// load scripts synchronously in order specified
			var scriptsToLoad = [
				// NC 'js/Chart.bundle.js',		// load Chart.js library
				'js/mqttws31.js',			// load mqtt library
				'<?php echo xgeturl('helperFunctions.js');?>',		// some helper functions			
				'<?php echo xgeturl('processAllMqttMsg.js');?>',		// functions for processing messages			
				'<?php echo xgeturl('setupMqttServices.js');?>'		// functions performing mqtt and start mqtt-service
			];
			scriptsToLoad.forEach(function (src) {
				var script = document.createElement('script');
				script.src = src;
				script.async = false;
				document.body.appendChild(script);
			});


			console.log('------------ $(document).ready  all scripts sheduled (but not loaded) -----' )
			wbdata.init();
			powerGraph.init();
			powerMeter.init();
			yieldMeter.init();
			chargePointList.init();
			smartHomeList.init();
			batteryList.init();
			priceChart.init();
			$("#homebutton").addClass("hide");

			$('.enableLp').click(function (event) {
				// send mqtt set to enable/disable charge point after click
				var lp = parseInt($(this).closest('[data-lp]').data('lp'));  // get attribute lp-# of parent element
				if (!isNaN(parseInt(lp)) && lp >= 1 && lp <= 3) {
					var isEnabled = $(this).hasClass("lpEnabledStyle")
					if (isEnabled) {
						publish("0", "openWB/set/lp/" + lp + "/ChargePointEnabled");
					} else {
						publish("1", "openWB/set/lp/" + lp + "/ChargePointEnabled");
					}
				}
			});

			$('.socConfiguredLp').click(function (event) {
				// send mqtt set to force reload of charge point SoC after click
				var lp = parseInt($(this).closest('[data-lp]').data('lp'));  // get attribute lp-# of parent element
				if (!isNaN(parseInt(lp)) && lp >=1 && lp <=3) {
					var spinner = $(this).find('.reloadLpSoc');
					var isRunning = spinner.hasClass("fa-spin");
					if (!isRunning) {
						spinner.addClass("fa-spin");
						publish("1", "openWB/set/lp/" + lp + "/ForceSoCUpdate");
					}
				}
			});

			$('.enableDevice').click(function (event) {
				// send mqtt set to enable/disable Device after click
				var dev = parseInt($(this).closest('[data-dev]').data('dev'));  // get attribute device-# of parent element
				var isLocked = $(this).hasClass("locked");
				if (isLocked) {
					if (!isNaN(parseInt(dev)) && dev > 0 && dev < 10) {
						var isEnabled = $(this).hasClass("lpEnabledStyle")
						if (isEnabled) {
							publish("0", "openWB/config/set/SmartHome/Devices/" + dev + "/device_manual_control");
							$(this).removeClass('lpEnabledStyle').removeClass('lpDisabledStyle').addClass('lpWaitingStyle');
						} else {
							publish("1", "openWB/config/set/SmartHome/Devices/" + dev + "/device_manual_control");
							$(this).removeClass('lpEnabledStyle').removeClass('lpDisabledStyle').addClass('lpWaitingStyle');
						}
					}
				}
			});

			$('.changeSHMode').click(function (event) {
				// send mqtt set to enable/disable Device after click
				var dev = parseInt($(this).closest('[data-dev]').data('dev'));  // get attribute device-# of parent element
				if ($(this).text() == "Auto") {
					publish("1", "openWB/config/set/SmartHome/Devices/" + dev + "/mode");
				} else {
					publish("0", "openWB/config/set/SmartHome/Devices/" + dev + "/mode");
				}
			});

			<?php makerctclicker(); ?>

			$('#chargeModeSelectBtn').click(function (event) {
				$("#chargeModeModal").modal("show");
			});


			$('.chargeModeBtn').click(function (event) {
				var chargeMode = $(this).attr("chargeMode")
				publish(chargeMode, "openWB/set/ChargeMode");
			});

			$('.priorityModeBtn').click(function (event) {
				// prio: 0 = battery, 1 = ev
				var priority = $(this).attr('priority');
				if (priority == '0' || priority == '1') {
					publish(priority, 'openWB/config/set/pv/priorityModeEVBattery');
				}
			});

			$('.70PvBtn').click(function (event) {
				// 0 deaktiviert, 1 aktiviert
				var element = document.getElementById('70PvBtn');
				if (element.classList.contains("btn-success")) {
					publish("0", "openWB/set/pv/NurPV70Status");
				} else {
					publish("1", "openWB/set/pv/NurPV70Status");
				}
			});

			$('.btn[value="Reset"]').click(function (event) {
				var topic = getTopicToSendTo($(this).attr('id'));
				publish("1", topic);
			});

			function sendCode() {
				let value = document.getElementById('codeInput').value
				if (value.length > 0) {
					publish(value, 'openWB/set/system/SimulateRFID')
					$('#chargeModeModal').modal('hide')
				}
			}
			$('#codeEnterButton').click(function () {
				sendCode()
			})

			$('#codeInput').change(function () {
				sendCode()
			})


			$('.sofortladenLadezielSelektor').change(function (event) {
				// switches the visibility of the settings-divs according to dropdown selection
				var selectorId = '#' + event.target.id;
				var divAusId = selectorId.slice(0, 8) + 'n' + selectorId.slice(8);
				var divSocId = selectorId.slice(0, 8) + 's' + selectorId.slice(8);
				var divMengeId = selectorId.slice(0, 8) + 'm' + selectorId.slice(8);
				switch ($(selectorId).val()) {
					case '0':
						$(divAusId).show();
						$(divSocId).hide();
						$(divMengeId).hide();
						break;
					case '1':
						$(divAusId).hide();
						$(divSocId).hide();
						$(divMengeId).show();
						break;
					case '2':
						$(divAusId).hide();
						$(divSocId).show();
						$(divMengeId).hide();
						break;
				}
			});

			$('.btn-group-toggle').change(function (event) {
				// only charge limitation has class btn-group-toggle so far
				// option: 0 = keine, 1 = Energiemenge, 2 = EV-SoC
				var elementId = $(this).attr('id');
				var option = $('input[name="' + elementId + '"]:checked').data('option').toString();
				var topic = getTopicToSendTo(elementId);
				publish(option, topic);
				// show/hide respective option-values and progress
				chargeLimitationOptionsShowHide(this, option);
			});

			$('.rangeInput').on('input', function () {
				// show slider value in label of class valueLabel
				var elementId = $(this).attr('id');
				updateLabel(elementId);
				var element = $('#' + $.escapeSelector(elementId));
				var label = $('label[for="' + elementId + '"].valueLabel');
				label.addClass('text-danger');

				delayUserInput(elementId, function (id) {
					// gets executed on callback, 2000ms after last input-change
					// changes label color back to normal and sends input-value by mqtt
					var elem = $('#' + $.escapeSelector(id));
					var value = elem.val();
					var topic = getTopicToSendTo(id);
					publish(value, topic);
					var label = $('label[for="' + id + '"].valueLabel');
					label.removeClass('text-danger');
					// if rangeInput is for chargeLimitation, recalculate progress
					if (id.includes('/energyToCharge')) {
						var parent = elem.closest('.chargeLimitation')  // get parent div element for charge limitation
						var element = parent.find('.progress-bar');  // now get parents progressbar
						var actualCharged = element.data('actualCharged');  // get stored value
						if (isNaN(parseFloat(actualCharged))) {
							actualCharged = 0;  // minimum value
						}
						var progress = (actualCharged / value * 100).toFixed(0);
						element.width(progress + "%");
					}
				}, 2000);
			});

			// register an event listener for changes in visibility
			let hidden;
			let visibilityChange;
			if (typeof document.hidden !== 'undefined') { // Opera 12.10 and Firefox 18 and later support
				hidden = 'hidden';
				visibilityChange = 'visibilitychange';
			} else if (typeof document.msHidden !== 'undefined') {
				hidden = 'msHidden';
				visibilityChange = 'msvisibilitychange';
			} else if (typeof document.webkitHidden !== 'undefined') {
				hidden = 'webkitHidden';
				visibilityChange = 'webkitvisibilitychange';
			}
			window.document.addEventListener(visibilityChange, () => {
				if (!document[hidden]) {
					// once page is unhidden... reload graph completely
					if (wbdata.graphMode == 'live') {
						powerGraph.deactivateDay();
						powerGraph.activateLive();
					} else {
						powerGraph.deactivateLive();
						powerGraph.activateDay();
					}
					// powerGraph.reset();
					// subscribeMqttGraphSegments();
				}
			});
			console.log('------------ $(document).ready --end ----------------' )
		});  // end document ready
	</script>

<?php
	 if($debug>2)
	 {
		$lines="striped";
		$owbconf="striped";
   		makedebugreihe();
	 }
?>

	<br>
	<div id="footer">
		<footer class="bg-dark fixed-bottom small text-light">
			<div class="container text-center">
				openWB_lite <span id='spanversion' class='spanversion'></span>, die modulare Wallbox
			</div>
		</footer>
	</div>

</body>

</html>
