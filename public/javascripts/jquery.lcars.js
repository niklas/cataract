(function($){
  $.fn.lcars = function() {
    return this.each(function() {
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
    var me = this;
    if ( !this.hasClass('busy') ) {
      me.addClass('busy');
      this.find('div.inner.modal').fadeIn('slow');
    }
  };

  $.fn.lessBusy = function() {
    var count = (this.data('requestCount') || 0) - 1;
    if (count < 0)
      count = 0;
    this.data('requestCount', count);
    if (count == 0)  {
      var me = this;
      this.find('div.inner.modal').fadeOut('fast', function() {
        me.removeClass('busy')
      });
    }
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
  // finds the lcars element $(this) (a) links to
  $.fn.lcarsTarget = function() {
    var name = $(this).attr('target');
    if (name && (elem = Lcars.find(name)) ) {
      return elem;
    } else {
      return $(this).lcarsParent();
    }
  };

  $.fn.lcarsLink = function() {
    return this.each(function() {
      var elem = $(this);
      elem.click( function(ev) {
        ev.preventDefault();
        var parent = elem.lcarsTarget();
        parent.moreBusy('Loading...');
        $.ajax({
          type: 'GET',
          url: elem.attr('href'),
          dataType: "script", 
          complete: function(data, textStatus) {
            parent.lessBusy();
          }
        });
      });
    });
  };

  $.fn.lcarsFormButton = function() {
    return this.each(function() {
      var elem = $(this);
      elem.click( function(ev) {
        ev.preventDefault();
        var parent = elem.lcarsTarget();
        var form = elem.parents('form');
        var verb = form.find('input[type=hidden][name=_method]').val() || 'post';

        if ( verb.match(/delete/i) && !confirm("Really " + (elem.attr('title') || 'delete') + "?") ) {
          return false;
        }

        parent.moreBusy('Loading...');
        $.ajax({
          type: verb,
          url: form.attr('action'),
          data: form.serialize() + '&commit=' + elem.val(),
          dataType: "script", 
          complete: function(data, textStatus) {
            parent.lessBusy();
          }
        });
      });
    });
  };

  $.lcars = {};
  $.lcars.decoration = function(kind, variant, klass) {
    return '<img class="' + kind + ' ' + variant + ' ' + klass + ' decoration"' +
    ' src="lcars/decoration/' + kind + '/' + variant + '.png" />'
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


