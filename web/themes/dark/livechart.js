var style = getComputedStyle(document.body);
var fontCol = style.getPropertyValue('--fontCol');
var gridCol = style.getPropertyValue('--gridCol');
var xgridCol = style.getPropertyValue('--xgridCol');
var gridSocCol = style.getPropertyValue('--gridSocCol');
var tickCol = style.getPropertyValue('--tickCol');
var lp1Col = style.getPropertyValue('--lp1Col');
var lp1bgCol = style.getPropertyValue('--lp1bgCol');
var lp2Col = style.getPropertyValue('--lp2Col');
var lp2bgCol = style.getPropertyValue('--lp2bgCol');
var evuCol = style.getPropertyValue('--evuCol');
var evubgCol = style.getPropertyValue('--evubgCol');
var pvCol = style.getPropertyValue('--pvCol');
var pvbgCol = style.getPropertyValue('--pvbgCol');
var speicherCol = style.getPropertyValue('--speicherCol');
var speicherSocCol = style.getPropertyValue('--speicherSocCol');
var speicherbgCol = style.getPropertyValue('--speicherbgCol');
var speicherSocbgCol = style.getPropertyValue('--speicherSocbgCol');
var lp1SocCol = style.getPropertyValue('--lp1SocCol');
var lp2SocCol = style.getPropertyValue('--lp2SocCol');
var hausverbrauchCol = style.getPropertyValue('--hausverbrauchCol');
var hausverbrauchbgCol = style.getPropertyValue('--hausverbrauchbgCol');
var lpgesamtCol = style.getPropertyValue('--lpgesamtCol');
var lpgesamtbgCol = style.getPropertyValue('--lpgesamtbgCol');
var lp3Col = style.getPropertyValue('--lp3Col');
var lp3bgCol = style.getPropertyValue('--lp3bgCol');
// var lp4Col = style.getPropertyValue('--lp4Col');
// var lp4bgCol = style.getPropertyValue('--lp4bgCol');
// var lp5Col = style.getPropertyValue('--lp5Col');
// var lp5bgCol = style.getPropertyValue('--lp5bgCol');
// var lp6Col = style.getPropertyValue('--lp6Col');
// var lp6bgCol = style.getPropertyValue('--lp6bgCol');
// var lp7Col = style.getPropertyValue('--lp7Col');
// var lp7bgCol = style.getPropertyValue('--lp7bgCol');
// var lp8Col = style.getPropertyValue('--lp8Col');
// var lp8bgCol = style.getPropertyValue('--lp8bgCol');
var verbraucher1Col = style.getPropertyValue('--verbraucher1Col');
var verbraucher1bgCol = style.getPropertyValue('--verbraucher1bgCol');
var verbraucher2Col = style.getPropertyValue('--verbraucher2Col');
var verbraucher2bgCol = style.getPropertyValue('--verbraucher2bgCol');
var d1Col = style.getPropertyValue('--d1Col');
var d1bgCol = style.getPropertyValue('--d1bgCol');
var d2Col = style.getPropertyValue('--d2Col');
var d2bgCol = style.getPropertyValue('--d2bgCol');
var d3Col = style.getPropertyValue('--d3Col');
var d3bgCol = style.getPropertyValue('--d3bgCol');
var d4Col = style.getPropertyValue('--d4Col');
var d4bgCol = style.getPropertyValue('--d4bgCol');
var d5Col = style.getPropertyValue('--d5Col');
var d5bgCol = style.getPropertyValue('--d5bgCol');
var d6Col = style.getPropertyValue('--d6Col');
var d6bgCol = style.getPropertyValue('--d6bgCol');
var d7Col = style.getPropertyValue('--d7Col');
var d7bgCol = style.getPropertyValue('--d7bgCol');
var d8Col = style.getPropertyValue('--d8Col');
var d8bgCol = style.getPropertyValue('--d8bgCol');
var d9Col = style.getPropertyValue('--d9Col');
var d9bgCol = style.getPropertyValue('--d9bgCol');

