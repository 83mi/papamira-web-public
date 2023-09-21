var voice_file = "/audio/notification.mp3";
var voice_file_path = "/audio/notification.mp3";
var voice_dic = {};
var update_flg = false;
var update_star = 0;
var favicon = new Favico({
  animation:'slide'
});

function init() {
  var ws = null;
  open();
}

function open() {
  var proto  = location.protocol === 'https:' ? 'wss' : 'ws'
  var ws     = new WebSocket(proto + '://' + window.location.host + window.location.pathname);

  ws.onopen  = function() {
    update_connect('online');
  };

  ws.onclose = function() {
    update_connect('offline');
    log_history();
    open();
  };

  ws.onerror = function() {
    ws.close();
  };

  setInterval(() => {
    ws.close();
  }, 295000);

  ws.onmessage = function(m) { 
    json_data = $.parseJSON(m.data);
    if (json_data.mode == 'chat') {
      name = json_data.name;
      text = json_data.body;
      out = '<span class="badge badge-dark">'+name+'</span>:'+text+'<br>'
      $('#stream_chat_body').prepend(out)

      if ($("#live_chat").is(':hidden')) {
        body = "【" + name + "】:" + text
        $("#live_people").attr('data-content', body);
        $("#live_people").click();
        setTimeout(function(){
          $("#live_people").click();
        },500);
      }
    } else {
      var template = '';
      if (splitByLine(m.data) == true) {
        getAudioBuffer(voice_file, function(buffer){
          playSound(buffer, ($("#volume_voice").val() / 100));
        });
        template  = '<tr><td><div style="display:none">SERVER</div></td>';
        template += '<td><div class="text-nowrap fixed" style="display:none">DATE</div></td>';
        template += '<td class="text-nowrap fixed STAT"><div style="display:none">NAME</div></td>';
        template += '<td><div style="display:none">';
        template += '<img src="/favicon-32x32.png" align="left" class="image-ppap"/>';
        template += '<h2 class="type-shine">BODY</h2></div></td></tr>';
        changeFavicon('/favicon2.ico');
        if (update_star >= 1){
          titlenotifier.set(update_star);
          favicon.badge(update_star);
        };
      } else {
        template  = '<tr><td><div style="display:none">SERVER</div></td>';
        template += '<td><div class="text-nowrap fixed" style="display:none">DATE</div></td>';
        template += '<td class="text-nowrap fixed STAT"><div style="display:none">NAME</div></td>';
        if($("#font_size").prop('checked')) {
          template += '<td><div class="type-shine2" style="display:none">BODY</div></td></tr>';
        } else {
          template += '<td><div class="type-shine2 small" style="display:none">BODY</div></td></tr>';
        }

        if (update_flg == true){
          if (update_star >= 1){
            if (update_star == 1){
              changeFavicon('/favicon3.ico');
            };
            titlenotifier.set(update_star);
            favicon.badge(update_star);
          };
        };
      };
      show_json(m.data, template);
    }
  };
};

function update_connect(c_status) {
  switch(c_status) {
    case 'online':
      s =  '<span class="ppap_online ' + c_status + '">' + c_status + '<span class="oi oi-fire"></span></span>';
      break;
    case 'offline':
      s =  '<span class="ppap_online ' + c_status + '">' + c_status + '<span class="oi oi-pulse"></span></span>';
      break;
    default:
      s = '<span class="ppap_online ' + c_status + '">' + c_status + '</span>';
      break;
  }
  $("#connect_status").html(s);
}

