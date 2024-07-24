/* powerData.js
 * data definitions and shared data for the power graphs
 *
 * Author: Claus Hagen
 *
 */

class WbData {

	constructor(date) {
		this.date = date;
		this.pvwatt = 0;       	// openWB/pv/W posive --> "pv"
		this.pvDailyYield = 0;
		this.powerEvuIn = 0;	// openWB/evu/W wenn positiv, gegenseitedann =0 --> "evuIn"
		this.powerEvuOut = 0;   // openWB/evu/W wenn negativ -->"evuOut"
		this.evuiDailyYield = 0;
		this.evueDailyYield = 0;
		this.chargePower = 0;
		this.chargeSum = 0;
		this.housePower = 0;		// akt watt
		this.smartHomePower = 0;	// wattnichtHaus
		this.houseEnergy = 0;		// counter KWH
		this.soctarget = '';
		this.batteryEnergyExport = 0;	// counter
		this.batteryEnergyImport = 0;   // counter
		this.batteryPowerExport = 0;
		this.batteryPowerImport = 0;
        this.batteryenable_priceloading = 0;
        this.batteryiskalib   =0;
        this.batteryloadWatt   ="0";
        this.batteryload_minutes  ="0";
        this.batterydischarge_max   ="0";
		this.chargeMode = "0"
		this.u1p3p_state = 0;
		this.u1p3p_inwork = 0;
		this.cplp1_inwork = 0;
		this.graphDate = new Date();
		this.graphMonth = {
			"month": this.graphDate.getMonth(),
			"year": this.graphDate.getFullYear()
		}
        this.etPrice = 0;
        this.etMaxPrice = 0;
        this.etPriceList = "";
        this.isEtEnabled = false;		
		this.rfidConfigured = false;
		// sammelpunkte fuer die Daten
		this.consumer = [new Consumer(), new Consumer()];	// Verbraucher1 verbraucher2
		this.chargePoint = Array.from({ length: 3 }, (v, i) => new ChargePoint(i));
		this.shDevice = Array.from({ length: 9 }, (v, i) => new SHDevice(i));

		console.log('consumer',this.consumer);		
		console.log('chargePoint',this.chargePoint);		
		console.log('shDevice',this.shDevice);		

		this.sourceSummary =   {
								'evuIn': new Counter('Netz' , "\uf275"),
		                        'pv': 	  new Counter('PV',  "\uf5ba"  ), 
		                        'batOut': new Counter('Bat-', "\uf5df\uf061" ) 
  	                            };
		console.log('sourceSummary',this.sourceSummary);		
		this.usageSummary = {
								'evuOut': new Counter('Einsp.' , "\uf061\uf57d"  ),
								'batIn': new Counter('Bat+', "\uf061\uf5df" ),
								'house': new Counter('Haus', "\uf015" ),
								'charging': new Counter('Laden', "\uf5e7"),
								'devices': new Counter('Geräte', "\uf1e6" )
							};
		console.log('usageSummary',this.usageSummary);		
		this.historicSummary = {
								'evuIn': new Counter('Netz' , "\uf275" ),
		                        'pv': 	  new Counter('PV', "\uf5ba"), 
		                        'batOut': new Counter('Bat--', "\uf5df\uf061"), 
								'evuOut': new Counter('Einsp.', "\uf061\uf57d"),
								'charging': new Counter('Laden', "\uf5e7"),
								'devices': new Counter('Geräte', "\uf1e6"),
								'batIn': new Counter('Bat++', "\uf061\uf5df"),
								'house': new Counter('Haus', "\uf015")
								}		
		console.log('historicSummary',this.historicSummary);		
		this.usageDetails = []; // [this.usageSummary.evuOut];    // dynamisch usageSummary + SH + Geräte

		this.graphPreference = "live";
		this.graphMode = "live";
		this.showTodayGraph = true;
		this.showGrid = false;
		this.displayMode = "gray";
		this.usageStackOrder = 0;
		this.decimalPlaces = 1;
		this.smartHomeColors = "normal";
		this.showCpEnergyDetails = true; 
		this.showCpEnergySummary = true;
		this.smartHomeSummary = true;
		this.prefs = {};
		this.phaseSymbols = ['?', '\u2460', '\u2461', '\u2462']

	};