var initialread = 0;
var graphloaded = 0;
var boolDisplayHouseConsumption;
var boolDisplayLoad1;
var boolDisplayLp1Soc;
var boolDisplayLoad2;
var boolDisplayLp2Soc;
var boolDisplayShD1;
var boolDisplayShD2;
var boolDisplayShD3;
var boolDisplayShD4;
var boolDisplayShD5;
var boolDisplayShD6;
var boolDisplayShD7;
var boolDisplayShD8;
var boolDisplayShD9;
var boolDisplayLp1;
var boolDisplayLp2;
var boolDisplayLp3;
var boolDisplayLpAll;
var boolDisplaySpeicherSoc;
var boolDisplaySpeicher;
var boolDisplayEvu;
var boolDisplayPv;
var boolDisplayLegend;
var boolDisplayLiveGraph;
var d1name = 'Device 1';
var d2name = 'Device 2';
var d3name = 'Device 3';
var d4name = 'Device 4';
var d5name = 'Device 5';
var d6name = 'Device 6';
var d7name = 'Device 7';
var d8name = 'Device 8';
var d9name = 'Device 9';
var all1 = 0;
var all2 = 0;
var all3 = 0;
var all4 = 0;
var all5 = 0;
var all6 = 0;
var all7 = 0;
var all8 = 0;
var all9 = 0;
var all10 = 0;
var all11 = 0;
var all12 = 0;
var all13 = 0;
var all14 = 0;
var all15 = 0;
var all16 = 0;
var all1p;
var all2p;
var all3p;
var all4p;
var all5p;
var all6p;
var all7p;
var all8p;
var all9p;
var all10p;
var all11p;
var all12p;
var all13p;
var all14p;
var all15p;
var all16p;

var hidehaus;
var myLine;