function splitByLine(data) {
  flag = false
  var json_data = $.parseJSON(data);
  var keys = $("#push_word").val().replace(/\r\n|\r/g, "\n").split('\n');
  var rserver = $("#reg_server").val();

  rserver_flg = false
  switch(rserver) {
    case '' :
      rserver_flg = true
      break
    case 's' :
      if (json_data.server == "s") {
        rserver_flg = true
      }
      break
    case 'b' :
      if (json_data.server == "b") {
        rserver_flg = true
      }
      break
    case 'v' :
      if (json_data.server == "v") {
        rserver_flg = true
      }
      break
    case 'g' :
      if (json_data.server == "g") {
        rserver_flg = true
      }
      break
    default:
      rserver_flg = true
      break
  }

  if (rserver_flg == true) {
    $.each(keys, function(index, key){
      if (key != '') {
        reg = RegExp(key, 'i');
        rrange = $("#reg_range").val();
        fetch_data = "";
        switch(rrange) {
          case '0' :
            fetch_data = json_data.search_name + json_data.search_body;
            break
          case '1' :
            fetch_data = json_data.search_name;
            break
          case '2' :
            fetch_data = json_data.search_body;
            break
          default:
            fetch_data = json_data.search_name + json_data.search_body;
            break
        }
        if (reg.test(fetch_data) == true) {
          update_flg = true;
          runNotification(json_data);
          flag = true;
          return false;
        } 
      }
    })
  }
  if (update_flg == true){
    update_star++;
  };
  return flag
};

function runNotification(json_data) {
  options = {
    tag:  'papamira',
    body: '【'+json_data.name+'】 ' + json_data.body,
    icon: '/png/noti.png'
  }
  Notification("ぱぱみら", options);
}

function runNotification2(title, name, body) {
  options = {
    tag:  'papamira',
    body: '【'+name+'】 ' + body,
    icon: '/png/noti.png'
  }
  Notification(title, options);
}

function testNotification() {
  options = {
    tag:  'papamira',
    body: 'Hello World',
    icon: '/png/noti.png'
  }
  Notification("ぱぱみら", options);
}

