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
});
