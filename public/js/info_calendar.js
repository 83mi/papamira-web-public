function setChart() {
  var chart = new CanvasJS.Chart("sh_chartBox", {
    title: {
      text: "",
      margin: 15
    },
    toolTip:{
      shared: true,
      borderColor: "#000000",
      backgroundColor: "#FFFFFF",
      fontColor: "#000000",
      fontWeight: "bold",
      fontSize: "18"
    },
    zoomEnabled: false,
    exportEnabled: false,
    theme: 'theme3',
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
    url: '/api/v1/info_calendar?days=' + val,
    type: "GET",
    timeout: 30000,
    success: function(data) {
      $.each(data['body'], function(key, value){
      dataPlot = data['body'];
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

$(function() {
  $("#datepicker").keypress(function (e) { if (e.which === 13) {
    $("#cl_search").trigger("click");
    }
  });

  $('#cl_search').click(function() {
    preChart($('#datepicker').val());
  });

  $('#datepicker').datepicker();
});