function loadgraph(animationDuration = 1000) {
    console.log('loadgraph')
	var lineChartData = {
		labels: atime,
		datasets: [{
			label: 'Lp1',
			borderColor: lp1Col,
			backgroundColor: lp1bgCol,
			borderWidth: 2,
			hidden: boolDisplayLp1,
			fill: false,
			lineTension: 0.2,
			data: alp1,
			yAxisID: 'y-axis-1'
		} , {
			label: 'Lp2',
			borderColor: lp2Col,
			backgroundColor: lp2bgCol,
			borderWidth: 2,
			hidden: boolDisplayLp2,
			fill: false,
			lineTension: 0.2,
			data: alp2,
			yAxisID: 'y-axis-1'
		} , {
			label: 'EVU',
			borderColor: evuCol,
			backgroundColor: evubgCol,
			borderWidth: 1,
			fill: true,
			lineTension: 0.2,
			data: abezug,
			hidden: boolDisplayEvu,
			yAxisID: 'y-axis-1'
		} , {
			label: 'PV',
			borderColor: pvCol,
			backgroundColor: pvbgCol,
			fill: true,
			lineTension: 0.2,
			hidden: boolDisplayPv,
			borderWidth: 1,
			data: apv,
			yAxisID: 'y-axis-1'
		}  , {
			label: 'Speicher',
			borderColor: speicherCol,
			backgroundColor: speicherbgCol,
			fill: true,
			lineTension: 0.2,
			borderWidth: 1,
			data: aspeicherl,
			hidden: boolDisplaySpeicher,
			yAxisID: 'y-axis-1'
		} , {
			label: 'Speicher SoC',
			borderColor: speicherSocCol,
			backgroundColor: speicherSocbgCol,
			borderDash: [10,5],
			hidden: boolDisplaySpeicherSoc,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: aspeichersoc,
			yAxisID: 'y-axis-2'
		} , {
			label: 'LP1 SoC',
			borderColor: lp1SocCol,
			borderDash: [10,5],
			borderWidth: 2,
			hidden: boolDisplayLp1Soc,
			fill: false,
			lineTension: 0.2,
			data: asoc,
			yAxisID: 'y-axis-2'
		} , {
			label: 'LP2 SoC',
			borderColor: lp2SocCol,
			borderDash: [10,5],
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			hidden: boolDisplayLp2Soc,
			data: asoc1,
			yAxisID: 'y-axis-2'
		} , {
			label: 'Hausverbrauch',
			borderColor: hausverbrauchCol,
			backgroundColor: hausverbrauchbgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			hidden: boolDisplayHouseConsumption,
			data: ahausverbrauch,
			yAxisID: 'y-axis-1'
		} , {
			label: 'Verbraucher 1',
			borderColor: verbraucher1Col,
			backgroundColor: verbraucher1bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			hidden: boolDisplayLoad1,
			data: averbraucher1,
			yAxisID: 'y-axis-1'
		} , {
			label: 'Verbraucher 2',
			borderColor: verbraucher2Col,
			backgroundColor: verbraucher2bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: averbraucher2,
			hidden: boolDisplayLoad2,
			yAxisID: 'y-axis-1'
		} , {
			label: 'LP Gesamt',
			borderColor: lpgesamtCol,
			backgroundColor: lpgesamtbgCol,
			fill: true,
			lineTension: 0.2,
			borderWidth: 2,
			data: alpa,
			hidden: boolDisplayLpAll,
			yAxisID: 'y-axis-1'
		} , {
			label: 'Lp3',
			borderColor: lp3Col,
			backgroundColor: lp3bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: alp3,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayLp3
		}, {
			label: d1name,
			borderColor: d1Col,
			backgroundColor: d1bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd1,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD1
		}, {
			label: d2name,
			borderColor: d2Col,
			backgroundColor: d2bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd2,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD2
		}, {
			label: d3name,
			borderColor: d3Col,
			backgroundColor: d3bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd3,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD3
		}, {
			label: d4name,
			borderColor: d4Col,
			backgroundColor: d4bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd4,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD4
		}, {
			label: d5name,
			borderColor: d5Col,
			backgroundColor: d5bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd5,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD5
		}, {
			label: d6name,
			borderColor: d6Col,
			backgroundColor: d6bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd6,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD6
		}, {
			label: d7name,
			borderColor: d7Col,
			backgroundColor: d7bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd7,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD7
		}, {
			label: d8name,
			borderColor: d8Col,
			backgroundColor: d8bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd8,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD8
		}, {
			label: d9name,
			borderColor: d9Col,
			backgroundColor: d9bgCol,
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd9,
			yAxisID: 'y-axis-1',
			hidden: boolDisplayShD9
		}/*, {
			label: 'Device 1t0',
			borderColor: "rgba(250, 250, 155, 0.7)",
			backgroundColor: 'blue',
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd1t0,
			yAxisID: 'y-axis-2',
			hidden: boolDisplayLp8
		}, {
			label: 'Device 1t1',
			borderColor: "rgba(150, 250, 255, 0.7)",
			backgroundColor: 'blue',
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd1t1,
			yAxisID: 'y-axis-2',
			hidden: boolDisplayLp8
		}, {
			label: 'Device 1t2',
			borderColor: "rgba(255, 150, 255, 0.7)",
			backgroundColor: 'blue',
			fill: false,
			lineTension: 0.2,
			borderWidth: 2,
			data: ashd1t2,
			yAxisID: 'y-axis-2',
			hidden: boolDisplayLp8
		}*/
		]
	}

	function getMaxTicksLimit(width) {
		if ( width < 350 ) {
			return 6;
		} else if ( width < 470 ) {
			return 9;
		} else if ( width < 768 ) {
			return 12;
		} else {
			return 18;
		}
	}

	function setGraphLineBorderWidth(theGraph, newWidth) {
		// sets borderWidth attribute for all single lines without fill
		for ( var index = 0; index < theGraph.config.data.datasets.length; index++) {
			if ( !theGraph.config.data.datasets[index].fill ) {
				theGraph.config.data.datasets[index].borderWidth = newWidth;
			}
		}
	}

	function doGraphResponsive(chartInstance) {
		// changes graph responding to screen size
		// quantity of x-axis labels
		chartInstance.config.options.scales.xAxes[0].ticks.maxTicksLimit = getMaxTicksLimit(chartInstance.width);
		// other settings
		if ( chartInstance.width > 390 ) {
			setGraphLineBorderWidth(chartInstance, 2);
			chartInstance.config.options.scales.xAxes[0].ticks.fontSize = 12;
			chartInstance.config.options.scales.yAxes[0].ticks.fontSize = 12;
			chartInstance.config.options.scales.yAxes[0].scaleLabel.fontSize = 12;
			chartInstance.config.options.scales.yAxes[1].ticks.fontSize = 12;
			chartInstance.config.options.scales.yAxes[1].scaleLabel.fontSize = 12;
		} else {
			setGraphLineBorderWidth(chartInstance, 1);
			chartInstance.config.options.scales.xAxes[0].ticks.fontSize = 10;
			chartInstance.config.options.scales.yAxes[0].ticks.fontSize = 9;
			chartInstance.config.options.scales.yAxes[0].scaleLabel.fontSize = 10;
			chartInstance.config.options.scales.yAxes[1].ticks.fontSize = 9;
			chartInstance.config.options.scales.yAxes[1].scaleLabel.fontSize = 10;
		}

		chartInstance.update();
	}

	var ctx = document.getElementById('canvas').getContext('2d');

	window.myLine = new Chart.Line(ctx, {
		plugins: {
			afterInit: doGraphResponsive,
			resize: doGraphResponsive
		},
		data: lineChartData,
		options: {
			tooltips: {
				enabled: false
			},
			elements: {
				point: {
					radius: 0
				}
			},
			animation: {
				duration: animationDuration,
				onComplete: function(animation) {
					// if duration was set to 0 to avoid pumping after reload, set back to default
					this.options.animation.duration = 1000
				}
			},
			responsive: true,
			maintainAspectRatio: false,
			hover: {
				mode: 'null'
			},
			stacked: false,
			legend: {
				display: boolDisplayLegend,
				labels: {
					fontColor: fontCol,
					filter: function(item,chart) {
						if ( item.text.includes(hidehaus)   || item.text.includes(hideload2)  || item.text.includes(hideload1) 
						  || item.text.includes(hidelp2soc) || item.text.includes(hidelp1soc) || item.text.includes(hidelp1) 
						  || item.text.includes(hidelp2)    || item.text.includes(hidelp3)    
						  || item.text.includes(hidespeichersoc) || item.text.includes(hidespeicher) 
						  || item.text.includes(hidelpa) || item.text.includes(hidepv) || item.text.includes(hideevu) 
						  || item.text.includes(hideshd1)|| item.text.includes(hideshd2)|| item.text.includes(hideshd3)
						  || item.text.includes(hideshd4)|| item.text.includes(hideshd5)|| item.text.includes(hideshd6) 
						  || item.text.includes(hideshd7) || item.text.includes(hideshd8)|| item.text.includes(hideshd9) 
						  ) 
						     { return false } 
						else { return true}
					}
				}
			},
			title: {
				display: false
			},
			scales: {
				xAxes: [
					{
						gridLines: {
							color: xgridCol
						},
					ticks: {
							fontColor: tickCol,
							maxTicksLimit: 15
					}
				}],
				yAxes: [
					{
						// horizontal line for values displayed on the left side (power)
						position: 'left',
						id: 'y-axis-1',
						type: 'linear',
						display: true,
						scaleLabel: {
						display: true,
						labelString: 'Leistung [kW]',
						fontColor: fontCol
					},
						gridLines: {
							color: gridCol
						},
						ticks: {
							stepSize: 0.2,
							maxTicksLimit: 10,
							fontColor: tickCol
						}
					},{
						// horizontal line for values displayed on the right side (SoC)
						position: 'right',
						id: 'y-axis-2',
						type: 'linear',
						display: true,
						scaleLabel: {
							display: true,
							labelString: 'SoC [%]',
							fontColor: fontCol
						},
						gridLines: {
							// black, opacity = 0% (invisible)
							color: gridSocCol,
						},
						ticks: {
							min: 0,
							suggestedMax: 100,
							fontColor: tickCol
						}
					}
				]
			}
		}
	});
	initialread = 1;
	console.log('Set initialread = 1 ')
	$('#waitforgraphloadingdiv').hide();
}	// end loadgraph