	init() {
		var style = getComputedStyle(document.body);
		this.sourceSummary.pv.color = 'var(--color-pv)';
		this.sourceSummary.evuIn.color = 'var(--color-evu)';
		this.sourceSummary.batOut.color = 'var(--color-battery)';
		
		this.usageSummary.evuOut.color = 'var(--color-export)';
		this.usageSummary.charging.color = 'var(--color-charging)';
		this.usageSummary.devices.color = 'var(--color-devices)';
		this.usageSummary.batIn.color = 'var(--color-battery)';
		this.usageSummary.house.color = 'var(--color-house)';

		var i;
		this.chargePoint[0].color = 'var(--color-lp1)';
		this.chargePoint[1].color = 'var(--color-lp2)';
		this.chargePoint[2].color = 'var(--color-lp3)';
		
		this.chargePoint[0].socrange=0;	
		this.chargePoint[1].socrange=0;
		this.chargePoint[0].socTime='';
		this.chargePoint[1].socTime='';
					
		//for (i = 0; i < 8; i++) {
		//	this.chargePoint[i].color = 'var(--color-lp' + (i + 1) + ')';
		//}
		for (i = 0; i < 9; i++) {
			this.shDevice[i].color = 'var(--color-sh' + (i + 1) + ')';
		}
		this.consumer[0].color = 'var(--color-co1)';
		this.consumer[1].color = 'var(--color-co2)';
		for (i = 0; i < 9; i++) {
			this.historicSummary['sh' + i] = Object.assign(this.shDevice[i])
		}
		this.historicSummary.pv.color = 'var(--color-pv)';
		this.historicSummary.evuIn.color = 'var(--color-evu)';
		this.historicSummary.batOut.color = 'var(--color-battery)';
		this.historicSummary.evuOut.color = 'var(--color-export)';
		this.historicSummary.charging.color = 'var(--color-charging)';
		this.historicSummary.devices.color = 'var(--color-devices)';
		this.historicSummary.batIn.color = 'var(--color-battery)';
		this.historicSummary.house.color = 'var(--color-house)';
		evuCol = style.getPropertyValue('--evuCol');
		xgridCol = style.getPropertyValue('--xgridCol');
		tickCol = style.getPropertyValue('--tickCol');
		fontCol = style.getPropertyValue('--fontCol');
		gridCol = style.getPropertyValue('--gridCol');

		this.readGraphPreferences();
		this.graphMode = this.graphPreference;
		switch (this.graphMode) {
			case 'live':
				powerGraph.deactivateDay();
				powerGraph.activateLive();
				break;
			case 'day':
				powerGraph.deactivateLive();
				powerGraph.activateDay();
				break;
			default:
				powerGraph.deactivateDay();
				powerGraph.activateLive();
		}
		// set display mode
		const doc = d3.select("html");
		doc.classed("theme-dark", (this.displayMode == "dark"));
		doc.classed("theme-light", (this.displayMode == "light"));
		doc.classed("theme-gray", (this.displayMode == "gray"));
		doc.classed("theme-hh", (this.displayMode == "hh"));
		switch (this.smartHomeColors) {
			case 'standard':
				doc.classed("shcolors-standard", true);
				break;
			case 'advanced':
				doc.classed("shcolors-advanced", true);
				break;
			case 'normal':
				doc.classed("shcolors-normal", true);
				break;
			default:
				doc.classed("shcolors-normal", true);
				this.smartHomeColors = 'normal';
				this.persistGraphPreferences();
				break;
		}
        if(debugmode>3)
        {
        console.log('debugmode: ' + debugmode);
        console.log('wbdata after init');
        console.log(wbdata);
        }  
	}

