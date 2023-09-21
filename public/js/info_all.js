function setChart() {
  var chart = new CanvasJS.Chart("sh_chartBox", {
    title: {
      text: "",
      margin: 15
    },
    toolTip:{
      shared: true,
      borderColor: "#00000",
      backgroundColor: "#FFFFFF",
      fontColor: "#000000",
      fontWeight: "bold",
      fontSize: "18"
    },
    zoomEnabled: false,
    exportEnabled: false,
    theme: 'theme3', // "light2", "dark1", "dark2"
    //animationEnabled: true,
    //animationDuration: 800,
    data: [{
      name: info_name_s,
      showInLegend: true,
      type: 'spline',
      markerSize: 10,
      markerColor: "#B9332F",
      markerBorderColor: "#000000",
      color: "#D9534F",
      dataPoints: dataPlot_s
    },{
      name: info_name_b,
      showInLegend: true,
      type: 'spline',
      markerSize: 10,
      markerColor: "#225A97",
      markerBorderColor: "#000000",
      color: "#337AB7",
      dataPoints: dataPlot_b
    },{
      name: info_name_v,
      showInLegend: true,
      type: 'spline',
      markerSize: 10,
      markerColor: "#D08d2E",
      markerBorderColor: "#000000",
      color: "#F0AD4E",
      dataPoints: dataPlot_v
    },{
      name: info_name_g,
      showInLegend: true,
      type: 'spline',
      markerSize: 10,
      markerColor: "#FF5A97",
      markerBorderColor: "#000000",
      color: "#FF7AB7",
      dataPoints: dataPlot_g
    }],
    axisY:{
      //maximum: 300,
      //minimum: 0,
      prefix: "",
      suffix: "叫び"
    },
    axisX:{
      interval: 2,
      prefix: "",
      suffix: ""
    }
  });
  chart.render();
}

function preChart(val) {
  $('#sh_loading').text("loading...");
  $('#sh_chartBox').hide();
  $.ajax({
    url: '/api/v1/info_day?day=' + val,
    type: "GET",
    timeout: 30000,
    success: function(data) {
      $('#server_name').text(data['server'] + "鯖");
      $('#server_range').text("(" + data['range'] + "日)");
      $.each(data['body'], function(key, value){
        switch(key) {
          case 's':
            info_name_s = "S鯖";
            dataPlot_s = value;
            break;
          case 'b':
            info_name_b = "B鯖";
            dataPlot_b = value;
            break;
          case 'v':
            info_name_v = "V鯖";
            dataPlot_v = value;
            break;
          case 'g':
            info_name_g = "G鯖";
            dataPlot_g = value;
            break;
        };
      });
      $('#sh_loading').text("");
      $('#sh_chartBox').show();
      setChart();
    },
      error: function() {
    }
  });
}

$('#info_today').click(function() {
  preChart(0);
});

$('#info_days').click(function() {
  preChart(1);
});

$('#info_3days').click(function() {
  preChart(3);
});

$('#info_7days').click(function() {
  preChart(7);
});

$('#info_14days').click(function() {
  preChart(14);
});

$('#info_30days').click(function() {
  preChart(30);
});

preChart(1);
