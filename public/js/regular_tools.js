var test_redo = [$('#test_reg').val()]; 

function makeRegexp(aNum){
  start_str = toHalfWidth($("#reg_int_1").val());
  end_str = toHalfWidth($("#reg_int_2").val());
  start_value = Math.floor(Number(start_str));
  end_value = Math.floor(Number(end_str));

  if (start_str == '' || isNaN(start_value)) {
    start_str = '';
  } else {
    start_str = String(start_value);
  }

  if (end_str == '' || isNaN(end_value)) {
    end_str = '';
  } else {
    end_str = String(end_value);
  }

  $("#reg_int_1").val(start_str);
  $("#reg_int_2").val(end_str);

  if(aNum == '2'){
    $("#reg_compile").val(makeNumberRangeRegexp2(start_str, end_str));
  }else{
    $("#reg_compile").val(makeNumberRangeRegexp(start_str, end_str));
  }
}

function v2r_clear() {
  $("#reg_int_1").val("");
  $("#reg_int_2").val("");
  $("#reg_compile").val("");
}

function v2r_send_and() {
  $("#and_text").val($("#reg_compile").val());
}

function v2r_send_or() {
  $("#or_text").val($("#reg_compile").val());
}

function v2r_send_not() {
  $("#not_text").val($("#reg_compile").val());
}

function redo(e){
  var v, old = e.value;
  return function(){
    if(old != (v = e.value)){
      test_redo.push(old);
      old = v;
    }
  }
}

function keyword_and() {
  var renew = $("#test_reg").val();
  renew = $("#test_reg").val().replace(".*$", "")
  renew = renew.replace("^", "")

  ax = $("#and_text").val().split(',');
  $.each(ax, function(index, value){
    renew = renew + "(?=.*(" + value + "))";
  });
  renew = "^" + renew + ".*$"
  return renew
};

function keyword_or() {
  var renew = $("#test_reg").val();
  renew = $("#test_reg").val().replace(".*$", "")
  renew = renew.replace("^", "")

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
  renew = "^" + renew + "(?=.*(" + bx + "))" + ".*$";
  return renew
};

function keyword_not() {
  var renew = $("#test_reg").val();
  renew = $("#test_reg").val().replace(".*$", "")
  renew = renew.replace("^", "")

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
  renew = "^" + renew + "(?!.*(" + bx + "))" + ".*$";
  return renew
};

$('#run_reg').click(function() {
  word = $('#test_word').val();
  reg = RegExp($('#test_reg').val(), 'i');
  if (word != '') {
    if ($('#test_reg').val() != "") {
      if (reg.test(word) == true) {
        $('#test_res').html('<span class="text-primary">結果: <br>マッチしました!!</span>');
      } else {
        $('#test_res').html('<span class="text-danger">結果: <br>マッチしませんでした</span>');
      } 
    } else {
      $('#test_res').html('<span class="text-info">結果: <br>正規表現を入れてください</span>');
    }
  } else {
    $('#test_res').html('<span class="text-info">結果: <br>雄叫びを入れてください</span>');
  }
});

$('#run_copy').click(function(e) {
  $("#test_reg").select();
  document.execCommand("copy");
});

$('#run_update').click(function(e) {
  reg = $("#test_reg").val();
  $("#push_word").val(reg);
});

$('#run_add').click(function(e) {
  reg = $("#test_reg").val();
  $("#push_word").val(($("#push_word").val() + "\n" + reg));
});

$("#test_word").keypress(function (e) { if (e.which === 13) {
    $('#run_reg').click();
  } 
});

$("#test_reg").keypress(function (e) { if (e.which === 13) {
    $('#run_reg').click();
  } 
});

$("#and_text").keypress(function (e) { if (e.which === 13) {
    $('#keyword_preset_and').click();
  } 
});

$("#or_text").keypress(function (e) { if (e.which === 13) {
    $('#keyword_preset_or').click();
  } 
});

$("#not_text").keypress(function (e) { if (e.which === 13) {
    $('#keyword_preset_not').click();
  } 
});

$('#keyword_preset_redo').click(function(e) {
  $("#test_reg").val(test_redo.pop());
});

$('#keyword_preset_reset').click(function(e) {
  $("#test_reg").val("^.*$");
  test_redo.push($("#test_reg").val());
});

$('#keyword_preset_and').click(function(e) {
  test_redo.push($("#test_reg").val());
  $("#test_reg").val(keyword_and());
});

$('#keyword_preset_or').click(function(e) {
  test_redo.push($("#test_reg").val());
  $("#test_reg").val(keyword_or());
});

$('#keyword_preset_not').click(function(e) {
  test_redo.push($("#test_reg").val());
  $("#test_reg").val(keyword_not());
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
  test_redo.push($("#test_reg").val());
  $("#test_reg").val("");
});

$(function(){
  $('#test_reg').each(function(){
    $(this).bind('keyup', redo(this));
  });
});
