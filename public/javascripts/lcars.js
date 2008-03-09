// TODO
//  * count Requests Count of $worker
//  * only unbusy if == 0

Remote.LinkWithBusy = Behavior.create({
    initialize : function(worker) {
       return new Remote.Link(this.element, {
           onCreate: function() { 
             Lcars[worker].element.addClassName('busy');
           }, 
           onComplete: function() { 
             Lcars[worker].element.removeClassName('busy');
           },
           onFailure: function() {
             Lcars[worker].alert("Failure");
           },
           onError: function() {
             Lcars[worker].alert("Error");
           }
       })

    }
});


Lcars = Behavior.create({
  initialize : function() {
    this.id = this.element.id;
    Lcars[this.id] = this;
  },
  content : function() {
    return this.element.getElementsBySelector('div.inner > div.content').first();
  },
  right : function() {
    return this.element.getElementsBySelector('div.right').first();
  },
  alert : function(message) {
   var title = this.element.getElementsBySelector('span.title').first();
   if (title)
     Element.update(title,message);
    this.element.addClassName("error");
  },
  unAlert : function() {
    this.element.removeClassName("error")
  }
});

Object.extend(Lcars,{
  byId : function(id) {
    return Lcars[id];
  }
});


Event.addBehavior({
    'div.lcars' : Lcars
});
