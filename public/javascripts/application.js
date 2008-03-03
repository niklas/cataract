// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Ajax.Responders.register({ 
 onCreate: function() { 
   if (Ajax.activeRequestCount > 0) {
     $$('div.loading').each( function(loading_div) {
       loading_div.show();
     })
   }
 }, 
 onComplete: function() { 
   if (Ajax.activeRequestCount == 0) {
     $$('div.loading').each( function(loading_div) {
       loading_div.hide();
     })
   }
 } 
});


var myrules = {
	'div.torrent a' : function(el) {
      if (el.href =~ /torrents\/\d+/) {
        el.onclick = function(){
          alert("foo");
        }
      }
	}
};

Behaviour.register(myrules);