// Sichtbarkeit für SmartHome Devices im Graph
function setvisibility(datarr,hidevar,hidevalue,booldisplay){
	var arrayLength = datarr.length;
	var vis=0
	for (var i = 0; i < arrayLength; i++) {
		if (( datarr[i] >= 0.002) || (datarr[i] <=- 0.002)) {
			vis=1
		}
	}
	console.log('setvisibility', hidevar, hidevalue, booldisplay, vis);
	if ( vis == 0){
		window[hidevar] = hidevalue;
		window[booldisplay] = true;
	} else {
		window[hidevar] = 'foo';
		window[booldisplay] = false;

	}
}

// ein Element xalllivevalues (csv array)
function putgraphtogether() {
	console.log('putGrpahtogesther ', all1,all2,all3,all4,all5,all6,all7,all8,all9,all10,all11,all12,all13,all14,all15,all16)
	if ( (all1 == 1) && (all2 == 1) && (all3 == 1) && (all4 == 1) && (all5 == 1) && (all6 == 1) && (all7 == 1) 
	  && (all8 == 1) && (all9 == 1) && (all10 == 1) && (all11 == 1) && (all12 == 1) && (all13 == 1) && (all14 == 1) 
	  && (all15 == 1) && (all16 == 1) )
	{
	   // wenn alle 16 subscriptes zusammen sind, alle 16 Blocks zusammenbasten zu einem ganzen Tag
		var alldata = all1p + "\n" + all2p + "\n" + all3p + "\n" + all4p + "\n" + all5p + "\n" + all6p + "\n" 
		            + all7p + "\n" + all8p + "\n" + all9p + "\n" + all10p + "\n" + all11p + "\n" + all12p + "\n" 
					+ all13p + "\n" + all14p + "\n" + all15p + "\n" + all16p;
		alldata = alldata.replace(/^\s*[\n]/gm, "");
		alldata = alldata.replace(/^\s*-[\n]/gm, "");	// leeren 11..16'er elemente wieder entfernen
		var csvData = [];
		var rawcsv = alldata.split(/\r?\n|\r/);
		// 542 Zeilen
		for (var i = 0; i < rawcsv.length; i++) {
			  csvData.push(rawcsv[i].split(","));
		}
		csvData.pop();
		// Retrived data from csv file content
		var splittime = [];
		getCol(csvData, 0).forEach(function(zeit){
			splittime.push(zeit.substring(0, zeit.length -3));
		});
		//console.log('splittime',splittime); // alle Zeiten als Array also Column 1 mit 5xx Zeilen ohne sekunden
		atime = splittime;
		if ( atime.length >= 30 ) {		// mindest 30 Zeilen beisammen
			//atime = getCol(csvData, 0);
			abezug = convertToKw(getCol(csvData, 1));		// alllivevalues spalte mit 5xx elems
			alpa = convertToKw(getCol(csvData, 2));
			apv = convertToKw(getCol(csvData, 3));
			alp1 = convertToKw(getCol(csvData, 4));
			alp2 = convertToKw(getCol(csvData, 5));
			// 6 llges ?
			aspeicherl = convertToKw(getCol(csvData, 7));
			aspeichersoc = getCol(csvData, 8);
			asoc = getCol(csvData, 9);
			asoc1 = getCol(csvData, 10);
			ahausverbrauch = convertToKw(getCol(csvData, 11));
			averbraucher1 = convertToKw(getCol(csvData, 12));
			averbraucher2 = convertToKw(getCol(csvData, 13));
			alp3 = convertToKw(getCol(csvData, 14));
//			alp4 = convertToKw(getCol(csvData, 15));
//			alp5 = convertToKw(getCol(csvData, 16));
//			alp6 = convertToKw(getCol(csvData, 17));
//			alp7 = convertToKw(getCol(csvData, 18));
//			alp8 = convertToKw(getCol(csvData, 19));
			ashd1 = convertToKw(getCol(csvData, 20));
			ashd2 = convertToKw(getCol(csvData, 21));
			ashd3 = convertToKw(getCol(csvData, 22));
			ashd4 = convertToKw(getCol(csvData, 23));
			ashd5 = convertToKw(getCol(csvData, 24));
			ashd6 = convertToKw(getCol(csvData, 25));
			ashd7 = convertToKw(getCol(csvData, 26));
			ashd8 = convertToKw(getCol(csvData, 27));
			ashd9 = convertToKw(getCol(csvData, 28));
			//ashd1t0 = getCol(csvData, 29);
			//ashd1t1 = getCol(csvData, 30);
			//ashd1t2 = getCol(csvData, 31);
			
			
			setvisibility(asoc,'hidelp1soc','Lp1 Soc','boolDisplayLp1Soc');
			setvisibility(asoc1,'hidelp2soc','Lp2 Soc','boolDisplayLp2Soc');
			setvisibility(alp1,'hidelp1','Lp1','boolDisplayLp1');
			setvisibility(alp2,'hidelp2','Lp2','boolDisplayLp2');
			setvisibility(alp3,'hidelp3','Lp3','boolDisplayLp3');
//			setvisibility(alp3,'hidelp4','Lp4','boolDisplayLp4');
//			setvisibility(alp3,'hidelp5','Lp5','boolDisplayLp5');
//			setvisibility(alp3,'hidelp6','Lp6','boolDisplayLp6');
//			setvisibility(alp3,'hidelp7','Lp7','boolDisplayLp7');
//			setvisibility(alp3,'hidelp8','Lp8','boolDisplayLp8');
			setvisibility(ashd1,'hideshd1',d1name,'boolDisplayShD1');
			setvisibility(ashd2,'hideshd2',d2name,'boolDisplayShD2');
			setvisibility(ashd3,'hideshd3',d3name,'boolDisplayShD3');
			setvisibility(ashd4,'hideshd4',d4name,'boolDisplayShD4');
			setvisibility(ashd5,'hideshd5',d5name,'boolDisplayShD5');
			setvisibility(ashd6,'hideshd6',d6name,'boolDisplayShD6');
			setvisibility(ashd7,'hideshd7',d7name,'boolDisplayShD7');
			setvisibility(ashd8,'hideshd8',d8name,'boolDisplayShD8');
			setvisibility(ashd9,'hideshd9',d9name,'boolDisplayShD9');

			initialread = 1 ;
			// after receipt of all 8 first data segments, unsubscribe from these topics to save bandwidth
			unsubscribeMqttGraphSegments();

			checkgraphload();
		} else {
			all1 = 0;
			all2 = 0;
			all3 = 0;
			all4 = 0;
			all5 = 0;
			all6 = 0;
			all7 = 0;
			all8 = 0;
			all9 = 0;
			all10 = 0;
			all11 = 0;
			all12 = 0;
			all13 = 0;
			all14 = 0;
			all15 = 0;
			all16 = 0;

			var percent = (atime.length / 60 * 100).toFixed();
			$('#waitforgraphloadingdiv').text('Erst ca. ' + percent + '% der mindestens benötigten Datenpunkte für den Graph seit Neustart vorhanden.');
		}
	}
}  // end putgraphtogether

