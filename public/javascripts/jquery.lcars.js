(function($){
  $.fn.lcars = function() {
    return this.each(function() {
      switch( $(this).lcarsKind() ) {
        case 'nes':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['corner','se'],
            ['bow','se'],
            ['stump','w','nw'],
            ['stump','w','sw']
          ]);
          break;
        case 'nws':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','ne'],
            ['stump','e','se']
          ]);
          break;
        case 'ne':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['stump','w','nw'],
            ['stump','s','se']
          ]);
          break;
        case 'nw':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['stump','e','ne'],
            ['stump','s','sw']
          ]);
          break;
        case 'sen':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['corner','se'],
            ['bow','se'],
            ['stump','w','nw'],
            ['stump','w','sw']
          ]);
          break;
        case 'swn':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','ne'],
            ['stump','e','se']
          ]);
          break;
        case 'wse':
          $(this).setLcarsDecorations([
            ['corner','sw'],
            ['bow','sw'],
            ['corner','se'],
            ['bow','se'],
            ['stump','n','ne'],
            ['stump','n','nw']
          ]);
          break;
        case 'wne':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['corner','ne'],
            ['bow','nw'],
            ['bow','ne'],
            ['stump','s','sw'],
            ['stump','s','se']
          ]);
          break;
        case 'se':
          $(this).setLcarsDecorations([
            ['corner','se'],
            ['bow','se'],
            ['stump','w','sw'],
            ['stump','n','ne']
          ]);
          break;
        case 'sw':
          $(this).setLcarsDecorations([
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','se'],
            ['stump','n','nw']
          ]);
          break;
      }
      $(this).find('ul.buttons').removeClass('right').removeClass('left');

      var kind = $(this).lcarsKind();
      if ( kind.match(/w/) ) {
        $(this).find('ul.buttons:has(li)').addClass('left');
      } else {
        $(this).find('ul.buttons:has(li)').addClass('right');
      }

      if ( kind.match(/n/) ) {
        $(this).find(' > span.title').addClass('top').removeClass('bottom');
      } else {
        $(this).find(' > span.title').addClass('bottom').removeClass('top');
      }
    })
  };

  $.fn.setLcarsDecorations =  function(decs) {
    var old = $(this).find('img.decoration');
    var html = '';
    $(decs).each(function() {
      html = html + $.lcars.decoration(this[0],this[1],this[2])
    });
    $(html).appendTo(this);
    old.remove();
    return $(this);
  };

  $.fn.setLcarsMessage =  function(msg) {
    return this.each(function() {
      if ( $(this).find('div.inner.modal > div.message').length == 0 ) {
        $($.lcars.messageBox()).appendTo($(this));
      }
      $(this).find('div.inner.modal > div.message').html(msg);
    })
  };

  $.fn.moreBusy = function(message) {
    var count = (this.data('requestCount') || 0) + 1;
    this.data('requestCount', count);
    if (message)
      this.setLcarsMessage(message);
    return this.addClass('busy');
  };

  $.fn.lessBusy = function() {
    var count = (this.data('requestCount') || 0) - 1;
    if (count < 0)
      count = 0;
    this.data('requestCount', count);
    if (count == 0)
      return this.removeClass('busy')
    else
      return this
  };

  $.fn.alert = function(message) {
    if (message)
      this.find(' > span.title').text(message);
    return this.addClass('alert');
  };
  
  $.fn.unAlert = function(message) {
    return this.removeClass('alert');
  };


  $.fn.lcarsKind = function() {
    if (m = $(this).attr('class').match(/\b([nwse]{2,3})\b/)) {
      return m[1]
    } else {
      return '';
    }
  };

  // finds the lcars element $(this) belongs to
  $.fn.lcarsParent = function() {
    return $(this).parents('div.lcars:first')
  };

  $.fn.lcarsLink = function() {
    return this.each(function() {
      var elem = $(this);
      elem.click( function(ev) {
        ev.preventDefault();
        elem.lcarsParent().moreBusy('Loading...');
        $.getScript( elem.attr('href'), function(data, textStatus) {
          elem.lcarsParent().lessBusy();
        });
      });
    });
  };

  $.lcars = {};
  $.lcars.decoration = function(kind, variant, klass) {
    return '<img class="' + kind + ' ' + variant + ' ' + klass + ' decoration"' +
    ' src="/lcars/decoration/' + kind + '/' + variant + '.png" />'
  };
  $.lcars.messageBox = function() {
    return '<div class="inner modal"><div class="message" /></div>'
  };

}(jQuery));

var Lcars = {
  find: function(name, element) {
    if (element) {
      return $('div#'+ name +'.lcars .' + element)
    } else {
      return $('div#'+ name +'.lcars')
    }
  }
}


