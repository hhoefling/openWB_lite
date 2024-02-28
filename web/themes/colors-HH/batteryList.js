/** 
 * List the status of the battery
 * 
 */


  function BatButtonClicked() {
  console.log('wbdata.batteryenable_priceloading:',wbdata.batteryenable_priceloading)
  if (wbdata.batteryenable_priceloading) {
    //wbdata.batteryenable_priceloading=false
    //batteryList.update();
    publish("0", "openWB/set/houseBattery/enable_priceloading");
  } else {
    //wbdata.batteryenable_priceloading=true
    //batteryList.update();
    publish("1", "openWB/set/houseBattery/enable_priceloading");
  }
//  d3.select("button#lpbutton-" + i)
//    .classed("disabled", true);
}


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
  update() {
    this.div.selectAll("*").remove();
    if (wbdata.isBatteryConfigured) {
      d3.select("div#batteryWidget").classed("hide", false);
      const table = this.div.append("table")
        .attr("class", "table table-borderless table-condensed p-0 m-0");

      if(Math.floor(wbdata.batterydischarge_max)>0) 
           var headers = ["State", "Leistung", "Geladen", "Geliefert", "Ladestand"]
      else var headers = ["Leistung", "Geladen", "Geliefert", "Ladestand"];
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



    if (Math.floor(wbdata.batterydischarge_max)>0)   // rct vorhanden, sonst default -1
    { 
        const xcell = row.append("td")
            .attr("class", "tablecell py-1 px-1")
            .attr("style", "vertical-align: middle;")
            .attr("onClick", "BatButtonClicked()");
        if (wbdata.batteryenable_priceloading >0) 
              xcell.append("span").attr("class", "fa fa-chart-line text-green px-0")
        else  xcell.append("span").attr("class", "fa fa-chart-line text-red px-0")
      
        //xcell
        //    .append("span").text(''+wbdata.batteryload_minutes)
        //    .attr("class", "px-1");
        //console.log(wbdata);
        //console.log('wbdata.batteryloadWatt', wbdata.batteryloadWatt )

        if (Math.floor(wbdata.batteryloadWatt)>100 ) 
        {
            const span = xcell.append("span");
            if( wbdata.batteryload_minutes >= 178 )
                span.attr("class", "fa fa-battery-full px-1")
            else if( wbdata.batteryload_minutes >= 119 )
                span.attr("class", "fa fa-battery-three-quarters px-1")
            else if( wbdata.batteryload_minutes >= 59 )
                span.attr("class", "fa fa-battery-half px-1")
            else if( wbdata.batteryload_minutes > 0 )
                span.attr("class", "fa fa-battery-quarter px-1")
            else  
                span.attr("class", "fa fa-battery-empty px-1")
            span.classed("text-orange", (!true))
            span.classed("text-green", (true))
        } else
        {
          if( wbdata.batteryload_minutes !=0 )
          {
            const span = xcell.append("span");
            //.append("span").text(''+wbdata.batteryload_minutes)
            //.attr("class", "px-1");
            span.attr("class", "fa  fa-cog fa-spin px-1")
            span.classed("text-green", (true))
          }            
        }
      if (Math.floor(wbdata.batterydischarge_max)<=2) 
      {
         const span=xcell.append("span")
          .attr("class", "fa fa-ban pl-1");
          span.classed("text-red", (true))
      } 
      if (wbdata.batteryiskalib) {        // rct vorhanden, sonst default false
          const span=xcell.append("span")
            .attr("class", "fa fa-recycle pl-1")
            .attr("onClick", "alert('haha')");
           span.classed("text-green", (true))
       }
    }

      // current power
      const cell = row.append("td")
        .attr("class", "tablecell py-1 px-1")
        .attr("style", "vertical-align: middle;");
      if (wbdata.batteryPowerImport > 0) {
        cell.text("Laden: " + formatWatt(wbdata.batteryPowerImport))
      } else if (wbdata.batteryPowerExport > 0) {
        cell.text("Liefern: " + formatWatt(wbdata.batteryPowerExport))
      } else {
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
        .text(formatWattH(wbdata.batteryEnergyExport*1000));

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




var batteryList = new BatteryList();



