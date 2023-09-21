function live_chat_on(page) {
  switch(page) {
    case 'ppap':
      $('#stream_cell').removeClass("col-sm-9").addClass("col-sm-11");
      $('#live_cell').removeClass("col-sm-3").addClass("col-sm-1");
      $('#live_visible').text("Live");
      $('#live_visible').css('width', '58px');
      $('#loadtime').show();
      break
    case 'stream':
      $('#stream_cell').removeClass("col-sm-9").addClass("col-sm-11");
      $('#live_cell').removeClass("col-sm-3").addClass("col-sm-1");
      $('#live_visible').text("Live");
      $('#live_visible').css('width', '58px');
      $('#stream_help').show();
      $('#table_size').show();
      $('#font_size').show();
      $('#free_mode').show();
      $('#table_size_label').show();
      $('#font_size_label').show();
      $('#free_mode_label').show();
      break
    default:
      break
  }
  false
}

function live_chat_off(page) {
  switch(page) {
    case 'ppap':
      $('#stream_cell').removeClass("col-sm-11").addClass("col-sm-9");
      $('#live_cell').removeClass("col-sm-1").addClass("col-sm-3");
      $('#live_visible').text("Live Chat");
      $('#live_visible').css('width', '');
      $('#loadtime').hide();
      break
    case 'stream':
      $('#stream_cell').removeClass("col-sm-11").addClass("col-sm-9");
      $('#live_cell').removeClass("col-sm-1").addClass("col-sm-3");
      $('#live_visible').text("Live Chat");
      $('#live_visible').css('width', '');
      $('#stream_help').hide();
      $('#table_size').hide();
      $('#font_size').hide();
      $('#free_mode').hide();
      $('#table_size_label').hide();
      $('#font_size_label').hide();
      $('#free_mode_label').hide();
      break
    default:
      break
  }
  false
}