	updateEvu(field, value) {
		this[field] = value;
		switch (field) {
			case 'powerEvuIn':
			case 'powerEvuOut':
				this.updateSourceSummary("evuIn", "power", this.powerEvuIn);
				this.updateUsageSummary("evuOut", "power", this.powerEvuOut);
				break;
			case 'evuiDailyYield':
				this.updateSourceSummary("evuIn", "energy", this.evuiDailyYield);

				break;
			case 'evueDailyYield':
				this.updateUsageSummary("evuOut", "energy", this.evueDailyYield);
				break;
			default:
				break;
		}
	}

	updateGlobal(field, value) {
		this[field] = value;
		switch (field) {
			case 'cplp1_inwork':
				chargePointList.update();
				break;
			case 'u1p3p_inwork':
				chargePointList.update();
				break;
			case 'u1p3p_state':
				chargePointList.update();
				break;
			case 'housePower':
				this.updateUsageSummary("house", "power", value);
				break;
			case 'chargePower':
				this.updateUsageSummary("charging", "power", value);
				break;
			case 'chargeEnergy':
				this.updateUsageSummary("charging", "energy", value);
				break;
			case 'houseEnergy':
				this.updateUsageSummary("house", "energy", value);
				break;
			case 'smarthomePower':
				this.updateConsumerSummary();
				powerMeter.update();
				break;
			case 'currentPowerPrice':
			case 'chargeMode':
				priceChart.update();
				chargePointList.update();
				break
			case 'rfidConfigured':
				d3.select('#codeEntry').classed("hide", (!value))
				break
			default:
				break;
		}
	}

	updatePv(field, value) {
		this[field] = value;
		switch (field) {
			case 'pvwatt':
				this.updateSourceSummary("pv", "power", this.pvwatt);
				break;
			case 'pvDailyYield':
				this.updateSourceSummary("pv", "energy", this.pvDailyYield);
				break;
			default:
				break;
		}
	}

// verbraucher1/2
	updateConsumer(index, field, value) {
		this.consumer[index - 1][field] = value;
		switch (field) {
			case 'power':
				this.updateConsumerSummary('power');
				break;
			case 'energy':
				this.updateConsumerSummary('energy');
				break;
			default:
				break;
		}
		smartHomeList.update();
	}

	updateSH(index, field, value) {
		this.shDevice[index - 1][field] = value;
		switch (field) {
			case 'power':
				this.updateConsumerSummary("power");
				break;
			case 'energy':
				this.updateConsumerSummary("energy");
				break;
			case 'showInGraph':
				this.persistGraphPreferences();
				this.updateUsageDetails();
				yieldMeter.update();
				break;
			case 'countAsHouse':
				break;
			default:
				break;
		}
		//console.log(this.shDevice);
		smartHomeList.update();
	}

	updateCP(index, field, value) {	// index 1..3
		if( index >3 )
		 {
		 	 console.log('chargepointindex ',index,' nicht erlaubt')
		 	 return		 
	 	 }
		this.chargePoint[index - 1][field] = value; // wbdata hat alle 3/8 lp's
		switch (field) {
			case 'power':
				powerMeter.update();
				break;
			case 'energy':
				yieldMeter.update();
				break;
			case 'socrange':
			case 'soc':
				powerMeter.update();
				break;
			default:
				break;
		}
		chargePointList.update();
	}

	updateBat(field, value) {
		this[field] = value;
        //console.log('updateBat  field:',field,' = ', value);
		switch (field) {
        
			case 'batteryenable_priceloading':
				break;
			case 'batteryloadWatt':
				break;
			case 'batteryload_minutes':
				break;
			case 'batterydischarge_max':
				break;
			case 'batteryPowerImport':
				this.updateUsageSummary("batIn", "power", value);
				powerMeter.update();
				break;
			case 'batteryPowerExport':
				this.updateSourceSummary("batOut", "power", value);
				powerMeter.update();
				break;
			case 'batteryEnergyImport':
				this.updateUsageSummary("batIn", "energy", value);
				yieldMeter.update();
				break;
			case 'batteryEnergyExport':
				this.updateSourceSummary("batOut", "energy", value);
				yieldMeter.update();
				break;
			case 'batterySoc':
				powerMeter.update();
				break;                
			default:
				break;
		}
		batteryList.update();
	}


