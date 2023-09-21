$("#shop_pass").keypress(function (e) { if (e.which === 13) {
  $.cookie("papamira_shop_pass", $('#shop_pass').val(), {
    expires: 7,
    path: '/your_shop/',
  });
  $("#message_noti").attr('class', "alert alert-warning alert-dismissible fade show");
  $("#message_noti").css('display','block');
  body = "<strong>" + "PASSの保存:" + "</strong>" + "Pass【" + $('#shop_pass').val() + "】をCookieに保存しました!!";
  $("#message_text").html(body);
  setTimeout('$("#message_noti").css("display","none");', 5000);
}});
