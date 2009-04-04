// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  $('div.lcars').livequery(function() { $(this).lcars() });
  $('div.lcars a').livequery(function() { $(this).lcarsLink() });
  $('div.lcars form > button ').livequery(function() { $(this).lcarsFormButton() });
});