function updateGraph(dataset) {
	var lines = dataset.split("\n");
	for (var i = 0; i < lines.length; i++) 
	{
		var linessplit=lines[i].split(",");
	
		var ldate = linessplit[0];
		var lbezug = linessplit[1];
		var lpa = linessplit[2];
		var lpv = linessplit[3];
		var llp1 = linessplit[4];
		var llp2 = linessplit[5];
		// 6 llges ?
		var lspeicherl = linessplit[7];
		var lspeichersoc = linessplit[8];
		var lsoc = linessplit[9];
		var lsoc1 = linessplit[10];
		var lhausverbrauch = linessplit[11];
		var lverbraucher1 = linessplit[12];
		var lverbraucher2 = linessplit[13];
		var lp3 = linessplit[14];
		//var lp4 = linessplit[15];
		//var lp5 = linessplit[16];
		//var lp6 = linessplit[17];
		//var lp7 = linessplit[18];
		//var lp8 = linessplit[19];
		var shd1 = linessplit[20];
		var shd2 = linessplit[21];
		var shd3 = linessplit[22];
		var shd4 = linessplit[23];
		var shd5 = linessplit[24];
		var shd6 = linessplit[25];
		var shd7 = linessplit[26];
		var shd8 = linessplit[27];
		var shd9 = linessplit[28];
		//var shd1t0 = lines[i].split(",")[29];
		//var shd1t1 = lines[i].split(",")[30];
		//var shd1t2 = lines[i].split(",")[31];
	}
	myLine.data.labels.push(ldate.substring(0, ldate.length -3));
	myLine.data.datasets[0].data.push(llp1 / 1000);
	myLine.data.datasets[1].data.push(llp2 / 1000);
	myLine.data.datasets[2].data.push(lbezug / 1000);
	myLine.data.datasets[3].data.push(lpv / 1000);
	myLine.data.datasets[4].data.push(lspeicherl / 1000);
	myLine.data.datasets[5].data.push(lspeichersoc);
	myLine.data.datasets[6].data.push(lsoc);
	myLine.data.datasets[7].data.push(lsoc1);
	myLine.data.datasets[8].data.push(lhausverbrauch / 1000);
	myLine.data.datasets[9].data.push(lverbraucher1 / 1000);
	myLine.data.datasets[10].data.push(lverbraucher2 / 1000);
	myLine.data.datasets[11].data.push(lpa / 1000);
	myLine.data.datasets[12].data.push(lp3 / 1000);
	myLine.data.datasets[13].data.push(0) //lp4 / 1000);
	myLine.data.datasets[14].data.push(0) //lp5 / 1000);
	myLine.data.datasets[15].data.push(0) //lp6 / 1000);
	myLine.data.datasets[16].data.push(0) //lp7 / 1000);
	myLine.data.datasets[17].data.push(0) //lp8 / 1000);
	myLine.data.datasets[/*18*/13].data.push(shd1 / 1000);
	myLine.data.datasets[/*19*/14].data.push(shd2 / 1000);
	myLine.data.datasets[/*20*/15].data.push(shd3 / 1000);
	myLine.data.datasets[/*21*/16].data.push(shd4 / 1000);
	myLine.data.datasets[/*22*/17].data.push(shd5 / 1000);
	myLine.data.datasets[/*23*/18].data.push(shd6 / 1000);
	myLine.data.datasets[/*24*/19].data.push(shd7 / 1000);
	myLine.data.datasets[/*25*/20].data.push(shd8 / 1000);
	myLine.data.datasets[/*26*/21].data.push(shd9 / 1000);
	//myLine.data.datasets[27].data.push(shd1t0);
	//myLine.data.datasets[28].data.push(shd1t1);
	//myLine.data.datasets[29].data.push(shd1t2);
	myLine.data.labels.splice(0, 1);
	myLine.data.datasets.forEach(function(dataset) {
		dataset.data.splice(0, 1);
	});
	myLine.update();
}

