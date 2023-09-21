function check_update() {
  url = '/api/v1/version';
  $.getJSON(
    url,
    null,
    function(web_version, status) {
      local_version = $('#version').attr('class');
      if (local_version != web_version) {
        if  (web_version != "") {
          $("#update_noti").attr('class', "alert alert-warning alert-dismissible fade show");
          $("#message_noti").css('display','block');
          body = "<strong>" + "お知らせ:" + "</strong>" + "ぱぱみらの新しいバージョンがリリースされています.リロードしてください"
          $("#update_text").html(body);
        }
      }
    }
  );
}

setInterval("check_update()", 1800000);