	updateET(field, value) {
		this[field] = value;    // set wbdata.isEtEnabled = treue/false 
		
		switch (field) {
			case 'etPrice':
			case 'isEtEnabled': 
					// Nicht noetig, preis steht jetzt oben im kreis 
					// chargePointList.updateValues();
				break;
			default:
				break;
		}
		priceChart.update()
	}

	updateSourceSummary(cat, field, value) {
		this.sourceSummary[cat][field] = value;
		if (field == "power") {
			this.updateUsageDetails();
			powerMeter.update();
		}

		if (field == "energy") {
			this.updateUsageDetails();
			yieldMeter.update();
		}
	}

	updateUsageSummary(cat, field, value) {
		this.usageSummary[cat][field] = value;

		if (field == "power") {
			this.updateUsageDetails();
			powerMeter.update();
		}
		if (field == "energy") {
			this.updateUsageDetails();
			yieldMeter.update();
		}
	}

	// nur bei Tagesgrafen
	updateUsageDetails() 
	{
		this.usageDetails = [this.usageSummary.evuOut,
							 this.usageSummary.charging]
			.concat(this.shDevice.filter(row => (row.configured && row.showInGraph)))
			.concat(this.consumer.filter(row => (row.configured)))
			.concat(this.usageSummary.batIn) 
			.concat(this.usageSummary.house);
		console.log('usageDetails',this.usageDetails);							 
	}

	updateConsumerSummary(cat) {
		if (cat == 'energy') {
			this.updateUsageSummary("devices", 'energy', 
					this.shDevice.filter(dev => dev.configured).reduce((sum, shDevice) => sum + shDevice.energy, 0)
				  + this.consumer.filter(dev => dev.configured).reduce((sum, consumer) => sum + consumer.energy, 0));
		} else {
			this.updateUsageSummary("devices", 'power', this.smarthomePower
				+ this.consumer.filter(dev => dev.configured).reduce((sum, consumer) => sum + consumer.power, 0));
		}
	}

	//update cookie
	persistGraphPreferences() {
		this.prefs.hideSH = this.shDevice.filter(device => !device.showInGraph).map(device => device.id);
		this.prefs.showLG = (this.graphPreference == 'live');
		this.prefs.displayM = this.displayMode;
		this.prefs.stackO = this.usageStackOrder;
		this.prefs.showGr = this.showGrid;
		this.prefs.decimalP = this.decimalPlaces;
		this.prefs.smartHomeC = this.smartHomeColors;
		this.prefs.smartHomeSum = this.smartHomeSummary;
		setCookie( "openWBColorTheme",JSON.stringify(this.prefs) , 360 )
		console.log('persistGraphPreferences()' , this.prefs );

	}
	// read cookies and update settings
	
