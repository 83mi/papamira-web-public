$(function() {
  $('#toc').toc({
    'selectors': 'h2, h3',
    'container': 'body',
    'smoothScrolling': true,
    'prefix': 'topic',
    'anchorName': function(i, heading, prefix) {
      return prefix+i;
    }
  });

  $('a').on('click',function(){
    setTimeout(function(){ scrollBy(0, -58); }, 100);
  });

  if (window.location.hash != "") {
  setTimeout(function(){
    hash_url = (window.location.pathname + window.location.hash);
    window.location.href = hash_url;
    scrollBy(0, -58);
    }, 500);
  }
});
