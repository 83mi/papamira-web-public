function shout_init() {
  $.ajax({
    url: "/api/v1/random_shout",
    type: "GET",
    timeout: 20000,
    success: function(data) {
      $('#pico').attr('title', data);
    },
      error: function() {
    }
  });
};

function shout_init() {
  $.ajax({
    url: "/api/v1/ppap_shout",
    type: "GET",
    timeout: 20000,
    success: function(data) {
      $('#pico').attr('title', data);
    },
      error: function() {
    }
  });
};

$('#pico').hover(function() {
  shout_init();
});