	readGraphPreferences() {
		
		var myCookie = getCookie("openWBColorTheme");
		console.log('MyCookie1' , myCookie);
		if (myCookie.length > 0) {
			this.prefs = JSON.parse(myCookie);
			if ('hideSH' in this.prefs) {
				this.prefs.hideSH.map(i => this.shDevice[i].showInGraph = false)
			}
			if ('showLG' in this.prefs) {
				this.graphPreference = (this.prefs.showLG) ? "live" : "day";
			}
			if ('maxPow' in this.prefs) {
				powerMeter.maxPower = +this.prefs.maxPow;
			}
			if ('relPM' in this.prefs) {
				powerMeter.showRelativeArcs = this.prefs.relPM;
			}
			if ('displayM' in this.prefs) {
				this.displayMode = this.prefs.displayM;
			}
			if ('stackO' in this.prefs) {
				this.usageStackOrder = this.prefs.stackO;
			}
			if ('showGr' in this.prefs) {
				this.showGrid = this.prefs.showGr;
			}
			if ('decimalP' in this.prefs) {
				this.decimalPlaces = this.prefs.decimalP;
			}
			if ('smartHomeC' in this.prefs) {
				this.smartHomeColors = this.prefs.smartHomeC;
			}
			if ('cpEnergySum' in this.prefs) {
				this.showCpEnergySummary = this.prefs.cpEnergySum;
			}
			if ('cpEnergyDetails' in this.prefs) {
				this.showCpEnergyDetails = this.prefs.cpEnergyDetails;
			}
			if ('smartHomeSum' in this.prefs) {
				this.smartHomeSummary = this.prefs.smartHomeSum;
			}
		}
	}
	dayGraphUpdated() {
		yieldMeter.update();
	}
	monthGraphUpdated() {
		yieldMeter.update();
	}
	yearGraphUpdated() {
		yieldMeter.update();
	}
}

var goid=0;
	goids=[];

class Counter {
	constructor(name = "", icon = "" ) {
		this.oid=goid;
		goids[goid]=this;
		goid++;
		
		this.classof = 'Z';
		this.name = name;
		this.icon = icon;  		
		this.power = 0;
		this.dailyYield = 0;
		this.configured = 0;
		this.color = "white";
		this.energy=0;
		this.energyPv=0;
		this.energyBat=0;
		this.pvPercentage=0;
  	    console.log(goids);
	}
};


class Consumer extends Counter {
	constructor(name = "", power = 0, dailyYield = 0, configured = false, color = "white") {
		super(name, "");
		this.classof = this.classof + 'V';
		this.name = name;
		this.power = power;
		this.dailyYield = dailyYield;
		this.configured = configured;
		this.color = color;
	}
};

class ChargePoint extends Counter {
	constructor(index, name = "", power = 0, dailyYield = 0, configured = false, isSocConfigured = false, isSocManual = false) {
		super(name, "");
		this.classof = this.classof + 'C';
        this.id = index; // 0..2
		this.name = name;
		this.icon = name;
		this.power = power;
		this.energy = dailyYield;
		this.energyPv = 0;
		this.energyBat = 0;
		this.configured = configured;
		this.isSocConfigured = isSocConfigured;
		this.isSocManual = isSocManual;
		this.socrange = 0;		
		this.soc = 0;

	}
};

class SHDevice extends Counter {
	constructor(index, name = "", power = 0, dailyYield = 0, configured = false, color = "white") {
		super(name, "");
		this.classof = this.classof + 'S';
		this.id = index;
		this.name = name;
		this.power = power;
		this.energy = dailyYield;
		this.configured = configured;
		this.showInGraph = true;
		this.color = color;
		this.countAsHouse = false;
		this.energyPv = 0;
		this.energyBat = 0;
		this.pvPercentage = 0;
		this.temp = [0.0, 0.0, 0.0];
	}
};


function formatWatt(watt) {
	if (watt >= 1000) {
		switch (wbdata.decimalPlaces) {
			case 0:	return Math.round(watt / 1000).toLocaleString('de-DE')  + " kW";
					break;
			case 1: return (Math.round(watt / 100) / 10).toLocaleString('de-DE') + " kW";
					break;
			case 2: return (Math.round(watt / 10) / 100).toLocaleString('de-DE') + " kW";
					break;
			case 3: return (Math.round(watt) /* / 1000*/).toLocaleString('de-DE') + " W";
					break;
			default:return (Math.round(watt / 100) / 10 ).toLocaleString('de-DE') + " kW";
					break;
		}
	} else {
		return (Math.round(watt).toLocaleString('de-DE') + " W");
	}
}

