iID = setInterval("init_load()", 1000 * $('#loadtime').val());

function stop_1(){
  clearInterval(iID);
}

function update_load(){
  $("#loading").html("Loading...");
}

function url_load(url) {
  $.ajax({
    url: url,
    type: "GET",
    timeout: 20000,
    success: function(data) {
      $("#stream_table tbody tr").remove();
      $('#loading').text('');
      render_tags2(data);
    },
      error: function() {
      $('#result').text('');
    }
  });
}

function init_load() {
  $.ajax({
    url: '/api/v1/history_shout?server=' + location.pathname.split('/')[1],
    type: "GET",
    timeout: 20000,
    success: function(data) {
      $("#stream_table tbody tr").remove();
      $('#loading').text('');
      render_tags2(data);
    },
      error: function() {
      $('#result').text('');
    }
  });
}

function init_autocomplete() {
  var autocomp_status = $("#auto_enable").val();
  $.cookie("papamira_autocomplete_check", autocomp_status,{
    expires: 365,
  });

  switch(autocomp_status) {
    case '0' :
      var data = []
      $('#word').autocomplete({
        source: data,
        autoFocus: true,
        delay: 500,
        minLength: 2
      });
      break;
    case '1' :
      $('#word').autocomplete({
        source: function( req, res ) {
          $.ajax({
            url: "/api/v1/autocomplete" + "?req=" + encodeURIComponent(req.term),
            dataType: "json",
            success: function( data ) {
            res(data);}
          });
        },
        autoFocus: false,
        delay: 0,
        minLength: 2
      });
      break;
    case '2' :
      $('#word').autocomplete({
        source: function( req, res ) {
          $.ajax({
            url: "/api/v1/user_search_word" + "?server=" + location.pathname.split('/')[1],
            dataType: "json",
            success: function( data ) {
            res(data);}
          });
        },
        autoFocus: false,
        delay: 0,
        minLength: 0
      });
      break;
    default:
      var data = []
      $('#word').autocomplete({
        source: data,
        autoFocus: true,
        delay: 500,
        minLength: 2
      });
      break;
  }
}

function init() {
  var ws = null;
  open();
}

function open() {
  var proto  = location.protocol === 'https:' ? 'wss' : 'ws'
  var ws     = new WebSocket(proto + '://' + window.location.host + window.location.pathname);

  ws.onopen  = function() {
  };

  ws.onclose = function() {
    ws = null;
    open();
  };

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
    }
  };
};

function tooltip_init() {
  $('[data-toggle="tooltip"]').tooltip();
};

function popover_init() {
  $('[data-toggle=popover]').popover();
};

function datepicker_init() {
  $('#datepicker').datepicker({
    showOtherMonths: true,
    selectOtherMonths: true
  });
};

function ppap_prop_disable(){
  $("#word").prop("disabled", true);
  $("#number").prop("disabled", true);
  $("#auto_enable").prop("disabled", true);
  $("#search").prop("disabled", true);
  $("#now").prop("disabled", true);
  $("#day").prop("disabled", true);
  $("#2day").prop("disabled", true);
  $("#3day").prop("disabled", true);
  $("#week").prop("disabled", true);
  $("#2week").prop("disabled", true);
  $('#stream').addClass('disabled');
  $('#calendar').addClass('disabled');
  $('#calendar_done').addClass('disabled');
}

function brank_load_prop(){
  $("#loading").html("");
  $("#word").prop("disabled", false);
  $("#number").prop("disabled", false);
  $("#auto_enable").prop("disabled", false);
  $("#search").prop("disabled", false);
  $("#now").prop("disabled", false);
  $("#day").prop("disabled", false);
  $("#2day").prop("disabled", false);
  $("#3day").prop("disabled", false);
  $("#week").prop("disabled", false);
  $("#2week").prop("disabled", false);
  $("#stream").removeClass('disabled');
  $("#calendar").removeClass('disabled');
  $('#calendar_done').removeClass('disabled');
}

function purge_word_text(){
  $('#word').val("");
}

function tags_table_clear(){
  update_load();
  stop_1();
  $("#stream_table tbody tr").hide().remove();
}

function run_search_tags(tag){
  return $.ajax({
    type: 'GET',
    url: '/api/v1/search_tags?tag='+ tag + '&s=' + location.pathname.split('/')[1],
    dataType: 'json',
  });
}

