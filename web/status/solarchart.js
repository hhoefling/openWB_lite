
console.log('compile solarchart.js')

function loadSolarchart(labels, dataPrice) {

	var ctxElectricityPricechart = $('#solarchartCanvas')[0].getContext('2d');

	var config = {
		type: 'line',
		data: {
		  	labels: labels,
			datasets: [{
				yAxisID: 'y-axis-left',
				data: dataPrice,
				borderColor: 'rgba(201, 38, 38, 1)',
				backgroundColor: 'rgba(30, 33, 194, 0.7)',
				borderWidth: 2,
				fill: false,
				steppedLine: true
			}]
		},
		options: {
			tooltips: {
				enabled: true,
				mode: 'index',
				callbacks: {
					label: function(tooltipItem, data) {
						return tooltipItem.yLabel + ' ct/kWh';
					}
				}
			},
			responsive: true,
			maintainAspectRatio: false,
			hover: {
				mode: 'null'
			},
			stacked: false,
			legend: {
				display: false
			},
			title: {
				display: false
			},
			scales: {
				xAxes: [
					{
					gridLines: {
							color: 'rgba(204, 204, 204, 0.3)',
						},

					ticks: {
							fontColor: 'rgba(153, 153, 153, 1)'
					}
				}],
				yAxes: [
					{
						// values displayed on the left side (price)
						position: 'left',
						id: 'y-axis-left',
						type: 'linear',
						display: true,
						scaleLabel: {
							display: true,
							labelString: 'stündl. Preis [ct/kWh]',
							fontColor: 'rgba(153, 153, 153, 1)'
						},
						gridLines: {
							color: 'rgba(204, 204, 204, 1)',
						},
						ticks: {
							fontColor: 'rgba(153, 153, 153, 1)',
							fontSize: 15
						}

					}]
			}
		}
	};

	var electricityPricechart = new Chart(ctxElectricityPricechart, config);

}


function fillCardSolar(response){
    /**
     */
    const options = { weekday: 'short', year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', timeZoneName: 'short' };
    var priceCurrentData = response?.data?.viewer?.home?.currentSubscription?.priceInfo?.current;
    var priceTodayData = response?.data?.viewer?.home?.currentSubscription?.priceInfo?.today;
    var priceTomorrowData = response?.data?.viewer?.home?.currentSubscription?.priceInfo?.tomorrow;
    var labels = [];
    var data = [];

    if (typeof priceCurrentData !== 'undefined') {
        var startsAt = new Date(priceCurrentData.startsAt);
        $('#currentPrice').text(convertToLocale((priceCurrentData.total * 100), 'ct/kWh'));
        $('#currentEnergyPrice').text(convertToLocale((priceCurrentData.energy * 100), 'ct/kWh'));
        $('#currentTax').text(convertToLocale((priceCurrentData.tax * 100), 'ct/kWh'));
        $('#currentValidSince').text(startsAt.toLocaleDateString(undefined, options));
        if (typeof priceTomorrowData !== 'undefined') {
            $('#noPricechartDiv').hide();
            // get current timestamp but at full hour
            var now = new Date;
            now.setMinutes(0, 0, 0);

            // chart should beginn at current hour, so
            // copy only prices at or after full hour in arrays for the chart
            for (i=0; i<priceTodayData.length; i++) {
                var startsAtDate = new Date(priceTodayData[i].startsAt);
                if (startsAtDate.valueOf() >= now.valueOf()){
                    data.push((priceTodayData[i].total*100).toFixed(2));
                    labels.push(createXLabel(priceTodayData[i].startsAt));
                }
            }
            for (i=0; i<priceTomorrowData.length; i++) {
                data.push((priceTomorrowData[i].total*100).toFixed(2));
                labels.push(createXLabel(priceTomorrowData[i].startsAt));
            }
            // create chart
            loadSolarchart(labels, data);
        } else {
            $('#solarchartCanvasDiv').hide();
        }
    }
}


