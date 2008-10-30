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
        case 'wse':
          this._addDecoration('corner','sw');
          this._addDecoration('bow','sw');
          this._addDecoration('corner','se');
          this._addDecoration('bow','se');
          this._addDecoration('stump','n','ne');
          this._addDecoration('stump','n','nw');
          break;
        case 'wne':
          this._addDecoration('corner','nw');
          this._addDecoration('corner','ne');
          this._addDecoration('bow','nw');
          this._addDecoration('bow','ne');
          this._addDecoration('stump','s','sw');
          this._addDecoration('stump','s','se');
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
  moreBusy: function(message) {
    this.requestCount++;
    if (message)
      this.setMessage(message);
    if (this.requestCount >= 1)
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

Lcars.EndlessList = Behavior.create({
  initialize: function () {
    this.timer = null;
    this.current_page = 1;
    // this.ajax_path = url;
    this.interval = 1000; // 1 second
    this.scroll_offset = 0.6; // 60%
    //this.auth_token = auth_token;
    this.url = this.element.getAttribute('href');
    this.startListener();
  },
  scrollDistanceFromBottom: function() {
    p = this.element.parentNode;
    return(p.scrollHeight - p.scrollTop - p.clientHeight);
  },
  checkScroll: function() {
    dist = this.scrollDistanceFromBottom();
    if (dist < this.element.parentNode.clientHeight/5) {
      if (this.fetchNextPage()) this.startListener(this.interval*2);
    } 
    else {
      this.startListener();
    }
  },
  stopListener: function () {
    this.timer = null;
  },
  startListener: function (more_delay) {
    if (!this.endOfTransmission()) {
      this.timer = setTimeout(this.checkScroll.bind(this), more_delay ? this.interval + more_delay : this.interval);
    }
  },
  endOfTransmission: function () {
    return $A(this.element.getElementsBySelector('li.end')).last();
  },
  fetchNextPage: function () {
    if (last_id = this.lastEntry().id) {
      if (this.lastRequestedId == last_id) {
        return false;
      } else {
        __list = this;
        new Ajax.Request(this.url, { 
            parameters: { last: last_id }, 
            method: 'get',
            onSuccess: function() { __list.lastRequestedId = last_id; }
            });
        return true;
      }
    } else return false
  },
  lastEntry: function () {
    return $A(this.element.getElementsByTagName('li')).last();
  },
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
          target = e.lcarsTarget() || 'main';
          if (target) {
            // FIXME Hack.. a fast-clicker could break this
            Lcars.lastTarget = target;
            if (box = Lcars.Box[target]) {
              box.setMessage(e.text);
              box.moreBusy();
            }
          }
          if (!e.original_onclick()) {
            box.lessBusy();
          }
          return false;
        }
      }
    }
});

Lcars.SearchForm = Behavior.create({
    initialize : function(options) {
      this.label = this.element.getElementsBySelector('label').first();
      this.field = this.element.getElementsBySelector('input').first();
      this.field.hide();
      __form = this.element;
      this.observed = new Observed(this.field, function(field,value) { __form.request(); }, {frequency: 2});
    },
    onclick: function() {
      this.field.show();
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
    },
    lcarsParent: function(element) {
      return $(element).ancestors().find(function(e) { return e.hasClassName('lcars') })
    },
    lcarsTarget: function(element) {
      if (match = $(element).className.match(/\blcars_target_(\w+)\b/)) {
        return match[1];
      }
      else 
        if (parent = $(element).lcarsParent()) {
          return(parent.id);
        }
        else {
          return null;
        }
    }
});

