$("#uniq_id").keypress(function (e) { if (e.which === 13) {
  $.cookie("papamira_uniq_id", $('#uniq_id').val(), {
    expires: 365,
    path: '/',
  });
  $("#message_noti").attr('class', "alert alert-warning alert-dismissible fade show");
  $("#message_noti").css('display','block');
  body = "<strong>" + "IDの保存:" + "</strong>" + "UniqID【" + $('#uniq_id').val() + "】をCookieに保存しました!!";
  $("#message_text").html(body);
  setTimeout('$("#message_noti").css("display","none");', 5000);
}});