function formatWattH(watt) {
	if (watt >= 1000) {
		switch (wbdata.decimalPlaces) {
			case 0:	return Math.round(watt / 1000).toLocaleString('de-DE') + ' kWh';
					break;
			case 1: return (Math.round(watt / 100) / 10).toLocaleString('de-DE') + ' kWh';
					break;
			case 2: return (Math.round(watt / 10) / 100).toLocaleString('de-DE') + ' kWh';
					break;
			case 3: return (Math.round(watt) /* / 1000*/).toLocaleString('de-DE')  + ' Wh';
					break;
			default:return (Math.round(watt / 100) / 10).toLocaleString('de-DE') + ' kWh';
					break;
		}
	} else {
		return (Math.round(watt).toLocaleString('de-DE') + " Wh");
	}
}

function formatWattHOpt(watth) {
  if (watth == 0 )
     return ""
  return "("  +  formatWattH(watth)  + ")";
}

function formatWattHX(watt) {
	if (watt >= 1000) {
		switch (wbdata.decimalPlaces) {
			case 0:	return Math.round(watt / 1000).toLocaleString('de-DE');
					break;
			case 1: return (Math.round(watt / 100) / 10).toLocaleString('de-DE');
					break;
			case 2: return (Math.round(watt / 10) / 100).toLocaleString('de-DE');
					break;
			case 3: return (Math.round(watt) /* / 1000*/).toLocaleString('de-DE')  + ' Wh';
					break;
			default:return (Math.round(watt / 100) / 10).toLocaleString('de-DE');
					break;
		}
	} else {
		return (Math.round(watt).toLocaleString('de-DE') + " Wh");
	}
}


function formatTime(seconds) {
	const hours = Math.floor(seconds / 3600);
	const minutes = ((seconds % 3600) / 60).toFixed(0);
	if (hours > 0) {
		return (hours + "h " + minutes);
	} else {
		return (minutes + " min");
	}
}

