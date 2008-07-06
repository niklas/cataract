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


Lcars.Box = Behavior.create({
  initialize: function() {
    Lcars.Box[this.element.id] = this;
    this.requestCount = 0;
    this._addDecorations();
    this._addMessageBox();
    this._decideMenuOrientation();
    this._decideTitleOrientation();
  },
  _getKind: function() {
    return(this.element.className.match(/\b[nwse]{2,3}\b/).first());
  },
  _addDecorations: function() {
    var oldDecors = this.element.getElementsBySelector('img.decoration');
    if (oldDecors.length < 4) {
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
      oldDecors.each(function(img) {img.remove()});
    }
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
        buttons.removeClassName('right');
        buttons.removeClassName('left');
        if (buttons.childElements().length > 0) {
          if (kind.match(/w/)) {
            buttons.addClassName('left');
          } else {
            buttons.addClassName('right');
          }
        }
    });
  },
  moreBusy: function() {
    this.requestCount++;
    if (this.requestCount == 1)
      this.element.addClassName('busy');
  },
  lessBusy: function() {
    this.requestCount--;
    if (this.requestCount < 0)
      this.requestCount = 0;
    if (this.requestCount == 0)
      this.element.removeClassName('busy');
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

Object.extend(Lcars.Box,{
  byId : function(id) {
    return Lcars.Box[id];
  }
});

Lcars.LinkTo = Behavior.create(Remote.Link, {
    initialize : function($super, target, options) {
      this.target = target;
      this.options = Object.extend({
        target: target,
        onCreate: function(oreq) {
          oreq.transport.lcars_target = this.target;
          Lcars.Box[target].moreBusy();
          return true;
        },
        onComplete: function(oreq) { 
          target = oreq.transport.lcars_target;
          Lcars.Box[target].lessBusy();
          return true;
        },
        onFailure: function(oreq) {
          Lcars[target].alert("Failure");
        },
        onError: function(oreq) {
          Lcars[target].alert("Error");
        },
      }, options || {} );
      $super(this.options);
    }
});




Event.addBehavior({
    'div.lcars' : Lcars.Box
});

Element.addMethods({
    resetBehavior: function(element) {
      $(element).$$assigned = null;
    }
});
