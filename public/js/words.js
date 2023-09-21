function init_load() {
  $.ajax({
    url: "/api/v1/words",
    dataType: "json",
    timeout: 20000,
    success: function(j){
      render(j);
    }
  });
}

function url_load(url) {
  $.ajax({
    url: url,
    dataType: "json",
    type: "GET",
    timeout: 20000,
    success: function(data) {
      render(data);
    },
      error: function() {
    }
  });
}

function render(j) {
  document.charset='UTF-8';
  document.characterSet = 'UTF-8';

  $.each(j, function(key, value){
    data = "";

    switch(key) {
    case 'all':
      server_name = "#words_result_all";
      break;
    case 's':
      server_name = "#words_result_s";
      break;
    case 'b':
      server_name = "#words_result_b";
      break;
    case 'v':
      server_name = "#words_result_v";
      break;
    case 'g':
      server_name = "#words_result_g";
      break;
    };

    $.each(value, function(key2, value2){
      data += "<tr><td>" + value2['word'] + "</td>"
      data += "<td>" + value2['days']+ "</td>"
      data += "<td>" + value2['count'] + "回</td>"
      data += "</tr>"
    });
    data += "<br>"
    $(server_name).html(data);
  });
}

function datepicker_init() {
  $('#datepicker').datepicker({
    showOtherMonths: true,
    selectOtherMonths: true
  });
};

function run_datepicker(){
  url_load('/api/v1/select_history_words?day=' + $('#datepicker').val());
}

$("#datepicker").keypress(function (e) { if (e.which === 13) {
  run_datepicker();
}});

$('#calendar_done').click(function() {
  run_datepicker();
});

init_load();
datepicker_init();