function render_tags(j){
  template = []
  $.each(j, function(index, key){
    tag_tmp = '<tr><td class="fixed">DATE</td><td class="STAT fixed">NAME</td><td>BODY</td></tr>'
    server = location.pathname.split('/')[1];

    uid_url = '/ss/'+key.id;
    link_url = '/'+key.server+'/ss/'+key.date.split(/ /)[0];

    switch(key.stat) {
      case 'wt':
        tag_tmp = tag_tmp.replace(/STAT/, 'wname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + key.name + '</a></span>');
        date_field = '<a target="_brank" href="'+link_url+'">' + key.date + '</a>';
        break;
      case 'sh':
        tag_tmp = tag_tmp.replace(/STAT/, 'sname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span class="shout"><a class="shout" target="_blank" href="' + uid_url +'">' + key.name + '</a></span>');
        date_field = '<a target="_brank" href="'+link_url+'">' + key.date + '</a>';
        break;
      case 'err':
        tag_tmp = tag_tmp.replace(/STAT/, 'xname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span>' + key.name + '</span>');
        date_field = 'key.date';
        break;
      default:
        tag_tmp = tag_tmp.replace(/STAT/, 'xname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span>' + key.name + '</span>');
        date_field = 'key.date';
    }
    
    tag_tmp = tag_tmp.replace(/DATE/, date_field);
    tag_tmp = tag_tmp.replace(/BODY/, key.body);
    template.push(tag_tmp);
  })

  $("#stream_table").prepend(template);
  $('#loading').text('');
}

function render_tags2(j){
  template = []
  $.each(j, function(index, key){
    tag_tmp = '<tr><td class="fixed">DATE</td><td class="STAT fixed">NAME</td><td>BODY</td></tr>'

    uid_url = '/ss/'+key.id;
    link_url = '/'+key.server+'/ss/'+key.date.split(/ /)[0];

    switch(key.stat) {
      case 'wt':
        tag_tmp = tag_tmp.replace(/STAT/, 'wname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span class="world"><a class="world" target="_blank" href="' + uid_url +'">' + key.name + '</a></span>');
        date_field = '<a target="_brank" href="'+link_url+'">' + key.date + '</a>';
        break;
      case 'sh':
        tag_tmp = tag_tmp.replace(/STAT/, 'sname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span class="shout"><a class="shout" target="_blank" href="' + uid_url +'">' + key.name + '</a></span>');
        date_field = '<a target="_brank" href="'+link_url+'">' + key.date + '</a>';
        break;
      case 'err':
        tag_tmp = tag_tmp.replace(/STAT/, 'xname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span>' + key.name + '</span>');
        date_field = key.date;
        break;
      default:
        tag_tmp = tag_tmp.replace(/STAT/, 'xname');
        tag_tmp = tag_tmp.replace(/NAME/, '<span>' + key.name + '</span>');
        date_field = key.date;
    }

    tag_tmp = tag_tmp.replace(/DATE/, date_field);
    tag_tmp = tag_tmp.replace(/BODY/, key.body);
    template.push(tag_tmp);
  })

  $("#stream_table").prepend(template);
  $('#loading').text('');
}

function run_datepicker(){
  url_load('/api/v1/select_day?server=' + location.pathname.split('/')[1] + "&day=" +  $('#datepicker').val());
}

$("#datepicker").keypress(function (e) { if (e.which === 13) {
  run_datepicker();
}});

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
  live_chat_on('ppap');
});

$("#live_chat").on('shown.bs.collapse', function() {
  live_chat_off('ppap');
});

$('#now').click(function() {
  update_load();
  stop_1();
  iID = setInterval("init_load()", 1000 * $('#loadtime').val());
  init_load();
});
$('#day').click(function() {
  update_load();
  stop_1();
  url_load("/api/v1/shout_days?server=" + location.pathname.split('/')[1] + "&limit=" + "1");
});
$('#2day').click(function() {
  update_load();
  stop_1();
  url_load("/api/v1/shout_days?server=" + location.pathname.split('/')[1] + "&limit=" + "2");
});
$('#3day').click(function() {
  update_load();
  stop_1();
  url_load("/api/v1/shout_days?server=" + location.pathname.split('/')[1] + "&limit=" + "3");
});
$('#week').click(function() {
  update_load();
  stop_1();
  url_load("/api/v1/shout_days?server=" + location.pathname.split('/')[1] + "&limit=" + "7");
});
$('#2week').click(function() {
  update_load();
  stop_1();
  url_load("/api/v1/shout_days?server=" + location.pathname.split('/')[1] + "&limit=" + "14");
});
$('#stream').click(function() {
  stop_1();
});
$('#calendar_done').click(function() {
  stop_1();
  run_datepicker();
});
$('#home').click(function() {
  stop_1();
});
$('#s').click(function() {
  stop_1();
});
$('#b').click(function() {
  stop_1();
});
$('#v').click(function() {
  stop_1();
});

$("#word").keypress(function (e) { if (e.which === 13) {
  $("#search").trigger("click");
  }
});

