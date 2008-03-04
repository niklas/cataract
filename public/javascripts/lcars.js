Remote.LinkWithBusy = Behavior.create({
    initialize : function(worker) {
       return new Remote.Link(this.element, {
           onCreate: function() { 
             $(worker).addClassName('busy');
           }, 
           onComplete: function() { 
             $(worker).removeClassName('busy');
           } 
       })

    }
});