function checkgraphload(){
	if ( graphloaded == 1 ) {
		myLine.destroy();
		loadgraph(0);  // when reloading graph, no more "pumping" animations
		return;
	}
	if (typeof boolDisplayHouseConsumption === "boolean" &&
		typeof boolDisplayLoad1 === "boolean" &&
		typeof boolDisplayLp1Soc === "boolean" &&
		typeof boolDisplayLp2Soc === "boolean" &&
		typeof boolDisplayLoad2 === "boolean" &&
		typeof boolDisplayLp1 === "boolean" &&
		typeof boolDisplayLp2 === "boolean" &&
		typeof boolDisplayLp3 === "boolean" &&
		typeof boolDisplayShD1 === "boolean" &&
		typeof boolDisplayShD2 === "boolean" &&
		typeof boolDisplayShD3 === "boolean" &&
		typeof boolDisplayShD4 === "boolean" &&
		typeof boolDisplayShD5 === "boolean" &&
		typeof boolDisplayShD6 === "boolean" &&
		typeof boolDisplayShD7 === "boolean" &&
		typeof boolDisplayShD8 === "boolean" &&
		typeof boolDisplayShD9 === "boolean" &&
		typeof boolDisplayLpAll === "boolean" &&
		typeof boolDisplaySpeicherSoc === "boolean" &&
		typeof boolDisplaySpeicher === "boolean" &&
		typeof boolDisplayEvu === "boolean" &&
		typeof boolDisplayPv === "boolean" &&
		typeof boolDisplayLegend === "boolean" ) {
		if ( initialread != 0 ) {
			if ( graphloaded == 0 ) {
				graphloaded = 1;
			} else {
				myLine.destroy();
			}
			loadgraph();
		}
	}
}