function show_json(msg, template){
  var j = $.parseJSON(msg);

  switch(j.server) {
    case 's':
      template = template.replace(/SERVER/, '<span class="badge badge-danger">S</span>');
      break;
    case 'b':
      template = template.replace(/SERVER/, '<span class="badge badge-primary">B</span>');
      break;
    case 'v':
      template = template.replace(/SERVER/, '<span class="badge badge-warning">V</span>');
      break;
    case 'g':
      template = template.replace(/SERVER/, '<span class="badge badge-secondary">G</span>');
      break;
    default:
      template = template.replace(/SERVER/, '<span class="badge badge-default">'+j.server+'</span>');
  }

  uid_url = '/ss/'+j.id;

  switch(j.stat) {
    case 'wt':
      template = template.replace(/STAT/, 'wname');
      template = template.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
      break;
    case 'sh':
      template = template.replace(/STAT/, 'sname');
      template = template.replace(/NAME/, '<span class="shout"><a class="shout" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
      break;
    default:
      template = template.replace(/STAT/, 'xname');
      template = template.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
  }

  link_url = '/'+j.server+'/ss/'+j.date.split(/ /)[0];
  date_field = '<a target="_brank" href="'+link_url+'">' + j.date + '</a>';
  template = template.replace(/DATE/, date_field);
  template = template.replace(/>BODY</, ">"+j.body+"<");

  $("#stream_table tbody").prepend(template);

  len = $("#stream_table tbody").children().length;
  if (len > $("#max_line").val()) {
    $("#stream_table tbody tr:last").hide().fadeOut(1000).remove();
  };
  $("#stream_table tbody tr:first").hide().fadeIn(1000);
  $("#stream_table tbody td div").slideDown("slow");

  $("#live_people").text(j.web_people + "人");

  var voice_status = $("#auto_voice").val();
  switch(voice_status) {
    case '1' :
      getAudioBuffer(j.store_audio, function(buffer){
        playSound(buffer, ($("#volume_voice").val() / 100));
      });
      break
    case '2' :
      speech_text = j.search_body;
      $.each(voice_dic, function(key, value){
        speech_text = speech_text.replace(key, value);
      });
      WebSpeechAPI(j.server + "鯖＿"+ speech_text, ($("#volume_voice").val() / 100));
      break
    default:
      break
  }
};

function show_json2(msg, template){
  var j = msg;

  switch(j.server) {
    case 's':
      template = template.replace(/SERVER/, '<span class="badge badge-danger">S</span>');
      break;
    case 'b':
      template = template.replace(/SERVER/, '<span class="badge badge-primary">B</span>');
      break;
    case 'v':
      template = template.replace(/SERVER/, '<span class="badge badge-warning">V</span>');
      break;
    case 'g':
      template = template.replace(/SERVER/, '<span class="badge badge-secondary">G</span>');
      break;
    default:
      template = template.replace(/SERVER/, '<span class="badge badge-default">'+j.server+'</span>');
  }

  uid_url = '/ss/'+j.id;

  switch(j.stat) {
    case 'wt':
      template = template.replace(/STAT/, 'wname');
      template = template.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
      break;
    case 'sh':
      template = template.replace(/STAT/, 'sname');
      template = template.replace(/NAME/, '<span class="shout"><a class="shout" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
      break;
    default:
      template = template.replace(/STAT/, 'xname');
      template = template.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + j.name + '</a></span>');
  }

  link_url = '/'+j.server+'/ss/'+j.date.split(/ /)[0];
  date_field = '<a target="_brank" href="'+link_url+'">' + j.date + '</a>';
  template = template.replace(/DATE/, date_field);
  template = template.replace(/>BODY</, ">"+j.body+"<");

  $("#stream_table tbody").append(template);
};

function show(msg){
  $("#stream_text").prepend(msg);
};

function close() {
  ws = null;
};

function push_setting() {
  if (window.Notification) {
    if (Notification.permission === 'granted') {
      alert('通知許可されています');
      testNotification();
    } else if (Notification.permission === 'denied') {
      alert('通知拒否されています');
    } else if (Notification.permission === 'default') {
      Notification.requestPermission(function(result) {
        if (result === 'granted') {
          alert('通知許可されました');
          testNotification();
        }
      })
    }
  } else {
    alert('通知は未対応です');
  }
};

function log_history() {
  url = '/api/v1/all_shout';
  if ($.cookie("papamira_font_size_check") == 'true') {
    $("#font_size").prop('checked', true)
  } else {
    $("#font_size").prop('checked', false)
  }

  $.ajax({
    url: url,
    type: "GET",
    timeout: 20000,
    success: function(data) {
      template  = '<tr><td><div>SERVER</div></td>';
      template += '<td><div class="text-nowrap fixed">DATE</div></td>';
      template += '<td class="STAT"><div class="text-nowrap fixed">NAME</div></td>';
      if($("#font_size").prop('checked')) {
        template += '<td><div>BODY</div></td></tr>';
      } else {
        template += '<td><div class="small">BODY</div></td></tr>';
      }

      $("#stream_table tbody tr").remove();

      $.each(data, function(index, value){
        show_json2(value, template);
      });

      if ($.cookie("papamira_table_size_check") == 'true') {
        $('#table_size').prop("checked", true);
        $("#stream_table").attr("class", "table")
      } else {
        $('#table_size').prop("checked", false);
        $("#stream_table").attr("class", "table table-sm")
      }
    },
      error: function() {
        $('#stream_text').text('');
    }
  });
};

function changeFavicon(url) {
  var canvas = document.createElement("canvas");
  canvas.height = 48;
  canvas.width  = 48;
  var img = new Image();
  img.onload = function() {
    var c = canvas.getContext('2d');
        c.drawImage(img,0,0);
    var f = canvas.toDataURL('image/png');         
    $('#favicon').remove();
    $('#favicon2').remove();
    $('#favicon3').remove();
    $('head').append(update_string_favicon(url));
  };
  img.src = url;
};

function update_string_favicon(text) {
  return '<link type="image/x-icon" id="favicon" rel="icon" href="'+ text +'">';
};

function tooltip_init() {
  $('[data-toggle="tooltip"]').tooltip();
};

function popover_init() {
  $('[data-toggle=popover]').popover();
};

function voice_dic_init() {
  $.ajax({
    url: "/api/v1/voice_dic",
    type: "GET",
    timeout: 20000,
    success: function(data) {
      voice_dic = data;
    },
      error: function() {
        voice_dic = [];
    }
  });
};

function volume_star() {
  switch($('#volume_voice').val()) {
    case '0':
      $('#volume_star1').removeClass("text-warning text-success")
      $('#volume_star1').addClass("text-danger");
      break;
    case '200':
      $('#volume_star1').removeClass("text-danger text-success")
      $('#volume_star1').addClass("text-warning");
      break;
    default:
      $('#volume_star1').removeClass("text-danger text-warning")
      $('#volume_star1').addClass("text-success");
      break;
  }

  if ($('#auto_voice').val() != "0") {
    $('#volume_star2').removeClass("text-black").addClass("text-info");
  } else {
    $('#volume_star2').removeClass("text-info").addClass("text-black");
  }
};

function copy_shout_data(){
  $('#shout').select();
  document.execCommand("copy");
  $('#modal-copy').modal('toggle')
}

function copy_regular_data(){
  $('#test_word').val($('#shout').val());
  $('#modal-copy').modal('toggle')
}

$('#stream_table tbody').on('click','td', function(){
  if($("#free_mode").prop('checked')) {
  } else {
    $('#shout').val($(this).text());
    $('#modal-copy').modal({
      keyboard: true,
      focus: false,
    });
  }
});

$('#push_word').focusin(function(e) {
  $(this).css('height', '128px');
})

$('#push_word').focusout(function(e) {
  $(this).css('height', '32');
});

$('#push_setting').click(push_setting);
$('#push_recall').click(open);

$('#push_word_clear').click(function() {
  $('#push_word').val('');
});

$('#push_word_save').click(function() {
  $.cookie("papamira_stream_key", $('#push_word').val(), {
    expires: 365,
    SameSite: 'Lax',
  });
});

$('#push_word_load').click(function() {
  $('#push_word').val($.cookie("papamira_stream_key"));
});

$("#auto_voice").change(function() {
  volume_star();
  voice_status = $('#auto_voice').val();
  switch(voice_status) {
    case '0':
      $.cookie("papamira_autovoice_check", 0,{
        expires: 365,
        SameSite: 'Lax',
      });
      voice_flg = false;
      voice_bufarr = [];
      break;
    case '1':
      $.cookie("papamira_autovoice_check", 1,{
        expires: 365,
        SameSite: 'Lax',
      });
      break;
    case '2':
      $.cookie("papamira_autovoice_check", 2,{
        expires: 365,
        SameSite: 'Lax',
      });
      voice_flg = false;
      voice_bufarr = [];
      break;
    default:
      $.cookie("papamira_autovoice_check", 0,{
        expires: 365,
        SameSite: 'Lax',
      });
      voice_flg = false;
      voice_bufarr = [];
      break;
  }
});

$("#max_line").change(function() {
  maxline_status = $('#max_line').val();
  $.cookie("papamira_stream_max_line", maxline_status,{
    expires: 365,
    SameSite: 'Lax',
  });
});

$("#free_mode").change(function() {
  switch($("#free_mode").prop('checked')) {
    case 'true':
      $.cookie("papamira_freemode_check", true,{
        expires: 365,
        SameSite: 'Lax',
      });
      break;
    case 'false':
      $.cookie("papamira_freemode_check", false,{
        expires: 365,
        SameSite: 'Lax',
      });
      break;
    default:
      break;
  }
});

$("#reg_server").change(function() {
  rserver_status = $('#reg_server').val();
  $.cookie("papamira_stream_reg_server", rserver_status,{
    expires: 365,
    SameSite: 'Lax',
  });
});

$("#table_size").change(function() {
  if($("#table_size").prop('checked')) {
    $("#stream_table").attr("class", "table")
    $.cookie("papamira_table_size_check", true,{
      expires: 365,
      SameSite: 'Lax',
    });
  } else {
    $("#stream_table").attr("class", "table table-sm")
    $.cookie("papamira_table_size_check", false,{
      expires: 365,
      SameSite: 'Lax',
    });
  };
});

$('#font_size').click(function() {
  if($("#font_size").prop('checked')) {
    $.cookie("papamira_font_size_check", true,{
      expires: 365,
      SameSite: 'Lax',
    });
  } else {
    $.cookie("papamira_font_size_check", false,{
      expires: 365,
      SameSite: 'Lax',
    });
  };
  log_history();
});

$("#stream_chat_text").keypress(function (e) { if (e.which === 13) {
    name = $('#stream_chat_name').val();
    text = $('#stream_chat_text').val();
    url = '/chat_send?chat_text=' + text + '&' + 'chat_name=' + name;
    $.get(url);
    setTimeout(function(){
      $('#stream_chat_text').val('');
    },100);
  } 
});

$("#live_chat").on('hidden.bs.collapse', function() {
  live_chat_on('stream');
});

$("#live_chat").on('shown.bs.collapse', function() {
  live_chat_off('stream');
});

$('#volume_voice').on('change', function(){
  volume_star();
  $.cookie("papamira_autovoice_volume", $('#volume_voice').val(),{
    expires: 365,
    SameSite: 'Lax',
  });
});

$('#file_voice').change(function() {
  file = this.files[0];
  voice_file = URL.createObjectURL(file);
  voice_file_path = file;
});

$('#keyword_preset_0').click(function(e) {
  $("#push_word").val("(?=.*(ギルド|攻城|ステG|GVG))^(?!.*(ギルドクエ|ギルドデイリ)).*$");
});

$('#keyword_preset_1').click(function(e) {
  $("#push_word").val("(?=.*(秘密))^(?!.*(BF|メインクエ|MQ)).*$");
});

$('#keyword_preset_2').click(function(e) {
  $("#push_word").val("(?=.*(かけら|欠片|カケラ))(?=.*(飛ばし|代行|出し))^(?!.*(黒き炎|魔界|試練|神秘)).*$");
});

$('#keyword_preset_3').click(function(e) {
  $("#push_word").val("(?=.*代行)^(?!.*(欠片|かけら|カケラ)).*$");
});

window.onload = function(){
  log_history();
  init();
  tooltip_init();
  popover_init();
  voice_dic_init();

  $('#push_word').val($.cookie("papamira_stream_key"));
  $('#reg_server').val($.cookie("papamira_stream_reg_server"));
  if ($.cookie("papamira_autovoice_volume")) {
    $('#volume_voice').val($.cookie("papamira_autovoice_volume"));
  }

  if($.cookie("papamira_freemode_check")) {
    switch($.cookie("papamira_freemode_check")) {
      case 'false':
        $("#free_mode").prop('checked', false)
        break
      case 'true':
        $("#free_mode").prop('checked', true)
        break
      default:
        $('#free_mode').val($.cookie("papamira_freemode_check"));
        break
    }
  } else {
    $("#free_mode").prop('checked', true)
  }

  if($.cookie("papamira_autovoice_check")) {
    switch($.cookie("papamira_autovoice_check")) {
      case 'false':
        $('#auto_voice').val(0);
        break
      case 'true':
        $('#auto_voice').val(1);
        break
      default:
        $('#auto_voice').val($.cookie("papamira_autovoice_check"));
        break
    }
  }

  if($.cookie("papamira_stream_max_line")) {
    $('#max_line').val($.cookie("papamira_stream_max_line"));
  }

  volume_star();
};

window.onfocus = function(){
  if (update_flg == true){
    titlenotifier.reset();
    changeFavicon('/favicon.ico');
    update_flg = false;
    update_star = 0;
  };
};

window.onblur = function(){
  update_flg = true
};
