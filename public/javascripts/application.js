// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  $('div.lcars').livequery(function() { $(this).lcars() });
  $('div.lcars a').livequery(function() { $(this).lcarsLink() });
  $('div.lcars form > button ').livequery(function() { $(this).lcarsFormButton() });
  $('div.lcars form input[type=submit]').livequery(function() { $(this).lcarsFormButton() });
  $('input#term').livequery(function() {
    var form = $('form#torrent_search');
    $(this).typeWatch({
      captureLength : null,
      callback: function() {
        $.ajax({
          type: 'GET',
          url: form.attr('action'),
          data: form.serialize(),
          dataType: "script",
        });
      }
    });
  });
  $('select#files_directory_id').livequery(function() {
    $(this).populateSubdirs();
  });
  if ( $('div#container .stats') ) {
    window.setInterval(function() {
      $.getScript('/statistic');
    }, 60000)
  }
});