$(document).ready(function(){
	if( iscloud ) {
		setTimeout(forcegraphload, 15000);
		console.log('Timer 15000 startet')
	} else {
		console.log('no cloud, No Timer ,  ')
	}
});

function forcegraphload() {
	console.log('-------------forceGrapthLoad from read+150000');
	if ( graphloaded == 0 ) {
		if ( !(typeof boolDisplayHouseConsumption === "boolean") ) {
			showhidedataset('boolDisplayHouseConsumption');
		}
		if ( !(typeof boolDisplayLoad1 === "boolean") ) {
			showhidedataset('boolDisplayLoad1');
		}
		if ( !(typeof boolDisplayLp1Soc === "boolean") ) {
			showhidedataset('boolDisplayLp1Soc');
		}
		if ( !(typeof boolDisplayLp2Soc === "boolean") ) {
			showhidedataset('boolDisplayLp2Soc');
		}
		if ( !(typeof boolDisplayLoad2 === "boolean") ) {
			showhidedataset('boolDisplayLoad2');
		}
		if ( !(typeof boolDisplayLp1 === "boolean") ) {
			showhidedataset('boolDisplayLp1');
		}
		if ( !(typeof boolDisplayLp2 === "boolean") ) {
			showhidedataset('boolDisplayLp2');
		}
		if ( !(typeof boolDisplayLp3 === "boolean") ) {
			showhidedataset('boolDisplayLp3');
		}
		if ( !(typeof boolDisplayLpAll === "boolean") ) {
			showhidedataset('boolDisplayLpAll');
		}
		if ( !(typeof boolDisplayShD1 === "boolean") ) {
			showhidedataset('boolDisplayShD1');
		}
		if ( !(typeof boolDisplayShD1 === "boolean") ) {
			showhidedataset('boolDisplayShD1');
		}
		if ( !(typeof boolDisplayShD2 === "boolean") ) {
			showhidedataset('boolDisplayShD2');
		}
		if ( !(typeof boolDisplayShD3 === "boolean") ) {
			showhidedataset('boolDisplayShD3');
		}
		if ( !(typeof boolDisplayShD4 === "boolean") ) {
			showhidedataset('boolDisplayShD4');
		}
		if ( !(typeof boolDisplayShD5 === "boolean") ) {
			showhidedataset('boolDisplayShD5');
		}
		if ( !(typeof boolDisplayShD6 === "boolean") ) {
			showhidedataset('boolDisplayShD6');
		}
		if ( !(typeof boolDisplayShD7 === "boolean") ) {
			showhidedataset('boolDisplayShD7');
		}
		if ( !(typeof boolDisplayShD8 === "boolean") ) {
			showhidedataset('boolDisplayShD8');
		}
		if ( !(typeof boolDisplaySpeicherSoc === "boolean") ) {
			showhidedataset('boolDisplaySpeicherSoc');
		}
		if ( !(typeof boolDisplaySpeicher === "boolean") ) {
			showhidedataset('boolDisplaySpeicher');
		}
		if ( !(typeof boolDisplayEvu === "boolean") ) {
			showhidedataset('boolDisplayEvu');
		}
		if ( !(typeof boolDisplayPv === "boolean") ) {
			showhidedataset('boolDisplayPv');
		}
		if ( !(typeof boolDisplayLegend === "boolean") ) {
			showhidedataset('boolDisplayLegend');
		}
		checkgraphload();
	}
}  // end forcegraphload

