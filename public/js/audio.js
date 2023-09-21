window.AudioContext = window.AudioContext || window.webkitAudioContext;  
var context = new AudioContext();
var voice_flg = false;
var voice_bufarr = [];

var getAudioBuffer = function(url, fn) {  
  var req = new XMLHttpRequest();
  req.responseType = 'arraybuffer';
  req.onreadystatechange = function() {
    if (req.readyState === 4) {
      if (req.status === 0 || req.status === 200) {
        context.decodeAudioData(req.response, function(buffer) {
          fn(buffer);
        });
      }
    }
  };
  req.open('GET', url, true);
  req.send('');
};

var playSound = function(buffer, volume) {
  if (voice_flg == false) {
    voice_flg = true;

    if (voice_bufarr.length != 0) {
      call_buffer = voice_bufarr[0];
      voice_bufarr.shift();
    } else {
      call_buffer = buffer;
    }

    var gain   = context.createGain();
    var source = context.createBufferSource();
    source.buffer = call_buffer;
    source.connect(gain);
    gain.connect(context.destination);
    gain.gain.value = volume;
    source.start(0);

    source.onended = function() {
      voice_flg = false;
      if (voice_bufarr.length != 0) {
        playSound(voice_bufarr[0], volume);
      }
    }
  } else {
    voice_bufarr.push(buffer);
  };
  return voice_flg;
};

function WebSpeechAPI(text, volume) {
  sp = new SpeechSynthesisUtterance();
  sp.text = text;
  sp.voiceURI = "Google 日本人 ja-JP";
  sp.lang = 'ja-JP';
  sp.rate = 1.0;
  sp.volume = volume;
  sp.rate = 1.0;
  sp.pitch = 1.0;
  speechSynthesis.speak(sp);
};
