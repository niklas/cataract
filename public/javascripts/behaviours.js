Event.addBehavior({
    'div.torrent > a' : Remote.Link({
         onCreate: function() { 
           $('helm').addClassName('busy');
         }, 
         onComplete: function() { 
           $('helm').removeClassName('busy');
         } 
     })
});
