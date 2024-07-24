/** 
 * List the status of the battery
 * 
 */

class BatteryList {

/* div; */
  
	constructor() {
		this.div = null; 
	};

	// initialize after document is created
	init() {
		this.div = d3.select("div#batteryStatus");
	}

	// update if data has changed
	update() 
	{
		this.div.selectAll("*").remove();
		if (wbdata.isBatteryConfigured) 
		{
			d3.select("div#batteryWidget").classed("hide", false);
			const table = this.div.append("table")
				.attr("class", "table table-borderless table-condensed p-0 m-0");
			const headers = ["Leistung", "Geladen", "Geliefert", "Ladestand"];
			const thead = table.append("thead")
				.selectAll("headers")
				.data(headers).enter()
				.append("th")
				.attr("style", "text-align:center;")
				.attr("class", "tablecell ")
				.text((data) => data)
				;

			const row = table.append("tbody")
				.append("tr")
				.style("color", wbdata.sourceSummary.batOut.color)
				.style("text-align", "center");

			// current power
			const cell = row.append("td")
				.attr("class", "tablecell py-1 px-1 d-flex align-items-center justify-content-center flex-wrap");
			if (wbdata.batteryPowerImport > 0) 
			{
				cell.append("span").attr("class", "pr-1").text("Laden: ");
				cell.append("span").text(formatWatt(wbdata.batteryPowerImport));
			} else if (wbdata.batteryPowerExport > 0) 
			{
				cell.append("span").attr("class", "pr-1").text("Liefern: ");
				cell.append("span").text(formatWatt(wbdata.batteryPowerExport));
			} else 
			{
				cell.text("0 W")
			}
			
			// Daily Import  
			row.append("td")
				.attr("class", "tablecell py-1 px-1")
				.attr("style", "vertical-align: middle;")
				.text(formatWattH(wbdata.batteryEnergyImport * 1000));

			// Daily Export
			row.append("td")
				.attr("class", "tablecell py-1 px-1")
				.attr("style", "vertical-align: middle;")
				.text(formatWattH(wbdata.batteryEnergyExport * 1000));

			// SoC
			const scell = row.append("td")
				.attr("class", "tablecell py-1 px-1")
				.attr("style", "vertical-align: middle;");
			scell.html( wbdata.batterySoc + " %" + "<br>&nbsp;<small>(" + wbdata.soctarget + "</small>)" );
		}
		else {
			d3.select("div#batteryWidget").classed("hide", true);
		}
	}
}



// batteryList div enthält D3 
var batteryList = new BatteryList();
console.log('batteryList.create');


