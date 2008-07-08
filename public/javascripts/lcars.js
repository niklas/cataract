Lcars = Behavior.create({
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
    if (!this.messageBox()) {
      this.element.appendChild(
        $div({class: 'inner modal'}, $div({class: 'message'}))
      );
    }
  },
  messageBox: function() {
    return this.element.getElementsBySelector('div.inner.modal > div.message').first();
  },
  setMessage: function(mess) {
    this.messageBox().update(mess);
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
    this.titles().each(function(title) {
        if (kind.match(/n/)) {
          title.addClassName('top');
          title.removeClassName('bottom');
        } else {
          title.addClassName('bottom');
          title.removeClassName('top');
        }
    });
  },
  alert : function(message) {
   if (title = this.titles().first())
     Element.update(title,message);
    this.element.addClassName("error");
  },
  unAlert : function() {
    this.element.removeClassName("error")
  },
  titles: function() {
    return $$('div#' + this.element.id + ' > span.title');
  }
});

Object.extend(Lcars.Box,{
  byId : function(id) {
    return Lcars.Box[id];
  }
});

Lcars.lastTarget = null;

Lcars.LinkTo = Behavior.create({
    initialize : function(target, options) {
      this.target = target;
      this.options =  Object.extend({
        target: this.target,
        message: 'Loading...',
        onCreate: function(oreq) {
          oreq.transport.lcars_target = this.target;
          box = Lcars.Box[target];
          box.setMessage(this.message);
          box.moreBusy();
          return false;
        },
        onComplete: function(oreq) { 
          target = oreq.transport.lcars_target;
          Lcars.Box[target].lessBusy();
          return false;
        },
        onFailure: function(oreq) {
          Lcars[target].alert("Failure");
        },
        onError: function(oreq) {
          Lcars[target].alert("Error");
        },
      }, options || {} );

      // do not apply to already ajaxified links (by rails)
      if (!this.element.href.match(/#$/)) {
        new Remote.Link(this.element, this.options);
      } else {
        e = this.element;
        e.original_onclick = e.onclick;
        e.onclick = function(ev) {
          var e = ev.element();
          target = e.className.match(/\blcars_target_(\w+)\b/)[1];
          if (target) {
            // FIXME Hack.. a fast-clicker could break this
            Lcars.lastTarget = target;
            if (box = Lcars.Box[target]) {
              box.setMessage(e.text + 'ing');
              box.moreBusy();
            }
          }
          e.original_onclick();
          return false;
        }
      }
    }
});

Ajax.Responders.register({
  onCreate : function(oreq,x) { 
    if (!oreq.lcars_target)
      oreq.lcars_target = Lcars.lastTarget;
  },
  onComplete : function(oreq) { 
    if (target = oreq.lcars_target)
      Lcars.Box[target].lessBusy();
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
