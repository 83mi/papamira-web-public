click_func = false;

function prop_disable(){
  $("#home_server").prop("disabled", true);
  $("#home_word").prop("disabled", true);
  $("#home_number").prop("disabled", true);
  $("#home_search").prop("disabled", true);
  $("#home_clear").prop("disabled", true);
  $("#home_auto_complete").prop("disabled", true);
}

function prop_enable(){
  $("#home_server").prop("disabled", false);
  $("#home_word").prop("disabled", false);
  $("#home_number").prop("disabled", false);
  $("#home_search").prop("disabled", false);
  $("#home_clear").prop("disabled", false);
  $("#home_auto_complete").prop("disabled", false);
}

function init_cookie(){
  if ($.cookie("papamira_search_server_key") == null) {
    $('#home_server').val("s");
  } else {
    $('#home_server').val($.cookie("papamira_search_server_key"));
  }
  if ($.cookie("papamira_search_number_key") == null) {
    $('#home_number').val("100");
  } else {
    $('#home_number').val($.cookie("papamira_search_number_key"));
  }
  if ($.cookie("papamira_search_word_key") == null) {
    $('#home_word').val("");
  } else {
    $('#home_word').val($.cookie("papamira_search_word_key"));
  }
  if ($.cookie("papamira_search_autocomplete_check") == 'true') {
    $('#home_auto_complete').prop("checked", true);
  } else {
    $('#home_auto_complete').prop("checked", false);
  }
}

function read_autocomplete(){
  if($("#home_auto_complete").prop('checked')) {
    $.cookie("papamira_search_autocomplete_check", true,{
      expires: 365,
      path: '/',
    });
    $('#home_word').autocomplete({
      source: function( req, res ) {
        $.ajax({
          url: "/api/v1/autocomplete" + "?req=" + encodeURIComponent(req.term),
          dataType: "json",
          success: function( data ) {
          res(data);}
        });
      },
      autoFocus: true,
      delay: 500,
      minLength: 1
    });
  } else {
    $.cookie("papamira_search_autocomplete_check", false,{
      expires: 365,
      path: '/',
    });
    var data = []
    $('#home_word').autocomplete({
      source: data,
      autoFocus: true,
      delay: 500,
      minLength: 1
    });
  };
}

function user_autocomplete() {
  if($("#home_auto_complete").prop('checked')) {
    $.cookie("papamira_search_autocomplete_check", true,{
      expires: 365,
      path: '/',
    });

    switch($("#home_server").val()) {
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
      case 'all':
        server = 'all';
        break;
      default:
        server = '';
    }

    $('#home_word').autocomplete({
      source: function( req, res ) {
        $.ajax({
          url: "/api/v1/user_search_word" + "?server=" + server,
          dataType: "json",
          success: function( data ) {
            res(data);
          }
        });
      },
      autoFocus: false,
      delay: 0,
      minLength: 0
    });
  }
}

function purge_home_word_text(){
  $('#home_word').val("");
}

$("#home_server").change(function() {
  user_autocomplete();
});

$("#home_server").focusin(function() {
  user_autocomplete();
});

function run_search(){
  return $.ajax({
    type: 'GET',
    url: '/api/v2/search_shout?server='+server+'&number='+number+'&word='+encodeURIComponent($('#home_word').val()),
    dataType: 'json',
  });
}

function run_tags(){
  return $.ajax({
    type: 'GET',
    url: '/api/v1/tags',
    dataType: 'json',
  });
}

$('#home_clear').click(function(e) {
  if (click_func == false) {
    click_func = true;
    $("#home_table tbody tr").hide().remove();
    $("#home_word").val('');
    $('#search_progress.progress-bar').css('width', '0%');
    $('#search_progress_int').text('');
    $.cookie("papamira_search_word_key", '', {
      expires: 365,
      path: '/',
    });
    setTimeout(function(){click_func = false}, 1000);
  } else {
  };
});

$("#home_word").keypress(function (e) { if (e.which === 13) {
  $("#home_search").trigger("click");
  }
});

$('#home_search').click(function() {
  if (click_func == false) {
    click_func = true;
    $.cookie("papamira_search_server_key", $('#home_server').val(), {
      expires: 365,
      path: '/',
    });
    $.cookie("papamira_search_word_key", $('#home_word').val(), {
      expires: 365,
      path: '/',
    });
    $.cookie("papamira_search_number_key", $('#home_number').val(), {
      expires: 365,
      path: '/',
    });

    if ($("#home_word").val().length > 0) {

      prop_disable();

      $('#search_progress.progress-bar').css('width', '10%');
      $('#search_progress_int').text('10%');

      $("#home_table tbody tr").hide().remove();
      $('#search_progress.progress-bar').css('width', '20%');
      $('#search_progress_int').text('20%');

      switch($("#home_server").val()) {
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
        case 'all':
          server = 'all';
          break;
        default:
          server = '';
      }

      number = $("#home_number").val()

      run_search().done(function(j) {
        document.charset='UTF-8';
        document.characterSet = 'UTF-8';

        $('#search_progress.progress-bar').css('width', '30%');
        $('#search_progress_int').text('30%');

        template = []
        var len = j.length;
        for(var i=0; i < len; i++){
          tag_server = '<td>SERVER</td>'

          switch(j[i].server) {
            case 's':
              tag_server = tag_server.replace(/SERVER/, '<span class="badge badge-danger">S</span>');
              break;
            case 'b':
              tag_server = tag_server.replace(/SERVER/, '<span class="badge badge-primary">B</span>');
              break;
            case 'v':
              tag_server = tag_server.replace(/SERVER/, '<span class="badge badge-warning">V</span>');
              break;
            case 'g':
              tag_server = tag_server.replace(/SERVER/, '<span class="badge badge-secondary">G</span>');
              break;
            default:
              tag_server = tag_server.replace(/SERVER/, '<span class="badge badge-default">'+j.server+'</span>');
          }

          ss_link_url = '/'+j[i].server+'/ss/'+j[i].date.split(/ /)[0];
          ss_field = '<a target="_brank" href="'+ss_link_url+'">' + j[i].date + '</a>';
          
          id_link_url = '/ss/'+j[i].id;

          tag_tmp = 'class="STAT"'
          switch(j[i].stat) {
            case 'wt':
              tag_tmp = tag_tmp.replace(/STAT/, 'world');
              id_field = '<a ' +tag_tmp+ ' target="_brank" href="'+id_link_url+'">' + j[i].name + '</a>';
              break;
            case 'sh':
              tag_tmp = tag_tmp.replace(/STAT/, 'shout');
              id_field = '<a ' +tag_tmp+ ' target="_brank" href="'+id_link_url+'">' + j[i].name + '</a>';
              break;
            case 'err':
              tag_tmp = tag_tmp.replace(/STAT/, '');
              ss_field = j[i].date;
              id_field = j[i].name;
              break;
            default:
              tag_tmp = tag_tmp.replace(/STAT/, '');
              ss_field = j[i].date;
              id_field = j[i].name;
          }

          template.push('<tr>'+tag_server+'<td class="fixed">'+ss_field+'</td><td class="fixed">'+id_field+'</td><td><small>'+j[i].body+'</small></td></tr>');
        }

        $("#home_table tbody").append(template);

        $('#search_progress.progress-bar').css('width', '100%');
        $('#search_progress_int').text('100%');

        prop_enable();
      }).fail(function(result) {
        prop_enable();
      });
    }
    setTimeout(function(){click_func = false}, 1000);
  } else {
  };
});

$("#home_auto_complete").change(function() {
  user_autocomplete();
});

init_cookie();
user_autocomplete();
