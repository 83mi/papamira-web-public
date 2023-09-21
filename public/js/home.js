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
    setTimeout(open(), 500);
  };

  ws.onmessage = function(m) { 
    template = 'BODY';
    show_json(m.data, template);
  };
};

function show_json(msg, template){
  var j = $.parseJSON(msg);

  template  = '<tr><td>BODY</td></tr>';
  template  = template.replace(/BODY/, j.body);

  $("#stream_table tbody").prepend(template);
  $("#stream_table tbody tr:last").hide().fadeOut(2000).remove();
  $("#stream_table tbody tr:first").hide().fadeIn(2000);
};

function close() {
  ws = null;
};

window.onload = function(){
  init();
};
