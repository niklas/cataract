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


LcarsBox = Behavior.create({
  initialize: function() {
    this._addDecorations();
    this._addMessageBox();
    this._decideMenuOrientation();
    this._decideTitleOrientation();
  },
  _getKind: function() {
    return(this.element.className.match(/\b[nwse]{2,3}\b/).first());
  },
  _addDecorations: function() {
    this.element.getElementsBySelector('img.decoration').each(function(img) {img.remove()});
    var kind = this._getKind();
    switch(kind) {
      case 'nes':
        this._addDecoration('corner','ne');
        this._addDecoration('bow','ne');
        this._addDecoration('corner','se');
        this._addDecoration('bow','se');
        this._addDecoration('stump','w','nw');
        this._addDecoration('stump','w','sw');
        break;
      case 'nws':
        this._addDecoration('corner','nw');
        this._addDecoration('bow','nw');
        this._addDecoration('corner','sw');
        this._addDecoration('bow','sw');
        this._addDecoration('stump','e','ne');
        this._addDecoration('stump','e','se');
        break;
      case 'ne':
        this._addDecoration('corner','ne');
        this._addDecoration('bow','ne');
        this._addDecoration('stump','w','nw');
        this._addDecoration('stump','s','se');
        break;
      case 'nw':
        this._addDecoration('corner','nw');
        this._addDecoration('bow','nw');
        this._addDecoration('stump','e','ne');
        this._addDecoration('stump','s','sw');
        break;
      case 'sen':
        this._addDecoration('corner','ne');
        this._addDecoration('bow','ne');
        this._addDecoration('corner','se');
        this._addDecoration('bow','se');
        this._addDecoration('stump','w','nw');
        this._addDecoration('stump','w','sw');
        break;
      case 'swn':
        this._addDecoration('corner','nw');
        this._addDecoration('bow','nw');
        this._addDecoration('corner','sw');
        this._addDecoration('bow','sw');
        this._addDecoration('stump','e','ne');
        this._addDecoration('stump','e','se');
        break;
      case 'se':
        this._addDecoration('corner','se');
        this._addDecoration('bow','se');
        this._addDecoration('stump','w','sw');
        this._addDecoration('stump','n','ne');
        break;
      case 'sw':
        this._addDecoration('corner','sw');
        this._addDecoration('bow','sw');
        this._addDecoration('stump','e','se');
        this._addDecoration('stump','n','nw');
        break;
    };
  },
  _addDecoration: function(kind, variant, klass) {
    img = $img({
      class: [kind,variant,klass,'decoration'].join(' '),
      src: ('/lcars/decoration/' + kind + '/' + variant + '.png')
    });
    this.element.appendChild(img);
  },
  _addMessageBox: function() {
    this.messagebox = $div({class: 'message'});
    this.element.appendChild(
      $div({class: 'inner modal'}, this.messagebox)
    );
  },
  _setMessage: function(message) {
    this.messagebox.update(message);
  },
  _decideMenuOrientation: function() {
    var kind = this._getKind();
    this.element.getElementsBySelector('ul.buttons').each(function(buttons) {
        if (kind.match(/w/)) {
          buttons.addClassName('left');
          buttons.removeClassName('right');
        } else {
          buttons.removeClassName('left');
          buttons.addClassName('right');
        }
    });
  },
  _decideTitleOrientation: function() {
    var kind = this._getKind();
    this.element.getElementsBySelector('span.title').each(function(title) {
        if (kind.match(/n/)) {
          title.addClassName('top');
          title.removeClassName('bottom');
        } else {
          title.addClassName('bottom');
          title.removeClassName('top');
        }
    });
  }
});

Object.extend(Lcars,{
  byId : function(id) {
    return Lcars[id];
  }
});


Event.addBehavior({
    'div.lcars' : LcarsBox
});
