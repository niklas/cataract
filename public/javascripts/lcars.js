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

/*
LcarsBox = Behavior.create({
  initialize: function() {
    this._addDecorations();
    this._addMessageBox();
  },
  _getKind: function() {
    this.element.classes.find(function(cl) { cl =~ /[nwse]{2,3}/ });
  },
  _addDecorations: function() {
    // TODO add all the other classes, too
    switch(this._getKind()) {
      case 'nes':
        this._addDecoration('corner','ne');
        this._addDecoration('bow','ne');
        break;
      case 'nws':
        this._addDecoration('corner','nw');
        this._addDecoration('bow','nw');
        break;
    };
  },
  _addDecoration: function(kind, variant, klass) {
    img = $img(
      class: [kind,variant,klass,'decoration'].join(' '),
      src: ('../lcars/decoration/' + kind + '/' + variant + '.png')
    );
    this.element.appendChild(img);
  },
  _addMessageBox: function() {
    this.messagebox = $div(class: 'message');
    this.element.appendChild(
      $div(class: 'inner modal', this.messagebox)
    );
  },
  _setMessage: function(message) {
    this.messagebox.update(message);
  },
  _decideMenuOrientation: function() {
    // ul.menu: set class to left if _getKind =~ /w/, right if /e/
  }
});
*/
Object.extend(Lcars,{
  byId : function(id) {
    return Lcars[id];
  }
});


Event.addBehavior({
    'div.lcars' : Lcars
});