$('#search').click(function() {
  ppap_prop_disable();
  update_load();
  stop_1();
  $("#stream_table tbody tr").hide().remove();

  url = location.pathname.split('/')[1];
  switch(url) {
    case 's':
      server = 's';
      break;
    case 'b':
      server = 'b';
      break;
    case 'v':
      server = 'v';
      break;
    case 'g':
      server = 'g';
      break;
    default:
      server = '';
  }

  number = $("#number").val()

  $.ajax({
    type: 'GET',
    url: '/api/v2/search_shout?server='+server+'&number='+number+'&word='+encodeURIComponent($('#word').val()),
    dataType: 'json',
    success: function(j){
      document.charset='UTF-8';
      document.characterSet = 'UTF-8';

      template = []
      $.each(j, function(index, key){

        id_link_url = '/ss/'+key.id;
        ss_link_url = '/'+key.server+'/ss/'+key.date.split(/ /)[0];
        ss_field = '<a target="_brank" href="'+ss_link_url+'">' + key.date + '</a>';

        tag_tmp = '<tr><td class="fixed">'+ss_field+'</td><td class="STAT fixed">NAME</td><td>BODY</td></tr>'
        server = location.pathname.split('/')[1];

        switch(key.stat) {
          case 'wt':
            tag_tmp = tag_tmp.replace(/STAT/, 'wname');
            tag_tmp = tag_tmp.replace(/NAME/, '<a class="world" target="_brank" href="'+id_link_url+'">' + key.name + '</a>');
            break;
          case 'sh':
            tag_tmp = tag_tmp.replace(/STAT/, 'sname');
            tag_tmp = tag_tmp.replace(/NAME/, '<a class="shout" target="_brank" href="'+id_link_url+'">' + key.name + '</a>');
            break;
          case 'err':
            tag_tmp = tag_tmp.replace(/STAT/, '');
            tag_tmp = tag_tmp.replace(/NAME/, key.name);
            tag_tmp = '<tr><td class="fixed">'+key.date+'</td><td class="STAT fixed">NAME</td><td>BODY</td></tr>'
            break;
          default:
            tag_tmp = tag_tmp.replace(/STAT/, 'xname');
            tag_tmp = tag_tmp.replace(/NAME/, '<a class="world">' + key.name + '</a>');
            break;
        }
        tag_tmp = tag_tmp.replace(/DATE/, key.date);
        tag_tmp = tag_tmp.replace(/BODY/, key.body);
        template.push(tag_tmp);
      })
      $("#stream_table").prepend(template);
      brank_load_prop();
    }
  });
});

$("#auto_enable").change(function() {
  init_autocomplete();
});

$("#loadtime").change(function() {
  stop_1();
  iID = setInterval("init_load()", 1000 * $('#loadtime').val());
});

$("#ppap_tags").on('hidden.bs.collapse', function() {
  $.cookie("papamira_ppap_tags_check", false,{
    expires: 365,
  });
});

$("#ppap_tags").on('shown.bs.collapse', function() {
  $.cookie("papamira_ppap_tags_check", true,{
    expires: 365,
  });
});

$('#tag0').click(function(e) {
  tags_table_clear();
  run_search_tags('買').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag1').click(function(e) {
  tags_table_clear();
  run_search_tags('売').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag2').click(function(e) {
  tags_table_clear();
  run_search_tags('ギルド').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag3').click(function(e) {
  tags_table_clear();
  run_search_tags('PT').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag4').click(function(e) {
  tags_table_clear();
  run_search_tags('クエ').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag5').click(function(e) {
  tags_table_clear();
  run_search_tags('秘密').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag6').click(function(e) {
  tags_table_clear();
  run_search_tags('かけら').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag7').click(function(e) {
  tags_table_clear();
  run_search_tags('各種代行').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag8').click(function(e) {
  tags_table_clear();
  run_search_tags('鏡').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag9').click(function(e) {
  tags_table_clear();
  run_search_tags('GEM').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag10').click(function(e) {
  tags_table_clear();
  run_search_tags('ツボ').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag11').click(function(e) {
  tags_table_clear();
  run_search_tags('クレスト').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag12').click(function(e) {
  tags_table_clear();
  run_search_tags('インク').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag13').click(function(e) {
  tags_table_clear();
  run_search_tags('テイム').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

$('#tag14').click(function(e) {
  tags_table_clear();
  run_search_tags('その他').done(function(j) {
    render_tags(j);
  }).fail(function(result) {
    propt_enable();
  });
});

window.onload = function(){
  if ($.cookie("papamira_ppap_tags_check") == 'true') {
    $('#tags').click();
  }

  if ($.cookie("papamira_autocomplete_check")) {
    $('#auto_enable').val($.cookie("papamira_autocomplete_check"));
  }

  init();
  init_load();
  init_autocomplete();
  tooltip_init();
  popover_init();
  datepicker_init();
};
