function init_load() {
  $.ajax({
    url: "/api/v1/ranking",
    dataType: "json",
    timeout: 20000,
    success: function(j){
      document.charset='UTF-8';
      document.characterSet = 'UTF-8';

      data = "";
      len = j['s'].length;
      for(i=0; i < len; i++){
        data += "<tr><td>" + j['s'][i].name + "</td>"
        data += "<td>" + j['s'][i].count + "</td></tr>"
      }
      data += "<br>"
      $('#rank_result_s').html(data);

      data = "";
      len = j['b'].length;
      for(i=0; i < len; i++){
        data += "<tr><td>" + j['b'][i].name + "</td>"
        data += "<td>" + j['b'][i].count + "</td></tr>"
      }
      data += "<br>"
      $('#rank_result_b').html(data);

      data = "";
      len = j['v'].length;
      for(i=0; i < len; i++){
        data += "<tr><td>" + j['v'][i].name + "</td>"
        data += "<td>" + j['v'][i].count + "</td></tr>"
      }
      data += "<br>"
      $('#rank_result_v').html(data);

      data = "";
      len = j['g'].length;
      for(i=0; i < len; i++){
        data += "<tr><td>" + j['g'][i].name + "</td>"
        data += "<td>" + j['g'][i].count + "</td></tr>"
      }
      data += "<br>"
      $('#rank_result_g').html(data);
    }
  });
}

init_load();
