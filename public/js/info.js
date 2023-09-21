function setChart() {
  var chart = new CanvasJS.Chart("sh_chartBox", {
    title: {
      text: "",
      margin: 15,
    },
    toolTip:{
      shared: false,
      borderColor: "#000000",
      backgroundColor: "#FFFFFF",
      fontColor: "#000000",
      fontWeight: "bold",
      fontSize: "18",
    },
    zoomEnabled: false,
    exportEnabled: false,
    theme: "theme2",
    data: [{
      type: "splineArea",
      name: "",
      showInLegend: false,
      markerSize: 10,
      markerBorderColor: "#000000",
      dataPoints: dataPlot
    }]
  });
  chart.render();
}

function preChart(val) {
  $('#sh_loading').text("loading...");
  $('#sh_chartBox').hide();
  $.ajax({
    url: '/api/v1/info_server?server=' + val,
    type: "GET",
    timeout: 30000,
    success: function(data) {
      $('#server_range').text("(" + data['range'] + "日)");
      $('#server_name').text(data['server'] + "鯖");
      $('#server_name').removeClass('badge-danger badge-primary badge-warning badge-secondary');
      switch(data['server']) {
        case 'S':
          $('#server_name').addClass('badge-danger');
          break;
        case 'B':
          $('#server_name').addClass('badge-primary');
          break;
        case 'V':
          $('#server_name').addClass('badge-warning');
          break;
        case 'G':
          $('#server_name').addClass('badge-secondary');
          break;
      };
      dataPlot = data['body'];
      $('#sh_loading').text("");
      $('#sh_chartBox').show();
      setChart();
    },
      error: function() {
    }
  });
}

$('#info_s').click(function() {
  preChart("s");
});

$('#info_b').click(function() {
  preChart("b");
});

$('#info_v').click(function() {
  preChart("v");
});

$('#info_g').click(function() {
  preChart("g");
});

preChart(location.pathname.split('/')[1]);