// Nach timer 15000 
function showhidedataset(thedataset) {
	if ( window[thedataset] == true ) {
		publish("1","openWB/graph/"+thedataset);
	} else if ( window[thedataset] == false ) {
		publish("0","openWB/graph/"+thedataset);
	} else {
		publish("1","openWB/graph/"+thedataset);
	}
}

// NC
function showhidelegend(thedataset) {
	if ( window[thedataset] == true ) {
		publish("0","openWB/graph/"+thedataset);
	} else if ( window[thedataset] == false ) {
		publish("1","openWB/graph/"+thedataset);
	} else {
		publish("0","openWB/graph/"+thedataset);
	}
}

// NC
function showhide(thedataset) {
	if ( window[thedataset] == 0 ) {
		publish("1","openWB/graph/"+thedataset);
	} else if ( window[thedataset] == 1 ) {
		publish("0","openWB/graph/"+thedataset);
	} else {
		publish("1","openWB/graph/"+thedataset);
	}
}

// nur bei "local"
function subscribeMqttGraphSegments() {
	for (var segments = 1; segments < 17; segments++) {
		topic = "openWB/graph/" + segments + "alllivevalues";
		client.subscribe(topic, {qos: 0});
	}
}

// nur bei "local"
function unsubscribeMqttGraphSegments() {
	for (var segments = 1; segments < 17; segments++) {
		topic = "openWB/graph/" + segments + "alllivevalues";
		client.unsubscribe(topic);
	}
}