function formatMonth(month, year) {
	months = ['Jan', 'Feb', 'März', 'April', 'Mai', 'Juni', 'Juli', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
	return (months[month] + " " + year);
}

function formatTemp(t) {
	return ((Math.round(t * 10) / 10).toLocaleString(undefined, { minimumFractionDigits: 1 }) + "°")
}
function shiftLeft() {
	switch (wbdata.graphMode) {
		case 'live':
			wbdata.graphMode = 'day';
			wbdata.graphPreference = 'day';
			wbdata.showTodayGraph = true;
			powerGraph.deactivateLive();
			powerGraph.activateDay();
			wbdata.prefs.showLG = false;
			wbdata.persistGraphPreferences();
			d3.select("button#graphRightButton").classed("disabled", false)
			break;
		case 'day':
			wbdata.showTodayGraph = false;
			wbdata.graphDate.setTime(wbdata.graphDate.getTime() - 86400000);
			powerGraph.activateDay();
			break;
		case 'month':
			wbdata.graphMonth.month = wbdata.graphMonth.month - 1;
			if (wbdata.graphMonth.month < 0) {
				wbdata.graphMonth.month = 11;
				wbdata.graphMonth.year = wbdata.graphMonth.year - 1;
			}
			powerGraph.activateMonth();
			break;
		default: break;
	}
}

function shiftRight() {
	today = new Date();
	const d = wbdata.graphDate;
	switch (wbdata.graphMode) {
		case 'live':
			break;
		case 'day':
			if (d.getDate() == today.getDate() && d.getMonth() == today.getMonth() && d.getFullYear() == today.getFullYear()) { // date is today, switch to live graph
				wbdata.graphMode = 'live';
				powerGraph.deactivateDay();
				powerGraph.activateLive();
				wbdata.graphPreference = 'live';
				wbdata.prefs.showLG = true;
				wbdata.persistGraphPreferences();
				d3.select("button#graphLeftButton").classed("disabled", false)
				d3.select("button#graphRightButton").classed("disabled", true)
				yieldMeter.update()
			} else { // currently looking at a previous day
				wbdata.graphDate.setTime(wbdata.graphDate.getTime() + 86400000);
				const nd = wbdata.graphDate;
				if (nd.getDate() == today.getDate() && nd.getMonth() == today.getMonth() && nd.getFullYear() == today.getFullYear()) {
					wbdata.showTodayGraph = true;
				}
				powerGraph.activateDay();
			}
			break;
		case 'month':
			if ((today.getMonth() != wbdata.graphMonth.month) || (today.getFullYear() != wbdata.graphMonth.year)) { // we are looking at a previous month
				wbdata.graphMonth.month = wbdata.graphMonth.month + 1;
				if (wbdata.graphMonth.month == 12) {
					wbdata.graphMonth.month = 0;
					wbdata.graphMonth.year = wbdata.graphMonth.year + 1;
				}
				powerGraph.activateMonth();
			} 
	}

}

function toggleGrid() {
	wbdata.showGrid = !wbdata.showGrid;
	powerGraph.updateGraph();
	yieldMeter.update();
	wbdata.persistGraphPreferences();
}

function switchDecimalPlaces() {
	if (wbdata.decimalPlaces  < 3) {
		wbdata.decimalPlaces = wbdata.decimalPlaces + 1;
	} else {
		wbdata.decimalPlaces = 0;
	}
	wbdata.persistGraphPreferences();
	powerMeter.update();
	yieldMeter.update();
	smartHomeList.update();
}

function switchSmartHomeColors() {

	const doc = d3.select("html");
	switch (wbdata.smartHomeColors) {
		case 'normal':
			wbdata.smartHomeColors = 'standard';
			doc.classed("shcolors-normal", false);
			doc.classed("shcolors-standard", true);
			doc.classed("shcolors-advanced", false);
			break;
		case 'standard':
			wbdata.smartHomeColors = 'advanced';
			doc.classed("shcolors-normal", false);
			doc.classed("shcolors-standard", false);
			doc.classed("shcolors-advanced", true);
			break;
		case 'advanced':
			wbdata.smartHomeColors = 'normal';
			doc.classed("shcolors-normal", true);
			doc.classed("shcolors-standard", false);
			doc.classed("shcolors-advanced", false);
			break;
		default:
			wbdata.smartHomeColors = 'normal';
			doc.classed("shcolors-normal", true);
			doc.classed("shcolors-standard", false);
			doc.classed("shcolors-advanced", false);
			break;
	}
	wbdata.persistGraphPreferences();
}

function toggleChargepointSummary() {
	if (wbdata.showCpEnergyDetails) {
		if (wbdata.showCpEnergySummary) { 
			wbdata.showCpEnergyDetails = false;
		} else { 
			wbdata.showCpEnergySummary = true;
		}
	} else { 
			wbdata.showCpEnergyDetails = true;
			wbdata.showCpEnergySummary = false;
	}
	yieldMeter.update()
	wbdata.persistGraphPreferences();
}

function toggleSmartHomeSummary() {
	wbdata.smartHomeSummary = !wbdata.smartHomeSummary
	yieldMeter.update()
	wbdata.persistGraphPreferences();
}

function toggleMonthView() {
	console.log('toggleMonthView')
	if (wbdata.graphMode == 'month') {
		wbdata.graphMode = wbdata.graphPreference;	// live oder day)
		powerGraph.deactivateMonth();
		if (wbdata.graphPreference == 'live') 
			powerGraph.activateLive();
		else 
			powerGraph.activateDay();
	} else {	// month einschalten
		wbdata.graphMode = 'month';
		powerGraph.deactivateDay();
		powerGraph.deactivateLive();
		powerGraph.activateMonth();
	}
	yieldMeter.update();
}
// required for price chart to work
var evuCol;
var xgridCol;
var gridCol;
var tickCol;
var fontCol;

var wbdata = new WbData(new Date(Date.now()));
console.log('wbdata.created');
if(debugmode>2)
  console.log('wbdata:', wbdata);

