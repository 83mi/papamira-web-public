$(function() {
  $('#toc').toc({
    'selectors': 'h2',
    'container': 'body',
    'smoothScrolling': true,
    'prefix': 'i'
  });

  $('a').on('click',function(){
    setTimeout(function(){ scrollBy(0, -58); }, 100);
  });
});
