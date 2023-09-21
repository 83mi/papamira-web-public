var redo = [];
var voice_dic = {};

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

$('#run_voice').click(function() {
  word = $('#test_word').val();
  speech_text = word;
  $.each(voice_dic, function(key, value){
    speech_text = speech_text.replace(key, value);
  });
  speech_text = speech_text.replace(" |　", "＿");
  WebSpeechAPI(speech_text, 1.0);
});

$('#run_reg').click(function() {
  word = $('#test_word').val();
  reg = RegExp($('#test_reg').val());
  if (reg.test(word) == true) {
    $('#test_res').text("マッチしました");
  } else {
    $('#test_res').text("マッチしませんでした");
  } 
});

$("#test_word").keypress(function (e) { if (e.which === 13) {
    $('#run_voice').click();
    $('#run_reg').click();
  } 
});

$('#keyword_preset_redo').click(function(e) {
  $("#test_reg").val(redo.pop());
});

$('#keyword_preset_x').click(function(e) {
  redo.push($("#test_reg").val());
  ax = $("#and_text").val().split(',');
  $.each(ax, function(index, value){
    $("#test_reg").val($("#test_reg").val() + "(?=.*" + value + ")");
  });
});

$('#keyword_preset_y').click(function(e) {
  redo.push($("#test_reg").val());
  ax = $("#or_text").val().split(',');
  bx = ""
  $.each(ax, function(index, value){
    switch(index) {
      case 0 :
        bx = value;
        break;
      default:
        bx = bx + "|" + value;
        break;
    }
  });
  $("#test_reg").val($("#test_reg").val() + "(?=.*(" + bx + "))");
});

$('#keyword_preset_z').click(function(e) {
  redo.push($("#test_reg").val());
  ax = $("#not_text").val().split(',');
  bx = ""
  $.each(ax, function(index, value){
    switch(index) {
      case 0 :
        bx = value;
        break;
      default:
        bx = bx + "|" + value;
        break;
    }
  });
  $("#test_reg").val($("#test_reg").val() + "^(?!.*(" + bx + ")).*$");
});

$('#keyword_and_clear').click(function(e) {
  $("#and_text").val("");
});

$('#keyword_or_clear').click(function(e) {
  $("#or_text").val("");
});

$('#keyword_not_clear').click(function(e) {
  $("#not_text").val("");
});

$('#test_word_reset').click(function(e) {
  $("#test_word").val("");
});

$('#test_reg_reset').click(function(e) {
  $("#test_reg").val("");
});

window.onload = function() {
  $('#sort-drop-area').sortable({
    revert: true
  });

  $('#dragArea').find('a').draggable({
    connectToSortable: '#sort-drop-area',
    helper: 'move',
    //helper: 'clone',
    revert: 'invalid'
  });

  $('a').dblclick(function(e) {
    alert(e);
    //$(this).remove();
  });

  $('#dragArea').disableSelection();

};


//    $('.draggable').draggable( {
//
//        containment: '#draggableArea',
//        scroll: false,
//
//    });
//
//    $('.dragTarget').on('dragstart', function(e) {
//
//        // this は p.dragTarget のうち今ドラッグしてるもの
//        dragSrcEl = this;
//        console.log(this);
//
//    });
//
//    // ドラッグエリアに要素を追加，ドラッグエリアから要素をダブルクリックで削除
//    $('#draggableArea').on('dragover', function(e) {
//
//        e.preventDefault();
//
//    }).on('drop', function(e) {
//
//        if( !(e.isDefaultPrevented()) ) {
//            e.stopPropagation();
//        }
//
//        if(dragSrcEl != this) {
//            // this は div#draggableArea
//            $('#'+this.id).append("<div class='draggable'><p>"+dragSrcEl.innerText+"</p></div>");
//        }
//
//        $('.draggable').each(function() {
//            $(this).draggable( {
//                containment: '#draggableArea',
//                scroll: false,
//            });
//        });
//
//    }).on('dblclick', '.draggable', function(e) {
//        $(this).remove();
//    });


voice_dic_init();


